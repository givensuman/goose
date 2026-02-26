#!/usr/bin/bash

# Replicate Ultramarine migration script.
set -euo pipefail

trace() {
  set -x
  "$@"
  { set +x; } 2> /dev/null
}

os_version=$(grep -E '^VERSION_ID=' /etc/os-release | sed -e 's/VERSION_ID=//g'; true)

echo "  [1/3] RPM Fusion"
nonfree=$(rpm -qa rpmfusion-nonfree-release | head -c1 | wc -c)
free=$(rpm -qa rpmfusion-free-release | head -c1 | wc -c)
if [ "$nonfree" -eq 0 ] && [ "$free" -eq 0 ]; then
  echo " --> Installing rpmfusion-nonfree-release and rpmfusion-free-release"
  trace sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${os_version}.noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${os_version}.noarch.rpm"
elif [ "$nonfree" -eq 0 ]; then
  echo " --> Detected rpmfusion-free-release"
  echo " --> Installing rpmfusion-nonfree-release"
  trace sudo dnf install -y "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${os_version}.noarch.rpm"
elif [ "$free" -eq 0 ]; then
  echo " --> Detected rpmfusion-nonfree-release"
  echo " --> Installing rpmfusion-free-release"
  trace sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${os_version}.noarch.rpm"
else
  echo " --> Seems like both rpmfusion-nonfree-release and rpmfusion-free-release are installed"
fi

releasever=$(rpm -E '%fedora')

echo
echo "  [2/3] Terra"
if [ "$(rpm -qa terra-release | head -c1 | wc -c)" -eq 0 ]; then
  trace sudo dnf install -y --repofrompath "terra,https://repos.fyralabs.com/terra$releasever" --setopt="terra.gpgkey=https://repos.fyralabs.com/terra$releasever/key.asc" terra-release
else
  echo " --> Seems like terra-release has already been installed"
fi

echo
echo "  [3/3] Ultramarine Repositories"
if [ "$(rpm -qa ultramarine-repos-common | head -c1 | wc -c)" -eq 0 ]; then
  trace sudo dnf install -y --repofrompath "ultramarine,https://repos.fyralabs.com/um$releasever" --setopt="ultramarine.gpgkey=https://repos.fyralabs.com/um$releasever/key.asc" ultramarine-repos-common
else
  echo " --> Seems like ultramarine-repos-common has already been installed"
fi

# echo "Converting to Ultramarine..."
# trace sudo dnf swap -y fedora-release-common ultramarine-release-common --allowerasing
# trace sudo dnf group install --allowerasing --no-best -y ultramarine-product-common
# if [ "$(rpm -qa ultramarine-logos | head -c1 | wc -c)" -eq 0 ]; then
#   trace sudo dnf swap -y fedora-logos ultramarine-logos --allowerasing
# fi

# dnf5 config-manager addrepo --from-repofile https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo

echo "Adding DNF defaults..."
echo max_parallel_downloads=20 >> /etc/dnf/dnf.conf
echo defaultyes=True >> /etc/dnf/dnf.conf
