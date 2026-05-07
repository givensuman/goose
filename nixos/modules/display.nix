{ pkgs, ... }:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    wlsunset
  ];

  services.wlsunset = {
    enable = true;

    temperature = {
      day = 6500;
      night = 3000;
    };

    sunrise = "06:00";
    sunset = "18:00";
  };
}
