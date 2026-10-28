function _fish_cdutils_cdup_handle_error
    echo "Usage: cdup <distance>"
    return 1
end

function _fish_cdutils_cdup --description "Change to the parent directory, or a specified number of levels up"
    if test (count $argv) -gt 1
        _fish_cdutils_cdup_handle_error
    end

    if set -q $argv[1]; and test $argv[1] -le 0
        _fish_cdutils_cdup_handle_error
    end

    set -l distance
    if test $(count $argv) -eq 0
        set distance 1
    else
        set distance $argv[1]
    end

    set -l path (string repeat -n $distance '../')
    cd $path
end
