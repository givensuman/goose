{ pkgs, username, ... }: {
 home-manager.users.${username} = {
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        mkhl.direnv
      jnoortheen.nix-ide
      tamasfe.even-better-toml
      rust-lang.rust-analyzer
      golang.go
      ms-python.python
      drmerfy.overtype
      catppuccin.catppuccin-vsc
      ];
    }
}