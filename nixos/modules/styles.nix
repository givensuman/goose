{ pkgs, inputs, config, ... }: {
  imports = [
    inputs.stylix.nixosModules.stylix
    # inputs.spicetify.nixosModules.default
  ];

  # https://github.com/nix-community/stylix
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

  stylix.fonts = {
    sansSerif = {
      package = pkgs.inter;
      name = "Inter";
    };

    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrains Mono Nerd Font";
    };

    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
    };
  };
  stylix.fonts.serif = config.stylix.fonts.sansSerif;

  environment.systemPackages = with pkgs; [
    fira-sans
    open-sans
    ubuntu-sans
    roboto
  ];

  # https://wiki.nixos.org/wiki/Spicetify-Nix
  # programs.spicetify =
  # let
  #   spicePkgs = inputs.spicetify.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  # in
  # {
  #   enable = true;
  #
  #   enabledExtensions = with spicePkgs.extensions; [
  #     adblock
  #     shuffle # shuffle+ (special characters are sanitized out of extension names)
  #   ];
  #   enabledCustomApps = with spicePkgs.apps; [
  #     newReleases
  #     ncsVisualizer
  #   ];
  #   enabledSnippets = with spicePkgs.snippets; [
  #     rotatingCoverart
  #     pointer
  #   ];
  #
  #   theme = spicePkgs.themes.catppuccin;
  #   colorScheme = "mocha";
  # };
}
