# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# opencode: the CLI and its config layering.

category opencode rlog "🤖 Setting up opencode..." "Set up opencode?" \
  setup-opencode

setup-opencode() {
  if ! command -v opencode &> /dev/null; then
    rlog "Installing opencode CLI..."
    curl -fsSL https://opencode.ai/install | bash
  else
    skip "opencode already installed"
  fi

  # Config layering (Juliet does NOT stow opencode.json or tui.json):
  #   global  ~/.config/opencode/opencode.json   yours, or owned by a work tool
  #           (e.g. an org config laid down by a work extension — pinned
  #           plugins, team MCP servers, LSPs)
  #   custom  $OPENCODE_CONFIG                    Juliet's opencode/config.json,
  #           exported from fish/env.fish (opencode.json-space keys only —
  #           NEVER the deprecated theme/tui/keybinds keys: opencode rewrites
  #           any config file containing them in place, which would dirty
  #           this repo; verified on 1.18.0)
  #   project <repo>/opencode.json                per-repo overrides
  # opencode loads them in that precedence order, so Juliet's keys override the
  # global defaults without either side touching the other's file.
  # config/opencode content (commands/, plugins/) stays stow-symlinked — it's
  # immutable, nothing writes to it. Interactive theme picks persist to
  # ~/.local/state/opencode/kv.json, never a config file.

  # Migration: an earlier revision of this branch stow-symlinked opencode.json
  # into ~/.config/opencode. Tools that manage the global file write it via
  # mv(1), which would silently replace that symlink with a real file and break
  # the stow link. Remove the stale Juliet-owned link so the global file is free.
  local oc_json="$HOME/.config/opencode/opencode.json"
  if [[ -L "$oc_json" ]] && readlink "$oc_json" | grep -q "$HOME/.config/Juliet/"; then
    rlog "Removing stale Juliet stow link for opencode.json (now layered via OPENCODE_CONFIG)"
    rm "$oc_json"
  fi

  # tui.json is SEEDED (copied once), never symlinked: opencode itself writes
  # tui.json (deprecated-key migrations), and a write through a symlink would
  # dirty this repo. After the seed, your theme settings are yours.
  local tui_src="$HOME/.config/Juliet/opencode/tui.json"
  local tui_dst="$HOME/.config/opencode/tui.json"
  if [[ -L "$tui_dst" ]] && readlink "$tui_dst" | grep -q "$HOME/.config/Juliet/"; then
    rlog "Converting stow-linked tui.json to a real file (opencode writes tui.json; a link would dirty the repo)..."
    rm "$tui_dst"
    cp "$tui_src" "$tui_dst"
  elif [[ ! -f "$tui_dst" ]]; then
    substep "Seeding ~/.config/opencode/tui.json (theme: system)..."
    cp "$tui_src" "$tui_dst"
  else
    skip "tui.json already present — leaving your theme settings alone"
  fi

  # OPENCODE_CONFIG is exported by the stowed fish/env.fish; it only reaches
  # shells started after the stow run, so hint when the current shell lacks it.
  if [[ -z "${OPENCODE_CONFIG:-}" ]]; then
    warn "OPENCODE_CONFIG not set in this shell yet — open a new shell (or 'source ~/.config/fish/env.fish') so opencode picks up Juliet's override layer."
  fi
}
