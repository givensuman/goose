# Copy current command line buffer to clipboard
function _fish_copyutils_copybuffer
    commandline | fish_clipboard_copy
    if command -q notify-send
        notify-send "Copied to clipboard" --icon=dialog-information
    end
end
