// opencode → cmux notification bridge (OpenCode v2 plugin API).
//
// Rings the cmux workspace tab when the agent needs attention: on session.idle
// (the agent has finished responding / is waiting for input) and
// session.execution.failed (the v2 successor to v1's session.error event —
// step/tool-level failures stay silent because the loop can retry them).
//
// Auto-loaded because it lives in ~/.config/opencode/plugins/ (v2 discovers
// direct .js/.ts files there — no opencode.json registration needed). No-op
// unless we're inside a cmux workspace; if the cmux CLI is missing or notify
// fails, the error is swallowed so it never breaks a session.
//
// Ported from the v1 plugin API (named export + returned `event` hook + Bun `$`
// shell) to v2: a default-exported { id, setup } definition, an explicit
// ctx.event.subscribe() async-iterator subscription, and node:child_process for
// the cmux CLI call. Like j2-eng's entry plugin, this deliberately does NOT
// import @opencode/plugin for Plugin.define — a plain { id, setup } default
// export satisfies v2's loader, and skipping the import keeps this bare file
// free of node_modules resolution concerns.
import { execFile } from "node:child_process"

const inCmux = Boolean(process.env.CMUX_WORKSPACE_ID)

// Never rejects: a missing cmux binary or a failed notify must not break a session.
const notify = (subtitle, body) =>
  new Promise((resolve) => {
    execFile(
      "cmux",
      ["notify", "--title", "opencode", "--subtitle", subtitle, "--body", body],
      () => resolve(),
    )
  })

export default {
  id: "cmux-notify",
  setup(ctx) {
    if (!inCmux) return

    const controller = new AbortController()

    void (async () => {
      for await (const event of ctx.event.subscribe({
        types: ["session.idle", "session.execution.failed"],
        signal: controller.signal,
      })) {
        if (event.type === "session.idle") {
          await notify("Ready", "Agent is waiting for input")
        } else if (event.type === "session.execution.failed") {
          await notify("Error", "Session error")
        }
      }
    })()

    return () => controller.abort()
  },
}
