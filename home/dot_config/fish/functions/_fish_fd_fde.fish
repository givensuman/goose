# Find files by extension
function _fish_fd_fde --wraps _fish_fd_find
    _fish_fd_find --extension $argv
end
