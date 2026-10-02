import type { Bones, Pet } from '../types'

import { hex, keccak256, unhex } from './keccak'
import {
  PUNK_CHIN, PUNK_FOREHEAD, PUNK_LEFT_EYES, PUNK_LEFT_FACE, PUNK_MOUTHS, PUNK_NECK, PUNK_NOSE_LEFT,
  PUNK_NOSE_RIGHT, PUNK_NOSES, PUNK_RIGHT_EYES, PUNK_RIGHT_FACE, PUNK_TOPS,
} from './punk-parts'
import { BODIES, EGG, HEARTS, IDLE } from './sprites'

const ANIMALS = Object.keys(BODIES)
export const SPECIES = [...ANIMALS, 'punk']
export const RARITIES = ['common', 'uncommon', 'rare', 'epic', 'legendary'] as const
const WEIGHTS = [60, 25, 10, 4, 1]
const FLOORS = [5, 15, 25, 35, 50]
export const STATS = ['DEBUGGING', 'PATIENCE', 'CHAOS', 'WISDOM', 'SNARK'] as const
export const RARITY_COLOR = ['gray', 'green', 'blue', 'magenta', 'yellow']
const RAINBOW = ['red', 'yellow', 'green', 'cyan', 'blue', 'magenta']

export const NAMES = ['Pip', 'Mochi', 'Bean', 'Sprout', 'Nugget', 'Biscuit', 'Wren', 'Tofu', 'Pickle', 'Gizmo', 'Dumpling', 'Sprocket']

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
  // As in the contract, every look slot reads the same `rand`; rarity and stats
  // read its higher bytes so they don't move in step with the species.
  let roll = slot(rand >> 128n, 100)
  let tier = 0
  while (tier < WEIGHTS.length - 1 && roll >= WEIGHTS[tier]!) roll -= WEIGHTS[tier++]!
  const species = SPECIES[slot(rand, SPECIES.length)]!
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
  const mouths = BODIES[species]?.mouths ?? ['']
  return {
    seed,
    species,
    rarity: RARITIES[tier]!,
    eyes: [PUNK_LEFT_EYES[eye]!, PUNK_RIGHT_EYES[eye]!],
    mouth: mouths[slot(rand, mouths.length)]!,
    top: PUNK_TOPS[slot(rand, PUNK_TOPS.length)]!,
    nose: PUNK_NOSES[slot(rand, PUNK_NOSES.length)]!,
    punkMouth: PUNK_MOUTHS[slot(rand, PUNK_MOUTHS.length)]!,
    isShiny: slot(rand >> 64n, 100) === 0,
    stats,
  }
}

/** The species a pre-keccak (SHA-256, 18 species) seed hatched, so a migration keeps it. */
export async function legacySpecies(seed: string): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(seed))
  return ANIMALS[Number(BigInt(`0x${hex(new Uint8Array(digest))}`) % BigInt(ANIMALS.length))]!
}

/** A seed whose bones are this species, found the way the buddy salt was: by trying. */
export function seedFor(species: string): string {
  for (;;) {
    const seed = newSeed()
    if (bones(seed).species === species) return seed
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
    ...pet.punkMouth,
    ...PUNK_CHIN,
    ...PUNK_NECK,
  ]
}

export type Moment = { tick: number; isPetting: boolean; isHatching: boolean; isWorking: boolean }

function paint(line: string, pet: Bones, isBlinking: boolean): string {
  const [l, r] = isBlinking ? ['─', '─'] : pet.eyes
  return line.replaceAll('{L}', l).replaceAll('{R}', r).replaceAll('{M}', pet.mouth)
}

/** The sprite for this moment: the punk's 12 lines, or a top over an animal's 4. */
export function sprite(pet: Bones, m: Moment): string[] {
  const step = IDLE[m.tick % IDLE.length]!
  const isBlinking = step === -1 && !m.isWorking
  const body = BODIES[pet.species]
  // Working: fidget every other tick, eyes open.
  const isFidget = m.isWorking ? m.tick % 2 === 1 : step === 1
  const lines = body
    ? [...pet.top, ...(isFidget ? body.fidget : body.base).slice(1).map(l => paint(l, pet, isBlinking))]
    : punk(pet, isBlinking)
  if (m.isHatching) return [...lines.slice(0, lines.length - 4).map(() => ''), ...EGG[m.tick % EGG.length]!.slice(1)].map(l => l.padEnd(12))
  if (m.isPetting) lines[0] = HEARTS[m.tick % HEARTS.length]!
  return lines.map(l => l.padEnd(12))
}

/** One-line face for a short or narrow band. */
export function face(pet: Bones): string {
  const body = BODIES[pet.species]
  return body ? paint(body.base.find(l => l.includes('{L}'))!.trim(), pet, false) : punk(pet)[4]!.trim()
}

export function color(pet: Bones, tick: number): string {
  return pet.isShiny ? RAINBOW[tick % RAINBOW.length]! : RARITY_COLOR[RARITIES.indexOf(pet.rarity)]!
}

export function card(pet: Pet): string {
  const tier = RARITIES.indexOf(pet.rarity)
  const art = sprite(pet, { tick: 0, isPetting: false, isHatching: false, isWorking: false })
  const twin = punk(pet)
  // Side by side: the buddy, then the ASCIIPunk its seed draws.
  const height = Math.max(art.length, twin.length)
  const pad = (xs: string[]) => [...Array(height - xs.length).fill(''), ...xs].map(l => l.padEnd(12))
  const gallery = pet.species === 'punk' ? twin : pad(art).map((l, i) => `${l}    ${pad(twin)[i]}`)
  const bars = STATS.map(s => {
    const v = pet.stats[s] ?? 0
    return `${s.padEnd(10)} ${'█'.repeat(Math.round(v / 10)).padEnd(10, '░')} ${v}`
  })
  return [
    `${'★'.repeat(tier + 1)} ${pet.rarity.toUpperCase()}${pet.isShiny ? '  ✨ SHINY' : ''}`,
    ...gallery,
    pet.species === 'punk' ? `${pet.name} the punk` : `${pet.name} the ${pet.species}`.padEnd(16) + 'and their punk twin',
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
