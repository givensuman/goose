{ pkgs, ... }: {
  programs.fish.enable = true;
  programs.git.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    unzip
    zip
    git
    just
    gcc
    fish
    htop
    libcap
    iotop
    strace
    lsof
    util-linux
    wl-clipboard
    less
  ];
}
