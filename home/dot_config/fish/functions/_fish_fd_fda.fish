# Find all files
function _fish_fd_fda --wraps _fish_fd_find
    _fish_fd_find --no-ignore $argv
end
