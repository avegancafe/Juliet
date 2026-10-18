import { describe, expect, test } from 'claude-code/testing'

describe('background session', () => {
  test('a needs-input marker blocks it, and rate limits land in _usage.json', async ($, on) => {
    const writes: { path: string; text: string }[] = []
    on('fs.write', ($, e) => {
      writes.push(e)
      return { value: undefined }
    })
    on('process.run', () => ({ value: { exitCode: 0, stdout: '', stderr: '', isStdoutTruncated: false, isStderrTruncated: false } }))
    on('env.get', ($, e) => ({ value: e.name === 'HOME' ? '/home/t' : e.name === 'CLAUDE_JOB_DIR' ? '/home/t/.claude/jobs/abc123' : undefined }))
    on('session.id', () => ({ value: 'sess-bg' }))
    on('session.cwd', () => ({ value: '/work' }))
    on('session.model', () => ({ value: 'opus' }))
    on('clock.now', () => ({ value: 1000 }))
    on('turn.complete', ($, e) => ({ text: e.answer }))
    on('session.measure', ($, e) => ({ changed: e.changed }))

    await $.turn.complete({ answer: 'Looked around.\nneeds input: which color should the die be?', durationMs: 5, isAborted: false, turnId: 't1', reason: 'answer' })
    expect(JSON.parse(writes.at(-1)!.text)).toMatchObject({ kind: 'background', jobId: 'abc123', state: 'blocked', reason: 'which color should the die be?' })

    await $.session.measure({
      context: { tokens: 50_000, window: 200_000, percent: 25 },
      rateLimits: [{ kind: 'five_hour', percentUsed: 41 }, { kind: 'seven_day', percentUsed: 23 }],
      changed: ['context', 'rateLimits'],
    })
    const usage = writes.find((w) => w.path.endsWith('/_usage.json'))
    expect(JSON.parse(usage!.text).rateLimits).toEqual([
      { kind: 'five_hour', percentUsed: 41 },
      { kind: 'seven_day', percentUsed: 23 },
    ])
    const own = writes.filter((w) => w.path.endsWith('/sess-bg.json')).at(-1)
    expect(JSON.parse(own!.text).context).toEqual({ percent: 25, tokens: 50_000, window: 200_000 })
  })
})
