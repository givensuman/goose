# Find directories only
function _fish_fd_fdd --wraps _fish_fd_find
    _fish_fd_find --type d $argv
end
