import type { EngineInterface } from 'claude-code'

import type { Graph, Task } from '../types'
import type { Row } from './layout'
import { metaOf, taskActions, toggleDrawer, toggleFold } from './pane-model'
import type { Elements } from './pane-model'

// A desktop's graph, drawn with what a desktop draws natively: rows indented
// by depth (a desktop spaces its lines, so drawn rails never meet), a drawn
// status icon, a disclosure control on parents, and a drawer that is a
// bordered card of Markdown with real buttons.

/** Drawn the same size whatever the face: a glyph's width and baseline vary by font. */
const ICON_SIZE = 12

const icon = (body: string) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12" width="12" height="12">${body}</svg>`

const STATUS_ICON: Record<Task['status'], string> = {
  pending: icon('<circle cx="6" cy="6" r="4.5" fill="none" stroke="#8a8f98" stroke-width="1.5"/>'),
  in_progress: icon(
    '<circle cx="6" cy="6" r="4.5" fill="none" stroke="#d97757" stroke-width="1.5"/><circle cx="6" cy="6" r="2.25" fill="#d97757"/>',
  ),
  completed: icon(
    '<circle cx="6" cy="6" r="5.25" fill="#3fa266"/><path d="M3.6 6.2l1.6 1.6 3.2-3.4" fill="none" stroke="#fff" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"/>',
  ),
  canceled: icon(
    '<circle cx="6" cy="6" r="4.5" fill="none" stroke="#8a8f98" stroke-width="1.5"/><path d="M4.2 4.2l3.6 3.6M7.8 4.2l-3.6 3.6" stroke="#8a8f98" stroke-width="1.3" stroke-linecap="round"/>',
  ),
}

const STATUS_NAME: Record<Task['status'], string> = {
  pending: 'Pending',
  in_progress: 'In progress',
  completed: 'Completed',
  canceled: 'Canceled',
}

export function desktopRow(E: Elements, $: EngineInterface, row: Row, isSelected: boolean, isNew: boolean, isOpen: boolean) {
  const { Box, Button, Svg, Text } = E as Elements & { Box: any; Button: any; Svg: any; Text: any }
  const { task } = row
  const parts = [
    <Text
      inverse={isSelected}
      bold={row.isHead || isOpen}
      dimColor={task.status === 'canceled'}
      strikethrough={task.status === 'canceled'}
      color={isNew ? 'suggestion' : undefined}
    >
      {task.title}
    </Text>,
  ]
  if (row.hidden > 0) parts.push(<Text dimColor> (+{row.hidden})</Text>)
  if (row.isHead) parts.push(<Text color="claude"> ← HEAD</Text>)
  if (isNew) parts.push(<Text color="suggestion"> new</Text>)

  return (
    <Box key={`line-${task.id}`} flexDirection="row" alignItems="center" paddingLeft={row.prefix.length}>
      <Svg source={STATUS_ICON[task.status]} alt={STATUS_NAME[task.status]} width={ICON_SIZE} height={ICON_SIZE} />
      <Text> </Text>
      <Button key={`row-${task.id}`} plain onPress={() => toggleDrawer($, task.id)}>
        {parts}
      </Button>
      {row.hasVisibleChildren || row.hidden > 0 ? (
        <Button key={`fold-${task.id}`} label={row.hidden > 0 ? ' ▸' : ' ▾'} plain dimColor onPress={() => toggleFold($, task.id)} />
      ) : null}
    </Box>
  )
}

export function desktopDrawer(E: Elements, $: EngineInterface, row: Row, value: Graph, running: string | null) {
  const { Box, Button, Markdown, Text } = E as Elements & { Box: any; Button: any; Markdown: any; Text: any }
  const { task } = row
  const note = task.notes.at(-1)

  return (
    <Box
      key={`drawer-${task.id}`}
      flexDirection="column"
      // Under the title: past the indent and the icon.
      marginLeft={row.prefix.length + 2}
      marginBottom={1}
      borderStyle="round"
      borderDimColor
      paddingX={1}
    >
      <Text mono dimColor wrap="wrap">{metaOf(task)}</Text>
      {task.description === '' ? null : <Markdown key={`desc-${task.id}`} text={task.description} />}
      {task.acceptance === '' ? null : <Markdown key={`acc-${task.id}`} text={`**Done when:** ${task.acceptance}`} />}
      {note === undefined ? null : <Markdown key={`note-${task.id}`} dimColor text={`*Latest:* ${note}`} />}
      <Box flexDirection="row" flexWrap="wrap" columnGap={1} marginTop={1}>
        {taskActions($, task, value, running).map(action => (
          <Button
            key={`act-${action.name}-${task.id}`}
            label={action.label}
            variant={action.primary === true || action.urgent === true ? 'primary' : 'secondary'}
            onPress={action.run}
          />
        ))}
      </Box>
    </Box>
  )
}
