{ pkgs, inputs, config, ... }: {
  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.catppuccin.nixosModules.catppuccin
  ];

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

  catppuccin = {
    enable = true;
    accent = "lavender";
    flavor = "mocha";

    cursors.enable = true;
    gtk.icon.enable = true;
    grub.enable = true;
    tty.enable = true;
  };
}
