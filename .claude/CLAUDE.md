# Juliet Dotfiles

Portable development environment for Kyle's personal systems. The goal is that a fresh machine — macOS or Fedora — can be brought to a fully working, consistent setup by cloning this repo and running `bin/juliet-bootstrap`. Configs are managed via GNU Stow symlinks; packages, tooling, and desktop setup are scripted per-OS.

## System changes: Juliet-managed or ad-hoc? Decide every time.

**Before making — or telling the user to make — any change to the system, STOP and decide explicitly which of these it is:**

- **Juliet-managed (the default).** The change is reproducible on a fresh machine because this repo captures it. Anything Juliet *could* own but doesn't is a silent gap — it simply won't exist on the next machine.
- **Ad-hoc, this machine only.** A deliberate one-off (specific hardware, a secret, a throwaway experiment). That's fine — but say so out loud to the user; never leave it implicit.

**When in doubt, default to Juliet-managed; if it's genuinely unclear which it should be, ask the user.** Never silently `sudo`-install a tool or hand-edit a system file and move on — that is exactly the gap this repo exists to close.

**Where a managed change belongs:**

| Change | Home in Juliet |
|--------|----------------|
| A package | `Brewfile` (macOS) / `DNFfile` (Fedora — incl. `copr` lines) / `Flatpakfile` |
| A user-level config file | `symlinked/` via stow (see the architecture rules) |
| Anything else system-level — a service, a file under `/etc`, a system default, input remapping, a daemon | a `setup-*` step in `bin/juliet-bootstrap`, wired into the right `run-*` category (see `setup-keyd` / `setup-sddm` for the pattern) |

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

## Package Management

- **macOS**: `brew bundle --file ~/.config/Juliet/Brewfile`
- **Fedora**: Packages listed in `DNFfile`

## Skills

- `add-app-config` - Add configuration for a new application
- `add-fish-alias` - Create a new fish shell alias/function
