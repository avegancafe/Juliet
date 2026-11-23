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
    on('fs.read', () => ({ deny: 'no such file' }))
    on('turn.complete', ($, e) => ({ text: e.answer }))
    on('session.measure', ($, e) => ({ changed: e.changed }))
    on('tool.check', () => ({ decision: 'ask' }))
    on('tool.call', () => ({ result: 'ok' }))

    await $.turn.complete({ answer: 'Looked around.\nneeds input: which color should the die be?', durationMs: 5, isAborted: false, turnId: 't1', reason: 'answer' })
    expect(JSON.parse(writes.at(-1)!.text)).toMatchObject({ kind: 'background', jobId: 'abc123', state: 'blocked', reason: 'which color should the die be?' })

    // A check with nothing to prompt for keeps the real reason: a query (no call),
    // a subagent's call, a call nobody can be asked about...
    await $.tool.check({ tool: 'Bash', input: { command: 'ls' }, approver: 'person' })
    await $.tool.check({ tool: 'Bash', input: { command: 'ls' }, tool_use_id: 'u0', agentId: 'sub-1', approver: 'person' })
    await $.tool.check({ tool: 'Bash', input: { command: 'ls' }, tool_use_id: 'u0' })
    expect(JSON.parse(writes.at(-1)!.text).reason).toBe('which color should the die be?')
    // ...but a permission prompt on the session's own call blocks it,
    await $.tool.check({ tool: 'Bash', input: { command: 'rm -rf build' }, tool_use_id: 'u1', approver: 'person' })
    expect(JSON.parse(writes.at(-1)!.text)).toMatchObject({ state: 'blocked', reason: 'permission: Bash' })
    // and the call running means it was answered.
    await $.tool.call({ tool: 'Bash', command: 'rm -rf build' })
    expect(JSON.parse(writes.at(-1)!.text)).toMatchObject({ state: 'working' })

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
