function rlog
  printf (tput setaf 2)"==>"(tput sgr0)(tput bold)" %s"(tput sgr0)"\n" "$argv"
end

function log
  printf (tput setaf 4)"==>"(tput sgr0)(tput bold)" %s"(tput sgr0)"\n" "$argv"
end

function debuglog
  if test -n "$DEBUG"
    log $argv
  end
end

function error
  printf (tput setaf 1)"==>"(tput sgr0)(tput bold)" %s"(tput sgr0)"\n" "$argv"
end

function padlines
  echo
  $argv
  echo
end

function indent
  set -l output ($argv)
  set -l tmp_status $status
  string join \n $output | sed 's/^/  /'
  return $tmp_status
end
