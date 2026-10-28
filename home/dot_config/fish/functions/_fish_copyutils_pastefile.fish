# Paste clipboard contents to file
# Arguments: $argv[1] - file path
function _fish_copyutils_copyfile
    argparse --min-args 1 --max-args 1 -- $argv
    or return

    if test -f "$argv[1]"
        echo "file $argv[1] already exists"
        return 1
    end

    fish_clipboard_paste >"$argv[1]"
end
