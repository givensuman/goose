{
  pkgs,
  ...
}:
{
  imports = [
    ./helix.nix
    ./neovim.nix
    ./vscode.nix
  ];

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  environment.systemPackages = with pkgs; [
    opencode
  ];
}
