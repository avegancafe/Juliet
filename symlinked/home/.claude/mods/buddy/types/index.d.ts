/**
 * What `$.store` keeps: the seed is the buddy's whole body, the rest its soul.
 */
export type Stored = { seed: string; name: string; personality: string }

/** Derived from the seed on every load, never stored. */
export type Bones = {
  seed: string
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'
  eyes: [string, string]
  /** The contract's parts: a three-line top, an eye pair, a nose, a two-line mouth. */
  top: string[]
  nose: string
  mouth: string[]
  isShiny: boolean
  stats: Record<string, number>
}

export type Pet = Bones & Stored

declare module 'claude-code' {
  interface PluginState {
    buddy: { pet: Pet | null; tick: number; says: string | null; isHidden: boolean; isMuted: boolean }
  }
}
