#!/bin/bash
# Flatpak scaling and environment hints
# This file provides environment variables that help flatpak applications
# integrate better with the COSMIC desktop environment

# Enable all SDK extensions for flatpak (allows debugging and development)
export FLATPAK_ENABLE_SDK_EXT=*

# Additional Wayland hints for flatpak applications
# These help apps detect and use Wayland properly
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=COSMIC

# Qt platform hints
# Helps Qt applications use the correct platform plugin
export QT_QPA_PLATFORMTHEME=qt5ct
