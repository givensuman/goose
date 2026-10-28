alias uncd _fish_cdutils_uncd
alias cdup _fish_cdutils_cdup
alias mkcd _fish_cdutils_mkcd
alias back prevd
alias next nextd

function _fish_cdutils_install --on-event fish-cdutils_install
end

function _fish_cdutils_uninstall --on-event fish-cdutils_uninstall
    functions --erase uncd
    functions --erase cdup
    functions --erase mkcd
    functions --erase back
    functions --erase next
end

function _fish_cdutils_update --on-event fish-cdutils_update
    _fish_cdutils_uninstall
    _fish_cdutils_install
end
