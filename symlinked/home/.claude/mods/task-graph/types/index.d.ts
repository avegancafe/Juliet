export type TaskStatus = 'pending' | 'in_progress' | 'completed' | 'canceled'

export type Author = 'human' | 'claude'

export type Task = {
  id: string
  parentId: string | null
  title: string
  description: string
  acceptance: string
  status: TaskStatus
  order: number
  blockedBy: string[]
  createdBy: Author
  revision: number
  createdAt: number
  updatedAt: number
  notes: string[]
}

/** Claude's current claim: the HEAD of the graph. */
export type Claim = {
  taskId: string
  startedAt: number
  observedRevision: number
}

/** One change to the graph, kept so Claude can be told what moved. */
export type Change = {
  rev: number
  taskId: string
  by: Author
  summary: string
}

export type Graph = {
  tasks: Record<string, Task>
  /** Bumped by every change; Claude's last-seen value is `claudeSeen`. */
  rev: number
  nextId: number
  claim: Claim | null
  /** "Work on this next": put first in the eligible queue. */
  nextUp: string | null
  changes: Change[]
  claudeSeen: number
}

export type DraftFields = {
  title: string
  description: string
  acceptance: string
}

/** The modal's unsaved edit, kept apart from the graph so redraws never clobber it. */
export type Draft = {
  taskId: string
  baseRevision: number
  fields: DraftFields
  /** Set when Save found the task changed underneath the draft. */
  conflict: DraftFields | null
}

declare module 'claude-code' {
  interface PluginState {
    'task-graph': {
      graph: Graph
      selectedId: string | null
      collapsed: string[]
      newIds: string[]
      modalId: string | null
      /** The task whose inline drawer of details and actions is open. */
      expandedId: string | null
      draft: Draft | null
      turnId: string | null
    }
  }
}
