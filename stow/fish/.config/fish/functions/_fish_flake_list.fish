function _fish_flake_list
    if not test -f flake.nix
        echo (set_color yellow) "no flake.nix in current directory"
        return 2
    end

    set -l sys (nix eval --raw \
      --impure \
      --expr "builtins.currentSystem" 2>/dev/null)

    set -l json (nix eval .#devShell.$sys.buildInputs --json 2>/dev/null)

    if test -z "$json"
        echo (set_color red) "no devShell found in flake.nix"
        return 1
    end

    echo $json \
      | string match -a -r '"[^"]+"' \
      | string trim -c '"' \
      | sed -E 's|.*/[a-z0-9]{32}-||'
end
