# List only files containing matches
function _fish_ripgrep_rgl --wraps _fish_ripgrep_grep
    _fish_ripgrep_grep --files-with-matches $argv
end
