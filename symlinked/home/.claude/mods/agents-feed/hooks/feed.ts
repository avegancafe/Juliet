// Pure pieces of the feed: the snapshot shape, the background-job marker lines and
// the <=3-word summary. No `$` here, so the tests can hold them directly.

export type FeedState = 'idle' | 'working' | 'blocked' | 'failed' | 'done' | 'ended'

export type FeedRateLimit = { kind: string; percentUsed: number; resetsAt?: string }

// One file per session at ~/.cache/claude-agents/<sessionId>.json, read by the
// Noctalia claude_agents widget (symlinked/home/.local/share/noctalia/plugins/claude_agents).
export type Feed = {
  v: 1
  sessionId: string
  jobId: string | null
  kind: 'background' | 'interactive'
  cwd: string
  model: string
  state: FeedState
  reason: string
  summary: string
  context: { percent?: number; tokens?: number; window?: number }
  rateLimits: FeedRateLimit[]
  updatedAt: number
}

// Background sessions end a turn with one of these lines (see the background-job
// conventions): `result:` delivered, `needs input:` blocked on you, `failed:` stuck.
const MARKERS: ReadonlyArray<[RegExp, FeedState]> = [
  [/^\s*result:\s*(.*)$/i, 'done'],
  [/^\s*needs input:\s*(.*)$/i, 'blocked'],
  [/^\s*failed:\s*(.*)$/i, 'failed'],
]

// The last marker line in the answer wins; null when there is none.
export function parseMarkers(answer: string): { state: FeedState; reason: string } | null {
  let found: { state: FeedState; reason: string } | null = null
  for (const line of answer.split('\n')) {
    for (const [rx, state] of MARKERS) {
      const m = rx.exec(line)
      if (m) found = { state, reason: (m[1] ?? '').trim() }
    }
  }
  return found
}

const FILLER = new Set(['a', 'an', 'the', 'and', 'of', 'to', 'for', 'with', 'in', 'on', 'that', 'this', 'it', 'is', 'as'])

// "delivered agent roster, commands, and run workflow" -> "agent roster commands"
export function summarize(reason: string): string {
  const words = (reason.toLowerCase().match(/[a-z][a-z0-9_]*/g) ?? []).filter((w) => !FILLER.has(w))
  // Past-tense summaries ("delivered ...", "fixed ..."): drop the verb.
  if (words.length > 3 && words[0]?.endsWith('ed')) words.shift()
  return words.slice(0, 3).join(' ')
}

// First line, trimmed to what fits a panel row.
export function clip(text: string, max = 160): string {
  const line = text.trim().split('\n')[0] ?? ''
  return line.length > max ? `${line.slice(0, max - 1)}…` : line
}

export function feedDir(home: string): string {
  return `${home}/.cache/claude-agents`
}
