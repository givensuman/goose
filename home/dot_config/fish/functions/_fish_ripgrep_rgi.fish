# Search with case-insensitive matching
function _fish_ripgrep_rgi --wraps _fish_ripgrep_grep
    _fish_ripgrep_grep --ignore-case $argv
end
