import type { Pet } from '../types'

import { EGG, EYES, HATS, HEARTS, IDLE, SPECIES } from './sprites'

export const RARITIES = ['common', 'uncommon', 'rare', 'epic', 'legendary'] as const
const WEIGHTS = [60, 25, 10, 4, 1]
const FLOORS = [5, 15, 25, 35, 50]
export const STATS = ['DEBUGGING', 'PATIENCE', 'CHAOS', 'WISDOM', 'SNARK'] as const
// Hats a rarity may roll, cumulative: uncommon gets the first three, legendary all.
const HAT_POOL = ['crown', 'tophat', 'propeller', 'halo', 'wizard', 'beanie', 'tinyduck']
const HATS_BY_RARITY = [0, 3, 5, 6, 7]
export const RARITY_COLOR = ['gray', 'green', 'blue', 'magenta', 'yellow']
const RAINBOW = ['red', 'yellow', 'green', 'cyan', 'blue', 'magenta']

const NAMES = ['Pip', 'Mochi', 'Bean', 'Sprout', 'Nugget', 'Biscuit', 'Wren', 'Tofu', 'Pickle', 'Gizmo', 'Dumpling', 'Sprocket']

export function pick<T>(xs: readonly T[], rand = Math.random): T {
  return xs[Math.floor(rand() * xs.length)]!
}

export function roll(rand = Math.random, keep: Partial<Pet> = {}): Pet {
  let r = rand() * 100
  let tier = 0
  while (tier < WEIGHTS.length - 1 && r >= WEIGHTS[tier]!) r -= WEIGHTS[tier++]!
  const floor = FLOORS[tier]!
  const [peak, dump] = [...STATS].sort(() => rand() - 0.5)
  const stats = Object.fromEntries(
    STATS.map(s => [
      s,
      s === peak
        ? tier === 4 ? 100 : Math.min(100, floor + 50 + Math.floor(rand() * 30))
        : s === dump
          ? floor + Math.floor(rand() * 10)
          : floor + Math.floor(rand() * 40),
    ]),
  )
  const hats = HAT_POOL.slice(0, HATS_BY_RARITY[tier])
  const species = keep.species && SPECIES[keep.species] ? keep.species : pick(Object.keys(SPECIES), rand)
  return {
    species,
    rarity: RARITIES[tier]!,
    eye: pick(EYES, rand),
    hat: hats.length ? pick(hats, rand) : null,
    isShiny: rand() < 0.01,
    stats,
    name: keep.name ?? pick(NAMES, rand),
    personality: keep.personality ?? 'quietly judges your variable names',
  }
}

export function peakStat(pet: Pet): string {
  return Object.entries(pet.stats).sort((a, b) => b[1] - a[1])[0]![0]
}

export type Moment = { tick: number; isPetting: boolean; isHatching: boolean; isWorking: boolean }

/** The sprite's five lines for this moment. */
export function sprite(pet: Pet, m: Moment): string[] {
  const step = IDLE[m.tick % IDLE.length]!
  // Working: fidget faster, no blinking.
  const index = m.isWorking ? (m.tick % 3) : Math.max(0, step)
  const frames = m.isHatching ? EGG : (SPECIES[pet.species] ?? SPECIES.blob!)
  const eye = step === -1 && !m.isWorking ? '-' : pet.eye
  const lines = frames[m.isHatching ? m.tick % 3 : index]!.map(l => l.replaceAll('{E}', eye))
  if (m.isPetting) lines[0] = HEARTS[m.tick % HEARTS.length]!
  else if (!m.isHatching && !lines[0] && pet.hat) lines[0] = HATS[pet.hat] ?? ''
  return lines.map(l => l.padEnd(12))
}

/** One-line face for a short or narrow band. */
export function face(pet: Pet): string {
  const frames = SPECIES[pet.species] ?? SPECIES.blob!
  return frames[0].find(l => l.includes('{E}'))!.trim().replaceAll('{E}', pet.eye)
}

export function color(pet: Pet, tick: number): string {
  return pet.isShiny ? RAINBOW[tick % RAINBOW.length]! : RARITY_COLOR[RARITIES.indexOf(pet.rarity)]!
}

export function card(pet: Pet): string {
  const tier = RARITIES.indexOf(pet.rarity)
  const art = sprite(pet, { tick: 0, isPetting: false, isHatching: false, isWorking: false })
  const bars = STATS.map(s => {
    const v = pet.stats[s] ?? 0
    return `${s.padEnd(10)} ${'█'.repeat(Math.round(v / 10)).padEnd(10, '░')} ${v}`
  })
  return [
    `${'★'.repeat(tier + 1)} ${pet.rarity.toUpperCase()}${pet.isShiny ? '  ✨ SHINY' : ''}`,
    ...art,
    `${pet.name} the ${pet.species}${pet.hat ? ` (${pet.hat})` : ''}`,
    `"${pet.personality}"`,
    '',
    ...bars,
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
