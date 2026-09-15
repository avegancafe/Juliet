---
description: Blacklist an opencode model so it stops showing in the model picker
---

Blacklist the model named in `$ARGUMENTS` from the Juliet opencode config.

`$ARGUMENTS` may be a bare fragment (`mistral`) or a full id
(`fireworks-ai/accounts/fireworks/models/mistral-large-3-fp8`).

Steps:

1. Resolve the model id. Run `opencode models` and match `$ARGUMENTS`
   (case-insensitive substring). If nothing matches or several match, show the
   candidates and ask which — do not guess.
2. Split off the provider (the part before the first `/`). The blacklist stores
   the id **without** the provider prefix, e.g. provider `fireworks-ai` +
   `accounts/fireworks/models/mistral-large-3-fp8`.
3. Read `~/.config/Juliet/opencode/config.json` — the Juliet override layer
   (`OPENCODE_CONFIG`). Add the id to `provider.<provider>.blacklist`, keeping
   the array alphabetical; create the provider block if it doesn't exist.
   - Never edit the dev-env global file
     (`~/.config/opencode/opencode.json`) — it's org-managed.
   - If the provider is absent from `enabled_providers`, every model on it is
     already unavailable — say so and stop.
4. Validate the JSON:
   `python3 -c "import json;json.load(open('$HOME/.config/Juliet/opencode/config.json'))"`
5. Confirm it's gone: `opencode models | grep -i "$ARGUMENTS"` should print nothing.

Report the single added line and the provider it went under.
