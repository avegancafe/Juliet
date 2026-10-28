import { atom, read, update } from 'claude-code'
import type { EngineInterface, On } from 'claude-code'

import type { Draft, DraftFields, Graph, Task } from '../types'
import { INDENT, UNICODE, layout, wrapText } from './layout'
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
const showCanceled = atom({ plugin: 'task-graph', key: 'showCanceled' } as const, false)

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

const rowView = (E: Elements, $: EngineInterface, row: Row, isSelected: boolean, isNew: boolean, isOpen: boolean, outline: boolean) => {
  const { Box, Button, Text } = E as Elements & { Box: any; Button: any; Text: any }
  const { task } = row
  const canFold = row.hasVisibleChildren || row.hidden > 0
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
  const dot = <Text mono color={statusColor[task.status]}>{row.glyph}</Text>

  // The terminal folds a group from its dot. A desktop draws a Button in its own
  // face and size, so there the dot stays text and the fold control trails the
  // title, where a wider glyph shifts nothing.
  return (
    <Box key={`line-${task.id}`} flexDirection="row">
      <Text mono dimColor>{row.prefix}</Text>
      {canFold && !outline ? (
        <Button key={`fold-${task.id}`} plain onPress={() => toggleFold($, task.id)}>
          {dot}
        </Button>
      ) : (
        dot
      )}
      <Text mono> </Text>
      <Button key={`row-${task.id}`} plain onPress={() => toggleDrawer($, task.id)}>
        {parts}
      </Button>
      {canFold && outline ? (
        <Button key={`fold-${task.id}`} label={row.hidden > 0 ? ' ▸' : ' ▾'} plain dimColor onPress={() => toggleFold($, task.id)} />
      ) : null}
    </Box>
  )
}

/**
 * The open row's drawer: its details and every action on it, drawn under the
 * row behind the same rails so the graph still reads as one tree.
 */
const drawerView = (E: Elements, $: EngineInterface, row: Row, value: Graph, running: string | null, columns: number, outline: boolean) => {
  const { Box, Button, Text } = E as Elements & { Box: any; Button: any; Text: any }
  const { task } = row
  // The drawer is a card: a dim bar down its left edge, behind the tree's rails.
  // Every line, wrapped ones included, is its own row so the rails never break.
  // Under the title: past the rails and the dot, or in an outline past the indent.
  const gutter = outline ? `${row.prefix}  ` : `${row.below}${row.hasVisibleChildren ? '│' : ' '}  `
  const bar = '▏ '
  const width = Math.max(20, columns - gutter.length - bar.length - 1)
  const line = (key: string, body: unknown) => (
    <Box key={key} flexDirection="row">
      <Text mono dimColor>{gutter}</Text>
      <Text mono color="subtle">{bar}</Text>
      {body}
    </Box>
  )
  const block = (key: string, text: string, style: Record<string, unknown> = {}, lead = '') =>
    wrapText(lead + text, width).map((part, index) =>
      line(
        `${key}-${index}`,
        index === 0 && lead !== '' ? (
          <Text wrap="truncate-end" {...style}>
            <Text bold>{lead}</Text>
            {part.slice(lead.length)}
          </Text>
        ) : (
          <Text wrap="truncate-end" {...style}>
            {part}
          </Text>
        ),
      ),
    )
  const isDone = task.status === 'completed' || task.status === 'canceled'
  const meta = [
    task.id,
    task.status.replace('_', ' '),
    `r${task.revision}`,
    `created by ${task.createdBy}`,
    task.blockedBy.length === 0 ? '' : `blocked by ${task.blockedBy.join(', ')}`,
  ].filter(part => part !== '')
  const act = (name: string, label: string, onPress: () => unknown, loud = false) => (
    <Button key={`act-${name}-${task.id}`} label={label} plain dimColor={!loud} onPress={onPress} />
  )
  const actions = [
    act('edit', 'Edit', () => openModal($, task.id)),
    ...(isDone
      ? [act('reopen', 'Reopen', () => human($, (g, now) => reopen(g, task.id, 'human', now)))]
      : [
          act('next', 'Work on next', () => human($, (g, now) => workNext(g, task.id, 'human', now))),
          act('done', 'Complete', () => human($, (g, now) => complete(g, task.id, 'human', now))),
          act('cancel', 'Cancel', () => human($, (g, now) => cancel(g, task.id, 'human', now))),
        ]),
    act('up', 'Up', () => human($, (g, now) => reorder(g, task.id, -1, 'human', now))),
    act('down', 'Down', () => human($, (g, now) => reorder(g, task.id, 1, 'human', now))),
    ...(task.status === 'canceled' && value.claim?.taskId === task.id && running !== null
      ? [act('stop', 'Stop Claude now', () => stopNow($, task), true)]
      : []),
  ].flatMap((button, index) => (index === 0 ? [button] : [<Text dimColor> · </Text>, button]))

  // An outline has no rails to keep beside the card, so a desktop gets a real
  // bordered Box and wraps the text itself: a `▏` column breaks into dashes
  // there, as the rails did.
  if (outline) {
    return (
      <Box
        key={`drawer-${task.id}`}
        flexDirection="column"
        marginLeft={gutter.length}
        marginBottom={1}
        borderStyle="round"
        borderDimColor
        paddingX={1}
      >
        <Text mono dimColor wrap="wrap">{meta.join(' · ')}</Text>
        {task.description === '' ? null : <Text wrap="wrap">{task.description}</Text>}
        {task.acceptance === '' ? null : (
          <Text wrap="wrap">
            <Text bold>Done when: </Text>
            {task.acceptance}
          </Text>
        )}
        {task.notes.length === 0 ? null : <Text dimColor wrap="wrap">Latest: {task.notes.at(-1)}</Text>}
        <Box flexDirection="row" flexWrap="wrap" marginTop={1}>
          {actions}
        </Box>
      </Box>
    )
  }

  return (
    <Box key={`drawer-${task.id}`} flexDirection="column">
      {wrapText(meta.join(' · '), width).map((part, index) => line(`meta-${index}`, <Text mono dimColor wrap="truncate-end">{part}</Text>))}
      {task.description === '' ? null : block('desc', task.description)}
      {task.acceptance === '' ? null : block('acc', task.acceptance, {}, 'Done when: ')}
      {task.notes.length === 0 ? null : block('note', task.notes.at(-1) ?? '', { dimColor: true }, 'Latest: ')}
      {line('actions-above', <Text> </Text>)}
      {line(
        'actions',
        <Box flexDirection="row" flexWrap="nowrap">
          {actions}
        </Box>,
      )}
      <Box key="after-card" flexDirection="row">
        <Text mono dimColor>{gutter}</Text>
      </Box>
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
    const withCanceled = await read($, showCanceled)
    const outline = e.surface !== 'terminal'
    const rows = layout(value, folded, { hideCanceled: !withCanceled, glyphs: outline ? INDENT : UNICODE })
    const canceledCount = Object.values(value.tasks).filter(task => task.status === 'canceled').length
    const current = selected === null ? undefined : value.tasks[selected]
    const hasInput = Input !== undefined

    // The pane's one standing control: every action on a task lives in its
    // drawer, so the top row only toggles the canceled tasks, when there are any.
    const toolbar =
      openId !== null || canceledCount === 0 ? null : (
        <Box flexDirection="row">
          <Button
            key="toggle-canceled"
            label={withCanceled ? `hide canceled (${canceledCount})` : `show canceled (${canceledCount})`}
            plain
            dimColor
            onPress={() => update($, showCanceled, shown => !shown)}
          />
        </Box>
      )

    const graphView = (
      <Box flexDirection="column">
        {rows.length === 0 ? <Text dimColor>No tasks yet. Ask Claude for a plan.</Text> : null}
        {rows.flatMap(row => {
          const isOpen = row.task.id === expanded
          const view = rowView(E, $, row, row.task.id === selected, fresh.includes(row.task.id), isOpen, outline)

          return isOpen ? [view, drawerView(E, $, row, value, running, e.viewport?.columns ?? 80, outline)] : [view]
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
