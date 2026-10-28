import type { Graph, Task, TaskStatus } from '../types'
import { children } from './store'

// The graph as git-log-style rows: one row per visible task, its prefix the
// rails of its ancestors and its own branch connector.

export type Glyphs = {
  status: Record<TaskStatus, string>
  rail: string
  gap: string
  branch: string
  last: string
  folded: string
}

export const UNICODE: Glyphs = {
  status: { pending: '○', in_progress: '◉', completed: '✓', canceled: '✗' },
  rail: '│  ',
  gap: '   ',
  branch: '├─ ',
  last: '└─ ',
  folded: '▸',
}

/**
 * Indentation alone, for a surface that spaces its lines: there `│` and `├─`
 * stop short of the next line and the rails read as dashes, never as lines.
 */
export const INDENT: Glyphs = {
  status: UNICODE.status,
  rail: '  ',
  gap: '  ',
  branch: '  ',
  last: '  ',
  folded: '▸',
}

export const ASCII: Glyphs = {
  status: { pending: 'o', in_progress: '*', completed: '+', canceled: 'x' },
  rail: '|  ',
  gap: '   ',
  branch: '|- ',
  last: '`- ',
  folded: '>',
}

export type Row = {
  task: Task
  prefix: string
  glyph: string
  isHead: boolean
  /** How many descendants a collapsed row hides; 0 when expanded or a leaf. */
  hidden: number
  /** The rails drawn under this row: what its children, or its open drawer, line up behind. */
  below: string
  /** Whether rows of its own children follow it. */
  hasVisibleChildren: boolean
}

export type LayoutOptions = {
  /** Leaves canceled tasks, and everything beneath them, out of the rows. */
  hideCanceled?: boolean
  glyphs?: Glyphs
}

export const layout = (graph: Graph, collapsed: readonly string[], options: LayoutOptions = {}): Row[] => {
  const { hideCanceled = false, glyphs = UNICODE } = options
  const shown = (parentId: string | null) =>
    children(graph, parentId).filter(task => !hideCanceled || task.status !== 'canceled')
  const countBelow = (id: string): number => shown(id).reduce((sum, child) => sum + 1 + countBelow(child.id), 0)
  const rows: Row[] = []
  const folded = new Set(collapsed)
  const visit = (parentId: string | null, rails: string) => {
    const kids = shown(parentId)
    kids.forEach((task, index) => {
      const isLast = index === kids.length - 1
      const connector = parentId === null ? '' : isLast ? glyphs.last : glyphs.branch
      const isFolded = folded.has(task.id)
      const below = parentId === null ? rails : rails + (isLast ? glyphs.gap : glyphs.rail)
      rows.push({
        task,
        prefix: rails + connector,
        glyph: glyphs.status[task.status],
        isHead: graph.claim?.taskId === task.id,
        hidden: isFolded ? countBelow(task.id) : 0,
        below,
        hasVisibleChildren: !isFolded && shown(task.id).length > 0,
      })
      if (!isFolded) visit(task.id, below)
    })
  }
  visit(null, '')

  return rows
}

export const toText = (rows: readonly Row[]): string =>
  rows
    .map(row => `${row.prefix}${row.glyph} ${row.task.title}${row.hidden > 0 ? ` (+${row.hidden})` : ''}${row.isHead ? '  ← HEAD' : ''}`)
    .join('\n')

/**
 * Breaks text into lines of at most `width` characters, at spaces where it can.
 * The drawer wraps its own text so each line gets its own rails: a surface that
 * wrapped it instead would leave the rails off every line but the first.
 */
export const wrapText = (text: string, width: number): string[] => {
  const lines: string[] = []
  for (const paragraph of text.split('\n')) {
    let line = ''
    for (const word of paragraph.split(' ')) {
      let rest = word
      while (rest.length > width) {
        if (line !== '') {
          lines.push(line)
          line = ''
        }
        lines.push(rest.slice(0, width))
        rest = rest.slice(width)
      }
      if (line === '') line = rest
      else if (line.length + 1 + rest.length <= width) line += ` ${rest}`
      else {
        lines.push(line)
        line = rest
      }
    }
    lines.push(line)
  }

  return lines
}
