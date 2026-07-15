# Juliet Dotfiles

Portable development environment for Kyle's personal systems. The goal is that a fresh machine — macOS or Fedora — can be brought to a fully working, consistent setup by cloning this repo and running `bin/juliet-bootstrap`. Configs are managed via GNU Stow symlinks; packages, tooling, and desktop setup are scripted per-OS.

Anything done manually to set up a machine that this repo could have done is a gap: prefer scripting it in the bootstrap (or declaring it in the Brewfile/DNFfile/Flatpakfile) over one-off fixes.

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
