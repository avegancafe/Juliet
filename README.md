# Juliet

A comprehensive dotfiles repository for macOS development environment setup. Manages configurations for terminal applications, editors, system utilities, and development tools through symlinked dotfiles and automated setup scripts.

## Setup

To set up Juliet, run: 
```bash
$ git clone --recursive git@github.com:avegancafe/Juliet ~/.config/Juliet
$ ~/.config/Juliet/bin/juliet-bootstrap
```

## Available Tools and Functions

### System Setup & Management

**Core Binaries:**
- **`juliet-bootstrap`** - Main setup and update script
  - Installs Homebrew and dependencies
  - Updates Juliet repository from git
  - Runs `brew bundle` to install packages
  - Sets up symlinks using GNU Stow
  - Usage: `~/.config/Juliet/bin/juliet-bootstrap`

**System Utilities:**
- **`reindex-spotlight`** - macOS Spotlight reindexing
- **`update-kitty`** - Kitty terminal updater
- **`envsource`** - Environment variable sourcing
- **`sudo`** - Enhanced sudo wrapper

### Git & Version Control

**Git Binaries:**
- **`better-branch`** - Enhanced git branch viewer
  - Shows colorized branch list with commit counts
  - Displays ahead/behind status relative to main branch
  - Shows last commit info for each branch

- **`delete-current-branch`** - Safe branch deletion
  - Switches to main branch and deletes current branch
  - Logs deleted commit SHA to `~/.delog` for recovery

- **`git-recreate`** - Branch recreation utility
  - Deletes current branch and recreates it from latest main
  - Useful for starting fresh while keeping branch name

- **`git-hoard/`** - Git repository organization tool (Node.js project)

**Git Functions:**
- **`g`** - Short alias for git
- **`current-branch`** - Get current git branch name
- **`cb`** - Copy current branch name to clipboard
- **`current-sha`** - Get current commit SHA
- **`default-branch`** - Get repository's default branch
- **`gdiff`** - Git diff wrapper
- **`gut`** - Git status shortcut
- **`clone`** - Enhanced git clone

**Git Aliases:**
- **`git a`** - Add files to staging
- **`git ape`** - Amend previous commit and force push with lease
- **`git b`** / **`git bbranch`** - Show enhanced branch list (uses better-branch)
- **`git clean-branches`** - Delete all branches except master/main
- **`git clean-merged`** / **`git cm`** - Delete branches that have been merged
- **`git co`** - Checkout branch/commit
- **`git com`** - Commit changes
- **`git cp`** - Cherry-pick commits
- **`git del`** - Delete current branch safely (uses delete-current-branch)
- **`git diff-branch`** - Show diff from fork point with master
- **`git fixup`** - Create fixup commit for interactive rebase
- **`git fo`** - Fetch from origin
- **`git judge`** - Enhanced blame with whitespace/move detection
- **`git main`** - Switch to main/master branch automatically
- **`git o`** / **`git open`** - Open repository in GitHub
- **`git pdiff`** - Pretty diff using bat with syntax highlighting
- **`git pf`** - Push with force-with-lease (safer force push)
- **`git pu`** - Pull changes
- **`git rb`** - Rebase commits
- **`git re`** - Restore files
- **`git s`** - Switch branches
- **`git squash`** - Interactive rebase to squash commits against main
- **`git staash`** - Stash all changes including untracked files
- **`git staged`** - Show staged changes
- **`git su`** - Update submodules recursively
- **`git t`** - Ticket (custom command)
- **`git up`** - Push changes

### Editor & Development Environment

**Editor Tools:**
- **`nv`** - Launch Neovide GUI editor, auto-installs if missing
- **`vim`** - Alias for nvim
- **`cursor`** - Launch Cursor editor

**Neovim Management:**
- **`nvim-refresh-plugins`** - Neovim plugin manager
  - Clears lazy.nvim plugin cache
  - Restores plugins from lock file

### File Operations & Navigation

**Enhanced File Tools:**
- **`cat`** - Enhanced cat using `bat` with syntax highlighting
- **`ls`** - Enhanced ls using `eza` with better formatting

**Workspace Management:**
- **`work`** - Interactive workspace/directory switcher
  - Reads from `~/.workspaces` and `~/.workspaces__local`
  - Supports `@workspace` (directories with subdirs) and `@dir` (specific dirs)
  - Uses gum for interactive selection
  - Setup example:
    ```
    @workspace ~/workspace
    @dir ~/.config/nvim
    ```

### Development & DevOps Tools

**GitHub Integration:**
- **`run`** - GitHub Actions workflow runner
  - Runs workflows with optional current branch
  - Watches workflow execution
  - Usage: `run <workflow-name> [-c/--current] [-a/--args="args"]`

- **`gist-to-pdf`** - GitHub Gist converter
  - Clones gists and converts to PDF format
  - Usage: `gist-to-pdf <gist-id>`

**Container & Cloud Tools:**
- **`dc`** - Docker Compose shortcut
- **`kc`** - kubectl shortcut

**Language-Specific Tools:**
- **`node`** - Node.js wrapper
- **`has-pipfile`** - Check for Python Pipfile

### Monitoring & Utilities

**System Monitoring:**
- **`logs`** - System log viewer
- **`watch`** - File watching utility
- **`pv`** - Process viewer
- **`st`** - Status checker

**General Utilities:**
- **`note`** - Note-taking utility

## Downloads

- [Iosevka](https://drive.google.com/file/d/1kizplo6YXxxNMWzfh6cUVAGRiJq4jsTR/view?usp=share_link)
- [Logitech Options](https://www.logitech.com/en-us/product/options)
- [DisplayLink](https://www.displaylink.com/downloads/macos)

## Architecture

- `symlinked/` - Contains all dotfiles organized by target location
  - `symlinked/config/` - Files that go in ~/.config/
  - `symlinked/home/` - Files that go in ~/
- `bin/` - Custom utility scripts and tools
- `etc/` - Assets (fonts, themes, wallpapers, keyboard layouts)
- `Brewfile` - Homebrew package definitions

All Fish shell functions are auto-loaded alphabetically from `symlinked/config/fish/functions/aliases/` and integrate with the broader Juliet ecosystem for a cohesive development environment.
