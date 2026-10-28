# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# extension: loading the user's extension repos (a core phase) and running
# its own setup steps (the last category).

# The extensions' own steps (each bootstrap.bash defines extension-setup). Runs
# last, after packages and symlinks have been layered.
category extension rlog "🧩 Running extension setup..." \
  "Run your extension's setup steps?" \
  setup-extension-steps

# =============================================================================
# Extensions
# =============================================================================
# An extension is someone's own repo layered on top of Juliet: extra packages,
# packages to leave out, per-file config overrides, a gitconfig, fish config,
# .env template keys, a Claude settings fragment, and setup steps.
# JULIET_EXTENSION (env or ~/.config/local/.env) lists one or more, in order,
# as git URLs or local paths; each is exposed at ~/.config/juliet-extensions/<name>.
# EXTENSIONS.md is the contract; extension-template/ is a starting point.
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

# An extension's name: its URL or path basename, minus any .git suffix.
extension-name() {
  local src="${1%/}"
  src="${src%.git}"
  printf '%s\n' "${src##*/}"
}

# Expose one extension at $dir (~/.config/juliet-extensions/<name>): clone
# (then fast-forward) a git URL, or symlink a local path. Never deletes a real
# directory.
link-extension() {
  local src="$1" dir="$2" shown
  # shellcheck disable=SC2088  # a display path, not one to expand
  shown="~/.config/juliet-extensions/$(basename "$dir")"
  if is-git-url "$src"; then
    if [[ -L "$dir" ]]; then
      rm "$dir"
    fi
    if [[ -d "$dir/.git" ]]; then
      local origin
      origin=$(git -C "$dir" remote get-url origin 2> /dev/null || true)
      if [[ "$origin" != "$src" ]]; then
        bootstrap_error "$shown is a clone of $origin, but JULIET_EXTENSION lists $src." \
          "Move it aside (or fix JULIET_EXTENSION), then re-run: juliet-bootstrap"
        return 1
      fi
      if ! git -C "$dir" diff --quiet 2> /dev/null; then
        skip "unstaged changes in $shown — not pulling"
      else
        spin "Updating extension $(basename "$dir")..." git -C "$dir" pull --ff-only -q \
          || warn "Could not fast-forward $shown — using it as is."
      fi
    elif [[ -e "$dir" ]]; then
      bootstrap_error "$shown exists but isn't a git clone." \
        "Move it aside, then re-run: juliet-bootstrap"
      return 1
    else
      spin "Cloning extension $src..." git clone -q "$src" "$dir" || {
        bootstrap_error "Failed to clone extension $src" \
          "Check the URL and your git access, then re-run: juliet-bootstrap"
        return 1
      }
    fi
  else
    local path="${src/#\~/$HOME}"
    if [[ ! -d "$path" ]]; then
      bootstrap_error "JULIET_EXTENSION lists $path, which isn't a directory." \
        "Fix JULIET_EXTENSION in ~/.config/local/.env, then re-run: juliet-bootstrap"
      return 1
    fi
    if [[ -L "$dir" || ! -e "$dir" ]]; then
      ln -sfn "$path" "$dir"
    else
      bootstrap_error "$shown is a real directory, but JULIET_EXTENSION lists a local path for it." \
        "Move it aside, then re-run: juliet-bootstrap"
      return 1
    fi
  fi
}

# Before multi-extension support, the one extension lived at
# ~/.config/juliet-extension. Drop that symlink; move a clone into the new
# root when JULIET_EXTENSION still lists its origin, otherwise leave it alone.
migrate-legacy-extension() {
  local legacy="$HOME/.config/juliet-extension" src
  [[ -L "$legacy" ]] && { rm "$legacy"; return 0; }
  [[ -d "$legacy/.git" ]] || return 0
  local origin
  origin=$(git -C "$legacy" remote get-url origin 2> /dev/null || true)
  for src in "$@"; do
    if [[ "$src" == "$origin" && ! -e "$EXTENSIONS_ROOT/$(extension-name "$src")" ]]; then
      mv "$legacy" "$EXTENSIONS_ROOT/$(extension-name "$src")"
      notice "Moved ~/.config/juliet-extension to ~/.config/juliet-extensions/$(extension-name "$src")"
      return 0
    fi
  done
  # shellcheck disable=SC2088
  warn "~/.config/juliet-extension is an old extension clone that JULIET_EXTENSION no longer lists; delete it when you're done with it."
}

# .env files an extension repo commits, other than .env.template (names only).
extension-tracked-env-files() {
  git -C "$1" rev-parse --git-dir &> /dev/null || return 0
  git -C "$1" ls-files \
    | grep -E '(^|/)\.env($|\.)' \
    | grep -vE '(^|/)\.env\.template$' \
    || true
}

# Excludes match a line's package name: its first quoted string (Brewfile) or
# first word (DNFfile/Flatpakfile); copr/remote/tap lines are never dropped.
# Prints the combined file's path: Juliet's file minus every extension's
# `exclude` names, plus each extension's own file in order. Juliet's path when
# no extension changes anything.
build-package-file() {
  local base="$1" name="$2" dir any="false"
  for dir in ${EXTENSION_DIRS[@]+"${EXTENSION_DIRS[@]}"}; do
    [[ -f "$dir/$name" || -f "$dir/exclude" ]] && any="true"
  done
  if [[ "$any" != "true" ]]; then
    printf '%s\n' "$base"
    return
  fi
  local out exclude
  out=$(mktemp "${TMPDIR:-/tmp}/juliet-$name.XXXXXX")
  exclude=$(mktemp "${TMPDIR:-/tmp}/juliet-exclude.XXXXXX")
  for dir in ${EXTENSION_DIRS[@]+"${EXTENSION_DIRS[@]}"}; do
    [[ -f "$dir/exclude" ]] && { cat "$dir/exclude"; printf '\n'; }
  done > "$exclude"
  {
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
    for dir in ${EXTENSION_DIRS[@]+"${EXTENSION_DIRS[@]}"}; do
      if [[ -f "$dir/$name" ]]; then
        printf '\n# --- from the %s extension (%s) ---\n' "$(basename "$dir")" "$name"
        cat "$dir/$name"
      fi
    done
  } > "$out"
  rm -f "$exclude"
  printf '%s\n' "$out"
}

# Static hooks (~/.gitconfig, fish) read these instead of knowing the list:
# .order names each active extension in order; gitconfig includes theirs.
write-extension-index() {
  local dir
  mkdir -p "$EXTENSIONS_ROOT"
  {
    for dir in ${EXTENSION_DIRS[@]+"${EXTENSION_DIRS[@]}"}; do
      basename "$dir"
    done
  } > "$EXTENSIONS_ROOT/.order"
  {
    printf '# Written by juliet-bootstrap: one include per active extension, in order.\n'
    for dir in ${EXTENSION_DIRS[@]+"${EXTENSION_DIRS[@]}"}; do
      [[ -f "$dir/gitconfig" ]] && printf '[include]\n\tpath = %s/gitconfig\n' "$dir"
    done
  } > "$EXTENSIONS_ROOT/gitconfig"
}

setup-extension() {
  substep "Checking Juliet extensions..."
  local first_run="false"
  local-env-has-key JULIET_EXTENSION || first_run="true"
  merge-env-template "$JULIET_DIR/.env.template" "Juliet"

  local srcs="${JULIET_EXTENSION:-$(read-local-env JULIET_EXTENSION)}"
  # Ask once, on the run that first adds the key, so machines without an
  # extension aren't asked every time.
  if [[ -z "$srcs" && "$first_run" == "true" && -t 0 && "$YES_ALL" != "true" && "$NO_ALL" != "true" ]] \
    && should-run-step extension && command -v gum &> /dev/null; then
    _step_close
    srcs=$(gum input --header "Juliet extensions (git URLs or paths, space-separated) — Enter to skip; see EXTENSIONS.md" \
      --placeholder "https://github.com/you/juliet-you.git") || srcs=""
    [[ -n "$srcs" ]] && set-local-env JULIET_EXTENSION "$srcs"
  fi
  # Strip surrounding quotes a hand-edited .env may carry.
  srcs="${srcs#\"}"; srcs="${srcs%\"}"

  local -a list=()
  local src
  for src in $srcs; do list+=("$src"); done

  mkdir -p "$EXTENSIONS_ROOT"
  migrate-legacy-extension ${list[@]+"${list[@]}"}

  # Unlink extensions no longer listed (symlinks only; clones are left, with a warning).
  local entry wanted
  for entry in "$EXTENSIONS_ROOT"/*; do
    [[ -e "$entry" || -L "$entry" ]] || continue
    wanted="false"
    for src in ${list[@]+"${list[@]}"}; do
      [[ "$(extension-name "$src")" == "$(basename "$entry")" ]] && wanted="true"
    done
    [[ "$wanted" == "true" ]] && continue
    if [[ -L "$entry" ]]; then
      rm "$entry"
      notice "Unlinked extension $(basename "$entry") (no longer in JULIET_EXTENSION)"
    elif [[ -d "$entry" ]]; then
      # shellcheck disable=SC2088
      warn "~/.config/juliet-extensions/$(basename "$entry") is no longer in JULIET_EXTENSION; delete it when you're done with it."
    fi
  done

  EXTENSION_DIRS=()
  local seen=" " name dir tracked
  for src in ${list[@]+"${list[@]}"}; do
    name=$(extension-name "$src")
    if [[ "$seen" == *" $name "* ]]; then
      bootstrap_error "Two extensions in JULIET_EXTENSION are both named $name." \
        "Rename one repo or checkout, then re-run: juliet-bootstrap"
      continue
    fi
    seen+="$name "
    dir="$EXTENSIONS_ROOT/$name"
    link-extension "$src" "$dir" || continue
    tracked=$(extension-tracked-env-files "$dir")
    if [[ -n "$tracked" ]]; then
      bootstrap_error "The $name extension commits .env files — refusing to use it: $(paste -sd ' ' - <<< "$tracked")" \
        "Untrack them (git rm --cached), add them to its .gitignore, and rotate any secrets they held." \
        "Commit a .env.template with blank values instead."
      continue
    fi
    EXTENSION_DIRS+=("$dir")
    merge-env-template "$dir/.env.template" "$name"
  done
  write-extension-index

  if (( ${#EXTENSION_DIRS[@]} == 0 )); then
    unchanged "no extension"
    return
  fi
  EXTENSION_ACTIVE="true"
  JULIET_BREWFILE=$(build-package-file "$JULIET_DIR/Brewfile" Brewfile)
  JULIET_DNFFILE=$(build-package-file "$JULIET_DIR/DNFfile" DNFfile)
  JULIET_FLATPAKFILE=$(build-package-file "$JULIET_DIR/Flatpakfile" Flatpakfile)
  local names=""
  for dir in "${EXTENSION_DIRS[@]}"; do names+="${names:+, }$(basename "$dir")"; done
  unchanged "using $names"
}

# Extension override files ("home/<path>" → ~/<path>, "config/<path>" →
# ~/.config/<path>), one "source<TAB>target<TAB>relpath<TAB>package" per line.
# When two extensions override the same file, the later one wins (with a
# warning), so each target appears once.
extension-overrides() {
  [[ "$EXTENSION_ACTIVE" == "true" ]] || return 0
  local i dir pkg target_root f rel seen=$'\n'
  for (( i = ${#EXTENSION_DIRS[@]} - 1; i >= 0; i-- )); do
    dir="${EXTENSION_DIRS[$i]}"
    for pkg in home config; do
      [[ -d "$dir/$pkg" ]] || continue
      [[ "$pkg" == home ]] && target_root="$HOME" || target_root="$HOME/.config"
      while IFS= read -r f; do
        rel="${f#"$dir/$pkg/"}"
        if [[ "$seen" == *$'\n'"$pkg/$rel"$'\n'* ]]; then
          warn "Both extensions override $pkg/$rel; using the later one's, not $(basename "$dir")'s." >&2
          continue
        fi
        seen+="$pkg/$rel"$'\n'
        printf '%s\t%s\t%s\t%s\n' "$f" "$target_root/$rel" "$rel" "$pkg"
      done < <(find "$dir/$pkg/" -type f ! -name .DS_Store ! -name .gitkeep)
    done
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
  done < <(extension-overrides 2> /dev/null)
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
  # --list runs before setup-extension loads the extensions, so only the
  # configured list is known; whether they define steps is decided at run time.
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
  local dir
  for dir in "${EXTENSION_DIRS[@]}"; do
    [[ -f "$dir/bootstrap.bash" ]] && return 0
  done
  NA_REASON="no extension has a bootstrap.bash"
  return 1
}

# Each extension's bootstrap.bash defines its own extension-setup, so load and
# run them one at a time, in order, with $EXTENSION_DIR pointing at that one.
setup-extension-steps() {
  local dir
  for dir in "${EXTENSION_DIRS[@]}"; do
    [[ -f "$dir/bootstrap.bash" ]] || continue
    unset -f extension-setup
    EXTENSION_DIR="$dir"
    # shellcheck source=/dev/null
    source "$dir/bootstrap.bash"
    if declare -F extension-setup > /dev/null; then
      extension-setup
    else
      substep "$(basename "$dir")"
      skip "its bootstrap.bash defines no extension-setup"
    fi
  done
}
