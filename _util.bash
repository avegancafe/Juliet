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
# Step lines
#
#   substep "Checking cargo..."   =>  " ⣷  Checking cargo..."  (animated)
#                                 =>  " ✓  Checking cargo"             done
#                                 =>  " ⁃  Checking cargo (up to date)" skipped
#                                 =>  " ✗  Checking cargo"             failed
#
# "done" means something changed; "skipped (why)" means nothing did.
#
# A substep ending in "..." opens a step: a spinner runs on its line (TTY only)
# while the calling function works. The next thing printed through these
# helpers finishes it:
#   - unchanged "<why>"   skipped (no-op if the line was already finished,
#                         e.g. child steps printed under it)
#   - skip "<why>"        skipped, or a standalone "⁃ <why>" line otherwise
#   - step_done [note]    done, with an optional note
#   - anything else       done if the opening function has returned, or a
#                         "•" parent line if it's still running (its child
#                         steps follow underneath)
# Raw output from a command run under an open step would fight the spinner —
# capture it, or call _step_close first (sudo does this itself before a
# password prompt).
#
# This is a small bash spinner rather than `gum spin` because gum spin can only
# wrap one external command, while a step is arbitrary bash in the calling
# function. It uses gum's "dot" frames so both look the same.
# ---------------------------------------------------------------------------
_STEP_OPEN=""      # title of the open step, if any
_STEP_FN=""        # function that opened it
_STEP_DEPTH=0      # its call-stack depth when opened
_SPIN_PID=""
_SPIN_FRAMES=(⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷)
_C_GREEN=$(_tput setaf 2)
_C_RED=$(_tput setaf 1)
_C_SPIN=$(_tput setaf 5)
_C_DIM=$(_tput dim)

_spinner_start() {
  [ -t 1 ] || return 0
  _tput civis
  (
    trap 'exit 0' TERM
    i=0
    while :; do
      printf '\r %s%s%s  %s' "$_C_SPIN" "${_SPIN_FRAMES[i % 8]}" "$RESET_CODE" "$1"
      i=$((i + 1))
      sleep 0.08
    done
  ) &
  _SPIN_PID=$!
  disown "$_SPIN_PID" 2> /dev/null
}

_spinner_stop() {
  [[ -n "$_SPIN_PID" ]] || return 0
  kill "$_SPIN_PID" 2> /dev/null
  while kill -0 "$_SPIN_PID" 2> /dev/null; do sleep 0.01; done
  _SPIN_PID=""
  printf '\r%s' "$(_tput el)"
  _tput cnorm
}
# Never leave a spinner running or the cursor hidden (Ctrl-C, exit, errors).
trap '_spinner_stop' EXIT

# " <glyph>  <text>" — glyph in column 1 (same as the spinner), text in
# column 4 (under the "==> " header text).
_mark() { printf ' %s%s%s  %s\n' "$1" "$2" "$RESET_CODE" "$3"; }
_mark_done()   { _mark "$_C_GREEN" "✓" "$1${2:+ ($2)}"; }
_mark_skip()   { _mark "$_C_DIM" "⁃" "${_C_DIM}$1${2:+ ($2)}${RESET_CODE}"; }
_mark_fail()   { _mark "$_C_RED" "✗" "$1${2:+ ($2)}"; }
_mark_parent() { _mark "$_C_DIM" "•" "$1"; }

# Is the function that opened the step still running (on the call stack)?
_step_owner_running() {
  # Frames are counted from the bottom of the stack, so the owner's index
  # shifts by however many frames have been pushed since it opened the step.
  local idx=$(( ${#FUNCNAME[@]} - _STEP_DEPTH ))
  (( idx >= 1 )) && [[ "${FUNCNAME[$idx]}" == "$_STEP_FN" ]]
}

# Does the open step belong to the function calling the helper that calls this?
_step_owned_by_caller() {
  [[ -n "$_STEP_OPEN" && "${FUNCNAME[2]:-main}" == "$_STEP_FN" ]] \
    && (( ${#FUNCNAME[@]} - 2 == _STEP_DEPTH ))
}

# Finish the open step. $1 = done|skip|fail (default: auto), $2 = note.
_step_close() {
  [[ -n "$_STEP_OPEN" ]] || return 0
  local kind="${1-}" note="${2-}" title="${_STEP_OPEN%...}"
  _spinner_stop
  if [[ -z "$kind" ]]; then
    if _step_owner_running; then kind=parent; else kind=done; fi
  fi
  _STEP_OPEN=""
  case "$kind" in
    done) _mark_done "$title" "$note" ;;
    skip) _mark_skip "$title" "$note" ;;
    fail) _mark_fail "$title" "$note" ;;
    *)    _mark_parent "$title" ;;
  esac
}

# Section sub-step. "Doing x..." opens a step (above); anything else is a
# plain indented line.
substep() {
  _step_close
  if [[ "$1" == *... ]]; then
    _STEP_OPEN="$1"
    _STEP_FN="${FUNCNAME[1]:-main}"
    _STEP_DEPTH=$(( ${#FUNCNAME[@]} - 1 ))
    _spinner_start "$1"
  else
    printf '    %s\n' "$1"
  fi
}

# Nothing needed doing: finish the caller's open step as skipped. Silent if the
# line already finished. Keep <why> to a few words.
unchanged() {
  _step_owned_by_caller && _step_close skip "$1"
  return 0
}

# Skipped: finishes the caller's open step, or prints a standalone "⁃" line.
skip() {
  if _step_owned_by_caller; then
    _step_close skip "$1"
  else
    _step_close
    _mark_skip "$1"
  fi
}

# Finish the open step as done, with an optional note ("pulled 3 commits").
step_done() {
  if [[ -n "$_STEP_OPEN" ]]; then
    _step_close done "${1-}"
  elif [[ -n "${1-}" ]]; then
    _mark_done "$1"
  fi
}

# sudo that moves a password prompt off the spinner line. Only finishes the
# step when sudo would actually prompt.
sudo() {
  if [[ -n "$_STEP_OPEN" ]] && ! command sudo -n true 2> /dev/null; then
    _step_close
  fi
  command sudo "$@"
}

# Run a (verbose, non-interactive) command behind the spinner: output hidden,
# shown only if it fails. Leaves "✓ <title>" or "✗ <title>". The exit code is
# propagated, so callers can keep using `spin ... || warn ...`.
#
# Do NOT wrap interactive commands (anything that prompts, incl. sudo) — the
# spinner hides stdin prompts and the step will appear to hang.
spin() {
  local title="$1"; shift
  local rc=0 out
  _step_close
  _spinner_start "$title"
  out="$("$@" 2>&1)" || rc=$?
  _spinner_stop
  if (( rc == 0 )); then
    _mark_done "${title%...}"
  else
    _mark_fail "${title%...}"
    [[ -n "$out" ]] && printf '%s\n' "$out" | sed 's/^/      /' >&2
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
