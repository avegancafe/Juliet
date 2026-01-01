# Juliet Dotfiles

Dotfiles repo for development environment. Configs managed via GNU Stow symlinks.

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
