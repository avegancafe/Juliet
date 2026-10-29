import { atom, read, update } from 'claude-code'
import type { On } from 'claude-code'

import { desktopDrawer, desktopRow } from './desktop-view'
import { INDENT, UNICODE, layout } from './layout'
import { stopNow } from './native'
import { closeModal, editDraft, human, saveDraft, takeTheirs } from './pane-model'
import type { Elements } from './pane-model'
import { PANE } from './state'
import { cancel, complete, emptyGraph, reopen, workNext } from './store'
import { terminalDrawer, terminalRow } from './terminal-view'

// The state library lists what a file reads from its own consts, so each file
// names the atoms it reads; the same plugin and key are the same value.
const graph = atom({ plugin: 'task-graph', key: 'graph' } as const, emptyGraph())
const selectedId = atom({ plugin: 'task-graph', key: 'selectedId' } as const, null)
const collapsed = atom({ plugin: 'task-graph', key: 'collapsed' } as const, [])
const newIds = atom({ plugin: 'task-graph', key: 'newIds' } as const, [])
const modalId = atom({ plugin: 'task-graph', key: 'modalId' } as const, null)
const expandedId = atom({ plugin: 'task-graph', key: 'expandedId' } as const, null)
const draft = atom({ plugin: 'task-graph', key: 'draft' } as const, null)
const turnId = atom({ plugin: 'task-graph', key: 'turnId' } as const, null)
const showCanceled = atom({ plugin: 'task-graph', key: 'showCanceled' } as const, false)

// The pane: the task graph, one toggle above it, and a task modal drawn over
// the graph (never instead of it), its draft kept in state so live updates and
// Escape never lose an edit. The terminal draws the graph as characters, a
// desktop with its own controls: see terminal-view and desktop-view.

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
    const isTerminal = e.surface === 'terminal'
    const rows = layout(value, folded, { hideCanceled: !withCanceled, glyphs: isTerminal ? UNICODE : INDENT })
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
          const isSelected = row.task.id === selected
          const isNew = fresh.includes(row.task.id)
          if (isTerminal) {
            const view = terminalRow(E, $, row, isSelected, isNew, isOpen)

            return isOpen ? [view, terminalDrawer(E, $, row, value, running, e.viewport?.columns ?? 80)] : [view]
          }
          const view = desktopRow(E, $, row, isSelected, isNew, isOpen)

          return isOpen ? [view, desktopDrawer(E, $, row, value, running)] : [view]
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
