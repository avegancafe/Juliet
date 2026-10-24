#!/usr/bin/env bash
# Toggle niri between centered focus and left-aligned (default) focus.
# niri hot-reloads config.kdl, so editing it applies immediately.
set -eu
cfg="$HOME/.config/niri/config.kdl"
if grep -q '^\s*center-focused-column "always"' "$cfg"; then
    sed -i -E 's/^(\s*)center-focused-column "always"/\1center-focused-column "never"/; s|^(\s*)always-center-single-column|\1// always-center-single-column|' "$cfg"
    msg="Left aligned"
else
    sed -i -E 's/^(\s*)center-focused-column "[a-z-]+"/\1center-focused-column "always"/; s|^(\s*)// always-center-single-column|\1always-center-single-column|' "$cfg"
    msg="Centered"
fi
# Update the Noctalia bar widget right away (plugin: noctalia/plugins/niri_center).
command -v noctalia >/dev/null && noctalia msg plugin kyle/niri_center:status all refresh >/dev/null 2>&1 || true
command -v notify-send >/dev/null && notify-send -t 1500 "niri focus" "$msg" || true
