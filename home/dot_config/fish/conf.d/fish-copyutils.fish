alias copyfile _fish_copyutils_copyfile
alias copypath _fish_copyutils_copypath

if set -q copybuffer_keybind
    # Bind 'copybuffer' to copybuffer_keybind environment variable
    bind $copybuffer_keybind _fish_copyutils_copybuffer
else
    # or 'ctrl+o' if one isn't set
    bind \co _fish_copyutils_copybuffer
end

function _fish_copyutils_install --on-event fish-copyutils_install
end

function _fish_copyutils_uninstall --on-event fish-copyutils_uninstall
    functions --erase copyfile
    functions --erase copypath
    functions --erase _fish_copyutils_copybuffer
    if set -q copybuffer_keybind
        bind --erase $copybuffer_keybind
    else
        bind --erase \co
    end
    set --erase copybuffer_keybind
end

function _fish_copyutils_update --on-event fish-copyutils_update
    _fish_copyutils_uninstall
    _fish_copyutils_install
end
