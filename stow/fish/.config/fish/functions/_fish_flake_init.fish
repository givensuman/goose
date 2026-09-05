function _fish_flake_init
    set -f template "github:nixos/templates#utils-generic"

    if set -q argv[1]
        set template $argv[1]
    end

    if test -f flake.nix
        echo (set_color red) "flake.nix already exists"
        return 1
    end

    nix flake init -t $template

    if type -q direnv
        if not test -f .envrc
            echo "use flake" >.envrc
        else if not grep -q "use flake" .envrc
            echo "use flake" >>.envrc
        end

        direnv allow
    end
end
