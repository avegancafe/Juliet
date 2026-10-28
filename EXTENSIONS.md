# Juliet extensions

An extension is your own repo layered on top of Juliet, so you can run
Juliet's `main` as-is and keep everything personal (extra apps, your git
login, your Claude settings, your own setup steps) somewhere you own.
Kyle's own setup is one: [avegancafe/juliet-kyle](https://github.com/avegancafe/juliet-kyle).
A team can share one too: [avegancafe/juliet-j2](https://github.com/avegancafe/juliet-j2)
holds J2's work setup and nothing personal.
Start from [`extension-template/`](extension-template/).

## Pointing Juliet at an extension

Set `JULIET_EXTENSION` in `~/.config/local/.env` (machine-local, never
committed), then run `juliet-bootstrap`:

```
JULIET_EXTENSION=https://github.com/you/juliet-you.git  # cloned, pulled every run
JULIET_EXTENSION=~/workspace/juliet-you              # a local checkout, symlinked
```

Use an HTTPS URL for a public extension: bootstrap clones it before it sets up
SSH keys, so a `git@` URL fails on a fresh machine. The first bootstrap on a
machine asks for it once if the key is missing. Either way,
each extension is exposed at `~/.config/juliet-extensions/<name>` (its repo or
folder name). Remove one from the list to stop using it: a path extension is
unlinked, a cloned one stays until you delete that directory.

### Several extensions

List them space-separated, quoted, in the order they apply:

```
JULIET_EXTENSION="https://github.com/avegancafe/juliet-j2.git ~/workspace/juliet-you"
```

A common split is a work extension plus a personal one, so a personal laptop
lists only the personal one and gets nothing from work. Later extensions win
where they conflict (the same `home/`/`config/` file, or the same Claude
setting); packages, excludes, `.env.template` keys, gitconfigs, fish configs
and setup steps from all of them apply, in order. Names must differ. Prefix
your step functions (`setup-you-*`): every `bootstrap.bash` is sourced into the
same shell.

## What an extension can contain

Every file is optional.

| File | Effect |
|------|--------|
| `Brewfile`, `DNFfile`, `Flatpakfile` | Appended to Juliet's. Declare taps/coprs/remotes you use: bootstrap prunes undeclared ones |
| `exclude` | Juliet packages to skip, one name per line (`codex`, or `someone/tap/thing`). Stops installs only; never uninstalls |
| `home/<path>`, `config/<path>` | Replaces Juliet's copy of `~/<path>` / `~/.config/<path>`. The whole file is replaced: you stop getting Juliet's changes to it |
| `claude/settings.json` | Merged into the generated `~/.claude/settings.json` (see below) |
| `gitconfig` | Included by Juliet's `~/.gitconfig`, before `~/.config/local/gitconfig` |
| `fish/config.fish` | Sourced by every fish shell, before `~/.config/local/fish/config.fish` |
| `.env.template` | Keys merged into `~/.config/local/.env` (see below) |
| `bootstrap.bash` | Define `extension-setup` to run your own steps last, as the `extension` category (`juliet-bootstrap --enable=extension`). Each extension's is sourced and run in turn, with `$EXTENSION_DIR` set to it |

### Claude settings

`~/.claude/settings.json` is generated, not linked: Juliet's
`etc/claude/settings.json`, then each extension's `claude/settings.json` in
order, then `~/.config/local/claude/settings.json` (machine-only, never
committed: the place for anything private). Objects merge key by key, arrays
such as `permissions.allow` are appended without duplicates, and any other
value is replaced by the later layer (so `"enabledPlugins": {"x@y": false}`
turns a plugin off).

Claude Code also writes to this file (plugin toggles, `/config`). Those
changes aren't saved anywhere else. If the file changed since bootstrap last
wrote it, bootstrap names the keys and asks before replacing it, so move the
change into a layer first. An extension that still ships
`home/.claude/settings.json` replaces the whole file and skips the merge.

### Overrides and folded folders

Stow links some folders whole (e.g. `~/.config/fish/completions` → Juliet).
A file inside one of those can't be overridden without writing into Juliet,
so bootstrap skips it with a warning. Bootstrap creates an override's parent
folder before stowing, so this only happens for folders that already exist as
a link.

### Helpers `bootstrap.bash` can use

These are kept stable for extensions: `spin "Doing x..." cmd args`,
`substep "Doing x..."`, `skip "why"`, `notice`, `warn`,
`bootstrap_error "summary" "hint..."` (records a failure, doesn't exit),
`is-macos`, `is-fedora`, `gum-confirm "question?"` (respects `-y`/`-n`), and
`$EXTENSION_DIR` (the running extension's directory). Anything else in `bin/juliet-bootstrap` or `bin/bootstrap.d/` may change.

## Secrets and `.env`

- **Never commit a `.env`.** Commit a `.env.template` with blank values (or
  harmless defaults) instead. `extension-template/.gitignore` already ignores
  `.env` and `.env.*` except the template. Bootstrap refuses to use an
  extension that tracks any other `.env*` file.
- **Public extensions.** If yours is public, keep internal details out of it as
  well: hostnames, cluster, bucket and project names. Put those in
  `~/.config/local/claude/settings.json` or a private repo.
- **Merging.** Bootstrap merges Juliet's `.env.template`, then the
  extension's, into `~/.config/local/.env`. If that file doesn't exist, it's
  copied from the template (mode 600). Otherwise only keys the file doesn't
  have at all are appended, with the template's value, under a
  `# added from <name> .env.template` comment. A key that's present but blank
  counts as set. Existing lines are never changed.
- **Never printed.** Bootstrap only prints key names, never values.
- **AI guard.** Juliet's Claude settings deny reading `~/.config/local/.env`
  and `.env`, `.env.local`, `.env.development`, `.env.production`,
  `.env.staging` and `.env.test` anywhere. The deny also covers Bash file
  commands like `cat`, `head` and `sed`. `.env.template` stays readable. A
  `claude/settings.json` fragment keeps that list (arrays only grow); if your
  extension replaces `home/.claude/settings.json` instead, copy it over. This stops the file being read, not the values being seen: fish
  exports every `.env` value into each shell's environment, so `env`,
  `printenv` or `echo $KEY` in any shell (including an AI's) still show them.

## Example: turning a personal branch into an extension

Changes that used to live on a personal branch, and where they go now:

| Branch change | Extension home |
|---------------|----------------|
| Extra `brew`/`cask`/`vscode` lines in the Brewfile | `Brewfile` |
| Removing Juliet casks you don't want (`codex`, …) | `exclude` |
| `[github] user = you` in `.gitconfig` | `gitconfig` |
| A PATH line in `fish/config.fish` (e.g. Docker Desktop) | `fish/config.fish`, written with `~` rather than an absolute home path |
| Extra Claude plugins, marketplaces or permissions | `claude/settings.json` (a fragment) |
| `nvim/lazy-lock.json`, spellfile churn | Leave out; not personal config |
