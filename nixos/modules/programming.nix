{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # CLI utilities
    bat
    bottom
    delve
    eza
    fd
    fzf
    gh
    lazygit
    ripgrep
    p7zip
    opencode
    shellcheck
    shfmt
    tree-sitter
    zoxide

    # Programming languages
    bun
    yarn
    deno
    nodejs_24
    python3
    cargo
    rustc
    go
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
