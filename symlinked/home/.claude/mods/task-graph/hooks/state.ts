import { atom, read, update } from 'claude-code'
import type { EngineInterface } from 'claude-code'

import type { Graph } from '../types'
import { emptyGraph, markSeen } from './store'
import type { Result } from './store'

// The session's live copy lives in `$.state`; every graph write is mirrored to
// `$.store` under the session's id, so a restart or a resume of that session
// picks it up and no other session sees it.

export const graph = atom({ plugin: 'task-graph', key: 'graph' } as const, emptyGraph())
export const newIds = atom({ plugin: 'task-graph', key: 'newIds' } as const, [])

export const PANE = 'task-graph'
const NEW_HIGHLIGHT_MS = 8000
const KEY_PREFIX = 'graph:session:'
// A session's saved graph outlives it this long; `$.store` is capped at 4 MiB.
const KEEP_MS = 30 * 24 * 60 * 60 * 1000

type Store = { root: string; sessionId: string; graph: Graph; savedAt: number }

async function storeKey($: EngineInterface): Promise<string> {
  return `${KEY_PREFIX}${await $.session.id()}`
}

export async function persist($: EngineInterface, value: Graph): Promise<void> {
  const saved: Store = {
    root: await $.session.root(),
    sessionId: await $.session.id(),
    graph: value,
    savedAt: await $.clock.now(),
  }
  await $.store.set(await storeKey($), saved)
}

/**
 * Drops the graphs of sessions idle past `KEEP_MS`, and the older per-project
 * graphs (`graph:<root>`) every session in a directory used to share.
 */
async function prune($: EngineInterface): Promise<void> {
  const now = await $.clock.now()
  for (const key of await $.store.keys()) {
    if (!key.startsWith('graph:')) continue
    if (!key.startsWith(KEY_PREFIX)) {
      await $.store.delete(key)
      continue
    }
    const saved = (await $.store.get(key)) as Store | undefined
    if (saved === undefined || now - saved.savedAt > KEEP_MS) await $.store.delete(key)
  }
}

/** Loads this session's graph into the session, unless the session already holds one. */
export async function hydrate($: EngineInterface): Promise<void> {
  await prune($)
  const live = await read($, graph)
  if (live.rev > 0) return refreshStatus($, live)
  const saved = (await $.store.get(await storeKey($))) as Store | undefined
  if (saved?.graph === undefined) return
  // Older history is not replayed to Claude: it starts from the saved graph.
  const loaded = await update($, graph, () => ({ ...saved.graph, claudeSeen: saved.graph.rev }))
  await refreshStatus($, loaded)
}

/**
 * Applies one store operation to the live graph and persists it. The change
 * function may run more than once on a write race, so it stays pure.
 */
export async function mutate(
  $: EngineInterface,
  op: (value: Graph) => Result,
  options: { seenByClaude?: boolean } = {},
): Promise<Result> {
  let result: Result = { ok: false, error: 'The graph could not be written.' }
  const written = await update($, graph, value => {
    result = op(value)
    if (!result.ok) return value

    return options.seenByClaude === true ? markSeen(result.graph) : result.graph
  })
  if (result.ok) {
    await persist($, written)
    void refreshStatus($, written)
  }

  return result
}

export async function seen($: EngineInterface): Promise<void> {
  const value = await update($, graph, markSeen)
  await persist($, value)
}

/** Tints a newly arrived row for a few seconds, without touching the selection. */
export async function highlight($: EngineInterface, id: string): Promise<void> {
  await update($, newIds, ids => [...ids.filter(one => one !== id), id])
  $.clock.after(NEW_HIGHLIGHT_MS, () => {
    void update($, newIds, ids => ids.filter(one => one !== id))
  })
}

export async function refreshStatus($: EngineInterface, value: Graph): Promise<void> {
  const all = Object.values(value.tasks)
  if (all.length === 0) {
    $.ui.status(undefined)

    return
  }
  const done = all.filter(task => task.status === 'completed').length
  const live = all.filter(task => task.status !== 'canceled').length
  const head = value.claim === null ? undefined : value.tasks[value.claim.taskId]
  $.ui.status(`tasks ${done}/${live}${head === undefined ? '' : ` · HEAD ${head.title}`}`)
}
