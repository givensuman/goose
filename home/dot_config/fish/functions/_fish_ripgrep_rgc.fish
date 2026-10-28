# Count matching lines per file
function _fish_ripgrep_rgc --wraps _fish_ripgrep_grep
    _fish_ripgrep_grep --count $argv
end
