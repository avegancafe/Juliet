import { describe, expect, test } from 'claude-code/testing'

// A reload of the module runs session.start again with fresh variables: the
// session's file must carry its state through, not reset it to idle.
describe('reload', () => {
  test('session.start resumes from the session file', async ($, on) => {
    const writes: { path: string; text: string }[] = []
    const before = {
      v: 1, sessionId: 'sess-r', jobId: 'r1', kind: 'background', cwd: '/work', model: 'opus',
      state: 'blocked', reason: 'pick a color', summary: 'pick color',
      context: { percent: 6, tokens: 60, window: 1000 }, rateLimits: [], updatedAt: 500,
    }
    on('fs.write', ($, e) => {
      writes.push(e)
      return { value: undefined }
    })
    on('fs.read', ($, e) => (e.path.endsWith('/sess-r.json') ? { value: JSON.stringify(before) } : { deny: 'no such file' }))
    on('process.run', () => ({ value: { exitCode: 0, stdout: '', stderr: '', isStdoutTruncated: false, isStderrTruncated: false } }))
    on('env.get', ($, e) => ({ value: e.name === 'HOME' ? '/home/t' : e.name === 'CLAUDE_JOB_DIR' ? '/home/t/.claude/jobs/r1' : undefined }))
    on('session.id', () => ({ value: 'sess-r' }))
    on('session.cwd', () => ({ value: '/work' }))
    on('session.model', () => ({ value: 'opus' }))
    on('clock.now', () => ({ value: 2000 }))
    on('session.start', ($, e) => ({ cwd: e.cwd }))

    await $.session.start({ cwd: '/work', surface: null, isInteractive: false })
    expect(JSON.parse(writes.at(-1)!.text)).toMatchObject({ state: 'blocked', reason: 'pick a color', context: { percent: 6 } })
  })
})
