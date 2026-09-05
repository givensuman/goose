function _fish_flake_status
    if not test -f flake.nix
        echo (set_color yellow) "no flake.nix in current directory"
        return 2
    end

    echo "$(pwd)/flake.nix"
    if not test -f flake.lock
        echo (set_color yellow) "no lockfile found"
        echo (set_color yellow) "run `flake update`"
    else
        set -l age (date -r flake.lock "+%Y-%m-%d %H:%M:%S" 2>/dev/null;\
      or stat -f "%Sm" flake.lock)
        echo "lockfile updated $age"
    end

    if type -q direnv
        if test -n "$DIRENV_DIR"
            echo "direnv active"
        else if test -f .envrc
            echo "direnv inactive"
            echo "run `direnv allow`"
        else
            echo (set_color yellow) "no .envrc found"
            echo (set_color yellow) "run `echo 'use flake' > .envrc`"
        end
    end
end
