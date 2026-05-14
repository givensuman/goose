# Copy file contents to clipboard
# Arguments: $argv[1] - file path
function _fish_copyutils_copyfile
    argparse --min-args 1 --max-args 1 -- $argv
    or return

    if test ! -f "$argv[1]"
        echo "file $argv[1] not found"
        return 1
    end

    set -l cat_bin (command -v cat)
    $cat_bin $argv[1] | fish_clipboard_copy
end
