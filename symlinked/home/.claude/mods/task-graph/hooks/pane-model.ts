import { atom, read, update } from 'claude-code'
import type { EngineInterface } from 'claude-code'

import type { Draft, DraftFields, Graph, Task } from '../types'
import { stopNow } from './native'
import { cancel, complete, emptyGraph, reopen, reorder, updateTask, workNext } from './store'
import type { Result } from './store'
import { PANE, mutate } from './state'

// What the pane shows and does, apart from how a surface draws it: the
// atoms, the handlers behind every control, and each task's details and
// actions. The terminal and desktop views both draw from here.

const graph = atom({ plugin: 'task-graph', key: 'graph' } as const, emptyGraph())
const selectedId = atom({ plugin: 'task-graph', key: 'selectedId' } as const, null)
const collapsed = atom({ plugin: 'task-graph', key: 'collapsed' } as const, [])
const newIds = atom({ plugin: 'task-graph', key: 'newIds' } as const, [])
const modalId = atom({ plugin: 'task-graph', key: 'modalId' } as const, null)
const expandedId = atom({ plugin: 'task-graph', key: 'expandedId' } as const, null)
const draft = atom({ plugin: 'task-graph', key: 'draft' } as const, null)
const turnId = atom({ plugin: 'task-graph', key: 'turnId' } as const, null)
const showCanceled = atom({ plugin: 'task-graph', key: 'showCanceled' } as const, false)

export type Elements = ReturnType<EngineInterface['ui']['resolve']>

export const statusColor: Record<Task['status'], string> = {
  pending: 'subtle',
  in_progress: 'claude',
  completed: 'success',
  canceled: 'inactive',
}

const fieldsOf = (task: Task): DraftFields => ({
  title: task.title,
  description: task.description,
  acceptance: task.acceptance,
})

const sameFields = (a: DraftFields, b: DraftFields): boolean =>
  a.title === b.title && a.description === b.description && a.acceptance === b.acceptance

export async function human($: EngineInterface, op: (value: Graph, now: number) => Result): Promise<void> {
  const now = await $.clock.now()
  const result = await mutate($, value => op(value, now))
  if (!result.ok) $.ui.toast(result.error)
}

/** A click on a row (or Enter on it) selects it and opens its drawer; a second click closes it. */
export async function toggleDrawer($: EngineInterface, id: string): Promise<void> {
  const wasOpen = (await read($, expandedId)) === id && (await read($, selectedId)) === id
  await update($, selectedId, () => id)
  await update($, expandedId, () => (wasOpen ? null : id))
}

export async function toggleFold($: EngineInterface, id: string): Promise<void> {
  await update($, collapsed, ids => (ids.includes(id) ? ids.filter(one => one !== id) : [...ids, id]))
}

export async function openModal($: EngineInterface, id: string): Promise<void> {
  const task = (await read($, graph)).tasks[id]
  if (task === undefined) return
  await update($, selectedId, () => id)
  // A draft for this task survives a close: reopening resumes it.
  await update($, draft, held =>
    held !== null && held.taskId === id ? held : { taskId: id, baseRevision: task.revision, fields: fieldsOf(task), conflict: null },
  )
  await update($, modalId, () => id)
  void $.ui.focus({ requestId: PANE, key: 'm-title' }).catch(() => undefined)
}

export async function closeModal($: EngineInterface): Promise<void> {
  const held = await read($, draft)
  const task = held === null ? undefined : (await read($, graph)).tasks[held.taskId]
  // An untouched draft is dropped; an edited one waits for the next open.
  if (held !== null && (task === undefined || (held.conflict === null && sameFields(held.fields, fieldsOf(task))))) {
    await update($, draft, () => null)
  }
  const id = await read($, modalId)
  await update($, modalId, () => null)
  if (id !== null) void $.ui.focus({ requestId: PANE, key: `row-${id}` }).catch(() => undefined)
}

export function editDraft($: EngineInterface, field: keyof DraftFields, value: string): Promise<Draft | null> {
  return update($, draft, held => (held === null ? held : { ...held, fields: { ...held.fields, [field]: value } }))
}

/**
 * Saves the draft against the revision it was opened at. When the task moved
 * meanwhile, the draft is kept and the conflict shown, never overwritten.
 */
export async function saveDraft($: EngineInterface, force = false): Promise<void> {
  const held = await read($, draft)
  if (held === null) return
  const task = (await read($, graph)).tasks[held.taskId]
  if (task === undefined) return
  if (!force && task.revision !== held.baseRevision && !sameFields(fieldsOf(task), held.fields)) {
    await update($, draft, () => ({ ...held, conflict: fieldsOf(task) }))

    return
  }
  const now = await $.clock.now()
  const result = await mutate($, value => updateTask(value, held.taskId, held.fields, 'human', now))
  if (!result.ok) {
    $.ui.toast(result.error)

    return
  }
  await update($, draft, () => ({ taskId: held.taskId, baseRevision: result.task.revision, fields: fieldsOf(result.task), conflict: null }))
  $.ui.toast(`Saved ${held.taskId}`)
}

export async function takeTheirs($: EngineInterface): Promise<void> {
  const held = await read($, draft)
  const task = held === null ? undefined : (await read($, graph)).tasks[held.taskId]
  if (held === null || task === undefined) return
  await update($, draft, () => ({ taskId: task.id, baseRevision: task.revision, fields: fieldsOf(task), conflict: null }))
}

/** The drawer's one-line summary: id, status, revision, author, blockers. */
export const metaOf = (task: Task): string =>
  [
    task.id,
    task.status.replace('_', ' '),
    `r${task.revision}`,
    `created by ${task.createdBy}`,
    task.blockedBy.length === 0 ? '' : `blocked by ${task.blockedBy.join(', ')}`,
  ]
    .filter(part => part !== '')
    .join(' · ')

export type TaskAction = {
  /** Keys the control as `act-<name>-<task id>`, on every surface. */
  name: string
  label: string
  run: () => unknown
  /** The one to press: the terminal draws it at full strength, a desktop as its primary button. */
  primary?: boolean
  /** Stops Claude: drawn loud on the terminal, as a primary button on a desktop. */
  urgent?: boolean
}

/** Every action the drawer offers on a task, in the order drawn. */
export function taskActions($: EngineInterface, task: Task, value: Graph, running: string | null): TaskAction[] {
  const isDone = task.status === 'completed' || task.status === 'canceled'

  return [
    { name: 'edit', label: 'Edit', run: () => openModal($, task.id), primary: true },
    ...(isDone
      ? [{ name: 'reopen', label: 'Reopen', run: () => human($, (g, now) => reopen(g, task.id, 'human', now)) }]
      : [
          { name: 'next', label: 'Work on next', run: () => human($, (g, now) => workNext(g, task.id, 'human', now)) },
          { name: 'done', label: 'Complete', run: () => human($, (g, now) => complete(g, task.id, 'human', now)) },
          { name: 'cancel', label: 'Cancel', run: () => human($, (g, now) => cancel(g, task.id, 'human', now)) },
        ]),
    { name: 'up', label: 'Up', run: () => human($, (g, now) => reorder(g, task.id, -1, 'human', now)) },
    { name: 'down', label: 'Down', run: () => human($, (g, now) => reorder(g, task.id, 1, 'human', now)) },
    ...(task.status === 'canceled' && value.claim?.taskId === task.id && running !== null
      ? [{ name: 'stop', label: 'Stop Claude now', run: () => stopNow($, task), urgent: true }]
      : []),
  ]
}
