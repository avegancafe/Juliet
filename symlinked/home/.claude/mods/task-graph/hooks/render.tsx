import { atom, read, update } from 'claude-code'
import type { EngineInterface, On } from 'claude-code'

import type { Draft, DraftFields, Graph, Task } from '../types'
import { layout, step } from './layout'
import type { Row } from './layout'
import { stopNow } from './native'
import { cancel, complete, emptyGraph, reopen, reorder, updateTask, workNext } from './store'
import type { Result } from './store'
import { PANE, mutate } from './state'

const graph = atom({ plugin: 'task-graph', key: 'graph' } as const, emptyGraph())
const selectedId = atom({ plugin: 'task-graph', key: 'selectedId' } as const, null)
const collapsed = atom({ plugin: 'task-graph', key: 'collapsed' } as const, [])
const newIds = atom({ plugin: 'task-graph', key: 'newIds' } as const, [])
const modalId = atom({ plugin: 'task-graph', key: 'modalId' } as const, null)
const expandedId = atom({ plugin: 'task-graph', key: 'expandedId' } as const, null)
const draft = atom({ plugin: 'task-graph', key: 'draft' } as const, null)
const turnId = atom({ plugin: 'task-graph', key: 'turnId' } as const, null)

// The pane: a git-log-style graph of rows, a row of single-key controls, and a
// task modal drawn over the graph (never instead of it), its draft kept in
// state so live updates and Escape never lose an edit.

const fieldsOf = (task: Task): DraftFields => ({
  title: task.title,
  description: task.description,
  acceptance: task.acceptance,
})

const sameFields = (a: DraftFields, b: DraftFields): boolean =>
  a.title === b.title && a.description === b.description && a.acceptance === b.acceptance

async function human($: EngineInterface, op: (value: Graph, now: number) => Result): Promise<void> {
  const now = await $.clock.now()
  const result = await mutate($, value => op(value, now))
  if (!result.ok) $.ui.toast(result.error)
}

function scrollTo($: EngineInterface, id: string | null): void {
  if (id !== null) void $.ui.scroll({ to: { key: `row-${id}` }, in: PANE }).catch(() => undefined)
}

async function move($: EngineInterface, delta: number): Promise<void> {
  const rows = layout(await read($, graph), await read($, collapsed))
  const to = step(rows, await read($, selectedId), delta)
  await update($, selectedId, () => to)
  // An open drawer follows the selection, so j/k walks the details too.
  await update($, expandedId, open => (open === null ? null : to))
  scrollTo($, to)
}

/** A click on a row (or Enter on it) selects it and opens its drawer; a second click closes it. */
async function toggleDrawer($: EngineInterface, id: string): Promise<void> {
  const wasOpen = (await read($, expandedId)) === id && (await read($, selectedId)) === id
  await update($, selectedId, () => id)
  await update($, expandedId, () => (wasOpen ? null : id))
}

async function toggleFold($: EngineInterface, id: string): Promise<void> {
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

async function closeModal($: EngineInterface): Promise<void> {
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

function editDraft($: EngineInterface, field: keyof DraftFields, value: string): Promise<Draft | null> {
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

async function takeTheirs($: EngineInterface): Promise<void> {
  const held = await read($, draft)
  const task = held === null ? undefined : (await read($, graph)).tasks[held.taskId]
  if (held === null || task === undefined) return
  await update($, draft, () => ({ taskId: task.id, baseRevision: task.revision, fields: fieldsOf(task), conflict: null }))
}

type Elements = ReturnType<EngineInterface['ui']['resolve']>

const statusColor: Record<Task['status'], string> = {
  pending: 'subtle',
  in_progress: 'claude',
  completed: 'success',
  canceled: 'inactive',
}

// Every glyph, rail and title is drawn `mono`: the terminal always is, and a
// desktop or IDE surface otherwise sets the rails in a proportional face where
// `│` and `├─` no longer line up. The rails and glyph sit outside the Button: a
// desktop draws every Button natively, in its UI face, `mono` children or not,
// so only the title is pressable.

const rowView = (E: Elements, $: EngineInterface, row: Row, isSelected: boolean, isNew: boolean, isOpen: boolean) => {
  const { Box, Button, Text } = E as Elements & { Box: any; Button: any; Text: any }
  const { task } = row
  const parts = [
    <Text
      mono
      inverse={isSelected}
      bold={row.isHead || isOpen}
      dimColor={task.status === 'canceled'}
      strikethrough={task.status === 'canceled'}
      color={isNew ? 'suggestion' : undefined}
    >
      {task.title}
    </Text>,
  ]
  if (row.hidden > 0) parts.push(<Text mono dimColor> (+{row.hidden})</Text>)
  if (row.isHead) parts.push(<Text mono color="claude"> ← HEAD</Text>)
  if (isNew) parts.push(<Text mono color="suggestion"> new</Text>)

  return (
    <Box key={`line-${task.id}`} flexDirection="row">
      <Text mono>
        <Text mono dimColor>{row.prefix}</Text>
        <Text mono color={statusColor[task.status]}>{row.glyph}</Text>
        <Text mono> </Text>
      </Text>
      <Button key={`row-${task.id}`} plain onPress={() => toggleDrawer($, task.id)}>
        {parts}
      </Button>
    </Box>
  )
}

/**
 * The open row's drawer: its details and every action on it, drawn under the
 * row behind the same rails so the graph still reads as one tree.
 */
const drawerView = (E: Elements, $: EngineInterface, row: Row, value: Graph, running: string | null) => {
  const { Box, Button, Text } = E as Elements & { Box: any; Button: any; Text: any }
  const { task } = row
  const gutter = `${row.below}${row.hasVisibleChildren ? '│' : ' '}  `
  const line = (key: string, body: unknown) => (
    <Box key={key} flexDirection="row">
      <Text mono dimColor>{gutter}</Text>
      {body}
    </Box>
  )
  const isDone = task.status === 'completed' || task.status === 'canceled'
  const meta = [
    task.id,
    task.status.replace('_', ' '),
    `r${task.revision}`,
    `created by ${task.createdBy}`,
    task.blockedBy.length === 0 ? '' : `blocked by ${task.blockedBy.join(', ')}`,
  ].filter(part => part !== '')
  const act = (name: string, label: string, onPress: () => unknown, variant?: 'primary') => (
    <Button key={`act-${name}-${task.id}`} label={label} variant={variant} onPress={onPress} />
  )
  const actions = [
    act('edit', 'Edit', () => openModal($, task.id), 'primary'),
    ...(isDone
      ? [act('reopen', 'Reopen', () => human($, (g, now) => reopen(g, task.id, 'human', now)))]
      : [
          act('next', 'Work on next', () => human($, (g, now) => workNext(g, task.id, 'human', now))),
          act('done', 'Complete', () => human($, (g, now) => complete(g, task.id, 'human', now))),
          act('cancel', 'Cancel', () => human($, (g, now) => cancel(g, task.id, 'human', now))),
        ]),
    act('up', 'Move up', () => human($, (g, now) => reorder(g, task.id, -1, 'human', now))),
    act('down', 'Move down', () => human($, (g, now) => reorder(g, task.id, 1, 'human', now))),
    ...(row.hasVisibleChildren || row.hidden > 0
      ? [act('fold', row.hidden > 0 ? 'Unfold' : 'Fold', () => toggleFold($, task.id))]
      : []),
    ...(task.status === 'canceled' && value.claim?.taskId === task.id && running !== null
      ? [act('stop', 'Stop Claude now', () => stopNow($, task))]
      : []),
  ]

  return (
    <Box key={`drawer-${task.id}`} flexDirection="column">
      {line('meta', <Text mono dimColor>{meta.join(' · ')}</Text>)}
      {task.description === '' ? null : line('desc', <Text wrap="wrap">{task.description}</Text>)}
      {task.acceptance === '' ? null : line('acc', <Text wrap="wrap"><Text bold>Done when: </Text>{task.acceptance}</Text>)}
      {task.notes.length === 0 ? null : line('note', <Text dimColor wrap="wrap">Latest: {task.notes.at(-1)}</Text>)}
      {line(
        'actions',
        <Box flexDirection="row" flexWrap="wrap" columnGap={1}>
          {actions}
        </Box>,
      )}
    </Box>
  )
}

export const renderPane = (on: On): void => {
  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const E = $.ui.resolve(e) as Elements & Record<string, any>
    const { Box, Button, Text, Input } = E
    const value = await read($, graph)
    const folded = await read($, collapsed)
    const selected = await read($, selectedId)
    const fresh = await read($, newIds)
    const openId = await read($, modalId)
    const expanded = await read($, expandedId)
    const held = await read($, draft)
    const running = await read($, turnId)
    const rows = layout(value, folded)
    const current = selected === null ? undefined : value.tasks[selected]
    const hasInput = Input !== undefined

    const toolbar =
      openId !== null ? null : (
        <Box flexDirection="row" flexWrap="wrap" columnGap={1}>
          <Button key="k" label="↑" hotkey="k" plain onPress={() => move($, -1)} />
          <Button key="j" label="↓" hotkey="j" plain onPress={() => move($, 1)} />
          <Button key="o" label="details" hotkey="o" plain onPress={() => (current === undefined ? undefined : toggleDrawer($, current.id))} />
          <Button key="e" label="edit" hotkey="e" plain onPress={() => (current === undefined ? undefined : openModal($, current.id))} />
          <Button key="n" label="next" hotkey="n" plain onPress={() => (current === undefined ? undefined : human($, (g, now) => workNext(g, current.id, 'human', now)))} />
          <Button key="c" label="done" hotkey="c" plain onPress={() => (current === undefined ? undefined : human($, (g, now) => complete(g, current.id, 'human', now)))} />
          <Button key="x" label="cancel" hotkey="x" plain onPress={() => (current === undefined ? undefined : human($, (g, now) => cancel(g, current.id, 'human', now)))} />
          <Button key="r" label="reopen" hotkey="r" plain onPress={() => (current === undefined ? undefined : human($, (g, now) => reopen(g, current.id, 'human', now)))} />
          <Button key="u" label="up" hotkey="u" plain onPress={() => (current === undefined ? undefined : human($, (g, now) => reorder(g, current.id, -1, 'human', now)))} />
          <Button key="d" label="down" hotkey="d" plain onPress={() => (current === undefined ? undefined : human($, (g, now) => reorder(g, current.id, 1, 'human', now)))} />
          <Button
            key="z"
            label="fold"
            hotkey="z"
            plain
            onPress={() => (current === undefined ? undefined : toggleFold($, current.id))}
          />
        </Box>
      )

    const graphView = (
      <Box flexDirection="column">
        {rows.length === 0 ? <Text dimColor>No tasks yet. Ask Claude for a plan, or press a to add one.</Text> : null}
        {rows.flatMap(row => {
          const isOpen = row.task.id === expanded
          const view = rowView(E, $, row, row.task.id === selected, fresh.includes(row.task.id), isOpen)

          return isOpen ? [view, drawerView(E, $, row, value, running)] : [view]
        })}
      </Box>
    )

    const modalTask = openId === null ? undefined : value.tasks[openId]
    const modal =
      modalTask === undefined || held === null ? null : (
        <Box
          key="modal"
          position="absolute"
          top={1}
          left={2}
          width={Math.max(30, e.props.bodyColumns - 4)}
          flexDirection="column"
          borderStyle="round"
          borderColor="suggestion"
          backgroundColor="inverseText"
          paddingX={1}
        >
          <Text bold>
            {modalTask.id} · {modalTask.status} · r{modalTask.revision} · created by {modalTask.createdBy}
            {value.claim?.taskId === modalTask.id ? ' · HEAD' : ''}
          </Text>
          {modalTask.parentId === null ? null : <Text dimColor>under {modalTask.parentId}</Text>}
          {modalTask.blockedBy.length === 0 ? null : <Text dimColor>blocked by {modalTask.blockedBy.join(', ')}</Text>}
          {hasInput ? (
            <Box flexDirection="column">
              <Input key="m-title" label="Title " value={held.fields.title} autoFocus onInput={(text: string) => editDraft($, 'title', text)} onSubmit={() => saveDraft($)} />
              <Input key="m-desc" label="Description " rows={3} value={held.fields.description} onInput={(text: string) => editDraft($, 'description', text)} onSubmit={() => saveDraft($)} />
              <Input key="m-acc" label="Acceptance " rows={3} value={held.fields.acceptance} onInput={(text: string) => editDraft($, 'acceptance', text)} onSubmit={() => saveDraft($)} />
            </Box>
          ) : (
            <Box flexDirection="column">
              <Text>{modalTask.title}</Text>
              <Text>{modalTask.description}</Text>
              <Text>Acceptance: {modalTask.acceptance}</Text>
            </Box>
          )}
          {modalTask.notes.length === 0 ? null : <Text dimColor>Progress: {modalTask.notes.at(-1)}</Text>}
          {held.conflict === null ? null : (
            <Box flexDirection="column" borderStyle="single" borderColor="warning">
              <Text color="warning">Changed while you edited (r{held.baseRevision} → r{modalTask.revision}). Theirs:</Text>
              <Text dimColor>Title: {held.conflict.title}</Text>
              <Text dimColor>Description: {held.conflict.description}</Text>
              <Text dimColor>Acceptance: {held.conflict.acceptance}</Text>
              <Box flexDirection="row" columnGap={1}>
                <Button key="m-mine" label="Keep mine" variant="primary" onPress={() => saveDraft($, true)} />
                <Button key="m-theirs" label="Take theirs" onPress={() => takeTheirs($)} />
              </Box>
            </Box>
          )}
          <Box flexDirection="row" flexWrap="wrap" columnGap={1}>
            {hasInput ? <Button key="m-save" label="Save" variant="primary" onPress={() => saveDraft($)} /> : null}
            {modalTask.status === 'completed' || modalTask.status === 'canceled' ? (
              <Button key="m-reopen" label="Reopen" onPress={() => human($, (g, now) => reopen(g, modalTask.id, 'human', now))} />
            ) : (
              <Box flexDirection="row" columnGap={1}>
                <Button key="m-next" label="Work on this next" onPress={() => human($, (g, now) => workNext(g, modalTask.id, 'human', now))} />
                <Button key="m-done" label="Complete" onPress={() => human($, (g, now) => complete(g, modalTask.id, 'human', now))} />
                <Button key="m-cancel" label="Cancel task" onPress={() => human($, (g, now) => cancel(g, modalTask.id, 'human', now))} />
              </Box>
            )}
            {modalTask.status === 'canceled' && value.claim?.taskId === modalTask.id && running !== null ? (
              <Button key="m-stop" label="Stop Claude now" onPress={() => stopNow($, modalTask)} />
            ) : null}
            <Button key="m-close" label="Close" role="dismiss" onPress={() => closeModal($)} />
          </Box>
        </Box>
      )

    return (
      <Box flexDirection="column">
        {toolbar}
        {graphView}
        {modal}
      </Box>
    )
  })
}
