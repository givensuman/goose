#!/usr/bin/bash

# Load shared functions
# shellcheck source=build_files/00-functions.sh
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -euox pipefail

# Trap errors
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Installing MediaTek firmware for Framework laptops..."

# Create temporary directory for firmware downloads
firmware_tmp="/tmp/mediatek-firmware"
safe_mkdir "${firmware_tmp}"

# MediaTek MT7922 WiFi firmware files
# These are required for WiFi on Framework 13 laptops with MediaTek cards
firmware_base_url="https://gitlab.com/kernel-firmware/linux-firmware/-/raw/8f08053b2a7474e210b03dbc2b4ba59afbe98802/mediatek"

log_info "Downloading MediaTek WiFi firmware patch..."
download_file \
  "${firmware_base_url}/WIFI_MT7922_patch_mcu_1_1_hdr.bin?inline=false" \
  "${firmware_tmp}/WIFI_MT7922_patch_mcu_1_1_hdr.bin"

log_info "Downloading MediaTek WiFi firmware RAM code..."
download_file \
  "${firmware_base_url}/WIFI_RAM_CODE_MT7922_1.bin?inline=false" \
  "${firmware_tmp}/WIFI_RAM_CODE_MT7922_1.bin"

# Compress firmware files with xz
log_info "Compressing firmware files..."
xz --check=crc32 "${firmware_tmp}/WIFI_MT7922_patch_mcu_1_1_hdr.bin"
xz --check=crc32 "${firmware_tmp}/WIFI_RAM_CODE_MT7922_1.bin"

# Install firmware files
log_info "Installing firmware to /usr/lib/firmware/mediatek/..."
safe_mkdir /usr/lib/firmware/mediatek
mv -vf "${firmware_tmp}"/* /usr/lib/firmware/mediatek/

# Clean up
rm -rf "${firmware_tmp}"

log_info "MediaTek firmware installation completed successfully"

echo "::endgroup::"
