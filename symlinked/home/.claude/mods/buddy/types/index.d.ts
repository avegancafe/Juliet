export type Pet = { species: string; name: string }

declare module 'claude-code' {
  interface PluginState {
    buddy: { pet: Pet | null; frame: number; says: string | null; isHidden: boolean }
  }
}
