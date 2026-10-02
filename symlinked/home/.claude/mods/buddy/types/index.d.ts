export type Pet = {
  species: string
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'
  eye: string
  hat: string | null
  isShiny: boolean
  stats: Record<string, number>
  name: string
  personality: string
}

declare module 'claude-code' {
  interface PluginState {
    buddy: { pet: Pet | null; tick: number; says: string | null; isHidden: boolean; isMuted: boolean }
  }
}
