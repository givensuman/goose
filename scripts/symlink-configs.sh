#!/usr/bin/env bash
set -euox pipefail

DIR="$HOME/world/config"

for cfg in "${DIR}"/*; do
	dst="$HOME/.config/$(basename $cfg)"

  mkdir -p "$HOME/.config"
	if [ -e "$cfg" ]; then
		rm -rf "$dst"
		ln -s "$cfg" "$dst"
		echo "Linked $dst -> $cfg"
	fi
done
