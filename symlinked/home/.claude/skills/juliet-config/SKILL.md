---
name: juliet-config
description: Use when Kyle is changing or asking about his computer configuration — installing or removing a package, dotfiles, fish/shell aliases, editor/terminal/desktop/keyboard config, system services, or "how do I get X on my mac / on Fedora". Frames the request as "within Juliet (~/.config/Juliet), the scripted macOS + Fedora setup", and covers orientation, the managed-vs-ad-hoc decision, both-OS coverage, the no-sudo rule, and the report.
---

# Juliet: changing Kyle's computer config

Juliet (`~/.config/Juliet`, repo `avegancafe/Juliet`) is Kyle's scripted computer setup: a fresh **macOS** or **Fedora** machine becomes a complete, consistent setup by cloning it and running `~/.config/Juliet/bin/juliet-bootstrap`. A config request means **"in Juliet, X"**, even when the user doesn't say so. "Add ripgrep" means "declare ripgrep in Juliet for both OSes", not "run an install command".

## Orient before changing anything

1. **Detect the OS** you're running on: `/etc/fedora-release` exists → Fedora; `$OSTYPE` is `darwin*` → macOS. You can only test on this OS, so be explicit about what's untested on the other one.
2. **Read Juliet's own guidance.** It doesn't load automatically outside the repo:
   - `~/.config/Juliet/.claude/CLAUDE.md` — always. It holds the managed-vs-ad-hoc rule and the "where a change belongs" table.
   - `~/.config/Juliet/.claude/rules/*.md` — only the ones that apply (`architecture.md` for stow, `local-config.md` for `~/.config/local/`, `fish-aliases.md`, `theming.md`, `niri.md`).
   - `~/.config/Juliet/EXTENSIONS.md` — when the change might be personal to Kyle rather than part of the shared setup.
3. Run `git -C ~/.config/Juliet status` and note any uncommitted work that isn't yours.

Work in `~/.config/Juliet` using absolute paths, whatever directory the session started in. The one exception: if the session is already in a Juliet worktree, work there.

## Rules

- **Managed or ad-hoc? Decide every time, and say which out loud.** Managed is the default: the change lives in the repo, so it reproduces on the next machine. Ad-hoc means this machine only (secrets, specific hardware, experiments) and goes in `~/.config/local/`. Ask the user only if it's genuinely unclear.
- **Cover both OSes.** Use the `juliet-cross-platform` skill for every change:
  - If it makes sense on both OSes, implement it on both: the Brewfile *and* the DNFfile/Flatpakfile, plus both config variants.
  - If it only fits one OS, say so and gate it with a `-applicable` check or a fish `switch (uname)`.
  - Never silently implement only the OS you happen to be on.
- **No sudo.** Your Bash tool can't answer a password prompt. Script anything system-level as a bootstrap step (`juliet-bootstrap-step` skill), then give the user the exact command to run, e.g. `juliet-bootstrap --enable=keyd`. Don't hand out one-off `sudo` commands for something bootstrap should own.
- **Dotfiles:** edit only under `~/.config/Juliet/symlinked/`, never the symlink targets in `~` or `~/.config`, and never delete or recreate links by hand. New app configs: `add-app-config` skill. Fish functions: `add-fish-alias` skill.
- **Shared or personal? Decide every time.** Kyle's own apps, accounts and taste (e.g. HEY, Obsidian, his GitHub user) go in the extension repo `~/workspace/juliet-kyle`, not in Juliet. J2 work setup (J2 plugins, dev-env, work CLIs) goes in the public extension `~/workspace/juliet-j2`, so personal machines stay J2-free. `~/.claude/settings.json` is generated from layers: edit `etc/claude/settings.json` or an extension's `claude/settings.json`, never the generated file. The `juliet-extension` skill covers the split, where each kind of change lives there, and why an extension edit only applies after a push and `juliet-bootstrap --enable=extension`.
- **Package sources are declarative:** Brewfile `tap` lines and DNFfile `copr` lines are the full list, and bootstrap removes any that aren't declared. Never tap or enable a repo by hand.
- **Git and tasks:** don't commit or push unless asked. Use `bd` (beads) for task tracking in this repo, not markdown TODOs.

## Report back

End with:
- the files you changed (absolute paths);
- OS coverage — what applies on macOS, what applies on Fedora, and what you couldn't test;
- the managed/ad-hoc call;
- the exact command the user runs to apply it (`juliet-bootstrap`, `juliet-bootstrap --enable=<step>`, re-stow, or "open a new shell").
