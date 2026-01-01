# Repository Architecture

## Directory Structure

```
Juliet/
├── symlinked/
│   ├── config/      # Files → ~/.config/
│   └── home/        # Files → ~/
├── bin/             # Utility scripts
├── etc/             # Assets (fonts, themes, wallpapers)
├── Brewfile         # Homebrew packages (macOS)
├── DNFfile          # DNF packages (Fedora)
└── _util.bash       # Shared bash utilities
```

## Stow Symlink Behavior

GNU Stow creates symlinks at different levels:

- **Folder symlinks**: If target folder doesn't exist, stow symlinks the entire folder
  - Example: `~/.config/fuzzel` → `Juliet/symlinked/config/fuzzel/`
- **File symlinks**: If target folder exists with other contents, stow creates file-level symlinks

### Critical Rule

**Always edit files in `symlinked/`** - never delete files in `~/.config/` and recreate symlinks without checking if the parent folder is already a symlink. This can create circular symlinks and data loss.

## Stow Commands

```bash
# Symlink config files to ~/.config/
stow --target=$HOME/.config --dir=$HOME/.config/Juliet/symlinked config

# Symlink home files to ~/
stow --target=$HOME --dir=$HOME/.config/Juliet/symlinked home
```

## Key Configuration Systems

| System | Entry Point | Notes |
|--------|-------------|-------|
| Neovim | `symlinked/config/nvim/init.lua` | Config in Fennel (`fnl/Juliet/`) |
| Fish | `symlinked/config/fish/config.fish` | Aliases in `functions/aliases/` |
| Ghostty | `symlinked/config/ghostty/config` | Primary terminal |
| Niri | `symlinked/config/niri/config.kdl` | Wayland compositor |
