# Everything related to containerization goes here.
# https://nixos.wiki/wiki/Podman
# https://nixos.wiki/wiki/Docker
{ pkgs, ... }:
{
  # Enable common container config files in /etc/containers.
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      # dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    devbox
    dive
    skopeo
    docker-compose
    podman-compose
  ];
}
