import { atom, read, update } from 'claude-code'
import type { EngineInterface, On } from 'claude-code'

import type { Graph, Task } from '../types'
import { addTask, cancel, claim, complete, describe, emptyGraph, summarizeChanges, unseen, updateTask, walk } from './store'
import type { Result } from './store'
import { highlight, mutate, seen } from './state'

const graph = atom({ plugin: 'task-graph', key: 'graph' } as const, emptyGraph())
const turnId = atom({ plugin: 'task-graph', key: 'turnId' } as const, null)

// Claude Code's own task tools answered from the graph, so there is one store:
// TaskCreate/TaskUpdate/TaskList/TaskGet and TodoWrite never reach the engine's
// list. The desktop app's plan list keeps working and is mirrored in.

type NativeStatus = 'pending' | 'in_progress' | 'completed'

const nativeStatus = (task: Task): NativeStatus => (task.status === 'canceled' ? 'completed' : task.status)

const nativeSubject = (task: Task): string => (task.status === 'canceled' ? `[canceled] ${task.title}` : task.title)

const blocks = (value: Graph, id: string): string[] =>
  Object.values(value.tasks)
    .filter(task => task.blockedBy.includes(id))
    .map(task => task.id)

const byTitle = (value: Graph, title: string): Task | undefined =>
  walk(value).find(task => task.title === title.trim())

/** Moves a task to the status the model asked for, through the same checks as tg_*. */
const toStatus = (value: Graph, id: string, status: string, now: number): Result => {
  const task = value.tasks[id]
  if (task === undefined) return { ok: false, error: `No task ${id}.` }
  if (status === 'in_progress') return claim(value, id, now)
  if (status === 'completed') return complete(value, id, 'claude', now)
  if (status === 'deleted') return cancel(value, id, 'claude', now)

  return { ok: true, graph: value, task }
}

// Human changes Claude has not been shown yet, told with a native tool's result
// before the call marks them seen.
const changesNote = (value: Graph): string[] => {
  const changes = unseen(value)

  return changes.length === 0
    ? []
    : [`The human changed the shared task graph:\n${summarizeChanges(changes)}\nCanceled tasks must not be worked on; re-read any task of yours that changed.`]
}

const withNote = (note: string[]) => (note.length === 0 ? {} : { context: note })

const NATIVE = ['TaskCreate', 'TaskUpdate', 'TaskList', 'TaskGet', 'TodoWrite']

export const translateNative = (on: On): void => {
  on('tool.call', { tool: 'TaskCreate' }, async ($, e) => {
    const note = changesNote(await read($, graph))
    const now = await $.clock.now()
    const metadata = (e.metadata ?? {}) as Record<string, unknown>
    const parentId = typeof metadata.parentId === 'string' ? metadata.parentId : null
    const result = await mutate(
      $,
      value => addTask(value, { title: e.subject, description: e.description, parentId, createdBy: 'claude' }, now),
      { seenByClaude: true },
    )
    if (!result.ok) return { deny: result.error }
    await highlight($, result.task.id)

    return { result: { task: { id: result.task.id, subject: result.task.title } }, ...withNote(note) }
  })

  on('tool.call', { tool: 'TaskGet' }, async ($, e) => {
    const value = await read($, graph)
    const task = value.tasks[e.taskId]
    if (task === undefined) return { result: { task: null } }
    const extra = [
      task.acceptance === '' ? '' : `Acceptance criteria: ${task.acceptance}`,
      `Revision ${task.revision}, created by ${task.createdBy}.`,
    ].filter(part => part !== '')

    return {
      result: {
        task: {
          id: task.id,
          subject: nativeSubject(task),
          description: [task.description, ...extra].filter(part => part !== '').join('\n\n'),
          status: nativeStatus(task),
          blocks: blocks(value, task.id),
          blockedBy: task.blockedBy,
        },
      },
    }
  })

  on('tool.call', { tool: 'TaskList' }, async $ => {
    const note = changesNote(await read($, graph))
    await seen($)
    const value = await read($, graph)

    return {
      result: {
        tasks: walk(value)
          .filter(task => task.status !== 'canceled')
          .map(task => ({ id: task.id, subject: task.title, status: nativeStatus(task), blockedBy: task.blockedBy })),
      },
      ...withNote(note),
    }
  })

  on('tool.call', { tool: 'TaskUpdate' }, async ($, e) => {
    const now = await $.clock.now()
    const note = changesNote(await read($, graph))
    const before = (await read($, graph)).tasks[e.taskId]
    const patch = {
      ...(e.subject === undefined ? {} : { title: e.subject }),
      ...(e.description === undefined ? {} : { description: e.description }),
      ...(e.addBlockedBy === undefined ? {} : { blockedBy: [...new Set([...(before?.blockedBy ?? []), ...e.addBlockedBy])] }),
    }
    const result = await mutate(
      $,
      value => {
        const edited = Object.keys(patch).length === 0 ? null : updateTask(value, e.taskId, patch, 'claude', now)
        if (edited !== null && !edited.ok) return edited
        let next = edited === null ? value : edited.graph
        for (const other of e.addBlocks ?? []) {
          const blocked = next.tasks[other]
          if (blocked === undefined) continue
          const added = updateTask(next, other, { blockedBy: [...new Set([...blocked.blockedBy, e.taskId])] }, 'claude', now)
          if (!added.ok) return added
          next = added.graph
        }

        return e.status === undefined ? { ok: true, graph: next, task: next.tasks[e.taskId]! } : toStatus(next, e.taskId, e.status, now)
      },
      { seenByClaude: true },
    )
    if (!result.ok) return { deny: `${result.error}\n\n${describe(await read($, graph))}` }
    const fields = [...Object.keys(patch), ...(e.addBlocks === undefined ? [] : ['blocks']), ...(e.status === undefined ? [] : ['status'])]

    return {
      result: {
        success: true,
        taskId: e.taskId,
        updatedFields: fields,
        ...(before === undefined || e.status === undefined || before.status === result.task.status
          ? {}
          : { statusChange: { from: before.status, to: result.task.status } }),
      },
      ...withNote(note),
    }
  })

  // TodoWrite carries the whole list: each todo is matched to a task by title.
  on('tool.call', { tool: 'TodoWrite' }, async ($, e) => {
    const now = await $.clock.now()
    const old = await read($, graph)
    const note = changesNote(old)
    const refused: string[] = []
    const result = await mutate(
      $,
      value => {
        let next = value
        refused.length = 0
        for (const todo of e.todos) {
          let task = byTitle(next, todo.content)
          if (task === undefined) {
            const added = addTask(next, { title: todo.content, createdBy: 'claude' }, now)
            if (!added.ok) continue
            next = added.graph
            task = added.task
          }
          if (task.status === todo.status) continue
          const moved = toStatus(next, task.id, todo.status, now)
          if (moved.ok) next = moved.graph
          else refused.push(moved.error)
        }

        return { ok: true, graph: next, task: Object.values(next.tasks)[0]! }
      },
      { seenByClaude: true },
    )
    const asTodo = (value: Graph) =>
      walk(value)
        .filter(task => task.status !== 'canceled')
        .map(task => ({ content: task.title, status: nativeStatus(task), activeForm: task.title }))

    return {
      result: { oldTodos: asTodo(old), newTodos: asTodo(result.ok ? result.graph : old) },
      ...withNote([
        ...note,
        ...(refused.length === 0 ? [] : [`Some todo changes were refused by the shared task graph:\n${refused.join('\n')}`]),
      ]),
    }
  })

  // The desktop app's plan list: mirrored in one way, its own list left working.
  on('tool.call', { tool: 'mcp__ccd_turn__update_plan' }, async ($, e, next) => {
    const items = (e as Record<string, unknown>).items
    if (Array.isArray(items)) {
      const now = await $.clock.now()
      await mutate($, value => {
        let graphNow = value
        for (const item of items as { content?: unknown; status?: unknown }[]) {
          if (typeof item.content !== 'string') continue
          let task = byTitle(graphNow, item.content)
          if (task === undefined) {
            const added = addTask(graphNow, { title: item.content, createdBy: 'claude' }, now)
            if (!added.ok) continue
            graphNow = added.graph
            task = added.task
          }
          if (typeof item.status === 'string' && item.status !== task.status) {
            const moved = toStatus(graphNow, task.id, item.status, now)
            if (moved.ok) graphNow = moved.graph
          }
        }

        return { ok: true, graph: graphNow, task: Object.values(graphNow.tasks)[0]! }
      })
    }

    return next(e)
  })
}

const PROTOCOL = [
  'A shared task graph is open beside this conversation. The human edits it too, and it is the authoritative plan.',
  '- Use the mcp__task-graph__tg_* tools (or TaskCreate/TaskUpdate/TaskList, which write to the same graph).',
  '- Before choosing new work, call tg_next: the human may have canceled, edited or reordered tasks. Never work on a canceled task.',
  '- Claim a task (tg_claim) before working on it, add subtasks as you discover them (tg_add with parentId), and complete with tg_complete.',
  '- When a task changed while you worked on it, re-read it and meet its current acceptance criteria before completing it.',
].join('\n')

/** Keeps Claude current with the graph at every boundary it has. */
export const keepFresh = (on: On): void => {
  on('prompt.compose', async ($, e, next) => {
    const composed = await next(e)

    return { ...composed, sections: [...composed.sections, { id: 'task-graph', text: PROTOCOL, scope: 'session' as const }] }
  })

  on('prompt.submit', async ($, e, next) => {
    if (e.command !== undefined) return next(e)
    const value = await read($, graph)
    if (Object.keys(value.tasks).length === 0) return next(e)
    const changes = unseen(value)
    const note = [
      'Shared task graph (authoritative; the human edits it too):',
      describe(value),
      changes.length === 0 ? '' : `\nChanged by the human since you last looked:\n${summarizeChanges(changes)}`,
    ].join('\n')
    await seen($)

    return next({ ...e, context: [...(e.context ?? []), note] })
  })

  // Between tool calls is the boundary a running turn has: a human change is
  // read with the next tool result, whatever the tool.
  on('tool.call', async ($, e, next) => {
    const ran = await next(e)
    if (e.agentId !== undefined || 'deny' in ran) return ran
    if (String(e.tool).startsWith('mcp__task-graph__') || NATIVE.includes(String(e.tool))) return ran
    const changes = unseen(await read($, graph))
    if (changes.length === 0) return ran
    await seen($)
    const note = `The human changed the shared task graph:\n${summarizeChanges(changes)}\nCall tg_next before picking new work; if your current task changed, re-read it with tg_get.`

    return { ...ran, context: [...(ran.context ?? []), note] }
  })

  on('turn.start', async ($, e, next) => {
    if (e.agentId === undefined) await update($, turnId, () => e.turnId)

    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    if (e.agentId === undefined) await update($, turnId, () => null)

    return next(e)
  })
}

/** Stops Claude's running turn now and asks it to report, after the human canceled its task. */
export async function stopNow($: EngineInterface, task: Task): Promise<void> {
  const running = await read($, turnId)
  if (running !== null) {
    try {
      await $.turn.abort({ turnId: running })
    } catch {
      // The turn ended on its own meanwhile.
    }
  }
  await $.prompt.submit({
    text: `I canceled task ${task.id} ("${task.title}") in the task graph and stopped your turn. Report what was already done for it, leave it canceled, and call tg_next before continuing.`,
  })
}
