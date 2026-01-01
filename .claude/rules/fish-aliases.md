# Fish Shell Aliases

Aliases are auto-loaded from `symlinked/config/fish/functions/aliases/` in alphabetical order.

## Git Shortcuts

| Alias | Command | Description |
|-------|---------|-------------|
| `g` | `git` | Git shorthand |
| `gut` | `git` | Typo-tolerant git |
| `ga` | `git commit -C @ --amend` | Amend commit with same message |
| `gl` | `git log -10` | Show last 10 commits |
| `gm` | `git rebase -i main` | Interactive rebase on main |
| `gdiff` | `git diff \| bat --diff` | Pretty diff with bat |
| `current-branch` | Get current branch name | |
| `cb` | Copy current branch to clipboard | |
| `current-sha` | Get current commit SHA | |
| `default-branch` | Detect main/master | |
| `commit <msg>` | Interactive commit with type/scope | Uses gum for prompts |
| `changed_files` | List modified files | |

## GitHub Functions

| Function | Description |
|----------|-------------|
| `_gh [file]` | Print GitHub URL for file |
| `glc [file]` | Copy GitHub URL to clipboard |
| `gho [file]` | Open file in GitHub browser |
| `clone <repo>` | Interactive clone (github/gitlab picker) |

## Tool Wrappers

| Alias | Wraps | Notes |
|-------|-------|-------|
| `cat` | `bat` | Syntax highlighting |
| `ls` | `eza` | Enhanced ls with `--oneline` |
| `dc` | `docker compose` | |
| `kc` | `kubectl` | |
| `pv` | `pipenv` | Auto-installs if missing, `pv i` = `pv install` |
| `nv` | `neovide` | Launches detached, auto-installs if missing |

## Workflow Functions

| Function | Description |
|----------|-------------|
| `work` | Fuzzy-find and cd to workspace directory |
| `run <workflow>` | Run GitHub Actions workflow and watch |
| `logs` | Tail GCloud app logs (interactive picker) |
| `note <text>` | Append timestamped note to ~/notes.txt |
| `envsource <file>` | Source .env file into fish environment |

## Utility Functions

| Function | Description |
|----------|-------------|
| `sudo !!` | Re-run last command with sudo |
