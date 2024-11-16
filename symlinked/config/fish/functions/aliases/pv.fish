function pv --wraps "pipenv"
    if ! command -v pipenv 2&> /dev/null
        gum confirm "Pipenv not installed. Install?" && pip install --upgrade pipenv
    end

    # alias i to install with a switch case
    switch $argv[1]
        case "i"
            set argv[1] install
    end

    pipenv $argv
end
