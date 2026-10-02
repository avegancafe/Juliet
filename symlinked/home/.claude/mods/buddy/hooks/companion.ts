import type { Bones, Pet } from '../types'

import { hex, keccak256, unhex } from './keccak'
import {
  PUNK_CHIN, PUNK_FOREHEAD, PUNK_LEFT_EYES, PUNK_LEFT_FACE, PUNK_MOUTHS, PUNK_NECK, PUNK_NOSE_LEFT,
  PUNK_NOSE_RIGHT, PUNK_NOSES, PUNK_RIGHT_EYES, PUNK_RIGHT_FACE, PUNK_TOPS,
} from './punk-parts'

export const RARITIES = ['common', 'uncommon', 'rare', 'epic', 'legendary'] as const
const WEIGHTS = [60, 25, 10, 4, 1]
const FLOORS = [5, 15, 25, 35, 50]
export const STATS = ['DEBUGGING', 'PATIENCE', 'CHAOS', 'WISDOM', 'SNARK'] as const
export const RARITY_COLOR = ['gray', 'green', 'blue', 'magenta', 'yellow']
const RAINBOW = ['red', 'yellow', 'green', 'cyan', 'blue', 'magenta']

export const NAMES = ['Pip', 'Mochi', 'Bean', 'Sprout', 'Nugget', 'Biscuit', 'Wren', 'Tofu', 'Pickle', 'Gizmo', 'Dumpling', 'Sprocket']

// The egg sits where the punk's chin and neck will be.
const EGG = [
  ['    ┌──┐    ', '   ┌┘  └┐   ', '   └┐  ┌┘   ', '    └──┘    '],
  ['    ┌──┐    ', '   ┌┘╲╱└┐   ', '   └┐  ┌┘   ', '    └──┘    '],
  ['    ┌╲╱┐    ', '   ┌┘╲╱└┐   ', '   └┐╱╲┌┘   ', '    └──┘    '],
]
const HEARTS = ['   ♥    ♥   ', '  ♥  ♥  ♥   ', ' ♥   ♥   ♥  ', '   ♥  ♥     ']
// Every 500ms tick: true blinks.
const BLINKS = [8, 18]
const IDLE_TICKS = 20

export function pick<T>(xs: readonly T[], rand = Math.random): T {
  return xs[Math.floor(rand() * xs.length)]!
}

export function newSeed(): string {
  return hex(crypto.getRandomValues(new Uint8Array(32)))
}

/** The contract's `uint256(keccak256(abi.encodePacked(seed)))`: the seed's 32 bytes, hashed once. */
const hash = (seed: string) => BigInt(`0x${hex(keccak256(unhex(seed)))}`)

const slot = (rand: bigint, count: number) => Number(rand % BigInt(count))

/** Everything about a buddy but its name and personality, from its seed alone. */
export function bones(seed: string): Bones {
  const rand = hash(seed)
  // As in the contract, every part reads the same `rand`; rarity and stats
  // read its higher bytes so they don't move in step with the face.
  let roll = slot(rand >> 128n, 100)
  let tier = 0
  while (tier < WEIGHTS.length - 1 && roll >= WEIGHTS[tier]!) roll -= WEIGHTS[tier++]!
  const eye = slot(rand, PUNK_LEFT_EYES.length)
  const floor = FLOORS[tier]!
  const byte = (i: number) => slot(rand >> BigInt(136 + i * 8), 256)
  const order = STATS.map((s, i) => [s, byte(i)] as const).sort((a, b) => a[1] - b[1]).map(([s]) => s)
  const stats = Object.fromEntries(
    STATS.map((s, i) => {
      const jitter = byte(5 + i) / 256
      const value =
        s === order[4] ? (tier === 4 ? 100 : Math.min(100, floor + 50 + Math.floor(jitter * 30)))
        : s === order[0] ? floor + Math.floor(jitter * 10)
        : floor + Math.floor(jitter * 40)
      return [s, value]
    }),
  )
  return {
    seed,
    rarity: RARITIES[tier]!,
    top: PUNK_TOPS[slot(rand, PUNK_TOPS.length)]!,
    eyes: [PUNK_LEFT_EYES[eye]!, PUNK_RIGHT_EYES[eye]!],
    nose: PUNK_NOSES[slot(rand, PUNK_NOSES.length)]!,
    mouth: PUNK_MOUTHS[slot(rand, PUNK_MOUTHS.length)]!,
    isShiny: slot(rand >> 64n, 100) === 0,
    stats,
  }
}

export function peakStat(pet: Bones): string {
  return Object.entries(pet.stats).sort((a, b) => b[1] - a[1])[0]![0]
}

/** The contract's `draw(seed)`, line for line: top, forehead, eyes, nose, mouth, chin, neck. */
export function punk(pet: Bones, isBlinking = false): string[] {
  const [l, r] = isBlinking ? ['─', '─'] : pet.eyes
  return [
    ...pet.top,
    PUNK_FOREHEAD,
    `${PUNK_LEFT_FACE}${l} ${r}${PUNK_RIGHT_FACE}`,
    `${PUNK_NOSE_LEFT}${pet.nose}${PUNK_NOSE_RIGHT}`,
    ...pet.mouth,
    ...PUNK_CHIN,
    ...PUNK_NECK,
  ]
}

export type Moment = { tick: number; isPetting: boolean; isHatching: boolean }

/** The punk for this moment: blinking now and then, hearts while petted, an egg while hatching. */
export function sprite(pet: Bones, m: Moment): string[] {
  if (m.isHatching) return [...Array(8).fill(' '.repeat(12)), ...EGG[m.tick % EGG.length]!]
  const lines = punk(pet, BLINKS.includes(m.tick % IDLE_TICKS))
  if (m.isPetting) lines[0] = HEARTS[m.tick % HEARTS.length]!
  return lines
}

/** One-line face for a short or narrow band: the eye line. */
export function face(pet: Bones): string {
  return punk(pet)[4]!.trim()
}

export function color(pet: Bones, tick: number): string {
  return pet.isShiny ? RAINBOW[tick % RAINBOW.length]! : RARITY_COLOR[RARITIES.indexOf(pet.rarity)]!
}

export function card(pet: Pet): string {
  const tier = RARITIES.indexOf(pet.rarity)
  const bars = STATS.map(s => {
    const v = pet.stats[s] ?? 0
    return `${s.padEnd(10)} ${'█'.repeat(Math.round(v / 10)).padEnd(10, '░')} ${v}`
  })
  return [
    `${'★'.repeat(tier + 1)} ${pet.rarity.toUpperCase()}${pet.isShiny ? '  ✨ SHINY' : ''}`,
    ...punk(pet),
    pet.name,
    `"${pet.personality}"`,
    '',
    ...bars,
    '',
    `seed 0x${pet.seed}`,
  ].join('\n')
}

/**
 * Wraps a bubble's text to `width` columns and at most `maxLines` lines: a word
 * longer than a line is broken, and text past the last line ends it with `…`.
 */
export function wrap(text: string, width: number, maxLines = Infinity): string[] {
  const out: string[] = []
  let line = ''
  for (let word of text.split(/\s+/).filter(Boolean)) {
    while ([...word].length > width) {
      if (line) out.push(line)
      out.push([...word].slice(0, width).join(''))
      word = [...word].slice(width).join('')
      line = ''
    }
    if (line && [...line].length + [...word].length + 1 > width) {
      out.push(line)
      line = word
    } else line = line ? `${line} ${word}` : word
  }
  if (line) out.push(line)
  if (out.length <= maxLines) return out
  const kept = out.slice(0, Math.max(1, maxLines))
  kept[kept.length - 1] = `${[...kept[kept.length - 1]!].slice(0, width - 1).join('')}…`
  return kept
}

// What each stat means for how the buddy talks, from its lowest to its highest reading.
const TRAITS: Record<string, [low: string, high: string]> = {
  DEBUGGING: ['has no idea how code works and guesses wildly', 'spots the actual bug and names the concrete fix'],
  PATIENCE: ['is openly impatient about slow turns and long waits', 'is serene, unhurried, and encouraging'],
  CHAOS: ['is orderly and literal', 'goes on odd tangents and non sequiturs'],
  WISDOM: ['says naive, obvious things', 'drops a real insight about the work'],
  SNARK: ['is earnest and sweet', 'is dry, sarcastic, and teasing'],
}

const degree = (v: number) => (v >= 80 ? 'extremely' : v >= 60 ? 'clearly' : v >= 35 ? 'a bit' : 'not at all')

/** The system prompt that makes a buddy sound like its own stats, personality and face. */
export function voice(pet: Pet): string {
  const ranked = [...STATS].sort((a, b) => (pet.stats[b] ?? 0) - (pet.stats[a] ?? 0))
  const traits = STATS.map(s => {
    const v = pet.stats[s] ?? 0
    const [low, high] = TRAITS[s]!
    return `- ${s} ${v}/100: ${v >= 50 ? `${degree(v)} — ${high}` : `${degree(100 - v)} the opposite — ${low}`}`
  }).join('\n')
  return [
    `You are ${pet.name}, a ${pet.rarity}${pet.isShiny ? ', shiny' : ''} ASCII punk: a tiny box-drawn face that lives in a`,
    "pane beside a developer's terminal, watching them work with Claude. This is you:",
    '',
    ...punk(pet),
    '',
    `Personality: ${pet.personality}`,
    'How your stats shape your voice:',
    traits,
    `Lean hardest into ${ranked[0]}; your ${ranked[4]} barely shows.`,
    '',
    'You are not Claude and not an assistant; you are a pet with opinions. Reply with ONE speech-bubble line,',
    'under 14 words, lowercase, no quotes, no emoji, no hashtags. React to what just happened in character.',
    'Be specific to the situation, never generic. Your look (eyes, hat, mouth) may color what you say.',
    'Words only: never draw, never repeat your picture, no code fences.',
  ].join('\n')
}

/** The one plain line of a reply that may go in the bubble: no art, fences or quotes; null if none. */
export function bubbleLine(reply: string): string | null {
  const line = reply
    .split('\n')
    .map(l => l.trim())
    .find(l => l && !l.startsWith('```') && !/[\u2500-\u259F\u25A0-\u25FF]/.test(l))
  return line ? line.replace(/^["'“]|["'”]$/g, '') : null
}
