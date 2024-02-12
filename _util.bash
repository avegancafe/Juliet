RESET_CODE=`tput sgr0`

log() {
  BLUE=`tput setaf 4`
  printf "$BLUE==>$RESET_CODE$(tput bold) %s$RESET_CODE\n" "$1"
}

debuglog() {
  if [[ -n $DEBUG ]]; then
    log "$1"
  fi
}

# log indicating network will be used
rlog() {
  GREEN=`tput setaf 2`
  printf "$GREEN==>$RESET_CODE$(tput bold) %s$RESET_CODE\n" "$1"
}

notice() {
  printf "$(tput setaf 13)NOTICE: %s$(tput sgr0)\n" "$1"
}

warn() {
  YELLOW=`tput setaf 3`
  printf "$YELLOW==>$RESET_CODE$(tput bold) %s$RESET_CODE\n" "$1"
}

fatal() {
  RED=`tput setaf 1`
  printf "$REDFATAL: %s$RESET_CODE\n" "$1" >&2
  exit 1
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
