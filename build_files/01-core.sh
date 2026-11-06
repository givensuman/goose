#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
set -eou pipefail

mkdir -p /var/lib/samba/usershares
# chown -R root:usershares /var/lib/samba/usershares
firewall-offline-cmd --service=samba --service=samba-client
setsebool -P samba_enable_home_dirs=1
setsebool -P samba_export_all_ro=1
setsebool -P samba_export_all_rw=1
sed -i '/^\[homes\]/,/^\[/{/^\[homes\]/d;/^\[/!d}' /etc/samba/smb.conf

systemctl preset-all
systemctl --global preset-all

# Keep *-logos in RPM DB for downstream package installations
dnf -y swap fedora-logos generic-logos
rpm --erase --nodeps --nodb generic-logos

dnf makecache --refresh

OVERRIDES=(
    "intel-gmmlib"
    "intel-mediasdk"
    "libheif"
    "libva"
    "libva-intel-media-driver"
    "mesa-dri-drivers"
    "mesa-filesystem"
    "mesa-libEGL"
    "mesa-libGL"
    "mesa-libgbm"
    "mesa-libOpenCL"
    "mesa-vulkan-drivers"
    "openh264"
)

dnf5 distro-sync --skip-unavailable -y --repo='fedora-multimedia' "${OVERRIDES[@]}"
dnf5 versionlock add "${OVERRIDES[@]}"

FEDORA_PACKAGES=(
    adcli
    alsa-firmware
    apr{,-util}
    autofs
    borgbackup
    davfs2
    distrobox
    evtest
    fastfetch
    fish
    flatpak-spawn
    foo2zjs
    gcc{,-c++}
    git-credential-libsecret
    glow
    google-noto-sans-balinese-fonts
    google-noto-sans-cham-fonts
    google-noto-sans-cjk-fonts
    google-noto-sans-javanese-fonts
    google-noto-sans-linear-a-fonts
    google-noto-sans-linear-b-fonts
    google-noto-sans-sundanese-fonts
    grub2-tools-extra
    gum
    gvfs{,-fuse}
    htop
    icoutils
    ifuse
    igt-gpu-tools
    input-remapper
    intel-compute-runtime
    iwd
    just
    kate{-krunner-plugin,-plugins}
    fzf
    krb5-workstation
    ksystemlog
    libcamera-gstreamer
    libcamera-tools
    libimobiledevice-utils
    libratbag-ratbagd
    libxcrypt-compat
    lm_sensors
    lshw
    nvtop
    oddjob-mkhomedir
    openrgb-udev-rules
    pam-u2f
    pam_yubico
    pamu2fcfg
    pocl
    powertop
    rclone
    restic
    samba-winbind{,-clients,-modules}
    setools-console
    setroubleshoot-plugins
    solaar-udev
    squashfs-tools
    symlinks
    tcpdump
    tesseract-devel
    tesseract-langpack-{deu,fra,spa,por,ita,pol,fin,nld,jpn,jpn_vert,hin,chi_sim,chi_sim_vert,chi_tra,chi_tra_vert}
    tmux
    traceroute
    vim
    xdg-native-messaging-proxy
    yubikey-manager
    zsh
)

FEDORA_PACKAGES_AMD64=(
    powerstat
  )

NEGATIVO_PACKAGES=(
    ffmpeg{,-libs}
    libavcodec
    libfdk-aac
    libva-utils
    pipewire-libs-extra
    uld
  )

NEGATIVO_PACKAGES_AMD64=(
    intel-vaapi-driver
  )

PACKAGES=( "${FEDORA_PACKAGES[@]}" "${NEGATIVO_PACKAGES[@]}" )

if [[ $(arch) == x86_64 ]]; then
  PACKAGES+=( "${FEDORA_PACKAGES_AMD64[@]}" "${NEGATIVO_PACKAGES_AMD64[@]}" )
fi

dnf -y install \
  --setopt=install_weak_deps=False \
  --enablerepo='fedora-multimedia' "${PACKAGES[@]}"

# Covered by usage of ublue-os/base-main
# COPR_UBLUE_OS_PACKAGES=(
#     kcm_ublue
#     krunner-bazaar
#     oversteer-udev
# )

# dnf copr enable ublue-os/packages
# dnf -y install "${COPR_UBLUE_OS_PACKAGES[@]}"

# TERRA_PACKAGES=(
#   uupd
#   game-devices-udev
# )

# dnf5 install -y --nogpgcheck \
#   --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" \
#   terra-release

# dnf -y install "${TERRA_PACKAGES[@]}"

EXCLUDED_PACKAGES=(
    akonadi-server{,-mysql}
    fedora-bookmarks
    fedora-chromium-config{,-kde}
    fedora-third-party
    firewall-config
    kcharselect
    khelpcenter
    krfb{,-libs}
    # https://github.com/ublue-os/aurora/issues/3066
    xwaylandvideobridge
)

dnf -y remove "${EXCLUDED_PACKAGES[@]}"

echo "::endgroup::"