import type { EngineInterface } from 'claude-code'

import type { Graph } from '../types'
import { wrapText } from './layout'
import type { Row } from './layout'
import { metaOf, statusColor, taskActions, toggleDrawer, toggleFold } from './pane-model'
import type { Elements } from './pane-model'

// The terminal's graph: git-log rails and glyphs in characters, a drawer behind
// the same rails with a `▏` bar down its left edge, and its actions as text
// links. Every line is its own row, wrapped ones included, so no rail breaks.

export function terminalRow(E: Elements, $: EngineInterface, row: Row, isSelected: boolean, isNew: boolean, isOpen: boolean) {
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
  const dot = <Text mono color={statusColor[task.status]}>{row.glyph}</Text>

  // A parent's dot folds its group.
  return (
    <Box key={`line-${task.id}`} flexDirection="row">
      <Text mono dimColor>{row.prefix}</Text>
      {row.hasVisibleChildren || row.hidden > 0 ? (
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
    </Box>
  )
}

export function terminalDrawer(E: Elements, $: EngineInterface, row: Row, value: Graph, running: string | null, columns: number) {
  const { Box, Button, Text } = E as Elements & { Box: any; Button: any; Text: any }
  const { task } = row
  // Under the title: past the rails and the dot.
  const gutter = `${row.below}${row.hasVisibleChildren ? '│' : ' '}  `
  const bar = '▏ '
  const width = Math.max(20, columns - gutter.length - bar.length - 1)
  const line = (key: string, body: unknown) => (
    <Box key={key} flexDirection="row">
      <Box flexShrink={0}>
        <Text mono dimColor>{gutter}</Text>
        <Text mono color="subtle">{bar}</Text>
      </Box>
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
  const actions = taskActions($, task, value, running)
    .map(action => (
      <Button key={`act-${action.name}-${task.id}`} label={action.label} plain dimColor={action.urgent !== true} onPress={action.run} />
    ))
    .flatMap((button, index) => (index === 0 ? [button] : [<Text dimColor> · </Text>, button]))

  return (
    <Box key={`drawer-${task.id}`} flexDirection="column">
      {wrapText(metaOf(task), width).map((part, index) => line(`meta-${index}`, <Text mono dimColor wrap="truncate-end">{part}</Text>))}
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
