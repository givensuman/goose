alias compress _fish_archive_compress
alias extract _fish_archive_extract

function _fish_archive_install --on-event fish-archive_install
end

function _fish_archive_uninstall --on-event fish-archive_uninstall
    functions --erase compress
    functions --erase extract
end

function _fish_archive_update --on-event fish-archive_update
    _fish_archive_uninstall
    _fish_archive_install
end
