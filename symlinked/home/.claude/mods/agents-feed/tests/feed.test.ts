import { describe, expect, test } from 'claude-code/testing'

import { clip, parseMarkers, summarize } from '../hooks/feed'

describe('feed helpers', () => {
  test('the last marker line wins', async () => {
    expect(parseMarkers('working on it\nneeds input: pick a color')).toEqual({ state: 'blocked', reason: 'pick a color' })
    expect(parseMarkers('needs input: x\nresult: Shipped the widget')).toEqual({ state: 'done', reason: 'Shipped the widget' })
    expect(parseMarkers('failed: no such repo')).toEqual({ state: 'failed', reason: 'no such repo' })
    expect(parseMarkers('just chatting')).toBeNull()
  })

  test('summaries are at most three words, past-tense verb dropped', async () => {
    expect(summarize('delivered agent roster, commands, and run workflow')).toBe('agent roster commands')
    expect(summarize('Verified that `claude --bg -n <name>` names it')).toBe('claude bg n')
    expect(summarize('')).toBe('')
  })

  test('clip keeps the first line and caps its length', async () => {
    expect(clip('one\ntwo')).toBe('one')
    expect(clip('x'.repeat(200), 10)).toBe(`${'x'.repeat(9)}…`)
  })
})

describe('interactive session', () => {
  test('a turn goes working, then done with its answer', async ($, on) => {
    const writes: { path: string; text: string }[] = []
    on('fs.write', ($, e) => {
      writes.push(e)
      return { value: undefined }
    })
    on('process.run', () => ({ value: { exitCode: 0, stdout: '', stderr: '', isStdoutTruncated: false, isStderrTruncated: false } }))
    on('env.get', ($, e) => ({ value: e.name === 'HOME' ? '/home/t' : undefined }))
    on('session.id', () => ({ value: 'sess-1' }))
    on('session.cwd', () => ({ value: '/work' }))
    on('session.model', () => ({ value: 'opus' }))
    on('clock.now', () => ({ value: 1000 }))
    on('fs.read', () => ({ deny: 'no such file' }))
    on('turn.start', ($, e) => ({ turnId: e.turnId }))
    on('turn.complete', ($, e) => ({ text: e.answer }))

    await $.turn.start({ text: 'hi', turnId: 't1' })
    const working = JSON.parse(writes.at(-1)!.text)
    expect(writes.at(-1)!.path).toBe('/home/t/.cache/claude-agents/sess-1.json')
    expect(working).toMatchObject({ v: 1, sessionId: 'sess-1', kind: 'interactive', jobId: null, state: 'working' })

    await $.turn.complete({ answer: 'Renamed the widget', durationMs: 5, isAborted: false, turnId: 't1', reason: 'answer' })
    expect(JSON.parse(writes.at(-1)!.text)).toMatchObject({ state: 'done', reason: 'Renamed the widget', summary: 'renamed widget' })
  })
})
