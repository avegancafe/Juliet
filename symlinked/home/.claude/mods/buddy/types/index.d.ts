/** What `$.store` keeps: the seed is the whole buddy's body, the rest its soul. */
export type Stored = { seed: string; name: string; personality: string }

/** Derived from the seed on every load, never stored. */
export type Bones = {
  seed: string
  species: string
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'
  eyes: [string, string]
  mouth: string
  top: string
  isShiny: boolean
  stats: Record<string, number>
}

export type Pet = Bones & Stored

declare module 'claude-code' {
  interface PluginState {
    buddy: { pet: Pet | null; tick: number; says: string | null; isHidden: boolean; isMuted: boolean }
  }
}
