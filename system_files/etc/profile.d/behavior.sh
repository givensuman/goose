#!/bin/bash

# ghostty
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
  builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
elif [ -f /usr/share/ghostty/shell-integration/bash/ghostty.bash ]; then
  builtin source /usr/share/ghostty/shell-integration/bash/ghostty.bash
fi
if [[ "$TERM" == "xterm-ghostty" ]]; then
  # Check if the terminfo actually exists; if not, fallback to xterm-256color
  if ! infocmp xterm-ghostty >/dev/null 2>&1; then
    export TERM=xterm-256color
  fi
fi

# Enable Flatpak exports
if [ -d "/var/lib/flatpak/exports/bin" ]; then
  export PATH="$PATH:/var/lib/flatpak/exports/bin"
fi

# Whether or not you're inside a container
function inside {
  if [[ -v $DISTROBOX_ENTER_PATH ]]; then
    return 0
  else
    return 1
  fi
}
