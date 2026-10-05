import { describe, expect, mock, test } from 'claude-code/testing'

import { bones, bubbleLine, card, newSeed, punk, sprite, voice, wrap } from '../hooks/companion'
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
  on('model.complete', () => ({ value: { isAnswered: false, reason: 'empty-reply' } }) as never)
  // The engine's pane dock, in memory: whether the buddy pane is seated and shown.
  let isSeated = false
  on('ui.open', () => ({ value: { isPlaced: isSeated } }) as never)
  on('ui.close', () => ({ value: undefined }) as never)
  on('ui.panes', () =>
    ({ value: isSeated ? [{ id: 'buddy', title: 'Pip', isShown: true, isFocused: false, isPlaced: true }] : [] }) as never)
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  const PANE = {
    component: 'Pane',
    requestId: 'buddy',
    props: { title: 'Pip', isFocused: false, bodyColumns: 16, placement: 'dock', scroll: { offset: 0, bodyRows: 30 } } as never,
  } as const
  for (const surface of ['terminal', 'desktop'] as const) {
    // No pane seated (a narrow terminal): the band carries the one-line face.
    isSeated = false
    const flat = await $.ui.mount({ plugin: 'buddy', surface, ...BAND })
    expect(await flat.find({ type: 'Text', text: /├┐/ })).toBeUndefined()
    expect(await flat.find({ type: 'Text', text: /Pip/ })).toBeDefined()
    await flat.unmount()
    // Seated: the band steps aside and the pane draws the whole punk.
    isSeated = true
    const band = await $.ui.mount({ plugin: 'buddy', surface, ...BAND })
    expect(await band.find({ type: 'Text', text: /Pip/ })).toBeUndefined()
    await band.unmount()
    const pane = await $.ui.mount({ plugin: 'buddy', surface, ...PANE })
    // Off-terminal the punk is monospace SVG, since desktop Text is proportional.
    if (surface === 'terminal') expect(await pane.find({ type: 'Text', text: /├┐/ })).toBeDefined()
    else expect(String((await pane.find({ type: 'Svg' }))?.props.source)).toMatch(/├┐/)
    expect(await pane.find({ type: 'Text', text: /Pip/ })).toBeDefined()
    await pane.unmount()
  }
  isSeated = false

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

test("the card row keeps the punk's leading spaces and blank lines", async ($, on) => {
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)
    return <Box key="engine" />
  })
  const b = bones(newSeed())
  const text = card({ ...b, name: 'Mochi', personality: 'naps on keyboards' })
  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({
      plugin: 'buddy',
      surface,
      component: 'CommandOutput',
      props: { command: 'buddy', args: 'card', text, isErrored: false } as never,
    })
    const lines = (await ui.findAll({ type: 'Text' })).map(t => t.text)
    expect(lines.length).toBe(text.split('\n').length)
    for (const line of punk(b)) expect(lines).toContain(line.trim() ? line : ' ')
    await ui.unmount()
  }
})

test('the voice follows the stats, the personality and the face', async () => {
  const b = bones(newSeed())
  const snarky = voice({ ...b, stats: { DEBUGGING: 40, PATIENCE: 10, CHAOS: 30, WISDOM: 50, SNARK: 95 }, name: 'Zyx', personality: 'hoards semicolons' }, { width: 12, lines: 6 })
  expect(snarky).toContain('SNARK 95/100: extremely')
  expect(snarky).toContain('sarcastic')
  expect(snarky).toContain('impatient')
  expect(snarky).toContain('Lean hardest into SNARK')
  expect(snarky).toContain('hoards semicolons')
  expect(snarky).toContain('12 characters wide and 6 lines tall')
  for (const line of punk(b)) expect(snarky).toContain(line)
  const sweet = voice({ ...b, stats: { DEBUGGING: 40, PATIENCE: 90, CHAOS: 30, WISDOM: 50, SNARK: 5 }, name: 'Zyx', personality: 'x' }, { width: 40, lines: 1 })
  expect(sweet).toContain('earnest')
  expect(sweet).not.toContain('sarcastic')
  expect(sweet).toContain('40 characters wide and 1 line tall')
})

test("a finished turn puts the model's line, in its own voice, in the bubble", async ($, on) => {
  const clock = mock.clock(on)
  mock.store(on, { pet: { seed: newSeed(), name: 'Zyx', personality: 'hoards semicolons' } })
  on('command.register', (_, e) => ({ value: { command: e.name } }))
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)
    return <Box key="engine" />
  })
  on('ui.open', () => ({ value: { isPlaced: false, reason: 'narrow' } }) as never)
  on('ui.panes', () => ({ value: [] }) as never)
  const systems: string[] = []
  on('model.complete', (_, e) => {
    systems.push(e.system ?? '')
    return { value: { isAnswered: true, text: 'another semicolon, another day', usage: {} } } as never
  })
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  on('turn.complete', (_, e) => ({ text: e.answer }))
  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  await $.turn.complete({ answer: 'done', durationMs: 1500, isAborted: false, turnId: 't1', reason: 'answer' } as never)
  await clock.advance(1)
  expect(systems.length).toBe(1)
  expect(systems[0]).toContain('You are Zyx')
  const band = await $.ui.mount({ plugin: 'buddy', surface: 'terminal', ...BAND })
  expect(await band.find({ type: 'Text', text: /another semicolon/ })).toBeDefined()
})

test('only a plain line of a reply reaches the bubble', async () => {
  expect(bubbleLine('```\n ◙◙◙◙\n   ┌────┐\n```\nnice diff, i guess')).toBe('nice diff, i guess')
  expect(bubbleLine('"yo, add a test script."')).toBe('yo, add a test script.')
  expect(bubbleLine('```\n   ┌────┐\n```')).toBe(null)
})

test('a bubble wraps the whole quip to its width', async () => {
  const quip = 'oh the string isnt there? shocking. maybe read the file first next time.'
  const lines = wrap(quip, 12)
  for (const l of lines) expect([...l].length <= 12).toBe(true)
  expect(lines.join(' ')).toBe(quip)
  expect(wrap('supercalifragilistic', 8)).toEqual(['supercal', 'ifragili', 'stic'])
  const cut = wrap(quip, 12, 2)
  expect(cut.length).toBe(2)
  expect(cut[1]!.endsWith('…')).toBe(true)
})

test('a quip too long for the bubble goes back to the model once, with the measurements', async ($, on) => {
  const clock = mock.clock(on)
  mock.store(on, { pet: { seed: newSeed(), name: 'Zyx', personality: 'hoards semicolons' } })
  on('command.register', (_, e) => ({ value: { command: e.name } }))
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)
    return <Box key="engine" />
  })
  on('ui.open', () => ({ value: { isPlaced: false, reason: 'narrow' } }) as never)
  on('ui.panes', () => ({ value: [] }) as never)
  const prompts: string[] = []
  const LONG = 'this is a very long quip that rambles on and on and would never fit in a tiny speech bubble at all no way'
  on('model.complete', (_, e) => {
    prompts.push(e.prompt)
    return { value: { isAnswered: true, text: prompts.length === 1 ? LONG : 'too long. fine.', usage: {} } } as never
  })
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  on('turn.complete', (_, e) => ({ text: e.answer }))
  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  await $.turn.complete({ answer: 'done', durationMs: 1500, isAborted: false, turnId: 't1', reason: 'answer' } as never)
  await clock.advance(1)
  expect(prompts.length).toBe(2)
  expect(prompts[1]).toContain('Say it again, shorter.')
  expect(prompts[1]).toContain('characters')
  const band = await $.ui.mount({ plugin: 'buddy', surface: 'terminal', ...BAND })
  expect(await band.find({ type: 'Text', text: /too long\. fine\./ })).toBeDefined()
})
