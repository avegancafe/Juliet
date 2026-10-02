import { expect, mock, test } from 'claude-code/testing'

const BAND = { component: 'AbovePrompt', props: { hasSurvey: false, isWorking: false, maxRows: 10, columns: 80 } } as const

test('buddy shows, reacts to /buddy, and hides', async ($, on) => {
  mock.clock(on)
  mock.store(on, { pet: { species: 'duck', name: 'Pip' } })
  on('command.register', (_, e) => ({ value: { command: e.name } }))
  on('ui.render', ($, e) => { const { Box } = $.ui.resolve(e); return <Box key="engine" /> })
  on('command.run', () => ({ text: '' }))
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ plugin: 'buddy', surface, ...BAND })
    expect(await ui.find({ type: 'Text', text: /<\(o \)___/ })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: 'Pip' })).toBeDefined()
    await ui.unmount()
  }

  await $.command.run({ command: 'buddy', args: '' })
  const petted = await $.ui.mount({ plugin: 'buddy', surface: 'terminal', ...BAND })
  expect(await petted.find({ type: 'Text', text: /“/ })).toBeDefined()
  await petted.unmount()

  await $.command.run({ command: 'buddy', args: 'hide' })
  const hidden = await $.ui.mount({ plugin: 'buddy', surface: 'terminal', ...BAND })
  expect(await hidden.find({ type: 'Text', text: 'Pip' })).toBeUndefined()
})
