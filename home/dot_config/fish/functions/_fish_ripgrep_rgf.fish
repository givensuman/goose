# List files that would be searched
function _fish_ripgrep_rgf --wraps _fish_ripgrep_grep
    _fish_ripgrep_grep --files $argv
end
