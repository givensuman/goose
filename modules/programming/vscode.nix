{ pkgs, username, ... }: {
 home-manager.users.${username} = {
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        # WIP
        mkhl.direnv
        jnoortheen.nix-ide
        tamasfe.even-better-toml
        rust-lang.rust-analyzer
        golang.go
        ms-python.python
        catppuccin.catppuccin-vsc
      ];
    };
 };
}
