---
description: Disable an opencode model so it stops showing in the model picker
---

Disable the model named in `$ARGUMENTS` in the Juliet opencode config.

`$ARGUMENTS` may be a bare fragment (`mistral`) or a full id
(`fireworks-ai/accounts/fireworks/models/mistral-large-3-fp8`).

Steps:

1. Resolve the model id. Run `opencode models` and match `$ARGUMENTS`
   (case-insensitive substring). If nothing matches or several match, show the
   candidates and ask which — do not guess.
2. Split off the provider (the part before the first `/`). The models map is
   keyed by the id **without** the provider prefix, e.g. provider `fireworks-ai`
   + `accounts/fireworks/models/mistral-large-3-fp8`.
3. Read `~/.config/Juliet/opencode/config.json` — the Juliet override layer
   (`OPENCODE_CONFIG`). Add `providers.<provider>.models.<id>: { "disabled": true }`
   — note the v2 key is `providers` (plural) — keeping the keys alphabetical;
   create the provider block if it doesn't exist.
   (OpenCode v2 drops the old `blacklist`/`whitelist` arrays in its v1→v2
   config translation — `normalize.ts` lists them as unsupported — and the
   legacy singular `provider` key loses `disabled` in that same translation,
   so it must live under the native `providers` map. `enabled_providers`
   still translates fine, into `provider.use` policies.)
   - Never edit the dev-env global file
     (`~/.config/opencode/opencode.json`) — it's org-managed.
   - If the provider is absent from `enabled_providers`, every model on it is
     already unavailable — say so and stop.
4. Validate the JSON:
   `python3 -c "import json;json.load(open('$HOME/.config/Juliet/opencode/config.json'))"`
5. Restart the background server so it re-reads the layer — `OPENCODE_CONFIG`
   is not on v2's config watcher (only `~/.config/opencode` and `~/.opencode`
   are): `opencode service restart`.
6. Confirm it's gone: `opencode models | grep -i "$ARGUMENTS"` should print nothing.

Report the single added line and the provider it went under.
