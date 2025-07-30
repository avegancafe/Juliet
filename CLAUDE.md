# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Juliet is a comprehensive dotfiles repository for macOS development environment setup. It manages configurations for terminal applications, editors, system utilities, and development tools through symlinked dotfiles and automated setup scripts.

## Setup and Bootstrap Commands

```bash
# Initial setup (clone and bootstrap)
git clone --recursive git@github.com:avegancafe/Juliet ~/.config/Juliet
~/.config/Juliet/bin/juliet-bootstrap

# Update Juliet repository and dependencies
~/.config/Juliet/bin/juliet-bootstrap

# Install/update Homebrew packages
brew bundle --file ~/.config/Juliet/Brewfile

# Symlink dotfiles (done automatically by bootstrap)
stow --target=$HOME --dir=$HOME/.config/Juliet/symlinked home
stow --target=$HOME/.config --dir=$HOME/.config/Juliet/symlinked config
```

## Architecture and File Structure

### Core Structure
- `symlinked/` - Contains all dotfiles organized by target location
  - `symlinked/config/` - Files that go in ~/.config/
  - `symlinked/home/` - Files that go in ~/
- `bin/` - Custom utility scripts and tools
- `etc/` - Assets (fonts, themes, wallpapers, keyboard layouts)
- `Brewfile` - Homebrew package definitions
- `_util.bash` - Shared bash utility functions

### Key Configuration Systems

**Neovim (Primary Editor)**
- Configuration written in Fennel (Lisp that compiles to Lua)
- Entry point: `symlinked/config/nvim/init.lua`
- Main config: `symlinked/config/nvim/fnl/Juliet/init.fnl`
- Plugin management via lazy.nvim with lock file at `lazy-lock.json`
- Plugins organized by category in `fnl/Juliet/plugins/`

**Fish Shell**
- Main config: `symlinked/config/fish/config.fish`
- Aliases auto-loaded from `functions/aliases/` (alphabetical order)
- Initializers auto-loaded from `initializers/`
- Environment setup in `env.fish`

**Terminal Applications**
- Primary terminal: Ghostty (`symlinked/config/ghostty/config`)
- Secondary: Kitty (`symlinked/config/kitty/kitty.conf`)
- Tmux configuration in `symlinked/config/tmux/`

**System Integration**
- Hammerspoon: Window management and system automation (`symlinked/home/.hammerspoon/init.lua`)
- Karabiner Elements: Keyboard remapping (`symlinked/config/karabiner/karabiner.json`)
- Extensive caps lock layer for system shortcuts

## Key Utility Scripts

Located in `bin/` directory:
- `juliet-bootstrap` - Main setup and update script
- `better-branch` - Enhanced git branch management
- `delete-current-branch` - Safe git branch deletion
- `git-recreate` - Git repository recreation utility
- `nvim-refresh-plugins` - Neovim plugin management
- `git-hoard/` - Git repository organization tool (Node.js/Bun project)

## Fish Shell Aliases

Fish functions are auto-loaded from `symlinked/config/fish/functions/aliases/`. Key aliases include:
- `nv` - Launch Neovim GUI (Neovide)
- `g` - Git shortcuts
- `ls` - Enhanced ls with eza
- `cat` - Enhanced cat with bat
- `current-branch`, `current-sha`, `default-branch` - Git utilities

## Development Tools Integration

**Package Managers:**
- Homebrew (primary package manager)
- Node.js via nodenv
- Python via pyenv  
- Rust via rustup
- OCaml via opam

**Editor Integrations:**
- Neovim with comprehensive LSP setup
- VSCode configuration and extensions (via Brewfile)
- Helix editor as secondary option

**Development Workflow:**
- Git integration with enhanced tooling
- Docker and docker-compose support
- Language-specific tooling for JavaScript/TypeScript, Python, Go, Rust, etc.

## Theme and Appearance

- Primary theme: "Bamboo" (consistent across Neovim, Ghostty, Helix)
- Font: Iosevka Nerd Font Mono
- Terminal color schemes and themes stored in `etc/themes/`

## Notes for Claude Code

- Fish shell functions in `functions/aliases/` are sourced alphabetically
- Neovim plugins use Fennel configuration - compile to Lua when making changes
- Bootstrap script handles dependency installation and system setup
- All configurations use symlinks managed by GNU Stow
- Font installation handled automatically by bootstrap process
- Custom git utilities extend standard git functionality