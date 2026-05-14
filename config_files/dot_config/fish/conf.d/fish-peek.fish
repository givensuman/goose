alias peek _fish_peek

function _fish_peek_install --on-event fish-peek_install
end

function _fish_peek_uninstall --on-event fish-peek_uninstall
    functions --erase peek
end

function _fish_peek_update --on-event fish-peek_update
    _fish_peek_uninstall
    _fish_peek_install
end
