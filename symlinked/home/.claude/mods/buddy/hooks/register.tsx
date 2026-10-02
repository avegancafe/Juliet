import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Pet } from '../types'

import { card, color, face, peakStat, pick, roll, sprite, STATS, wrap } from './companion'

const pet = atom({ plugin: 'buddy', key: 'pet' } as const, null)
const tick = atom({ plugin: 'buddy', key: 'tick' } as const, 0)
const says = atom({ plugin: 'buddy', key: 'says' } as const, null)
const isHidden = atom({ plugin: 'buddy', key: 'isHidden' } as const, false)
const isMuted = atom({ plugin: 'buddy', key: 'isMuted' } as const, false)

const TICK_MS = 500
const BUBBLE_MS = 10_000
const PET_MS = 2_500
const HATCH_MS = 3_000
// ponytail: fixed model-call cooldown; make it an option if it's too chatty or too quiet
const CHIRP_COOLDOWN_MS = 30_000

const ERROR_QUIPS = ['uh oh', 'that one stung', '*hides behind input box*', 'we do not talk about that', 'have you tried reading the error']
const PET_QUIPS = ['♥', '*happy wiggle*', 'hehe', 'again again', '*purrs, regardless of species*']

let bubbleUntil = 0
let petUntil = 0
let hatchUntil = 0
let lastChirpAt = 0
let lastPrompt = ''

async function say($: EngineInterface, text: string) {
  if (await read($, isMuted)) return
  bubbleUntil = (await $.clock.now()) + BUBBLE_MS
  await update($, says, () => text)
}

async function chirp($: EngineInterface, situation: string, isForced = false) {
  const mine = await read($, pet)
  const now = await $.clock.now()
  if (!mine || (await read($, isHidden)) || (await read($, isMuted))) return
  if (!isForced && now - lastChirpAt < CHIRP_COOLDOWN_MS) return
  lastChirpAt = now
  const stats = STATS.map(s => `${s} ${mine.stats[s]}`).join(', ')
  const r = await $.model.complete({
    model: 'haiku',
    maxTokens: 60,
    effort: 'low',
    system:
      `You are ${mine.name}, a tiny ${mine.rarity} ${mine.species} who lives beside the input box of a developer's terminal, ` +
      `watching them work with Claude. Personality: ${mine.personality}. Stats (0-100): ${stats}. ` +
      'You are not Claude and not an assistant. Reply with ONE speech-bubble line under 14 words, lowercase, ' +
      'no quotes, no emoji, in character. Usually a dry little observation; sometimes a small genuinely useful ' +
      'insight about what just happened. High SNARK is snarkier, high CHAOS weirder, high WISDOM wiser.',
    prompt: situation,
  })
  if (r.isAnswered && r.text.trim()) await say($, r.text.trim().replace(/^["']|["']$/g, '').slice(0, 120))
}

async function hatch($: EngineInterface, keep: Partial<Pet> = {}): Promise<Pet> {
  hatchUntil = (await $.clock.now()) + HATCH_MS
  await update($, isHidden, () => false)
  await $.store.set('isHidden', false)
  let fresh = roll(Math.random, keep)
  await update($, pet, () => fresh)
  if (!keep.name) {
    const stats = Object.entries(fresh.stats).sort((a, b) => a[1] - b[1])
    const r = await $.model.complete({
      model: 'haiku',
      maxTokens: 100,
      effort: 'low',
      system: 'You name tiny terminal pets. Reply with only a JSON object.',
      prompt:
        `A ${fresh.rarity} ${fresh.species} just hatched in a developer's terminal. Strongest stat ${peakStat(fresh)}, ` +
        `weakest ${stats[0]![0]}. Reply {"name": "<short cute name>", "personality": "<one lowercase sentence under 12 words, specific and a little odd>"}`,
    })
    try {
      const soul = r.isAnswered ? JSON.parse(r.text.match(/\{[\s\S]*\}/)?.[0] ?? '') : null
      if (typeof soul?.name === 'string' && typeof soul?.personality === 'string') {
        fresh = { ...fresh, name: soul.name.slice(0, 16), personality: soul.personality.slice(0, 100) }
      }
    } catch {
      // keep the rolled fallback name and personality
    }
  }
  await $.store.set('pet', fresh)
  await update($, pet, () => fresh)
  await say($, `hi! i'm ${fresh.name}.`)
  return fresh
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    let mine = (await $.store.get('pet')) as Pet | Partial<Pet> | undefined
    // A buddy from the first version of this mod has no rarity: re-roll its bones, keep its name.
    if (mine && !mine.rarity) {
      mine = roll(Math.random, { species: mine.species, name: mine.name })
      await $.store.set('pet', mine)
    }
    await update($, pet, () => (mine as Pet | undefined) ?? null)
    const [hidden, muted] = await Promise.all([$.store.get('isHidden'), $.store.get('isMuted')])
    await update($, isHidden, () => hidden === true)
    await update($, isMuted, () => muted === true)
    await $.command.register({ name: 'buddy', description: 'Your terminal buddy: pet, card, mute, unmute, off, on, hatch' })
    $.clock.every(TICK_MS, async () => {
      await update($, tick, n => n + 1)
      if (bubbleUntil && (await $.clock.now()) > bubbleUntil) {
        bubbleUntil = 0
        await update($, says, () => null)
      }
    })
    return next(e)
  })

  on('command.run', { command: 'buddy' }, async ($, e) => {
    const arg = e.args.trim().toLowerCase()
    const mine = await read($, pet)
    if (!mine || arg === 'hatch') {
      const fresh = await hatch($)
      return { text: `A ${fresh.rarity} ${fresh.species} hatched: ${fresh.name}!\n\n${card(fresh)}` }
    }
    if (arg === 'off' || arg === 'on') {
      await update($, isHidden, () => arg === 'off')
      await $.store.set('isHidden', arg === 'off')
      return { text: arg === 'off' ? `${mine.name} is napping. /buddy on to wake them.` : `${mine.name} is back!` }
    }
    if (arg === 'mute' || arg === 'unmute') {
      await update($, isMuted, () => arg === 'mute')
      await $.store.set('isMuted', arg === 'mute')
      if (arg === 'mute') await update($, says, () => null)
      return { text: arg === 'mute' ? `${mine.name} will keep their thoughts to themselves.` : `${mine.name} has opinions again.` }
    }
    if (arg === 'pet') {
      petUntil = (await $.clock.now()) + PET_MS
      await update($, isHidden, () => false)
      await say($, pick(PET_QUIPS))
      return { text: `You pet ${mine.name}.` }
    }
    return { text: card(mine) }
  })

  on('prompt.compose', async ($, e, next) => {
    const result = await next(e)
    const mine = await read($, pet)
    if (!mine || (await read($, isHidden))) return result
    const text =
      `A small ${mine.species} named ${mine.name} sits beside the user's input box and occasionally comments in a speech bubble. ` +
      `You are not ${mine.name}; it is a separate watcher with its own voice. When the user addresses ${mine.name} directly, ` +
      `its bubble answers. Keep your own reply to one short line then, or answer only the part meant for you. ` +
      `Don't explain that you aren't ${mine.name}, and never speak for it.`
    return { ...result, sections: [...result.sections, { id: 'buddy:companion', text, scope: 'session' as const }] }
  })

  on('prompt.submit', async ($, e, next) => {
    lastPrompt = e.text
    const mine = await read($, pet)
    if (mine && new RegExp(`\\b${mine.name.replace(/\W/g, '')}\\b`, 'i').test(e.text)) {
      void chirp($, `The developer just said to you: "${e.text.slice(0, 500)}". Answer them.`, true)
    }
    return next(e)
  })

  on('tool.call', async ($, e, next) => {
    const ran = await next(e)
    if (!e.agentId && 'isError' in ran && ran.isError) await say($, pick(ERROR_QUIPS))
    return ran
  })

  on('turn.complete', async ($, e, next) => {
    if (!e.agentId && !e.isAborted && e.durationMs > 4000) {
      void chirp(
        $,
        `The developer asked Claude: "${lastPrompt.slice(0, 400)}"\n` +
          `After ${Math.round(e.durationMs / 1000)}s Claude answered: "${e.answer.slice(0, 600)}"\nReact.`,
      )
    }
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const mine = await read($, pet)
    if (e.props.hasSurvey || !mine || (await read($, isHidden))) return next(e)

    const { Box, Text } = $.ui.resolve(e)
    const n = await read($, tick)
    const now = await $.clock.now()
    const bubble = (await read($, isMuted)) ? null : await read($, says)
    const tint = color(mine, n)

    if (e.props.maxRows < 7 || e.props.bodyColumns < 40) {
      return (
        <Box>
          <Text color={tint}>{face(mine)} </Text>
          <Text dimColor>{mine.name}</Text>
          {bubble ? <Text> “{bubble}”</Text> : null}
        </Box>
      )
    }

    const lines = sprite(mine, {
      tick: n,
      isPetting: now < petUntil,
      isHatching: now < hatchUntil,
      isWorking: e.props.isWorking,
    })
    const width = Math.max(12, Math.min(36, e.props.bodyColumns - 20))

    return (
      <Box flexDirection="row" justifyContent="flex-end" alignItems="flex-end">
        {bubble ? (
          <Box key="bubble" flexDirection="column" borderStyle="round" borderDimColor paddingX={1} marginRight={1}>
            {wrap(bubble, width).map((l, i) => (
              <Text key={`b${i}`}>{l}</Text>
            ))}
          </Box>
        ) : null}
        <Box key="pet" flexDirection="column" width={12}>
          {lines.map((l, i) => (
            <Text key={`s${i}`} color={tint}>
              {l}
            </Text>
          ))}
          <Text key="name" dimColor>
            {mine.name.slice(0, 12).padStart(6 + Math.ceil(mine.name.length / 2))}
          </Text>
        </Box>
      </Box>
    )
  })
}
