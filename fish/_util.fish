function info
  printf (tput setaf 2)"==>"(tput sgr0)(tput bold)" %s"(tput sgr0)"\n" $argv[1]
end

function log
  printf (tput setaf 4)"==>"(tput sgr0)(tput bold)" %s"(tput sgr0)"\n" $argv[1]
end

function error
  printf (tput setaf 1)"==>"(tput sgr0)(tput bold)" %s"(tput sgr0)"\n" $argv[1]
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
