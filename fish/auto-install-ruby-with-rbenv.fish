function chpwd --on-variable PWD --description 'handler of changing $PWD'
  if test -e "$PWD/.ruby-version"
    set -l ruby_version (cat .ruby-version)
    if ! test -d "$HOME/.rbenv/versions/$ruby_version"
      while true
        read --local --nchars 1 --prompt "echo 'Ruby $ruby_version is not installed. Install it? [Yn] '" REPLY
        switch $REPLY
          case y Y
            rbenv install $ruby_version
            break
          case n N
            break
          case *
            echo "Please answer y or n."
        end
      end
    end
  end
end
