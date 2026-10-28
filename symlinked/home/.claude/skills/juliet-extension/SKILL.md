---
name: juliet-extension
description: Use when a change to Kyle's computer setup might be personal rather than shared — his own apps, accounts, git identity, Claude Desktop connectors, or setup steps — or when working in ~/workspace/juliet-kyle or ~/.config/juliet-extension. Covers the Juliet vs juliet-kyle split, how the extension is wired in, where each kind of change goes, and why an extension edit doesn't apply until it's pushed.
---

# Juliet vs juliet-kyle

Kyle's setup has three layers. `JULIET_EXTENSION` lists the extensions in order (work Mac: juliet-j2 then juliet-kyle; personal machines: juliet-kyle only):

| Layer | Repo | Holds |
|-------|------|-------|
| **Juliet** | `~/.config/Juliet` (`avegancafe/Juliet`, public) | Shared setup that anyone can run from `main`: packages, dotfiles and bootstrap steps that make sense for any Juliet user |
| **juliet-j2** | `~/workspace/juliet-j2` (`avegancafe/juliet-j2`, **public**) | J2 work setup that every J2 engineer wants (Jordan and Aaron use it too): j2-claude-plugins, dev-env, gcloud/kubectl, J2 aliases. Nothing personal, and nothing internal (no hostnames, cluster/bucket names, project IDs) |
| **juliet-kyle** | `~/workspace/juliet-kyle` (`avegancafe/juliet-kyle`) | Kyle's personal layer: his own apps and accounts (HEY, Obsidian, Zen, …), `[github] user`, and setup steps for those |

`~/.config/Juliet/EXTENSIONS.md` is the source of truth for the extension format. Read it before changing the extension.

## Which layer?

Ask: **"Would someone else running Juliet want this?"**
- **Yes** → Juliet. Use the other Juliet skills as normal.
- **Only J2 engineers would want it** (J2 plugins, dev-env, work CLIs) → juliet-j2. Personal machines must stay J2-free, so J2 things never go in Juliet or juliet-kyle.
- **No, it's Kyle's taste or account** → juliet-kyle.
- **This machine only, a secret, or internal J2 detail** (e.g. auto-mode `environment` naming clusters/buckets) → `~/.config/local/` (ad-hoc; `~/.config/local/claude/settings.json` for Claude settings), in no repo. Juliet and juliet-j2 are public.
- **A Claude connector (MCP server) that should work in claude.ai, on mobile or in Projects** → its own repo, deployed as a remote connector (like `avegancafe/hey-mcp` and `avegancafe/zola-mcp-remote` on Fly). Don't also register it locally in Claude Desktop or Claude Code: claude.ai connectors already reach both, and a local copy loads every tool twice.

Say which layer you picked and why. If a Juliet change is really personal (it names Kyle's accounts, or apps only he uses), move it to the extension rather than adding it to Juliet.

## How the extension is wired

- `JULIET_EXTENSION` in `~/.config/local/.env` lists the extensions, space-separated, in order. Don't read that file: it's denied and holds secrets. Each active extension is at `~/.config/juliet-extensions/<name>`, and `~/.config/juliet-extensions/.order` lists them; run `ls -l ~/.config/juliet-extensions/` to see the mode of each:
  - **URL mode**: the entry is itself a git clone (a real directory), and bootstrap fast-forwards it on every run.
  - **Path mode**: the entry is a symlink to a local checkout (`readlink -f` shows which one), and **bootstrap never pulls it**. If that checkout isn't the `~/workspace/<repo>` one, it only changes when someone runs `git -C <checkout> pull --ff-only`.
- In bootstrap steps, use `$EXTENSION_DIR`: bootstrap sets it to the running extension's `~/.config/juliet-extensions/<name>`. Never use the clone's or checkout's own path. Name each extension's step functions with its own prefix (`setup-j2-*`, `setup-kyle-*`): all extensions' `bootstrap.bash` share one shell.
- `~/.claude/settings.json` is **generated** (Juliet's `etc/claude/settings.json`, then each extension's `claude/settings.json`, then `~/.config/local/claude/settings.json`). Never edit it directly; edit the layer, then run `juliet-bootstrap --enable=claude`.
- **Edit `~/workspace/juliet-kyle`, never a live copy.** Unless the live extension is that same checkout, an edit takes effect only after you push it and the live copy picks it up: bootstrap pulls it in URL mode, but in path mode you pull it yourself. Then run `juliet-bootstrap --enable=extension`. Say which of these applies in the report.
- Claude Desktop rewrites `claude_desktop_config.json` while it's running, so a step that edits that file can be undone. Quit Desktop before running such a step, and re-run the step if the entry disappears.

## Where each kind of change goes in the extension

| Change | Juliet equivalent | In juliet-kyle |
|--------|-------------------|----------------|
| Package | `Brewfile` / `DNFfile` / `Flatpakfile` | Same filenames (appended to Juliet's). Declare any tap, copr or remote it needs there too |
| Drop a Juliet package | — | `exclude` (stops installs; never uninstalls) |
| Dotfile | `symlinked/home/…`, `symlinked/config/…` | `home/<path>` / `config/<path>`. This replaces Juliet's whole file, and it can't land inside a folder Juliet stows as a single link |
| Fish config | `symlinked/config/fish/…` | `fish/config.fish` |
| Git identity | — | `gitconfig` |
| Setup step | `bin/bootstrap.d/*.bash` | `bootstrap.bash`: a `setup-*` function called from `extension-setup` |
| Claude settings (plugins, marketplaces, permissions) | `etc/claude/settings.json` | `claude/settings.json`: a fragment merged on top (objects merge, arrays append). Never `home/.claude/settings.json` |
| `.env` keys | `.env.template` | `.env.template`, with blank values only |

Extension steps may use only the stable helpers listed in EXTENSIONS.md (`spin`, `substep`, `skip`, `notice`, `warn`, `bootstrap_error`, `is-macos`, `is-fedora`, `gum-confirm`, `$EXTENSION_DIR`). The rest of `bin/juliet-bootstrap` may change. Steps must be idempotent: skip when the work is already done. The other rules still apply (both OSes, no sudo).

## Testing an extension step before pushing

1. Run `bash -n ~/workspace/juliet-kyle/bootstrap.bash`, and `shellcheck` if it's installed.
2. Run the step from the checkout with the real helpers loaded:
   `bash -c 'source ~/.config/Juliet/_util.bash; source ~/.config/Juliet/bin/bootstrap.d/00-common.bash; bootstrap_error() { echo "ERROR: $*"; }; EXTENSION_DIR=~/.config/juliet-extensions/juliet-kyle; source ~/workspace/juliet-kyle/bootstrap.bash; setup-<name>'` (swap in `juliet-j2` for that extension)
   (`bootstrap_error` lives in `bin/juliet-bootstrap`, so it's stubbed here.) Run it twice to confirm the second run only skips.

## Report back

Add these to the `juliet-config` report:
- which layer the change went in, and why;
- for juliet-kyle, the apply steps: commit and push `~/workspace/juliet-kyle` (only when the user asks), update the live copy if it's a path-mode checkout elsewhere, then run `juliet-bootstrap --enable=extension`.
