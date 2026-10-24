---
name: juliet-bootstrap-step
description: Use when a change to Kyle's Juliet setup (~/.config/Juliet) is system-level — needs sudo, a service, a file under /etc, a system default, a daemon, or an install that isn't a plain package — and so must become (or modify) a setup-* step in bin/juliet-bootstrap's bootstrap.d modules.
---

# Juliet: add or change a bootstrap step

Claude can't run `sudo`, so anything system-level is scripted into bootstrap and the user runs it. All paths are under `~/.config/Juliet/`.

## Where steps live

`bin/juliet-bootstrap` sources `bin/bootstrap.d/*.bash` in order. There is one module per category:

| Module | Category | Holds |
|--------|----------|-------|
| `00-common.bash` | — | helpers: `category`, `is-macos`, `is-fedora`, `install-system-file` |
| `05-core.bash` | always runs | git, stow (`symlink-dotfiles`) |
| `10-packages.bash` | packages | brew / dnf + copr / flatpak |
| `20-fonts.bash` | fonts | |
| `30-dev.bash` | dev | cargo, go, rust, python, node, curl-installed tools |
| `40-shell.bash` | shell | fish, fzf, tmux plugins |
| `50-security.bash` | security | ssh, gpg |
| `60-desktop.bash` | desktop (Fedora) | sddm, keyd, nvidia, fingerprint, coredump |
| `70-claude.bash` / `80-opencode.bash` | claude / opencode | |
| `90-extension.bash` | extension | runs the personal extension repo |

## Recipe

1. **Write the function** `setup-<name>()` in the matching module. Its CLI name drops the prefix (`setup-keyd` → `--enable=keyd`).
2. **Register it** by adding it to that module's `category <name> <log|rlog> "<header>" "<question>" setup-a setup-b …` line, in run order. Use `rlog` for categories that hit the network. Without this, the step never runs.
3. **Gate it** when it only fits some machines: `setup-<name>-applicable() { is-fedora; }`. Keep it cheap and read-only (OS, `command -v`, `rpm -q`, a sysfs check). Set `NA_REASON="…"` to explain the skip in `--list`.
4. **Make it converge, not create-once.** Re-runs must be safe and should report "unchanged":
   - A tracked file for a root-owned path lives in `etc/<app>/` and is installed with `install-system-file "$JULIET_DIR/etc/<app>/<file>" /etc/<path> [mode]`. It returns 0 = wrote, 1 = already current, 2 = failed (already reported).
   - Check the current state before acting (`systemctl is-enabled/is-active`, `cmp`, `grep`).
5. **Log with the helpers** (from `_util.bash` / `bin/juliet-bootstrap`):
   - `substep "Doing x..."` opens a step;
   - `unchanged "why"` when nothing was needed;
   - `notice` / `warn` for messages;
   - `bootstrap_error "what failed" "how to fix it manually"` on failure (it collects errors rather than aborting).
6. **Validate:** `bash -n bin/bootstrap.d/<module>.bash`, then `shellcheck` if it's installed.

Canonical example — `setup-keyd` in `bin/bootstrap.d/60-desktop.bash`: OS guard → `command -v` guard → `substep` → `install-system-file` → skip with `unchanged` if the file is current and the service is running → `sudo systemctl enable --now` with a `bootstrap_error` fallback.

## Hand off to the user

- See what would run: `~/.config/Juliet/bin/juliet-bootstrap --list`
- Run just this step: `~/.config/Juliet/bin/juliet-bootstrap --enable=<name>`. Naming a category runs all of its steps; `--skip=<name>` excludes one.
- For a command the user runs through `!` in Claude Code: keep it one line (fish). Note that sudo prompts still fail without a TTY, so tell them to run it in a real terminal.

If the step only applies to Kyle personally, put it in the extension repo (`~/workspace/juliet-kyle`, `extension-setup`) instead. See `EXTENSIONS.md` and the `juliet-extension` skill (extension steps may use only the stable helpers, and they apply only after a push).
