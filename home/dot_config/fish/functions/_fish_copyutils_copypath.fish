# Copy path to clipboard
# Arguments: $argv[1] - file/directory path (optional, defaults to pwd)
function _fish_copyutils_copypath
    argparse --max-args 1 -- $argv
    or return

    switch "$argv"
        case ""
            pwd | fish_clipboard_copy
        case \*
            realpath $argv[1] | fish_clipboard_copy
    end
end
