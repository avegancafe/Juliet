# Safe tput wrapper — returns empty string when terminal is unavailable
_tput() { tput "$@" 2>/dev/null || true; }

RESET_CODE=$(_tput sgr0)
BOLD_CODE=$(_tput bold)

# Section header. Reserve log/rlog for section headers; use substep/skip/spin
# for the individual operations underneath them.
log() {
  _step_close
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
  _step_close
  local GREEN=$(_tput setaf 2)
  printf "$GREEN==>$RESET_CODE$BOLD_CODE %s$RESET_CODE\n" "$1"
}

notice() {
  _step_close
  printf "$(_tput setaf 13)NOTICE: %s$RESET_CODE\n" "$1"
}

warn() {
  _step_close
  local YELLOW=$(_tput setaf 3)
  printf "$YELLOW==>$RESET_CODE$BOLD_CODE %s$RESET_CODE\n" "$1" >&2
}

error() {
  _step_close
  local RED=$(_tput setaf 1)
  printf "$RED==>$RESET_CODE$BOLD_CODE %s$RESET_CODE\n" "$1" >&2
}

fatal() {
  _step_close
  local RED=$(_tput setaf 1)
  printf "${RED}FATAL: %s$RESET_CODE\n" "$1" >&2
  exit 1
}

# ---------------------------------------------------------------------------
# Step lines that finish in place
#
#   substep "Checking cargo..."   →   "    Checking cargo... done"
#
# A substep ending in "..." is printed WITHOUT a newline and left open. The
# next thing printed through these helpers finishes it:
#   - step_result "<text>"      appends that result ("... up to date")
#   - skip "<why>"              appends "skipped (<why>)"
#   - anything else             appends " done" if the function that opened
#                               the step has returned (it finished silently),
#                               or just a newline if that function is still
#                               running (its child steps follow underneath).
# No cursor movement is involved, so this is safe when output isn't a TTY.
# Raw output from a command run under an open step lands on the same line —
# capture it, or call step_result/_step_close first.
# ---------------------------------------------------------------------------
_STEP_OPEN=""      # text of the open step line, if any
_STEP_FN=""        # function that opened it
_STEP_DEPTH=0      # its call-stack depth when opened

# Is the function that opened the step still running (on the call stack)?
_step_owner_running() {
  # Frames are counted from the bottom of the stack, so the owner's index
  # shifts by however many frames have been pushed since it opened the step.
  local idx=$(( ${#FUNCNAME[@]} - _STEP_DEPTH ))
  (( idx >= 1 )) && [[ "${FUNCNAME[$idx]}" == "$_STEP_FN" ]]
}

# Finish the open step line. $1 = explicit result text; default = auto.
_step_close() {
  [[ -n "$_STEP_OPEN" ]] || return 0
  local result="${1-}"
  if [[ -z "$result" ]] && ! _step_owner_running; then
    result="done"
  fi
  if [[ -n "$result" ]]; then
    printf ' %s%s%s\n' "$(_tput setaf 2)" "$result" "$RESET_CODE"
  else
    printf '\n'
  fi
  _STEP_OPEN=""
}

# Explicitly finish the open step with a result, e.g. step_result "up to date".
step_result() {
  if [[ -n "$_STEP_OPEN" ]]; then
    _step_close "$1"
  else
    substep "$1"
  fi
}

# Quiet sub-step line for an individual operation under a log/rlog section
# header — indented with no "==>" banner, so the bold section headers stand out
# (Homebrew-style). "Doing x..." lines stay open and finish in place (above).
substep() {
  _step_close
  if [[ "$1" == *... ]]; then
    printf "    %s" "$1"
    _STEP_OPEN="$1"
    _STEP_FN="${FUNCNAME[1]:-main}"
    _STEP_DEPTH=$(( ${#FUNCNAME[@]} - 1 ))
  else
    printf "    %s\n" "$1"
  fi
}

# A step skipped because it was already satisfied. Under an open step it
# finishes that line ("Setting up fish... skipped (already the default
# shell)"); on its own it's a dim indented line.
skip() {
  local why="$1"
  # Only finish the open line if it belongs to the function calling skip.
  if [[ -n "$_STEP_OPEN" && "${FUNCNAME[1]:-main}" == "$_STEP_FN" \
        && $(( ${#FUNCNAME[@]} - 1 )) -eq $_STEP_DEPTH ]]; then
    printf ' %sskipped (%s)%s\n' "$(_tput dim)" "$why" "$RESET_CODE"
    _STEP_OPEN=""
  else
    _step_close
    printf "    %s%s%s\n" "$(_tput dim)" "$why" "$RESET_CODE"
  fi
}

# sudo that moves a password prompt onto its own line instead of the end of
# an open step line. Only closes the step when sudo would actually prompt.
sudo() {
  if [[ -n "$_STEP_OPEN" ]] && ! command sudo -n true 2> /dev/null; then
    _step_close
  fi
  command sudo "$@"
}

# Run a (verbose, non-interactive) command behind a gum spinner so its output is
# hidden on success and shown only if it fails (--show-error). On success the
# spinner (gum erases its own line on exit) is replaced by
# "    <title> done". Falls back to a captured run (no spinner) when gum
# is unavailable or stdout is not a TTY (CI, piped); output is shown only on
# failure there too. The command's exit code is always propagated, so callers
# can keep using `spin ... || warn ...` and `if ! spin ...; then`. 130 means
# Ctrl-C inside gum spin (it swallows the signal), so no result is printed.
#
# `--padding "0 0 0 2"` left-pads the WHOLE spinner line (glyph included) so
# the spinner text sits in the substep column (gum can't indent just the
# glyph; it always starts at column 0).
#
# Do NOT wrap interactive commands (anything that prompts, incl. sudo) — the
# spinner hides stdin prompts and the step will appear to hang.
spin() {
  local title="$1"; shift
  local rc=0
  _step_close
  if [ -t 1 ] && command -v gum &>/dev/null; then
    gum spin --spinner dot --show-error --padding "0 0 0 2" --title "$title" -- "$@" || rc=$?
  else
    local out
    out="$("$@" 2>&1)" || rc=$?
    (( rc != 0 )) && [[ -n "$out" ]] && printf '%s\n' "$out"
  fi
  if (( rc == 0 )); then
    printf "    %s %sdone%s\n" "$title" "$(_tput setaf 2)" "$RESET_CODE"
  elif (( rc != 130 )); then
    printf "    %s %sfailed%s\n" "$title" "$(_tput setaf 1)" "$RESET_CODE"
  fi
  return $rc
}

confirm() {
  _step_close
  local question=${1:-Okay?}
  local answer=''
  while ! [[ $answer =~ ^[YyNn]$ ]]; do
    read -r -p "$question (y/N) " answer
  done
  [[ $answer =~ ^[Yy]$ ]]
  return $?
}
