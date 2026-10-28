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

const countBelow = (graph: Graph, id: string): number =>
  children(graph, id).reduce((sum, child) => sum + 1 + countBelow(graph, child.id), 0)

export const layout = (graph: Graph, collapsed: readonly string[], glyphs: Glyphs = UNICODE): Row[] => {
  const rows: Row[] = []
  const folded = new Set(collapsed)
  const visit = (parentId: string | null, rails: string) => {
    const kids = children(graph, parentId)
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
        hidden: isFolded ? countBelow(graph, task.id) : 0,
        below,
        hasVisibleChildren: !isFolded && children(graph, task.id).length > 0,
      })
      if (!isFolded) visit(task.id, below)
    })
  }
  visit(null, '')

  return rows
}

/** The row `delta` steps from `selectedId`, clamped; the first row when none is selected. */
export const step = (rows: readonly Row[], selectedId: string | null, delta: number): string | null => {
  if (rows.length === 0) return null
  const at = rows.findIndex(row => row.task.id === selectedId)
  if (at === -1) return rows[0]!.task.id
  const to = Math.min(rows.length - 1, Math.max(0, at + delta))

  return rows[to]!.task.id
}

export const toText = (rows: readonly Row[]): string =>
  rows
    .map(row => `${row.prefix}${row.glyph} ${row.task.title}${row.hidden > 0 ? ` (+${row.hidden})` : ''}${row.isHead ? '  ← HEAD' : ''}`)
    .join('\n')
