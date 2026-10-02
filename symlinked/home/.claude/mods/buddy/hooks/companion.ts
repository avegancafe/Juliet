import type { Bones, Pet } from '../types'

import { BODIES, EGG, HEARTS, IDLE, LEFT_EYES, RIGHT_EYES, TOPS } from './sprites'

export const SPECIES = Object.keys(BODIES)
export const RARITIES = ['common', 'uncommon', 'rare', 'epic', 'legendary'] as const
const WEIGHTS = [60, 25, 10, 4, 1]
const FLOORS = [5, 15, 25, 35, 50]
// How far into TOPS a rarity reaches: common only the bare head, legendary all.
const TOP_REACH = [6, 12, 18, 21, TOPS.length]
export const STATS = ['DEBUGGING', 'PATIENCE', 'CHAOS', 'WISDOM', 'SNARK'] as const
export const RARITY_COLOR = ['gray', 'green', 'blue', 'magenta', 'yellow']
const RAINBOW = ['red', 'yellow', 'green', 'cyan', 'blue', 'magenta']

export const NAMES = ['Pip', 'Mochi', 'Bean', 'Sprout', 'Nugget', 'Biscuit', 'Wren', 'Tofu', 'Pickle', 'Gizmo', 'Dumpling', 'Sprocket']

export function pick<T>(xs: readonly T[], rand = Math.random): T {
  return xs[Math.floor(rand() * xs.length)]!
}

export function newSeed(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32))
  return Array.from(bytes, b => b.toString(16).padStart(2, '0')).join('')
}

/** keccak256(seed) in the contract; SHA-256 here, read as one big integer. */
async function hash(seed: string): Promise<bigint> {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(seed))
  return BigInt(`0x${Array.from(new Uint8Array(digest), b => b.toString(16).padStart(2, '0')).join('')}`)
}

const slot = (rand: bigint, count: number) => Number(rand % BigInt(count))

/** Everything about a buddy but its name and personality, from its seed alone. */
export async function bones(seed: string): Promise<Bones> {
  const rand = await hash(seed)
  // Like the contract, the cosmetic slots share one `rand`; rarity and stats
  // read higher bytes so they don't move in step with the species.
  let roll = slot(rand >> 128n, 100)
  let tier = 0
  while (tier < WEIGHTS.length - 1 && roll >= WEIGHTS[tier]!) roll -= WEIGHTS[tier++]!
  const species = SPECIES[slot(rand, SPECIES.length)]!
  const body = BODIES[species]!
  const eye = slot(rand, LEFT_EYES.length)
  const floor = FLOORS[tier]!
  const order = [...STATS].sort((a, b) => slot(rand >> BigInt(136 + STATS.indexOf(a) * 8), 256) - slot(rand >> BigInt(136 + STATS.indexOf(b) * 8), 256))
  const stats = Object.fromEntries(
    STATS.map((s, i) => {
      const jitter = slot(rand >> BigInt(176 + i * 8), 256) / 256
      const value =
        s === order[0] ? (tier === 4 ? 100 : Math.min(100, floor + 50 + Math.floor(jitter * 30)))
        : s === order[4] ? floor + Math.floor(jitter * 10)
        : floor + Math.floor(jitter * 40)
      return [s, value]
    }),
  )
  return {
    seed,
    species,
    rarity: RARITIES[tier]!,
    eyes: [LEFT_EYES[eye]!, RIGHT_EYES[eye]!],
    mouth: body.mouths[slot(rand, body.mouths.length)]!,
    top: TOPS[slot(rand, TOP_REACH[tier]!)]!,
    isShiny: slot(rand >> 64n, 100) === 0,
    stats,
  }
}

/** A seed whose bones are this species, found the way the buddy salt was: by trying. */
export async function seedFor(species: string): Promise<string> {
  for (;;) {
    const seed = newSeed()
    if ((await bones(seed)).species === species) return seed
  }
}

export function peakStat(pet: Bones): string {
  return Object.entries(pet.stats).sort((a, b) => b[1] - a[1])[0]![0]
}

export type Moment = { tick: number; isPetting: boolean; isHatching: boolean; isWorking: boolean }

function paint(line: string, pet: Bones, isBlinking: boolean): string {
  const [l, r] = isBlinking ? ['─', '─'] : pet.eyes
  return line.replaceAll('{L}', l).replaceAll('{R}', r).replaceAll('{M}', pet.mouth)
}

/** The sprite's five lines for this moment. */
export function sprite(pet: Bones, m: Moment): string[] {
  if (m.isHatching) return EGG[m.tick % EGG.length]!.map(l => l.padEnd(12))
  const step = IDLE[m.tick % IDLE.length]!
  const body = BODIES[pet.species] ?? BODIES.blob!
  // Working: fidget every other tick, eyes open.
  const isFidget = m.isWorking ? m.tick % 2 === 1 : step === 1
  const lines = (isFidget ? body.fidget : body.base).map(l => paint(l, pet, step === -1 && !m.isWorking))
  lines[0] = m.isPetting ? HEARTS[m.tick % HEARTS.length]! : lines[0] || pet.top
  return lines.map(l => l.padEnd(12))
}

/** One-line face for a short or narrow band. */
export function face(pet: Bones): string {
  const body = BODIES[pet.species] ?? BODIES.blob!
  return paint(body.base.find(l => l.includes('{L}'))!.trim(), pet, false)
}

export function color(pet: Bones, tick: number): string {
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
    `${pet.name} the ${pet.species}`,
    `"${pet.personality}"`,
    '',
    ...bars,
    '',
    `seed ${pet.seed.slice(0, 16)}…`,
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
