# CRUSH.md - Juliet Dotfiles Repository

## Build/Test/Lint Commands

```bash
# Linting & Formatting
stylua --check .                    # Check Lua formatting (Neovim config)
stylua .                           # Format Lua files
prettier --check .                 # Check JS/TS/JSON formatting
prettier --write .                 # Format JS/TS/JSON files

# Bootstrap & Setup
~/.config/Juliet/bin/juliet-bootstrap  # Update repository and dependencies
brew bundle --file ~/.config/Juliet/Brewfile  # Install/update packages

# Neovim Plugin Management
~/.config/Juliet/bin/nvim-refresh-plugins  # Update Neovim plugins
```

## Code Style Guidelines

**Fish Shell Functions:**
- Naming: lowercase-with-hyphens.fish
- Use `set -l` for local variables, `test` over `[`, `string` builtin functions
- Error handling with custom `error`, `warn`, `log` functions

**Fennel/Lua (Neovim):**
- 2-space indentation, lisp-style parentheses alignment
- Destructuring imports: `(import-macros {: pack} :Juliet.macros)`
- Kebab-case naming, lambda syntax `(fn name [] ...)`

**Shell Scripts:**
- POSIX-compatible `#!/bin/sh`, check exit codes with `$?`
- Use `terminal-notifier` for user feedback

**Git Commits:**
- Follow conventional commits: `type(scope): description`
- Use provided commit template in `.gitmessage`