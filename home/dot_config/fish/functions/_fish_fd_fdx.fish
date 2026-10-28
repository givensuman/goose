# Find executable files only
function _fish_fd_fdx --wraps _fish_fd_find
    _fish_fd_find --type x $argv
end
