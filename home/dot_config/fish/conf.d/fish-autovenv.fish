# Automatically activate/deactivate Python virtual environments
function _fish_autovenv_auto --on-variable PWD
    if command -q $autovenv_disable
        return 0
    end

    set -l venv ./.venv

    if test -d $venv
        source $venv/bin/activate.fish
    else if command -q deactivate
        deactivate
    end
end

function _fish_autovenv_install --on-event fish-autovenv_install
end

function _fish_autovenv_uninstall --on-event fish-autovenv_uninstall
    functions --erase _fish_autovenv_auto
    set --erase autovenv_disable
end

function _fish_autovenv_update --on-event fish-autovenv_update
    _fish_autovenv_uninstall
    _fish_autovenv_install
end
