---
name: juliet-cross-platform
description: Use when changing Kyle's Juliet setup (~/.config/Juliet) in a way that touches packages or OS-specific config — adding/removing a package, porting a config from macOS to Fedora or back, or deciding whether something belongs on one OS or both. Maps Brewfile ↔ DNFfile/Flatpakfile and the macOS ↔ Fedora equivalents.
---

# Juliet: macOS ↔ Fedora

> **Personal, not shared?** If this is Kyle's own taste rather than something any Juliet user would want, it goes in `~/workspace/juliet-kyle` instead. See the `juliet-extension` skill for the equivalent file there.

Juliet targets two OSes. Every change answers **"what happens on the other one?"** All paths below are under `~/.config/Juliet/`.

## Which package file?

| OS | File | Line formats | Applied by |
|----|------|--------------|------------|
| macOS | `Brewfile` | `tap "user/repo"`, `brew "name"`, `brew "user/tap/name"`, `cask "app"` | `setup-brew` (macOS only) |
| Fedora | `DNFfile` | `copr user/repo`, `<package>` (one per line, `#` comments) | `setup-dnf` |
| Fedora | `Flatpakfile` | `remote <name> <url>`, `<app-id>` | `setup-flatpak` |

- Homebrew **is installed on Fedora too**, but only for taps and brew's rust. The Brewfile does **not** install packages there. A CLI tool on Fedora goes in the DNFfile.
- **GUI apps:** `cask` on macOS. On Fedora, prefer a DNF package (or a COPR); fall back to Flathub in the `Flatpakfile`.
- **Not packaged for an OS?** Use a step in `bin/bootstrap.d/30-dev.bash`:
  - `setup-cargo`, `setup-go-tools`, `setup-node-tools`, `setup-python` (uv);
  - or a dedicated curl-install step, e.g. `setup-beads` / `setup-flyctl`.
  - Gate the step to the OS that needs it with `-applicable`.
- **Names differ between ecosystems.** Check before writing:
  - Fedora: `dnf search <x>` / `dnf info <x>`.
  - macOS: `brew info <x>` (from Fedora, check formulae.brew.sh instead).
  - Typical mismatches: `fd` (brew) vs `fd-find` (dnf); dev headers are `*-devel` on Fedora.
- **Sources are declarative:** `tap` / `copr` lines are the full list, and bootstrap untaps or `copr remove`s anything undeclared. A new COPR always goes in the DNFfile.
- Removing a package: delete it from the file on **both** OSes. `bin/brew-uninstall-removed <commit>` uninstalls what a commit removed from the Brewfile.

## Gating config to one OS

- **Bootstrap step:** `setup-foo-applicable() { is-fedora; }` (or `is-macos`). The helpers live in `bin/bootstrap.d/00-common.bash`. Also add a defensive `if ! is-fedora; then return; fi` inside the step, as `setup-keyd` does.
- **Fish:** branch on `uname`, sourcing an OS-specific file. Pattern from `symlinked/config/fish/initializers/ssh.fish`:
  ```fish
  switch (uname)
      case Darwin
          source (dirname (status filename))/ssh-macos.fish
  end
  ```
- **Stowed config for an app that exists on only one OS** is harmless on the other: it's just an unused dotfile. Don't add gating unless the file would break something there.

## What exists where

| Concern | macOS | Fedora |
|---------|-------|--------|
| Key remapping | Karabiner (`symlinked/config/karabiner/`) | keyd (`etc/keyd/` → `/etc/keyd`, `setup-keyd`) |
| Window management / automation | Hammerspoon (`symlinked/home/.hammerspoon/`) | niri (`symlinked/config/niri/`, rule `.claude/rules/niri.md`); hypr configs also exist |
| Bar / shell UI | macOS menu bar | noctalia (`symlinked/config/noctalia/`) |
| Launcher | Spotlight | fuzzel (`symlinked/config/fuzzel/`) |
| Login screen | — | sddm (`etc/sddm*`, `setup-sddm`) |
| GTK theming | — | `symlinked/config/gtk-3.0`, `gtk-4.0` |
| Sudo auth | Touch ID (`setup-touchid-sudo`) | fingerprint (`setup-fingerprint`, hardware-gated) |
| Packages | Brewfile | DNFfile + Flatpakfile |
| System files | `defaults` / scripted steps | `etc/<app>/` + `install-system-file` |

Shared on both OSes: fish, ghostty, nvim, tmux, git, starship, bat, btop, yazi, helix, Claude/opencode configs. Changes to these need no gating, but check for hard-coded paths (`/opt/homebrew` vs `/home/linuxbrew/.linuxbrew`, `pbcopy` vs `wl-copy`, `open` vs `xdg-open`).

## Porting checklist

1. Is the tool or app available on the target OS? Find its package name, or the equivalent app (table above).
2. Declare the package in the target OS's file.
3. Does the config work as-is? Look for hard-coded paths, clipboard and open commands, and key names (Cmd vs Super).
4. If the config needs to differ, branch it (fish `switch (uname)`, or OS-specific files).
5. Does the change need root on the target OS? Write a bootstrap step (`juliet-bootstrap-step` skill).
6. In your report, say what you verified on this machine and what is untested on the other OS.
