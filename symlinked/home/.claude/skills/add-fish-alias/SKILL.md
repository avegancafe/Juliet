---
name: add-fish-alias
description: Use when creating a new fish shell alias, function, or command shortcut in Kyle's Juliet dotfiles (~/.config/Juliet), or when user asks to "add an alias for X"
---

# Add Fish Alias

> **Personal, not shared?** If this is Kyle's own taste rather than something any Juliet user would want, it goes in `~/workspace/juliet-kyle` instead. See the `juliet-extension` skill for the equivalent file there.

Create a new fish shell function/alias in Juliet dotfiles.

## Process

1. **Create function file**
   ```
   ~/.config/Juliet/symlinked/config/fish/functions/aliases/<name>.fish
   ```

2. **Write the function**
   ```fish
   function <name> --wraps "<wrapped-command>"
       <wrapped-command> $argv
   end
   ```

3. **Reload fish** (or open new terminal)
   ```bash
   source ~/.config/fish/config.fish
   ```

## File Naming

- Filename = function name (e.g., `g.fish` defines `g` function)
- Use lowercase, hyphens for multi-word names
- Files are auto-loaded alphabetically

## Patterns

### Simple Wrapper
```fish
function g --wraps "git"
    git $argv
end
```

### Wrapper with Auto-Install
```fish
function nv --wraps "neovide"
    if ! command -v neovide 2&> /dev/null
        gum confirm "Neovide not installed. Install?" && brew install --cask neovide
    end
    neovide $argv
end
```

### Function with Subcommand Aliases
```fish
function pv --wraps "pipenv"
    switch $argv[1]
        case "i"
            set argv[1] install
    end
    pipenv $argv
end
```

### Interactive Function (using gum)
```fish
function clone
    set -l provider (gum choose --header "Source?" github gitlab)
    # ... rest of logic
end
```

### Multiple Functions in One File
Group related functions (e.g., `git.fish` contains `ga`, `gl`, `gm`, `commit`, etc.)

## Conventions

- Use `--wraps` for tab completion inheritance
- Use `$argv` to pass all arguments
- Use `gum` for interactive prompts (confirm, choose, input, spin)
- Helper functions: `log`, `error`, `debuglog` (defined in fish config)

## Common Mistakes

- Forgetting `--wraps` (loses tab completion)
- Using `$@` instead of `$argv` (bash syntax, not fish)
- Creating in wrong directory (must be in `~/.config/Juliet/symlinked/config/fish/functions/aliases/`)
