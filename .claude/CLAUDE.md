# Juliet Dotfiles

Portable development environment for Kyle's personal systems. The goal is that a fresh machine — macOS or Fedora — can be brought to a fully working, consistent setup by cloning this repo and running `bin/juliet-bootstrap`. Configs are managed via GNU Stow symlinks; packages, tooling, and desktop setup are scripted per-OS.

## System changes: Juliet-managed or ad-hoc? Decide every time.

**Before making — or telling the user to make — any change to the system, STOP and decide explicitly which of these it is:**

- **Juliet-managed (the default).** The change is reproducible on a fresh machine because this repo captures it. Anything Juliet *could* own but doesn't is a silent gap — it simply won't exist on the next machine.
- **Ad-hoc, this machine only.** A deliberate one-off (specific hardware, a secret, a throwaway experiment). That's fine — but say so out loud to the user; never leave it implicit.

**When in doubt, default to Juliet-managed; if it's genuinely unclear which it should be, ask the user.** Never silently `sudo`-install a tool or hand-edit a system file and move on — that is exactly the gap this repo exists to close.

**Where the ad-hoc/secrets category lives:** `~/.config/local/` — never committed, loaded into every fish shell; per-machine fish overrides, `.env` secrets, and git values. See `.claude/rules/local-config.md`.

**Where a managed change belongs:**

| Change | Home in Juliet |
|--------|----------------|
| A package | `Brewfile` (macOS) / `DNFfile` (Fedora — incl. `copr` lines) / `Flatpakfile` |
| A user-level config file | `symlinked/` via stow (see the architecture rules) |
| Anything else system-level — a service, a file under `/etc`, a system default, input remapping, a daemon | a `setup-*` step in its category's `bin/bootstrap.d/<NN>-<category>.bash` module, listed in that module's `category` line (plus a `<step>-applicable` check if it only fits some machines); a tracked file it installs lives in `etc/<app>/` and goes through `install-system-file` (see `setup-keyd` for the pattern) |
| A preference only one person has — Kyle's personal apps/accounts (e.g. HEY), or another user's | that person's **extension** repo, not Juliet: Kyle's is `avegancafe/juliet-kyle`. Contract in `EXTENSIONS.md` |

**Package sources are declarative, both ways.** Bootstrap treats the `tap` lines in the `Brewfile` and the `copr` lines in the `DNFfile` as the full list: what's declared gets enabled (and, for Homebrew 7, its tap-qualified formulae trusted), and what's enabled on the machine but *not* declared gets untapped / `dnf copr remove`d — packages still coming from it are re-homed onto the remaining repos first, and a repo that is the only source of something installed is left alone with a warning. So tapping or enabling something by hand doesn't stick: declare it in the `Brewfile` / `DNFfile` instead.

**Practical note on sudo:** system changes need root, and Claude Code's Bash tool runs non-interactively — it *cannot* run `sudo` (the password prompt has no TTY, and the `!`-prefix trick fails the same way). So the workflow is always: script the change into bootstrap, then have the user run `juliet-bootstrap` (or the relevant `--enable=<category>`). Don't hand the user one-off `sudo` commands to paste when the change belongs in bootstrap — put it there first.

## Quick Reference

- **Dotfiles**: `symlinked/config/` → `~/.config/`, `symlinked/home/` → `~/`
- **Bootstrap**: `~/.config/Juliet/bin/juliet-bootstrap`
- **Theme**: Bamboo (consistent across apps)
- **Font**: Iosevka Nerd Font Mono

## Key Locations

| Purpose | Path |
|---------|------|
| Fish aliases | `symlinked/config/fish/functions/aliases/` |
| Neovim config | `symlinked/config/nvim/fnl/Juliet/` |
| Terminal (Ghostty) | `symlinked/config/ghostty/config` |
| App configs | `symlinked/config/<app-name>/` |
| Machine-local config + secrets | `~/.config/local/` (outside the repo — see `.claude/rules/local-config.md`) |

## Package Management

- **macOS**: `brew bundle --file ~/.config/Juliet/Brewfile`
- **Fedora**: Packages listed in `DNFfile`

## Skills and the `noelle` agent

These ship in the **`juliet` plugin** in Kyle's marketplace (`~/workspace/avegancafe-marketplace/plugins/juliet`, repo `avegancafe/avegancafe-marketplace`), enabled from `etc/claude/settings.json`. They are global, so they work from any directory.

- `noelle` agent: a thin entry point. Invoking it says "I'm changing my computer config"; all behavior lives in the skills below, which it preloads.
- `juliet-config`: the core workflow. It frames requests as "in Juliet, X", then covers orientation, the managed-vs-ad-hoc decision, both-OS coverage, the no-sudo rule, and the report.
- `juliet-extension`: the Juliet vs extension-repo split (`juliet-kyle`, `juliet-j2`)
- `juliet-cross-platform`: macOS ↔ Fedora mapping (Brewfile ↔ DNFfile/Flatpakfile, OS-gating, equivalent tools)
- `juliet-bootstrap-step`: add or change a `setup-*` step in `bin/bootstrap.d/`
- `add-app-config`: add configuration for a new application
- `add-fish-alias`: create a new fish shell alias/function

**Claude primitives don't go in Juliet.** Agents, skills, hooks, slash commands, mods, output styles and MCP/LSP config belong in a plugin in the marketplace, not under `symlinked/home/.claude/`: the shared Juliet baseline goes in `juliet`, Kyle's personal tooling in `avegancafe`, or a new plugin when neither fits (J2 work tooling goes in J2's `claude-plugins` marketplace). Follow that repo's `CLAUDE.md` for versioning. Always ask Kyle before publishing (pushing, opening a PR, releasing). Skills there should use absolute `~/.config/Juliet/...` paths; add a new one to Noelle's `skills:` list if it should preload it. The `symlinked/home/.claude/mods/` still here predate this rule and should move too.
