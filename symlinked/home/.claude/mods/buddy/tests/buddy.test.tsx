import { describe, expect, mock, test } from 'claude-code/testing'

import { card, roll, sprite } from '../hooks/companion'
import { SPECIES } from '../hooks/sprites'

const BAND = {
  component: 'AbovePrompt',
  props: { hasSurvey: false, isWorking: false, maxRows: 20, bodyColumns: 100 } as never,
} as const

describe('companion', () => {
  test('every sprite frame is 5 lines, at most 12 columns, with eyes', async () => {
    for (const [name, frames] of Object.entries(SPECIES)) {
      for (const frame of frames) {
        expect(frame.length).toBe(5)
        for (const line of frame) expect(line.replaceAll('{E}', 'o').length <= 12 ? 'ok' : `${name}: ${line}`).toBe('ok')
        expect(frame.some(l => l.includes('{E}'))).toBe(true)
      }
    }
    expect(Object.keys(SPECIES).length).toBe(18)
  })

  test('a roll has five stats with a peak and a hat only above common', async () => {
    for (let i = 0; i < 200; i++) {
      const pet = roll()
      expect(Object.keys(pet.stats).length).toBe(5)
      if (pet.rarity === 'common') expect(pet.hat).toBe(null)
      if (pet.rarity === 'legendary') expect(Math.max(...Object.values(pet.stats))).toBe(100)
      expect(sprite(pet, { tick: 0, isPetting: false, isHatching: false, isWorking: false }).length).toBe(5)
    }
  })
})

test('an old buddy migrates, draws, shows its card, and hides', async ($, on) => {
  mock.clock(on)
  mock.store(on, { pet: { species: 'duck', name: 'Pip' } })
  on('command.register', (_, e) => ({ value: { command: e.name } }))
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)
    return <Box key="engine" />
  })
  on('command.run', () => ({ text: '' }))
  on('model.complete', () => ({ isAnswered: false, reason: 'empty-reply' }) as never)
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ plugin: 'buddy', surface, ...BAND })
    expect(await ui.find({ type: 'Text', text: /<\(. \)___/ })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: /Pip/ })).toBeDefined()
    await ui.unmount()
  }

  const shown = await $.command.run({ command: 'buddy', args: 'card' } as never)
  expect(shown.text).toContain('Pip the duck')
  expect(shown.text).toContain('SNARK')

  await $.command.run({ command: 'buddy', args: 'off' } as never)
  const hidden = await $.ui.mount({ plugin: 'buddy', surface: 'terminal', ...BAND })
  expect(await hidden.find({ type: 'Text', text: /Pip/ })).toBeUndefined()
})

test('card lists the name and every stat', async () => {
  const text = card(roll(Math.random, { species: 'cat', name: 'Mochi' }))
  for (const s of ['Mochi the cat', 'DEBUGGING', 'PATIENCE', 'CHAOS', 'WISDOM', 'SNARK']) expect(text).toContain(s)
})
