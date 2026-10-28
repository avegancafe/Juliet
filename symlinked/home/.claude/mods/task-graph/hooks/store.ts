import type { Author, Change, Graph, Task, TaskStatus } from '../types'

// Pure operations on the graph. Every write goes through `commit`, which bumps
// the task's revision and the graph's, and records a change for Claude.

export type Result = { ok: true; graph: Graph; task: Task } | { ok: false; error: string }

export type Patch = Partial<Pick<Task, 'title' | 'description' | 'acceptance' | 'blockedBy' | 'parentId'>>

const MAX_CHANGES = 200

export const emptyGraph = (): Graph => ({
  tasks: {},
  rev: 0,
  nextId: 1,
  claim: null,
  nextUp: null,
  changes: [],
  claudeSeen: 0,
})

export const isOpen = (task: Task): boolean =>
  task.status === 'pending' || task.status === 'in_progress'

export const children = (graph: Graph, parentId: string | null): Task[] =>
  Object.values(graph.tasks)
    .filter(task => task.parentId === parentId)
    .sort((a, b) => a.order - b.order || a.createdAt - b.createdAt)

/** Depth-first in sibling order: the order the graph draws and the queue reads. */
export const walk = (graph: Graph): Task[] => {
  const out: Task[] = []
  const visit = (parentId: string | null) => {
    for (const task of children(graph, parentId)) {
      out.push(task)
      visit(task.id)
    }
  }
  visit(null)

  return out
}

const ancestors = (graph: Graph, task: Task): Task[] => {
  const out: Task[] = []
  let parent = task.parentId === null ? undefined : graph.tasks[task.parentId]
  while (parent !== undefined && out.length < 1000) {
    out.push(parent)
    parent = parent.parentId === null ? undefined : graph.tasks[parent.parentId]
  }

  return out
}

/**
 * What Claude may claim: pending, under no canceled ancestor, with no open
 * child (a parent is finished after its children) and every blocker done.
 * "Work on this next" goes first; the rest in graph order.
 */
export const eligible = (graph: Graph): Task[] => {
  const ready = walk(graph).filter(task => {
    if (task.status !== 'pending') return false
    if (ancestors(graph, task).some(up => up.status === 'canceled')) return false
    if (children(graph, task.id).some(isOpen)) return false

    return task.blockedBy.every(id => {
      const blocker = graph.tasks[id]

      return blocker === undefined || !isOpen(blocker)
    })
  })
  const first = ready.findIndex(task => task.id === graph.nextUp)
  if (first > 0) ready.unshift(...ready.splice(first, 1))

  return ready
}

const commit = (
  graph: Graph,
  task: Task,
  by: Author,
  summary: string,
  now: number,
): Graph => {
  const rev = graph.rev + 1
  const change: Change = { rev, taskId: task.id, by, summary }

  return {
    ...graph,
    rev,
    tasks: { ...graph.tasks, [task.id]: { ...task, updatedAt: now } },
    changes: [...graph.changes, change].slice(-MAX_CHANGES),
  }
}

const find = (graph: Graph, id: string): Task | undefined => graph.tasks[id]

const missing = (id: string): Result => ({ ok: false, error: `No task ${id}.` })

const stale = (task: Task, revision: number | undefined): Result | null =>
  revision !== undefined && revision !== task.revision
    ? {
        ok: false,
        error: `Task ${task.id} is at revision ${task.revision}, not ${revision}: it changed since you read it. Re-read it and reconcile.`,
      }
    : null

const createsCycle = (graph: Graph, id: string, blockedBy: string[]): boolean => {
  const seen = new Set<string>()
  const stack = [...blockedBy]
  while (stack.length > 0) {
    const next = stack.pop()!
    if (next === id) return true
    if (seen.has(next)) continue
    seen.add(next)
    stack.push(...(graph.tasks[next]?.blockedBy ?? []))
  }

  return false
}

const isUnder = (graph: Graph, id: string, parentId: string | null): boolean => {
  let at = parentId
  for (let i = 0; at !== null && i < 1000; i++) {
    if (at === id) return true
    at = graph.tasks[at]?.parentId ?? null
  }

  return false
}

export type NewTask = {
  title: string
  parentId?: string | null
  description?: string
  acceptance?: string
  blockedBy?: string[]
  createdBy: Author
}

export const addTask = (graph: Graph, input: NewTask, now: number): Result => {
  const parentId = input.parentId ?? null
  if (parentId !== null && find(graph, parentId) === undefined) return missing(parentId)
  if (input.title.trim() === '') return { ok: false, error: 'A task needs a title.' }
  const id = `t${graph.nextId}`
  const blockedBy = input.blockedBy ?? []
  const unknown = blockedBy.find(one => find(graph, one) === undefined)
  if (unknown !== undefined) return missing(unknown)
  const siblings = children(graph, parentId)
  const task: Task = {
    id,
    parentId,
    title: input.title.trim(),
    description: input.description ?? '',
    acceptance: input.acceptance ?? '',
    status: 'pending',
    order: (siblings.at(-1)?.order ?? 0) + 1,
    blockedBy,
    createdBy: input.createdBy,
    revision: 1,
    createdAt: now,
    updatedAt: now,
    notes: [],
  }
  const next = commit({ ...graph, nextId: graph.nextId + 1 }, task, input.createdBy, `added "${task.title}"`, now)

  return { ok: true, graph: next, task: next.tasks[id]! }
}

export const updateTask = (
  graph: Graph,
  id: string,
  patch: Patch,
  by: Author,
  now: number,
  revision?: number,
): Result => {
  const task = find(graph, id)
  if (task === undefined) return missing(id)
  const refused = stale(task, revision)
  if (refused !== null) return refused
  if (patch.blockedBy !== undefined) {
    const unknown = patch.blockedBy.find(one => find(graph, one) === undefined)
    if (unknown !== undefined) return missing(unknown)
    if (createsCycle(graph, id, patch.blockedBy)) {
      return { ok: false, error: `That dependency would make a cycle through ${id}.` }
    }
  }
  if (patch.parentId !== undefined && patch.parentId !== null) {
    if (find(graph, patch.parentId) === undefined) return missing(patch.parentId)
    if (isUnder(graph, id, patch.parentId)) {
      return { ok: false, error: `${id} cannot be moved under its own subtree.` }
    }
  }
  const fields = (Object.keys(patch) as (keyof Patch)[]).filter(
    key => JSON.stringify(patch[key]) !== JSON.stringify(task[key]),
  )
  if (fields.length === 0) return { ok: true, graph, task }
  const updated: Task = { ...task, ...patch, revision: task.revision + 1 }
  let next = commit(graph, updated, by, `edited ${fields.join(', ')} of "${updated.title}"`, now)
  // Claude's own edit of its claimed task is not a change it must reconcile.
  if (by === 'claude' && next.claim?.taskId === id && next.claim.observedRevision === task.revision) {
    next = { ...next, claim: { ...next.claim, observedRevision: updated.revision } }
  }

  return { ok: true, graph: next, task: next.tasks[id]! }
}

const setStatus = (
  graph: Graph,
  task: Task,
  status: TaskStatus,
  by: Author,
  summary: string,
  now: number,
): Graph => commit(graph, { ...task, status, revision: task.revision + 1 }, by, summary, now)

/** Claude takes a task: refused for a canceled, finished or stale one. */
export const claim = (graph: Graph, id: string, now: number, revision?: number): Result => {
  const task = find(graph, id)
  if (task === undefined) return missing(id)
  if (task.status === 'canceled') return { ok: false, error: `Task ${id} was canceled; it cannot be claimed.` }
  if (task.status === 'completed') return { ok: false, error: `Task ${id} is already completed.` }
  const refused = stale(task, revision)
  if (refused !== null) return refused
  let next = graph
  const held = graph.claim === null ? undefined : graph.tasks[graph.claim.taskId]
  if (held !== undefined && held.id !== id && held.status === 'in_progress') {
    next = setStatus(next, held, 'pending', 'claude', `released "${held.title}"`, now)
  }
  const current = next.tasks[id]!
  next = current.status === 'in_progress' ? next : setStatus(next, current, 'in_progress', 'claude', `claimed "${current.title}"`, now)
  const claimed = next.tasks[id]!
  next = {
    ...next,
    claim: { taskId: id, startedAt: now, observedRevision: claimed.revision },
    nextUp: next.nextUp === id ? null : next.nextUp,
  }

  return { ok: true, graph: next, task: claimed }
}

/**
 * Finishes a task. Claude's completion is checked against the revision it
 * claimed (or names): a human edit since then must be reconciled first.
 */
export const complete = (
  graph: Graph,
  id: string,
  by: Author,
  now: number,
  revision?: number,
): Result => {
  const task = find(graph, id)
  if (task === undefined) return missing(id)
  if (task.status === 'canceled') return { ok: false, error: `Task ${id} was canceled; it cannot be completed.` }
  if (task.status === 'completed') return { ok: true, graph, task }
  const expected =
    revision ?? (by === 'claude' && graph.claim?.taskId === id ? graph.claim.observedRevision : undefined)
  if (expected !== undefined && expected !== task.revision) {
    const since = graph.changes
      .filter(change => change.taskId === id && change.by === 'human')
      .slice(-5)
      .map(change => `- ${change.summary}`)
      .join('\n')

    return {
      ok: false,
      error:
        `Task ${id} changed since you claimed it (revision ${expected} → ${task.revision}). ` +
        `Re-read it, make sure the work meets the current description and acceptance criteria, ` +
        `then complete it with revision ${task.revision}.` +
        (since === '' ? '' : `\nHuman changes:\n${since}`),
    }
  }
  let next = setStatus(graph, task, 'completed', by, `completed "${task.title}"`, now)
  if (next.claim?.taskId === id) next = { ...next, claim: null }

  return { ok: true, graph: next, task: next.tasks[id]! }
}

export const cancel = (graph: Graph, id: string, by: Author, now: number): Result => {
  const task = find(graph, id)
  if (task === undefined) return missing(id)
  if (task.status === 'canceled') return { ok: true, graph, task }
  let next = setStatus(graph, task, 'canceled', by, `canceled "${task.title}"`, now)
  if (next.nextUp === id) next = { ...next, nextUp: null }

  return { ok: true, graph: next, task: next.tasks[id]! }
}

/** Puts a canceled or completed task back to pending. */
export const reopen = (graph: Graph, id: string, by: Author, now: number): Result => {
  const task = find(graph, id)
  if (task === undefined) return missing(id)
  if (isOpen(task)) return { ok: true, graph, task }
  const next = setStatus(graph, task, 'pending', by, `reopened "${task.title}"`, now)

  return { ok: true, graph: next, task: next.tasks[id]! }
}

export const progress = (graph: Graph, id: string, note: string, now: number): Result => {
  const task = find(graph, id)
  if (task === undefined) return missing(id)
  // A note is not a requirement change: no revision bump, so it never makes a claim stale.
  const updated = { ...task, notes: [...task.notes, note].slice(-20) }
  const next = { ...graph, rev: graph.rev, tasks: { ...graph.tasks, [id]: { ...updated, updatedAt: now } } }

  return { ok: true, graph: next, task: next.tasks[id]! }
}

/** Swaps a task with its previous (-1) or next (+1) sibling. */
export const reorder = (graph: Graph, id: string, delta: -1 | 1, by: Author, now: number): Result => {
  const task = find(graph, id)
  if (task === undefined) return missing(id)
  const siblings = children(graph, task.parentId)
  const at = siblings.findIndex(one => one.id === id)
  const other = siblings[at + delta]
  if (other === undefined) return { ok: true, graph, task }
  const swapped = commit(
    { ...graph, tasks: { ...graph.tasks, [other.id]: { ...other, order: task.order } } },
    { ...task, order: other.order },
    by,
    `moved "${task.title}" ${delta < 0 ? 'up' : 'down'}`,
    now,
  )

  return { ok: true, graph: swapped, task: swapped.tasks[id]! }
}

export const workNext = (graph: Graph, id: string, by: Author, now: number): Result => {
  const task = find(graph, id)
  if (task === undefined) return missing(id)
  if (!isOpen(task)) return { ok: false, error: `Task ${id} is ${task.status}.` }
  const next = commit({ ...graph, nextUp: id }, task, by, `asked for "${task.title}" to be worked on next`, now)

  return { ok: true, graph: next, task: next.tasks[id]! }
}

/** The human changes Claude has not yet been shown. */
export const unseen = (graph: Graph): Change[] =>
  graph.changes.filter(change => change.rev > graph.claudeSeen && change.by === 'human')

export const markSeen = (graph: Graph): Graph =>
  graph.claudeSeen === graph.rev ? graph : { ...graph, claudeSeen: graph.rev }

const line = (task: Task, graph: Graph): string => {
  const head = graph.claim?.taskId === task.id ? ' ← HEAD' : ''
  const parent = task.parentId === null ? '' : ` (under ${task.parentId})`
  const blocked = task.blockedBy.length === 0 ? '' : ` blocked by ${task.blockedBy.join(', ')}`

  return `${task.id} [${task.status}] r${task.revision} ${task.title}${parent}${blocked}${head}`
}

/** A compact text view of the graph for the model. */
export const describe = (graph: Graph): string => {
  const all = walk(graph)
  if (all.length === 0) return 'The task graph is empty.'
  const queue = eligible(graph).map(task => task.id)

  return [
    ...all.map(task => line(task, graph)),
    `Eligible next, in order: ${queue.length === 0 ? 'none' : queue.join(', ')}`,
  ].join('\n')
}

export const describeTask = (task: Task, graph: Graph): string =>
  [
    line(task, graph),
    task.description === '' ? '' : `Description: ${task.description}`,
    task.acceptance === '' ? '' : `Acceptance criteria: ${task.acceptance}`,
    task.notes.length === 0 ? '' : `Progress notes:\n${task.notes.map(note => `- ${note}`).join('\n')}`,
    `Created by ${task.createdBy}.`,
  ]
    .filter(part => part !== '')
    .join('\n')

export const summarizeChanges = (changes: Change[]): string =>
  changes.map(change => `- ${change.taskId}: ${change.by} ${change.summary}`).join('\n')
