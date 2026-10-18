// agents-feed: every session writes what it is doing to
// ~/.cache/claude-agents/<sessionId>.json for the Noctalia claude_agents widget,
// plus the account-wide rate limits to _usage.json. Observe only: every hook
// passes its event through unchanged, and a failure here never reaches the session.

import type { EngineInterface, Register } from 'claude-code'

import { clip, feedDir, parseMarkers, summarize } from './feed'
import type { Feed, FeedRateLimit, FeedState } from './feed'

let feed: Feed | null = null
let dir = ''
// Set when a tool call's permission check came back `ask` (a prompt is up);
// the call itself starting means you answered it.
let isAwaitingPermission = false

async function ensure($: EngineInterface): Promise<Feed> {
  if (feed) return feed
  const home = (await $.env.get('HOME')) ?? ''
  const jobDir = await $.env.get('CLAUDE_JOB_DIR')
  dir = feedDir(home)
  feed = {
    v: 1,
    sessionId: await $.session.id(),
    jobId: jobDir ? (jobDir.replace(/\/+$/, '').split('/').pop() ?? null) : null,
    kind: jobDir ? 'background' : 'interactive',
    cwd: await $.session.cwd(),
    model: await $.session.model(),
    state: 'idle',
    reason: '',
    summary: '',
    context: {},
    rateLimits: [],
    updatedAt: 0,
  }
  return feed
}

// Tell a running widget to re-read now; missing noctalia (macOS) just fails quietly.
function ping($: EngineInterface) {
  $.process.run(['noctalia', 'msg', 'plugin', 'kyle/claude_agents:status', 'all', 'refresh']).catch(() => {})
}

async function save($: EngineInterface, patch: Partial<Feed>) {
  try {
    const f = await ensure($)
    Object.assign(f, patch, { updatedAt: await $.clock.now() })
    await $.fs.write(`${dir}/${f.sessionId}.json`, JSON.stringify(f))
    ping($)
  } catch {
    // never let the feed break the session
  }
}

function setState($: EngineInterface, state: FeedState, reason = '') {
  const text = clip(reason)
  return save($, { state, reason: text, summary: summarize(text) })
}

export const register: Register = (on) => {
  on('session.start', async ($, e, next) => {
    await save($, { cwd: e.cwd })
    return next(e)
  })

  on('turn.start', async ($, e, next) => {
    if (e.agentId === undefined) await setState($, 'working')
    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    if (e.agentId === undefined) {
      const f = await ensure($).catch(() => null)
      const isError = e.reason === 'error' || e.reason === 'refusal'
      const marked = f?.kind === 'background' ? parseMarkers(e.answer) : null
      if (marked) await setState($, marked.state, marked.reason)
      else if (isError) await setState($, 'failed', e.reason === 'refusal' ? (e.refusal.explanation ?? 'refused') : 'API error')
      else if (e.isAborted) await setState($, 'idle')
      else if (f?.kind === 'interactive') await setState($, 'done', e.answer)
      else await setState($, 'idle', e.answer)
    }
    return next(e)
  })

  // The model is asking you something: blocked on the question until it's answered.
  on('tool.call', { tool: 'AskUserQuestion' }, async ($, e, next) => {
    if (e.agentId === undefined) await setState($, 'blocked', e.questions[0]?.question ?? 'question')
    const result = await next(e)
    if (e.agentId === undefined) await setState($, 'working')
    return result
  }).catch(($, e, next) => next(e))

  // A permission prompt: the check answered `ask`. Read the verdict, never change it.
  on('tool.check', async ($, e, next) => {
    const verdict = await next(e)
    if (e.agentId === undefined && verdict.decision === 'ask') {
      isAwaitingPermission = true
      await setState($, 'blocked', `permission: ${e.tool}`)
    }
    return verdict
  }).catch(($, e, next) => next(e))

  // The call running means the prompt was answered: back to work.
  on('tool.call', async ($, e, next) => {
    if (isAwaitingPermission && e.agentId === undefined) {
      isAwaitingPermission = false
      await setState($, 'working')
    }
    return next(e)
  }).catch(($, e, next) => next(e))

  // Permission prompts and "waiting for input" notices, where classic hooks reach
  // installed plugins (an organization's managed settings can withhold them).
  on('classic.Notification', async ($, e, next) => {
    await setState($, 'blocked', e.message)
    return next(e)
  }).catch(($, e, next) => next(e))

  on('session.measure', async ($, e, next) => {
    const rateLimits: FeedRateLimit[] = e.rateLimits.map((r) => ({ kind: r.kind, percentUsed: r.percentUsed, resetsAt: r.resetsAt }))
    await save($, { context: { percent: e.context.percent, tokens: e.context.tokens, window: e.context.window }, rateLimits })
    if (rateLimits.length > 0) {
      try {
        await $.fs.write(`${dir}/_usage.json`, JSON.stringify({ at: await $.clock.now(), rateLimits }))
      } catch {
        // best-effort
      }
    }
    return next(e)
  })

  on('session.end', async ($, e, next) => {
    await setState($, 'ended')
    return next(e)
  })
}
