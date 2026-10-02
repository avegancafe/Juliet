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

/** Wraps a bubble's text to at most `width` columns. */
export function wrap(text: string, width: number): string[] {
  const out: string[] = []
  let line = ''
  for (const word of text.split(/\s+/)) {
    if (line && line.length + word.length + 1 > width) {
      out.push(line)
      line = word
    } else line = line ? `${line} ${word}` : word
  }
  if (line) out.push(line)
  return out.slice(0, 3)
}
