if not type -q nix
    echo "you're sourcing the plugin for nix flakes"
    echo "but don't have nix installed"
else
    if not type -q nix flake
        echo "you're souring the plugin for nix flakes"
        echo "but don't have flakes enabled"
        echo "https://nixos.wiki/wiki/flakes"
    end
end

function flake
    set -l cmd $argv[1]
    set -e argv[1]

    switch "$cmd"
        case init
            _fish_flake_init $argv
        case update
            _fish_flake_update
        case status
            _fish_flake_status
        case clean
            _fish_flake_clean
        case list
            _fish_flake_list
        case "*"
            echo (set_color red) "unknown command. try one of:"
            echo (set_color red) "init | update | status | clean | list"
    end
end
