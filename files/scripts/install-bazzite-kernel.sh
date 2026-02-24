#!/usr/bin/env bash
# install-bazzite-kernel.sh
# Pulls the Bazzite kernel OCI image and replaces the standard Fedora kernel.
# Must run before any akmod installation that targets the bazzite kernel base.
set -euo pipefail

# Ensure dnf5-plugin-versionlock is available for kernel pinning
dnf5 -y install dnf5-plugin-versionlock 2>/dev/null || true

FEDORA_VERSION=$(rpm -E %fedora)
ARCH=$(uname -m)
KERNEL_REF="ghcr.io/bazzite-org/kernel-bazzite:latest-f${FEDORA_VERSION}-${ARCH}"
KERNEL_DIR="/tmp/kernel-bazzite"
RPM_DIR="/tmp/rpms/kernel"

echo "==> Installing Bazzite kernel (Fedora ${FEDORA_VERSION}, ${ARCH})"
echo "    Source: ${KERNEL_REF}"

mkdir -p "${KERNEL_DIR}" "${RPM_DIR}"

# Pull the kernel OCI image as a directory layout
echo "==> Pulling kernel OCI image..."
skopeo copy \
    --retry-times 3 \
    "docker://${KERNEL_REF}" \
    "dir:${KERNEL_DIR}"

# Extract each layer; RPM files are stored at the root of the OCI image
echo "==> Extracting kernel RPMs from OCI layers..."
while IFS= read -r digest; do
    filename="${digest#sha256:}"
    layer_file="${KERNEL_DIR}/${filename}"
    if [[ -f "${layer_file}" ]]; then
        tar -xzf "${layer_file}" -C "${RPM_DIR}/" 2>/dev/null || \
        tar -xf  "${layer_file}" -C "${RPM_DIR}/" 2>/dev/null || \
        echo "    (skipping non-archive layer ${filename})"
    fi
done < <(jq -r '.layers[].digest' "${KERNEL_DIR}/manifest.json")

echo "==> Available kernel packages:"
find "${RPM_DIR}" -name "*.rpm" | sort

# Temporarily stub out the kernel install hooks so dnf5 doesn't try to
# regenerate dracut or trigger rpm-ostree during the raw RPM install step.
# (The initramfs module will regenerate properly afterward.)
INSTALL_D="/usr/lib/kernel/install.d"
for hook in 05-rpmostree.install 50-dracut.install; do
    [[ -f "${INSTALL_D}/${hook}" ]] && \
        cp "${INSTALL_D}/${hook}" "${INSTALL_D}/${hook}.bak"
    printf '#!/bin/sh\nexit 0\n' > "${INSTALL_D}/${hook}"
    chmod +x "${INSTALL_D}/${hook}"
done

# Remove the existing Fedora kernel packages
echo "==> Removing existing Fedora kernel..."
dnf5 -y remove --no-autoremove \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    kernel-modules-extra \
    kernel-tools \
    kernel-tools-libs 2>/dev/null || true

# Install the Bazzite kernel packages
echo "==> Installing Bazzite kernel packages..."
PKGS=(
    kernel
    kernel-core
    kernel-modules
    kernel-modules-core
    kernel-modules-extra
    kernel-modules-akmods
    kernel-devel
    kernel-devel-matched
    kernel-tools
    kernel-tools-libs
    kernel-common
)

PKG_PATHS=()
for pkg in "${PKGS[@]}"; do
    # Match any kernel version number (not just 6.x, to stay future-proof)
    matches=("${RPM_DIR}"/${pkg}-[0-9]*.rpm)
    if [[ ${#matches[@]} -gt 0 && -f "${matches[0]}" ]]; then
        PKG_PATHS+=("${matches[@]}")
    fi
done

if [[ ${#PKG_PATHS[@]} -eq 0 ]]; then
    echo "ERROR: No kernel RPMs found in ${RPM_DIR}" >&2
    exit 1
fi

dnf5 -y install "${PKG_PATHS[@]}"

# Pin the bazzite kernel so dnf updates cannot replace it
# (Only relevant during build; atomic images are already immutable post-deploy.)
echo "==> Pinning bazzite kernel packages..."
if dnf5 versionlock --help &>/dev/null; then
    dnf5 versionlock add "${PKGS[@]}" 2>/dev/null || true
else
    echo "    dnf5 versionlock not available; skipping pin (not needed for atomic images)."
fi

# Restore the original install hooks
for hook in 05-rpmostree.install 50-dracut.install; do
    [[ -f "${INSTALL_D}/${hook}.bak" ]] && \
        mv -f "${INSTALL_D}/${hook}.bak" "${INSTALL_D}/${hook}"
done

# Clean up temporary files
rm -rf "${KERNEL_DIR}" /tmp/rpms

echo "==> Bazzite kernel installation complete."
