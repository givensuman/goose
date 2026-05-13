#!/bin/bash
# flatpak-preinstall not supported with Flatpak
# currently shipped with Fedora.

# Directory containing the preinstall files
PREINSTALL_DIR="/usr/share/flatpak/preinstall.d"

# Check if the directory exists
if [ ! -d "$PREINSTALL_DIR" ]; then
    echo "Error: Directory $PREINSTALL_DIR does not exist."
    exit 1
fi

echo "Starting Flatpak preinstall process..."

# Loop through all .preinstall files
for file in "$PREINSTALL_DIR"/*.preinstall; do
    [ -e "$file" ] || continue

    echo "Processing: $(basename "$file")"

    # Read the file line by line
    while IFS= read -r line || [ -n "$line" ]; do
        ref=$(echo "$line" \
        | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        [[ -z "$ref" || "$ref" =~ ^# ]] && continue

        echo "Installing $ref..."

        flatpak install --system --noninteractive --needed -y "$ref"

        if [ $? -eq 0 ]; then
            echo "Successfully processed $ref"
        else
            echo "Failed to process $ref"
        fi
    done < "$file"
done

echo "Preinstall process complete."
