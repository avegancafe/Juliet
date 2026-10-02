/**
 * What `$.store` keeps: the seed is the buddy's whole body, the rest its soul.
 * `v` 2 seeds hash with keccak256; older ones with SHA-256 (see companion.ts).
 */
export type Stored = { seed: string; name: string; personality: string; v?: number }

/** Derived from the seed on every load, never stored. */
export type Bones = {
  seed: string
  species: string
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'
  eyes: [string, string]
  /** The species' own mouth; empty for the punk, which uses `punkMouth`. */
  mouth: string
  /** The contract's three-line top. */
  top: string[]
  nose: string
  punkMouth: string[]
  isShiny: boolean
  stats: Record<string, number>
}

export type Pet = Bones & Stored

declare module 'claude-code' {
  interface PluginState {
    buddy: { pet: Pet | null; tick: number; says: string | null; isHidden: boolean; isMuted: boolean }
  }
}
