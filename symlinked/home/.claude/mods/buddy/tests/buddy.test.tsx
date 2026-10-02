import { describe, expect, mock, test } from 'claude-code/testing'

import { bones, card, newSeed, seedFor, sprite, SPECIES } from '../hooks/companion'
import { BODIES, LEFT_EYES, RIGHT_EYES, TOPS } from '../hooks/sprites'

const BAND = {
  component: 'AbovePrompt',
  props: { hasSurvey: false, isWorking: false, maxRows: 20, bodyColumns: 100 } as never,
} as const

const AWAKE = { tick: 0, isPetting: false, isHatching: false, isWorking: false }

describe('companion', () => {
  test('every body, with every eye pair and mouth, fits 5 lines by 12 columns', async () => {
    expect(SPECIES.length).toBe(18)
    expect(LEFT_EYES.length).toBe(RIGHT_EYES.length)
    for (const [name, body] of Object.entries(BODIES)) {
      for (const frame of [body.base, body.fidget]) {
        expect(frame.length).toBe(5)
        expect(frame[0]).toBe('')
        expect(frame.some(l => l.includes('{L}'))).toBe(true)
        for (const mouth of body.mouths) {
          for (let e = 0; e < LEFT_EYES.length; e++) {
            for (const raw of frame) {
              const line = raw.replaceAll('{L}', LEFT_EYES[e]!).replaceAll('{R}', RIGHT_EYES[e]!).replaceAll('{M}', mouth)
              expect([...line].length <= 12 ? 'ok' : `${name}: "${line}"`).toBe('ok')
            }
          }
        }
      }
    }
    for (const top of TOPS) expect([...top].length <= 12 ? 'ok' : top).toBe('ok')
  })

  test('a seed always draws the same buddy', async () => {
    const seed = newSeed()
    expect(await bones(seed)).toEqual(await bones(seed))
  })

  test('bones keep their slots in range and their rarity rules', async () => {
    for (let i = 0; i < 300; i++) {
      const b = await bones(newSeed())
      expect(Object.keys(b.stats).length).toBe(5)
      expect(BODIES[b.species]!.mouths).toContain(b.mouth)
      if (b.rarity === 'common') expect(b.top).toBe('')
      if (b.rarity === 'legendary') expect(Math.max(...Object.values(b.stats))).toBe(100)
      expect(sprite(b, AWAKE).length).toBe(5)
    }
  })

  test('seedFor finds a seed that hatches the asked-for species', async () => {
    expect((await bones(await seedFor('owl'))).species).toBe('owl')
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
    expect(await ui.find({ type: 'Text', text: /┤/ })).toBeDefined()
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
  const text = card({ ...(await bones(await seedFor('cat'))), name: 'Mochi', personality: 'naps on keyboards' })
  for (const s of ['Mochi the cat', 'DEBUGGING', 'PATIENCE', 'CHAOS', 'WISDOM', 'SNARK', 'seed']) expect(text).toContain(s)
})
