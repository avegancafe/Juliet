# Safe tput wrapper — returns empty string when terminal is unavailable
_tput() { tput "$@" 2>/dev/null || true; }

RESET_CODE=$(_tput sgr0)
BOLD_CODE=$(_tput bold)

# Section header. Reserve log/rlog for section headers; use substep/skip/spin
# for the individual operations underneath them.
log() {
  local BLUE=$(_tput setaf 4)
  printf "$BLUE==>$RESET_CODE$BOLD_CODE %s$RESET_CODE\n" "$1"
}

debuglog() {
  if [[ -n $DEBUG ]]; then
    log "$1"
  fi
}

# Section header indicating network will be used
rlog() {
  local GREEN=$(_tput setaf 2)
  printf "$GREEN==>$RESET_CODE$BOLD_CODE %s$RESET_CODE\n" "$1"
}

notice() {
  printf "$(_tput setaf 13)NOTICE: %s$RESET_CODE\n" "$1"
}

warn() {
  local YELLOW=$(_tput setaf 3)
  printf "$YELLOW==>$RESET_CODE$BOLD_CODE %s$RESET_CODE\n" "$1" >&2
}

error() {
  local RED=$(_tput setaf 1)
  printf "$RED==>$RESET_CODE$BOLD_CODE %s$RESET_CODE\n" "$1" >&2
}

fatal() {
  local RED=$(_tput setaf 1)
  printf "${RED}FATAL: %s$RESET_CODE\n" "$1" >&2
  exit 1
}

# Quiet sub-step line for an individual operation under a log/rlog section
# header — indented with no "==>" banner, so the bold section headers stand out
# (Homebrew-style). Plain default foreground (readable on any theme); the
# hierarchy comes from the indent + absence of the bold ==> banner.
substep() {
  printf "    %s\n" "$1"
}

# Quiet sub-step line for a step that was skipped because it was already
# satisfied — same column alignment as spin()'s "✓" success line, but with a
# dim "-" so skipped steps read as distinct from completed ones at a glance.
skip() {
  printf " %s-%s  %s\n" "$(_tput dim)" "$RESET_CODE" "$1"
}

# Run a (verbose, non-interactive) command behind a gum spinner so its output is
# hidden on success and shown only if it fails (--show-error). On success it
# leaves a quiet "✓ <title>" sub-line — gum spin erases its own spinner line on
# exit. Falls back to a plain substep + run when gum is unavailable or stdout is
# not a TTY (CI, piped). The command's exit code is always propagated, so
# callers can keep using `spin ... || warn ...` and `if ! spin ...; then`.
#
# `--padding "0 0 0 1"` left-pads the WHOLE spinner line (glyph included) — gum
# wraps `<glyph> <title>` in a lipgloss style and applies this padding to it, so
# the spinner sits in line with the substep / ✓ lines (gum has no way to indent
# just the glyph otherwise; it always starts at column 0).
#
# Do NOT wrap interactive commands (anything that prompts, incl. sudo) — the
# spinner hides stdin prompts and the step will appear to hang.
spin() {
  local title="$1"; shift
  if [ -t 1 ] && command -v gum &>/dev/null; then
    gum spin --spinner dot --show-error --padding "0 0 0 1" --title "$title" -- "$@" || return $?
    printf " %s✓%s  %s\n" "$(_tput setaf 2)" "$RESET_CODE" "${title%...}"
  else
    substep "$title"
    "$@"
  fi
}

confirm() {
  local question=${1:-Okay?}
  local answer=''
  while ! [[ $answer =~ ^[YyNn]$ ]]; do
    read -r -p "$question (y/N) " answer
  done
  [[ $answer =~ ^[Yy]$ ]]
  return $?
}
