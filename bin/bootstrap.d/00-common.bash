# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# Shared helpers: OS detection, install-system-file, and the category
# registry, selection and runner machinery every module plugs into.

# =============================================================================
# Category Registry
# =============================================================================
# The one list of what bootstrap can do. Each category declares its header,
# its prompt and its steps, in run order. --help, --list, the prompts,
# --enable/--skip and the runner all read from here, so adding a step is one
# edit. A step is a function; its CLI name drops the setup- prefix
# (setup-keyd → keyd), so `--enable=keyd` runs just that step.
#
# A step may also define <function>-applicable: a cheap, read-only check
# (OS, installed tool, hardware). When it fails, the step is left out of the
# prompt and not run; a category with no applicable steps skips itself without
# asking. It may set NA_REASON to explain why, for --list and the skip line.
#
#   category <name> <log|rlog> <header> <question> <step-function>...
#   (rlog headers mark a category that uses the network)
CATEGORIES=()
category() {
  local name="$1"
  CATEGORIES+=("$name")
  printf -v "CATEGORY_LOG_$name" '%s' "$2"
  printf -v "CATEGORY_HEADER_$name" '%s' "$3"
  printf -v "CATEGORY_QUESTION_$name" '%s' "$4"
  shift 4
  printf -v "CATEGORY_STEPS_$name" '%s' "$*"
}

# category-field <category> <LOG|HEADER|QUESTION|STEPS>
category-field() {
  local var="CATEGORY_${2}_$1"
  printf '%s' "${!var}"
}

# CLI name of a step function: setup-keyd → keyd.
step-name() { printf '%s' "${1#setup-}"; }

# Is <word> one of the remaining arguments?
in-list() {
  local needle="$1"
  shift
  [[ " $* " == *" $needle "* ]]
}

# Did --enable name this category, or any of its steps?
category-enabled() {
  local cat="$1" fn
  in-list "$cat" "${ENABLED_STEPS[@]}" && return 0
  for fn in $(category-field "$cat" STEPS); do
    in-list "$(step-name "$fn")" "${ENABLED_STEPS[@]}" && return 0
  done
  return 1
}

# Should this category run at all under --enable/--skip?
should-run-step() {
  local cat="$1"
  in-list "$cat" "${SKIPPED_STEPS[@]}" && return 1
  [[ ${#ENABLED_STEPS[@]} -eq 0 ]] && return 0
  category-enabled "$cat"
}

# Should <step-function> of <category> run under --enable/--skip? Naming the
# category enables all its steps; naming a step enables just that one.
step-selected() {
  local cat="$1" name
  name=$(step-name "$2")
  in-list "$name" "${SKIPPED_STEPS[@]}" && return 1
  [[ ${#ENABLED_STEPS[@]} -eq 0 ]] && return 0
  in-list "$cat" "${ENABLED_STEPS[@]}" || in-list "$name" "${ENABLED_STEPS[@]}"
}

# Prompt for a category unless the flags already answered. Naming it (or one
# of its steps) with --enable runs it without asking.
confirm-category() {
  local cat="$1" question="$2"
  category-enabled "$cat" && return 0
  [[ "$YES_ALL" == "true" ]] && return 0
  if [[ "$NO_ALL" == "true" ]] || ! gum-confirm "$question"; then
    skip "Skipping $cat step(s)"
    return 1
  fi
  return 0
}

# Refuse typos in --enable/--skip instead of silently running nothing.
validate-step-names() {
  local known=" ${CATEGORIES[*]} " cat fn name bad=()
  for cat in "${CATEGORIES[@]}"; do
    for fn in $(category-field "$cat" STEPS); do
      known+="$(step-name "$fn") "
    done
  done
  for name in "${ENABLED_STEPS[@]}" "${SKIPPED_STEPS[@]}"; do
    [[ -z "$name" || "$known" == *" $name "* ]] || bad+=("$name")
  done
  if [[ ${#bad[@]} -gt 0 ]]; then
    error "Unknown step(s): ${bad[*]}"
    printf '      %s\n' "Run juliet-bootstrap --list to see the categories and steps." >&2
    exit 1
  fi
}

# OS Detection
is-fedora() {
  [ -f /etc/fedora-release ]
}

is-macos() {
  [[ "$OSTYPE" == "darwin"* ]]
}

# Install a tracked file (under etc/) to a root-owned path, writing only when
# the content differs. This converges: edit the repo copy and the next run
# updates the machine, which a create-once `[[ -f "$dest" ]]` guard never does.
# Returns 0 when it wrote the file, 1 when it was already current, and 2 on
# failure (already reported through bootstrap_error).
install-system-file() {
  local src="$1" dest="$2" mode="${3:-644}"
  if [[ ! -f "$src" ]]; then
    bootstrap_error "Missing tracked file $src" \
      "Restore it: git -C $JULIET_DIR checkout -- ${src#"$JULIET_DIR"/}"
    return 2
  fi
  cmp -s "$src" "$dest" && return 1
  if ! sudo install -D -m "$mode" "$src" "$dest"; then
    bootstrap_error "Failed to install $dest" \
      "Copy it manually: sudo install -D -m $mode $src $dest"
    return 2
  fi
  return 0
}

# =============================================================================
# Category Runner
# =============================================================================

# Does <step-function> apply on this machine? Steps without an -applicable
# check always do.
step-applicable() {
  declare -F "$1-applicable" > /dev/null || return 0
  "$1-applicable"
}

# Run one category: filter its steps by flags and applicability, ask once
# (listing exactly the steps that will run), then run them in order.
run-category() {
  local cat="$1" fn names="" steps=()
  if ! should-run-step "$cat"; then
    skip "Skipping $cat step(s) (filtered)"
    return
  fi
  NA_REASON=""
  for fn in $(category-field "$cat" STEPS); do
    step-selected "$cat" "$fn" || continue
    step-applicable "$fn" || continue
    steps+=("$fn")
    names+="${names:+, }$(step-name "$fn")"
  done
  if [[ ${#steps[@]} -eq 0 ]]; then
    [[ -n "$NA_REASON" ]] && skip "Skipping $cat step(s) ($NA_REASON)"
    return
  fi
  confirm-category "$cat" "$(category-field "$cat" QUESTION) ($names)" || return
  "$(category-field "$cat" LOG)" "$(category-field "$cat" HEADER)"
  for fn in "${steps[@]}"; do
    "$fn"
  done
}

run-categories() {
  local cat
  for cat in "${CATEGORIES[@]}"; do
    run-category "$cat"
  done
}

# --list: every category and step, and whether it applies on this machine.
list-steps() {
  local cat fn
  for cat in "${CATEGORIES[@]}"; do
    printf '%s%s%s  %s\n' "$BOLD_CODE" "$cat" "$RESET_CODE" "$(category-field "$cat" QUESTION)"
    for fn in $(category-field "$cat" STEPS); do
      NA_REASON=""
      if step-applicable "$fn"; then
        printf '  ∙ %s\n' "$(step-name "$fn")"
      else
        printf '  ◦ %s (not applicable here%s)\n' "$(step-name "$fn")" "${NA_REASON:+: $NA_REASON}"
      fi
    done
  done
}
