function _fish_fd_find --wraps fd
    if set -q fd_params; and test -n "$fd_params"
        set -l params (string split ' ' -- $fd_params)
        command fd $params $argv
    else
        command fd --hidden \
            --follow \
            --exclude .git \
            $argv
    end
end

if not command -q fd
    echo "fd is not installed but you're"
    echo "sourcing the fish plugin for it"
    return 1
end

if test "$TERM" = dumb
    echo "you are sourcing the fish plugin for fd"
    echo "in a dumb terminal, which won't support it"
    return 1
end

if command -q find
    alias rfind (command -v find)
end
alias find _fish_fd_find

alias fda _fish_fd_fda # Find all files
alias fdd _fish_fd_fdd # Find directories only
alias fde _fish_fd_fde # Find files by extension 
alias fdf _fish_fd_fdf # Find regular files only
alias fdx _fish_fd_fdx # Find executable files only

function _fish_fd_install --on-event fish-fd_install
end

function _fish_fd_uninstall --on-event fish-fd_uninstall
    functions --erase _fish_fd_find
    functions --erase find
    functions --erase fd
    functions --erase fda
    functions --erase fdd
    functions --erase fdf
    functions --erase fdx
    functions --erase fde
    set --erase fd_params
end

function _fish_fd_update --on-event fish-fd_update
    _fish_fd_uninstall
    _fish_fd_install
end
