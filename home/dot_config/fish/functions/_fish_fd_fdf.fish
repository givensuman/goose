# Find regular files only
function _fish_fd_fdf --wraps _fish_fd_find
    _fish_fd_find --type f $argv
end
