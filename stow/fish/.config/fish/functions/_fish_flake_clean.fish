function _fish_flake_clean
  if test -d .direnv
    rm -rf .direnv
  end

  nix-collect-garbage --delete-older-than 7d

  if type -q direnv; and test -f .envrc
    direnv allow
  end
end
