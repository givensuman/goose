{
  pkgs,
  hostname,
  ...
}:
{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Allow real-time priority for audio applications.
  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "-";
      value = "99999";
    }
  ];

  # Set Nix daemon to use lower scheduling priority.
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  # Enable hardware-accelerated graphics.
  hardware.graphics.enable = true;

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.editor = false;
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    # Silent Boot
    # https://wiki.archlinux.org/title/Silent_boot
    kernelParams = [
      "quiet"
      "splash"
      "vga=current"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    consoleLogLevel = 0;
    # https://github.com/NixOS/nixpkgs/pull/108294
    initrd.verbose = false;
  };

  # https://wiki.nixos.org/wiki/Hardware/Framework/Laptop_13
  # > "It is recommended to use power-profiles-daemon
  # > over tlp for the AMD framework."
  services.tlp.enable = false;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # https://wiki.nixos.org/wiki/USB_storage_devices
  services.udisks2.enable = true;
  # Unclear if this is required as well:
  services.gvfs.enable = true;

  # Enable networking.
  networking.networkmanager.enable = true;
  networking.hostName = hostname;
  hardware.bluetooth.enable = true;
}
