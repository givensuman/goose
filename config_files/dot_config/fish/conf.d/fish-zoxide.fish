if not command -q zoxide
    echo "zoxide is not installed but you're"
    echo "sourcing the fish plugin for it"
    return 1
end

if test "$TERM" = dumb
    echo "you are sourcing the fish plugin for zoxide"
    echo "in a dumb terminal, which won't support it"
    return 1
end

set -l cmd
if command -q cd
    set cmd "zoxide init --cmd cd fish"
    alias rcd (command -v cd)
else
    set cmd 'zoxide init fish'
end

# Initialize zoxide with generated shell integration
eval $cmd | source

function _fish_zoxide_install --on-event fish-zoxide_install
end

function _fish_zoxide_uninstall --on-event fish-zoxide_uninstall
end

function _fish_zoxide_update --on-event fish-zoxide_update
    _fish_zoxide_uninstall
    _fish_zoxide_install
end
