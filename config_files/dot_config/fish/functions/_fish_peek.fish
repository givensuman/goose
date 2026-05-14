# Either runs `ls` or `cat` depending on whether the argument is a directory or a file.
function _fish_peek
    set -l options
    set -l target "."
    set -l target_found 0

    # Separate flags from the target path
    for arg in $argv
        if string match -qr '^-' -- $arg
            # It's a flag
            set -a options $arg
        else if test $target_found -eq 0
            # It's the first non-flag argument, so it's our target
            set target $arg
            set target_found 1
        else
            # It's a positional argument after the target
            set -a options $arg
        end
    end

    if test -d "$target"
        ls $options "$target"
    else if test -f "$target"
        cat $options "$target"
    else
        echo "destination $target is not a file or directory" 
        return 1
    end
end
