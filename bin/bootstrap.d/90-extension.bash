# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# extension: loading the user's extension repo (a core phase) and running
# its own setup steps (the last category).

# The extension's own steps (its bootstrap.bash defines extension-setup). Runs
# last, after packages and symlinks have been layered.
category extension rlog "🧩 Running extension setup..." \
  "Run your extension's setup steps?" \
  setup-extension-steps

# =============================================================================
# Extensions
# =============================================================================
# An extension is someone's own repo layered on top of Juliet: extra packages,
# packages to leave out, per-file config overrides, a gitconfig, fish config,
# .env template keys, and setup steps. JULIET_EXTENSION (env or
# ~/.config/local/.env) names it as a git URL or a local path. EXTENSIONS.md is
# the contract; extension-template/ is a starting point.
#
# .env files hold secrets. Nothing here prints a value from one: keys are read
# one at a time with sed, compared by name, and appended straight to the file.

# One key's value from ~/.config/local/.env (empty if absent).
read-local-env() {
  [[ -f "$LOCAL_ENV" ]] || return 0
  sed -nE "s/^$1=(.*)\$/\1/p" "$LOCAL_ENV" | tail -n 1
}

local-env-has-key() {
  [[ -f "$LOCAL_ENV" ]] && grep -qE "^$1=" "$LOCAL_ENV"
}

# Set one key in ~/.config/local/.env, replacing its line or appending one.
set-local-env() {
  local key="$1" value="$2" tmp
  mkdir -p "$(dirname "$LOCAL_ENV")"
  if local-env-has-key "$key"; then
    tmp=$(mktemp "$LOCAL_ENV.XXXXXX")
    awk -v k="$key" -v v="$value" 'index($0, k "=") == 1 { print k "=" v; next } { print }' "$LOCAL_ENV" > "$tmp"
    chmod 600 "$tmp"
    mv -f "$tmp" "$LOCAL_ENV"
  else
    (umask 077 && printf '%s=%s\n' "$key" "$value" >> "$LOCAL_ENV")
  fi
}

# Key names a .env-format file declares.
env-keys() {
  sed -nE 's/^([A-Za-z_][A-Za-z0-9_]*)=.*/\1/p' "$1"
}

# Bring a .env.template's keys into ~/.config/local/.env. A missing .env is
# created from the template; otherwise only keys the .env lacks entirely are
# appended (with the template's value, usually blank). Existing lines are never
# touched, and only key names are printed.
merge-env-template() {
  local template="$1" label="$2" key
  [[ -f "$template" ]] || return 0
  mkdir -p "$(dirname "$LOCAL_ENV")"

  if [[ ! -f "$LOCAL_ENV" ]]; then
    (umask 077 && cp "$template" "$LOCAL_ENV")
    chmod 600 "$LOCAL_ENV"
    notice "Created ~/.config/local/.env from the $label .env.template — fill in: $(env-keys "$template" | paste -sd ' ' -)"
    return
  fi

  local -a added=()
  while read -r key; do
    local-env-has-key "$key" || added+=("$key")
  done < <(env-keys "$template")
  (( ${#added[@]} > 0 )) || return 0

  {
    printf '\n# added from %s .env.template\n' "$label"
    for key in "${added[@]}"; do
      grep -m 1 -E "^$key=" "$template"
    done
  } >> "$LOCAL_ENV"
  notice "Added to ~/.config/local/.env from the $label .env.template: ${added[*]}"
}

is-git-url() {
  [[ "$1" =~ ^(https?://|ssh://|git://|git@) ]]
}

# Expose the extension at $EXTENSION_DIR: clone (then fast-forward) a git URL,
# or symlink a local path. Never deletes a real directory.
link-extension() {
  local src="$1"
  if is-git-url "$src"; then
    if [[ -L "$EXTENSION_DIR" ]]; then
      rm "$EXTENSION_DIR"
    fi
    if [[ -d "$EXTENSION_DIR/.git" ]]; then
      local origin
      origin=$(git -C "$EXTENSION_DIR" remote get-url origin 2> /dev/null || true)
      if [[ "$origin" != "$src" ]]; then
        bootstrap_error "~/.config/juliet-extension is a clone of $origin, but JULIET_EXTENSION is $src." \
          "Move it aside (or fix JULIET_EXTENSION), then re-run: juliet-bootstrap"
        return 1
      fi
      if ! git -C "$EXTENSION_DIR" diff --quiet 2> /dev/null; then
        skip "unstaged changes in ~/.config/juliet-extension — not pulling"
      else
        spin "Updating extension..." git -C "$EXTENSION_DIR" pull --ff-only -q \
          || warn "Could not fast-forward ~/.config/juliet-extension — using it as is."
      fi
    elif [[ -e "$EXTENSION_DIR" ]]; then
      bootstrap_error "~/.config/juliet-extension exists but isn't a git clone." \
        "Move it aside, then re-run: juliet-bootstrap"
      return 1
    else
      spin "Cloning extension $src..." git clone -q "$src" "$EXTENSION_DIR" || {
        bootstrap_error "Failed to clone extension $src" \
          "Check the URL and your git access, then re-run: juliet-bootstrap"
        return 1
      }
    fi
  else
    local path="${src/#\~/$HOME}"
    if [[ ! -d "$path" ]]; then
      bootstrap_error "JULIET_EXTENSION points at $path, which isn't a directory." \
        "Fix JULIET_EXTENSION in ~/.config/local/.env, then re-run: juliet-bootstrap"
      return 1
    fi
    if [[ -L "$EXTENSION_DIR" || ! -e "$EXTENSION_DIR" ]]; then
      ln -sfn "$path" "$EXTENSION_DIR"
    else
      bootstrap_error "~/.config/juliet-extension is a real directory, but JULIET_EXTENSION is a local path." \
        "Move it aside, then re-run: juliet-bootstrap"
      return 1
    fi
  fi
}

# .env files an extension repo commits, other than .env.template (names only).
extension-tracked-env-files() {
  git -C "$EXTENSION_DIR" rev-parse --git-dir &> /dev/null || return 0
  git -C "$EXTENSION_DIR" ls-files \
    | grep -E '(^|/)\.env($|\.)' \
    | grep -vE '(^|/)\.env\.template$' \
    || true
}

# Excludes match a line's package name: its first quoted string (Brewfile) or
# first word (DNFfile/Flatpakfile); copr/remote/tap lines are never dropped.
# Prints the combined file's path: Juliet's file minus the extension's
# `exclude` names, plus the extension's own file. Juliet's path when the
# extension changes nothing.
build-package-file() {
  local base="$1" name="$2"
  local ext="$EXTENSION_DIR/$name" exclude="$EXTENSION_DIR/exclude"
  if [[ ! -f "$ext" && ! -f "$exclude" ]]; then
    printf '%s\n' "$base"
    return
  fi
  local out
  out=$(mktemp "${TMPDIR:-/tmp}/juliet-$name.XXXXXX")
  {
    if [[ -f "$exclude" ]]; then
      awk '
        NR == FNR {
          sub(/#.*/, ""); gsub(/^[[:space:]]+|[[:space:]]+$/, "")
          if ($0 != "") drop[$0] = 1
          next
        }
        {
          line = $0; pkg = ""
          if (line ~ /^[[:space:]]*(brew|cask|vscode|mas)[[:space:]]+"/) {
            pkg = line; sub(/^[^"]*"/, "", pkg); sub(/".*/, "", pkg)
          } else if (line !~ /^[[:space:]]*(#|$|copr[[:space:]]|remote[[:space:]]|tap[[:space:]])/) {
            pkg = line; sub(/^[[:space:]]+/, "", pkg); sub(/[[:space:]].*/, "", pkg)
          }
          short = pkg; sub(/.*\//, "", short)
          if (pkg != "" && (pkg in drop || short in drop)) next
          print
        }' "$exclude" "$base"
    else
      cat "$base"
    fi
    if [[ -f "$ext" ]]; then
      printf '\n# --- from the extension (%s) ---\n' "$name"
      cat "$ext"
    fi
  } > "$out"
  printf '%s\n' "$out"
}

setup-extension() {
  substep "Checking Juliet extension..."
  local first_run="false"
  local-env-has-key JULIET_EXTENSION || first_run="true"
  merge-env-template "$JULIET_DIR/.env.template" "Juliet"

  local src="${JULIET_EXTENSION:-$(read-local-env JULIET_EXTENSION)}"
  # Ask once, on the run that first adds the key, so machines without an
  # extension aren't asked every time.
  if [[ -z "$src" && "$first_run" == "true" && -t 0 && "$YES_ALL" != "true" && "$NO_ALL" != "true" ]] \
    && should-run-step extension && command -v gum &> /dev/null; then
    _step_close
    src=$(gum input --header "Juliet extension (git URL or path) — Enter to skip; see EXTENSIONS.md" \
      --placeholder "https://github.com/you/juliet-you.git") || src=""
    [[ -n "$src" ]] && set-local-env JULIET_EXTENSION "$src"
  fi

  if [[ -z "$src" ]]; then
    if [[ -L "$EXTENSION_DIR" ]]; then
      rm "$EXTENSION_DIR"
      notice "Unlinked ~/.config/juliet-extension (JULIET_EXTENSION is empty)"
    elif [[ -d "$EXTENSION_DIR" ]]; then
      warn "JULIET_EXTENSION is empty but ~/.config/juliet-extension is still there; its gitconfig and fish hooks stay active until you remove it."
    fi
    unchanged "no extension"
    return
  fi

  link-extension "$src" || return 0

  local tracked
  tracked=$(extension-tracked-env-files)
  if [[ -n "$tracked" ]]; then
    bootstrap_error "The extension commits .env files — refusing to use it: $(paste -sd ' ' - <<< "$tracked")" \
      "Untrack them (git rm --cached), add them to its .gitignore, and rotate any secrets they held." \
      "Commit a .env.template with blank values instead."
    return 0
  fi

  EXTENSION_ACTIVE="true"
  merge-env-template "$EXTENSION_DIR/.env.template" "$(basename "${src%.git}")"
  JULIET_BREWFILE=$(build-package-file "$JULIET_DIR/Brewfile" Brewfile)
  JULIET_DNFFILE=$(build-package-file "$JULIET_DIR/DNFfile" DNFfile)
  JULIET_FLATPAKFILE=$(build-package-file "$JULIET_DIR/Flatpakfile" Flatpakfile)
  if [[ -f "$EXTENSION_DIR/bootstrap.bash" ]]; then
    # shellcheck source=/dev/null
    source "$EXTENSION_DIR/bootstrap.bash"
  fi
  unchanged "using $(basename "${src%.git}")"
}

# Extension override files ("home/<path>" → ~/<path>, "config/<path>" →
# ~/.config/<path>), one "source<TAB>target<TAB>relpath<TAB>package" per line.
extension-overrides() {
  [[ "$EXTENSION_ACTIVE" == "true" ]] || return 0
  local pkg target_root f rel
  for pkg in home config; do
    [[ -d "$EXTENSION_DIR/$pkg" ]] || continue
    [[ "$pkg" == home ]] && target_root="$HOME" || target_root="$HOME/.config"
    while IFS= read -r f; do
      rel="${f#"$EXTENSION_DIR/$pkg/"}"
      printf '%s\t%s\t%s\t%s\n' "$f" "$target_root/$rel" "$rel" "$pkg"
    done < <(find "$EXTENSION_DIR/$pkg/" -type f ! -name .DS_Store ! -name .gitkeep)
  done
}

# Before stowing: keep stow away from overridden files (it would see the
# extension's link as a foreign file and abort the whole tree), and make each
# override's parent a real directory so stow doesn't fold it into a symlink to
# Juliet (writing the override there would land it in the repo).
prepare-extension-overrides() {
  local src target rel pkg parent
  while IFS=$'\t' read -r src target rel pkg; do
    STOW_IGNORES+=(--ignore="^$(printf '%s' "$rel" | sed 's/[][\.*^$+?(){}|]/\\&/g')\$")
    parent=$(dirname "$target")
    [[ -e "$parent" ]] || mkdir -p "$parent"
  done < <(extension-overrides)
}

# After stowing: link each override into place. Skips any target whose parent
# resolves inside Juliet (a folded stow dir) rather than writing into the repo.
link-extension-overrides() {
  local src target rel pkg parent real_parent juliet_real
  juliet_real=$(cd "$JULIET_DIR" && pwd -P)
  while IFS=$'\t' read -r src target rel pkg; do
    parent=$(dirname "$target")
    real_parent=$(cd "$parent" 2> /dev/null && pwd -P) || continue
    if [[ "$real_parent/" == "$juliet_real/"* ]]; then
      warn "Not overriding ~/${target#"$HOME/"}: its folder is a symlink into Juliet (see EXTENSIONS.md)."
      continue
    fi
    if [[ -e "$target" && ! -L "$target" ]]; then
      mv -f "$target" "$target.pre-extension.bak"
      notice "Previous $(basename "$target") saved as $target.pre-extension.bak"
    fi
    if [[ "$(readlink "$target" 2> /dev/null)" != "$src" ]]; then
      ln -sfn "$src" "$target"
      links=$(( ${links:-0} + 1 ))
    fi
  done < <(extension-overrides)
}

setup-extension-steps-applicable() {
  # --list runs before setup-extension loads the extension, so only the
  # configured URL/path is known; whether it defines steps is decided at run time.
  if [[ "$LIST_ONLY" == "true" ]]; then
    # A blank `JULIET_EXTENSION=` (the .env.template placeholder) means none.
    [[ -f "$LOCAL_ENV" ]] && grep -qE '^JULIET_EXTENSION=.' "$LOCAL_ENV" && return 0
    NA_REASON="no extension — set JULIET_EXTENSION in ~/.config/local/.env"
    return 1
  fi
  if [[ "$EXTENSION_ACTIVE" != "true" ]]; then
    NA_REASON="no extension — set JULIET_EXTENSION in ~/.config/local/.env"
    return 1
  fi
  if ! declare -F extension-setup > /dev/null; then
    NA_REASON="the extension defines no extension-setup"
    return 1
  fi
}

setup-extension-steps() { extension-setup; }
