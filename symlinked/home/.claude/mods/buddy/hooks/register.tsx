import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Pet } from '../types'

// [idle, blink, working] faces per species
export const SPECIES: Record<string, [string, string, string]> = {
  duck: ['<(o )___', '<(- )___', '<(° )___'],
  cat: ['(=^.^=)', '(=-.-=)', '(=°o°=)'],
  blob: ['( •ᴗ• )', '( -ᴗ- )', '( °□° )'],
  ghost: ['ᗣ( o o )', 'ᗣ( - - )', 'ᗣ( ° ° )'],
  crab: ['(\\/)(°,,°)(\\/)', '(\\/)(-,,-)(\\/)', '(\\/)(°□°)(\\/)'],
  owl: ['{O,O}', '{-,-}', '{@,@}'],
}
const NAMES = ['Pip', 'Mochi', 'Bean', 'Sprout', 'Nugget', 'Biscuit', 'Wren', 'Tofu']
const QUIPS: Record<string, string[]> = {
  Bash: ['ooh, a shell', 'careful with rm!', '*watches terminal*'],
  Edit: ['nice edit', 'tidy tidy', '*nods*'],
  Write: ['a whole new file!', 'writing!'],
  Read: ['reading along...', 'hmm interesting'],
  Grep: ['hunting...', 'sniff sniff'],
}
function pick<T>(xs: T[]): T {
  return xs[Math.floor(Math.random() * xs.length)]!
}
export const hatch = (): Pet => ({ species: pick(Object.keys(SPECIES)), name: pick(NAMES) })

const pet = atom({ plugin: 'buddy', key: 'pet' } as const, null)
const frame = atom({ plugin: 'buddy', key: 'frame' } as const, 0)
const says = atom({ plugin: 'buddy', key: 'says' } as const, null)
const isHidden = atom({ plugin: 'buddy', key: 'isHidden' } as const, false)

let quietAt = 0

async function say($: EngineInterface, text: string) {
  quietAt = (await $.clock.now()) + 4000
  await update($, says, () => text)
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    let mine = (await $.store.get('pet')) as Pet | undefined
    if (!mine) {
      mine = hatch()
      await $.store.set('pet', mine)
    }
    await update($, pet, () => mine)
    await $.command.register({ name: 'buddy', description: 'Pet your buddy (or: hide, show, hatch)' })
    // ponytail: one shared tick drives blink + bubble expiry; per-event timers if it ever matters
    $.clock.every(700, async () => {
      await update($, frame, n => n + 1)
      if (quietAt && (await $.clock.now()) > quietAt) {
        quietAt = 0
        await update($, says, () => null)
      }
    })
    return next(e)
  })

  on('command.run', { command: 'buddy' }, async ($, e) => {
    const arg = e.args.trim()
    if (arg === 'hide' || arg === 'show') {
      await update($, isHidden, () => arg === 'hide')
      return { text: arg === 'hide' ? 'Buddy is napping.' : 'Buddy is back!' }
    }
    if (arg === 'hatch') {
      const fresh = hatch()
      await $.store.set('pet', fresh)
      await update($, pet, () => fresh)
      await say($, 'hello world!')
      return { text: `A new ${fresh.species} hatched: ${fresh.name}!` }
    }
    await update($, isHidden, () => false)
    await say($, pick(['♥', '*purrs*', 'hehe', '♥ ♥ ♥']))
    return { text: 'You pet your buddy.' }
  })

  on('tool.call', async ($, e, next) => {
    const ran = await next(e)
    const quips = QUIPS[e.tool]
    if ('isError' in ran && ran.isError) await say($, 'uh oh :(')
    else if (quips && Math.random() < 0.4) await say($, pick(quips))
    return ran
  })

  on('turn.complete', async ($, e, next) => {
    if (Math.random() < 0.5) await say($, pick(['all done!', 'yay!', '*happy wiggle*', 'good job']))
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const mine = await read($, pet)
    if (e.props.hasSurvey || !mine || (await read($, isHidden))) return next(e)

    const { Box, Text } = $.ui.resolve(e)
    const faces = SPECIES[mine.species] ?? SPECIES.blob!
    const n = await read($, frame)
    const face = e.props.isWorking ? faces[2] : n % 6 === 5 ? faces[1] : faces[0]
    const bubble = await read($, says)

    return (
      <Box>
        <Text color="green">{face} </Text>
        <Text dimColor>{mine.name}</Text>
        {bubble ? <Text> “{bubble}”</Text> : null}
      </Box>
    )
  })
}
