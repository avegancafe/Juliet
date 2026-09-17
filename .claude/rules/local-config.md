# Local Machine Configuration — `~/.config/local/`

Machine-local config and secrets live in `~/.config/local/`. It is **outside this repo and never committed** — the sanctioned home for the deliberate "ad-hoc, this machine only" category. Nothing here reproduces on a fresh machine; if a value should, it belongs in `symlinked/` or a `setup-*` step instead.

## What lives there

| File | Purpose | Loaded by |
|------|---------|-----------|
| `.env` | Local secrets and per-machine values (`SENTRY_ACCESS_TOKEN`, `LINEAR_API_KEY`, `GITHUB_PAT`, …) | `~/.config/fish/config.fish` → `envsource ~/.config/local/.env` (the `# Local environment variables` block) |
| `fish/config.fish` | Fish settings that only make sense on this machine | `~/.config/fish/initializers/local.fish` sources it when present |
| `gitconfig` | Per-machine git identity and credential helpers | `~/.gitconfig` → `[include] path = ~/.config/local/gitconfig` |
| other files | Machine-local artifacts that would be noise (or a secret) in git — e.g. `slack-mcp-app-manifest.yaml` | whatever tool owns them |

## `.env` format

Loaded line-by-line by `envsource` (`symlinked/config/fish/functions/aliases/envsource.fish`):

- `NAME=value`, split on the **first** `=` — keep it simple
- **Don't quote values** — quotes are not stripped, so `NAME="x"` sets `"x"` (with quotes)
- Comments must have `#` in **column 1**; an indented `#` line is not skipped and will be misparsed
- Blank / whitespace-only lines are skipped
- Each entry is exported globally (`set -gx`), so every new fish shell — and everything launched from one — inherits it

## Propagation and restarts

- **New fish shells** pick up `.env` automatically; no action needed.
- **Long-running processes keep the environment they started with.** After editing `.env`, restart every consumer. For example, `SENTRY_ACCESS_TOKEN` feeds the Sentry MCP through the OpenCode service — restart it from a fresh shell (`opencode service stop && opencode service start`; a soft restart may not adopt a changed environment).
- Consuming config references the variable **name**, never the value. Example: `opencode/config.json` sends `"Authorization": "Sentry-Bearer {env:SENTRY_ACCESS_TOKEN}"`.

## Adding or rotating a value

1. Edit `~/.config/local/.env` directly (open it in an editor — don't echo secrets through shell history).
2. Open a new fish shell and verify: `echo $NAME`.
3. Restart long-running consumers and confirm they work.
4. For credentials, revoke the old value at the provider **only after** the new one is verified.
