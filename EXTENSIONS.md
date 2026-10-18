# Juliet extensions

An extension is your own repo layered on top of Juliet, so you can run
Juliet's `main` as-is and keep everything personal (extra apps, your git
login, your Claude settings, your own setup steps) somewhere you own.
Kyle's own setup is one: [avegancafe/juliet-kyle](https://github.com/avegancafe/juliet-kyle).
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
the extension is exposed at `~/.config/juliet-extension`. Clear the value to stop
using a path extension; a cloned one stays until you delete that directory.

## What an extension can contain

Every file is optional.

| File | Effect |
|------|--------|
| `Brewfile`, `DNFfile`, `Flatpakfile` | Appended to Juliet's. Declare taps/coprs/remotes you use: bootstrap prunes undeclared ones |
| `exclude` | Juliet packages to skip, one name per line (`cursor`, or `someone/tap/thing`). Stops installs only; never uninstalls |
| `home/<path>`, `config/<path>` | Replaces Juliet's copy of `~/<path>` / `~/.config/<path>` (e.g. `home/.claude/settings.json`). The whole file is replaced: you stop getting Juliet's changes to it |
| `gitconfig` | Included by Juliet's `~/.gitconfig`, before `~/.config/local/gitconfig` |
| `fish/config.fish` | Sourced by every fish shell, before `~/.config/local/fish/config.fish` |
| `.env.template` | Keys merged into `~/.config/local/.env` (see below) |
| `bootstrap.bash` | Sourced by bootstrap. Define `extension-setup` to run your own steps last, as the `extension` category (`juliet-bootstrap --enable=extension`) |

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
`$EXTENSION_DIR`. Anything else in `bin/juliet-bootstrap` may change.

## Secrets and `.env`

- **Never commit a `.env`.** Commit a `.env.template` with blank values (or
  harmless defaults) instead. `extension-template/.gitignore` already ignores
  `.env` and `.env.*` except the template. Bootstrap refuses to use an
  extension that tracks any other `.env*` file.
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
  commands like `cat`, `head` and `sed`. `.env.template` stays readable. If
  your extension replaces `home/.claude/settings.json`, copy that `deny` list
  over. This stops the file being read, not the values being seen: fish
  exports every `.env` value into each shell's environment, so `env`,
  `printenv` or `echo $KEY` in any shell (including an AI's) still show them.

## Example: turning a personal branch into an extension

Changes that used to live on a personal branch, and where they go now:

| Branch change | Extension home |
|---------------|----------------|
| Extra `brew`/`cask`/`vscode` lines in the Brewfile | `Brewfile` |
| Removing Juliet casks you don't want (`cursor`, …) | `exclude` |
| `[github] user = you` in `.gitconfig` | `gitconfig` |
| A PATH line in `fish/config.fish` (e.g. Docker Desktop) | `fish/config.fish`, written with `~` rather than an absolute home path |
| A different `~/.claude/settings.json` | `home/.claude/settings.json` |
| `nvim/lazy-lock.json`, spellfile churn | Leave out; not personal config |
