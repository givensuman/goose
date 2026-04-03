{ pkgs, inputs, ... }: {
  imports = [
    inputs.flatpaks.nixosModules.nix-flatpak
  ];

  services.flatpak.enable = true;
  services.flatpak.remotes = [{
    name = "flathub";
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  }];
  services.flatpak.packages = [
    "org.mozilla.firefox"
    "com.spotify.Client"
    "com.discordapp.Discord"
    "io.podman_desktop.PodmanDesktop"
  ];
  services.flatpak.overrides = {
    global = {
      Context.filesystems = ["xdg-config/gtk-3.0:ro" "xdg-config/gtk-4.0:ro"];
      Context.sockets = ["wayland" "!x11" "!fallback-x11"];
      Environments = {
        GDK_SCALE = "1";
        QT_SCALE_FACTOR = "1";
        GDK_BACKEND = "wayland";
        QT_QPA_PLATFORM = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };
    };
  };
  environment.systemPackages = with pkgs; [
    # Apps
    ghostty
    bazaar

    # Fonts
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    fira-sans
    inter
    open-sans
    roboto
    ubuntu-sans
  ];

  # Use COSMIC desktop.
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.system76-scheduler.enable = true;
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit   # Prefer Neovim
    cosmic-store  # Prefer Bazaar
    cosmic-term   # Prefer Ghostty
  ];
}
