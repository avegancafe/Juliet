function vim --wraps "nvim"
    argparse --name="debug" d/debug -- $argv

    if test -n "$_flag_d"
        rm ~/vim.log
        nvim --startuptime ~/vim.log $argv
    else
        if has_pipfile
            pipenv run nvim $argv
        else
            nvim $argv
        end
    end
end
