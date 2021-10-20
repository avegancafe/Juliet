RESET_CODE=`tput sgr0`
# General logging function
info() {
  BLUE=`tput setaf 4`
  printf "$BLUE==>$RESET_CODE$(tput bold) %s$RESET_CODE\n" "$1"
}

# Logging function to call if interacting with an external service
remoteinfo() {
  GREEN=`tput setaf 2`
  printf "$GREEN==>$RESET_CODE$(tput bold) %s$RESET_CODE\n" "$1"
}

notice() {
  printf "$(tput setaf 13)NOTICE: %s$(tput sgr0)\n" "$1"
}

step() {
  printf "$(tput setaf 4)==>$(tput sgr0)$(tput bold) %s$(tput sgr0)\n" "$1"
}

# Logging function to call with warning affordance
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
