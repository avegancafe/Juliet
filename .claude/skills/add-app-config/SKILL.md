---
name: add-app-config
description: Use when adding configuration for a new application to the dotfiles, setting up a new tool's config, adopting a config directory an app already created, or when user says "add config for X"
---

# Add App Configuration

Add a new application's configuration to Juliet dotfiles with proper stow symlinks.

## How the Stow Symlink Farm Works

Juliet manages dotfiles as three stow "packages" under `symlinked/`, each with its own target:

| Package | Stow command target | Files land in |
|---------|--------------------|---------------|
| `symlinked/home/` | `~` | `~/.gitconfig`, etc. |
| `symlinked/config/` | `~/.config` | `~/.config/<app>/` |
| `symlinked/local-state/` | `~/.local/state` | `~/.local/state/<app>/` |

`juliet-bootstrap` runs all three stow invocations in `symlink-dotfiles` on every run — so a new app config added under `symlinked/config/` is picked up automatically on other machines; **no bootstrap changes are needed**.

**Folding:** stow symlinks at the highest level it can:
- Target dir doesn't exist → ONE folder symlink (`~/.config/niri` → `Juliet/symlinked/config/niri`). Files the app later creates inside land in the repo automatically.
- Target dir already exists as a real dir → stow merges, creating file/subdir-level symlinks inside it. App-created runtime files then stay OUTSIDE the repo.

Prefer folder symlinks: get stow to run before the app first launches, or adopt the app's dir (below).

## Process

1. **Create config directory**
   ```bash
   mkdir -p ~/.config/Juliet/symlinked/config/<app-name>/
   ```

2. **Add configuration files**
   - Create config files inside `symlinked/config/<app-name>/`
   - Use the app's expected filenames (e.g., `config`, `config.toml`, `settings.json`)

3. **Run stow to create symlinks**
   ```bash
   stow --target=$HOME/.config --dir=$HOME/.config/Juliet/symlinked config
   ```

4. **Apply Bamboo theme** (if applicable)
   - Check if app supports Bamboo theme
   - Apply consistent colors: dark green-tinted background, soft white foreground
   - Document theme setting in `.claude/rules/theming.md`

## Pre-flight Check

Before creating, verify the target doesn't already exist:
```bash
ls -la ~/.config/<app-name>
```

If it exists and is NOT a symlink, back it up first:
```bash
mv ~/.config/<app-name> ~/.config/<app-name>.backup
```

## Adopting a Config Dir the App Already Created

If the app ran before stow (e.g. noctalia on first launch), `~/.config/<app>` is a real dir and stow can't fold it into a folder symlink. To adopt it into Juliet:

```bash
# 1. Stop the app first — running apps rewrite their config on exit/startup
#    and will clobber files moved out from under them
systemctl --user stop <app>  # or pkill

# 2. Move its files into the repo
mkdir -p ~/.config/Juliet/symlinked/config/<app>/
mv ~/.config/<app>/* ~/.config/Juliet/symlinked/config/<app>/

# 3. Remove the now-empty real dir and restow (creates the folder symlink)
rmdir ~/.config/<app>
stow --target=$HOME/.config --dir=$HOME/.config/Juliet/symlinked config

# 4. Restart the app and verify it reads/writes through the symlink
```

**Runtime-rewritten files** (e.g. noctalia's `settings.json`): only edit these while the app is stopped, or through the app's own UI — external edits made while it runs get overwritten when it next saves.

## Example: Adding Fuzzel Config

```bash
# Create directory
mkdir -p ~/.config/Juliet/symlinked/config/fuzzel/

# Create config file
# (write fuzzel.ini content)

# Stow it
stow --target=$HOME/.config --dir=$HOME/.config/Juliet/symlinked config

# Verify
ls -la ~/.config/fuzzel  # Should show symlink to Juliet
```

## Common Mistakes

- Creating files directly in `~/.config/` instead of `symlinked/config/`
- Forgetting to run `stow` after adding files
- Not checking if target folder already exists (could overwrite user data)
