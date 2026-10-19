# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# Core phases that always run, before any category: dependency check,
# self-update, machine-local git config, and stowing dotfiles.

setup-git() {
  substep "Setting up git..."
  mkdir -p ~/.config/local
  if [[ -f ~/.config/local/gitconfig ]]; then
    unchanged "already configured"
  else
    cp ~/.config/Juliet/.gitconfig__local ~/.config/local/gitconfig
  fi
}

# One hash over everything bootstrap loads at startup: the entry script, its
# bin/bootstrap.d modules and _util.bash. update-juliet compares it across the
# pull to decide whether the code in memory is stale.
bootstrap-code-hash() {
  cat "$1/bin/juliet-bootstrap" "$1"/bin/bootstrap.d/*.bash "$1/_util.bash" 2> /dev/null \
    | sha256sum | cut -d' ' -f1
}

update-juliet() {
  substep "Updating Juliet repository..."
  WORKDIR="$HOME/.config/Juliet"
  if [ -d "$WORKDIR" ]; then
    cd "$WORKDIR"

    if ! git diff --quiet; then
      skip "unstaged changes in ~/.config/Juliet"
      cd - > /dev/null
      return
    fi


    DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)

    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then
      local self="$WORKDIR/bin/juliet-bootstrap"
      local old_hash=""
      [[ -f "$self" ]] && old_hash=$(bootstrap-code-hash "$WORKDIR")

      local before pull_out
      before=$(git rev-parse HEAD)
      if ! pull_out=$(git pull 2>&1); then
        _step_close
        printf '%s\n' "$pull_out" | sed 's/^/      /' >&2
        bootstrap_error "git pull failed in $WORKDIR"
      elif [[ "$(git rev-parse HEAD)" == "$before" ]]; then
        unchanged "already up to date"
      else
        step_done "pulled $(git rev-list --count "$before..HEAD") commit(s)"
      fi

      # If the pull changed this script, a bootstrap.d module or _util.bash,
      # the rest of this run would execute against the stale, already-loaded
      # copy in memory. Re-exec the
      # freshly pulled version with the exact original arguments instead, so
      # any new steps/fixes take effect immediately rather than on the next
      # invocation. Guarded by JULIET_BOOTSTRAP_REEXEC so a re-exec loop can't
      # happen even if the script kept changing underneath itself.
      if [[ -n "$old_hash" && -z "${JULIET_BOOTSTRAP_REEXEC:-}" ]]; then
        local new_hash
        new_hash=$(bootstrap-code-hash "$WORKDIR")
        if [[ "$new_hash" != "$old_hash" ]]; then
          substep "juliet-bootstrap was updated by the pull — re-executing the new version..."
          _step_close
          cd - > /dev/null
          JULIET_BOOTSTRAP_REEXEC=1 exec "$self" "${ORIGINAL_ARGS[@]}"
        fi
      fi
    else
      warn "Warning: ~/.config/Juliet is not on the default branch. Current branch: $CURRENT_BRANCH"
      return
    fi

    cd - > /dev/null
  else
    error "Juliet directory not found at $WORKDIR"
  fi
}

# Install the tools bootstrap itself relies on before it uses them: stow (for
# symlinking dotfiles in core setup) and gum (for the confirmation prompts).
# The full package steps run later and are idempotent, so this early install is
# just to satisfy the ordering dependency.
ensure-bootstrap-deps() {
  substep "Checking stow and gum..."
  if is-macos; then
    ensure-brew
    for tool in stow gum; do
      command -v "$tool" &> /dev/null && continue
      rlog "Installing $tool via brew..."
      brew install "$tool"
    done
  elif is-fedora; then
    for tool in stow gum; do
      command -v "$tool" &> /dev/null && continue
      rlog "Installing $tool via dnf..."
      sudo dnf install -y "$tool"
    done
  fi
  unchanged "already installed"
}

# Files Juliet stows that other apps rewrite in place. An app that writes to a
# stow symlink normally lands on the tracked file (visible as a git diff), but
# some replace the symlink with a real file instead — Firefox's "make me your
# default browser" does exactly that to mimeapps.list. That single real file
# makes stow abort the *entire* config tree, so nothing new gets linked and the
# failure looks unrelated to whatever config went missing. The repo copy is the
# source of truth here, so take it back; the displaced file is kept alongside as
# a .pre-stow.bak rather than deleted outright.
STOW_RECLAIMABLE=(
  "$HOME/.config/mimeapps.list"
)

reclaim-stow-casualties() {
  local target
  for target in "${STOW_RECLAIMABLE[@]}"; do
    # Only a *real* file is a conflict; a symlink (ours) or a missing file is fine.
    if [[ -f "$target" && ! -L "$target" ]]; then
      substep "Reclaiming $(basename "$target") (an app replaced the Juliet symlink with a real file)..."
      mv -f "$target" "$target.pre-stow.bak" \
        || bootstrap_error "Could not move $target aside" \
          "Remove it by hand, then re-run: juliet-bootstrap"
      notice "Previous $(basename "$target") saved as $target.pre-stow.bak"
    fi
  done
}

# OS litter that lands in symlinked/ when a folder is opened in Finder. It's
# gitignored, but stow doesn't know that: a stray .DS_Store in symlinked/home
# collides with the real ~/.DS_Store and aborts stowing the entire home tree.
STOW_IGNORES=(--ignore='\.DS_Store')

symlink-dotfiles() {
  substep "Symlinking dotfiles..."
  mkdir ~/.claude 2>/dev/null || true
  # Keep ~/.config/opencode a real dir so stow file-links only our tracked
  # content (plugins/cmux.js) into it; opencode writes node_modules/
  # package.json (its own bun-managed plugin deps) at that root, which must
  # stay out of the repo. opencode.json and tui.json are deliberately NOT
  # stowed — opencode/dev-env both write config files, and a write through a
  # symlink would dirty this repo (see setup-opencode for the layering).
  mkdir -p ~/.config/opencode 2>/dev/null || true
  reclaim-stow-casualties
  prepare-extension-overrides
  local links=0
  stow-package home "$HOME" \
    || bootstrap_error "stow home failed — conflicts with existing real files (see above)." \
      "Resolve the conflicts, then re-run: juliet-bootstrap"
  stow-package config "$HOME/.config" \
    || bootstrap_error "stow config failed — conflicts with existing real files (see above)." \
      "Resolve the conflicts, then re-run: juliet-bootstrap"
  # local-state only exists when something needs ~/.local/state files
  if [[ -d $HOME/.config/Juliet/symlinked/local-state ]]; then
    mkdir -p "$HOME/.local/state"
    stow-package local-state "$HOME/.local/state"
  fi
  link-extension-overrides
  (( links > 0 )) || unchanged "already linked"
}

# stow one package verbosely, adding the links it made to the caller's
# `links` count. Output stays hidden unless stow fails (conflict details).
stow-package() {
  local out rc=0
  out=$(stow -v "${STOW_IGNORES[@]}" --target="$2" --dir="$HOME/.config/Juliet/symlinked" "$1" 2>&1) || rc=$?
  links=$(( links + $(grep -c '^LINK:' <<< "$out") ))
  if (( rc != 0 )); then
    _step_close
    printf '%s\n' "$out" | sed 's/^/      /' >&2
  fi
  return $rc
}
