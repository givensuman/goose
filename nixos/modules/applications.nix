{ pkgs, inputs, ... }:
{
  imports = [
    inputs.flatpaks.nixosModules.nix-flatpak
  ];

  services.flatpak.packages = [
    # Pinned
    "com.spotify.Client"
    "io.github.milkshiift.GoofCord"
    "org.localsend.localsend_app"
    "de.haeckerfelix.Fragments"
    "io.podman_desktop.PodmanDesktop"
    # Additional
    # "dev.edfloreshz.Tasks" # To-Do list
    "org.nickvision.tubeconverter" # Media downloader
    "io.github.kriptolix.Poliedros" # Dice roller
    "de.til7701.Puzzled" # Lil' puzzles
    "com.obsproject.Studio"
    "org.kde.kdenlive"
  ];

  environment.systemPackages = with pkgs; [
    steam
  ];
}
