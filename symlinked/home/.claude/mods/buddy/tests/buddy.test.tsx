import { describe, expect, mock, test } from 'claude-code/testing'

import { bones, card, newSeed, punk, sprite } from '../hooks/companion'
import { hex, keccak256 } from '../hooks/keccak'
import { PUNK_LEFT_EYES, PUNK_MOUTHS, PUNK_NOSES, PUNK_RIGHT_EYES, PUNK_TOPS } from '../hooks/punk-parts'

const BAND = {
  component: 'AbovePrompt',
  props: { hasSurvey: false, isWorking: false, maxRows: 20, bodyColumns: 100 } as never,
} as const

const AWAKE = { tick: 0, isPetting: false, isHatching: false }
const width = (line: string) => [...line].length

describe('companion', () => {
  test('keccak256 matches Ethereum', async () => {
    const k = (s: string) => hex(keccak256(new TextEncoder().encode(s)))
    expect(k('')).toBe('c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470')
    expect(k('abc')).toBe('4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45')
  })

  test("the contract's slot lists are all here, at the contract's sizes", async () => {
    expect([PUNK_TOPS.length, PUNK_LEFT_EYES.length, PUNK_RIGHT_EYES.length, PUNK_NOSES.length, PUNK_MOUTHS.length]).toEqual([55, 48, 48, 9, 32])
    for (const top of PUNK_TOPS) expect(top.map(width)).toEqual([12, 12, 12])
    for (const mouth of PUNK_MOUTHS) expect(mouth.map(width)).toEqual([12, 12])
  })

  test("a buddy is the contract's 12 by 12 draw", async () => {
    for (let i = 0; i < 50; i++) {
      const twin = punk(bones(newSeed()))
      expect(twin.length).toBe(12)
      for (const line of twin) expect(width(line)).toBe(12)
    }
  })

  test('a seed always draws the same buddy', async () => {
    const seed = newSeed()
    expect(bones(seed)).toEqual(bones(seed))
  })

  test('bones keep their slots in range and their rarity rules', async () => {
    for (let i = 0; i < 300; i++) {
      const b = bones(newSeed())
      expect(Object.keys(b.stats).length).toBe(5)
      expect(PUNK_TOPS).toContain(b.top)
      expect(PUNK_MOUTHS).toContain(b.mouth)
      if (b.rarity === 'legendary') expect(Math.max(...Object.values(b.stats))).toBe(100)
      expect(sprite(b, AWAKE)).toEqual(punk(b))
      expect(sprite(b, { ...AWAKE, isHatching: true }).length).toBe(12)
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
    expect(await ui.find({ type: 'Text', text: /├┐/ })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: /Pip/ })).toBeDefined()
    await ui.unmount()
  }

  const shown = await $.command.run({ command: 'buddy', args: 'card' } as never)
  expect(shown.text).toContain('Pip')
  expect(shown.text).toContain('SNARK')

  await $.command.run({ command: 'buddy', args: 'off' } as never)
  const hidden = await $.ui.mount({ plugin: 'buddy', surface: 'terminal', ...BAND })
  expect(await hidden.find({ type: 'Text', text: /Pip/ })).toBeUndefined()
})

test('card shows the punk, its name, and every stat', async () => {
  const b = bones(newSeed())
  const text = card({ ...b, name: 'Mochi', personality: 'naps on keyboards' })
  for (const s of ['Mochi', 'DEBUGGING', 'PATIENCE', 'CHAOS', 'WISDOM', 'SNARK', b.seed, ...punk(b)]) expect(text).toContain(s)
})
