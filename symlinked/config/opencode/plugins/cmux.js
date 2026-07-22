// opencode → cmux notification bridge.
//
// Rings the cmux workspace tab when the agent needs attention: on session.idle
// (the agent has finished responding / is waiting for input) and session.error.
// This is the working equivalent of the cmux "OpenCode integration" guide
// (https://manaflow-ai-cmux.mintlify.app/integrations/opencode) — that guide's
// ~/.opencode/hooks.sh + config.json "hooks" object predates opencode's plugin
// API and does not fire on current opencode, so we call `cmux notify` from a
// real plugin instead.
//
// Auto-loaded because it lives in ~/.config/opencode/plugins/ (no opencode.json
// registration needed). No-op unless we're inside a cmux workspace; if the cmux
// CLI is missing the notify call is swallowed by .nothrow() so it never breaks a
// session.
export const CmuxNotify = async ({ $ }) => {
  const inCmux = Boolean(process.env.CMUX_WORKSPACE_ID)
  const notify = (subtitle, body) =>
    $`cmux notify --title opencode --subtitle ${subtitle} --body ${body}`
      .quiet()
      .nothrow()

  return {
    event: async ({ event }) => {
      if (!inCmux) return
      if (event.type === "session.idle") {
        await notify("Ready", "Agent is waiting for input")
      } else if (event.type === "session.error") {
        await notify("Error", "Session error")
      }
    },
  }
}
