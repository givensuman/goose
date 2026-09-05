function _fish_flake_update
    nix flake update $argv
    if type -q direnv; and test -f .envrc
        direnv reload
    end
end
