#!/usr/bin/env bash
# Restore original files on Linux / Steam Deck

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CANDIDATES=(
    "$SCRIPT_DIR"
    "$HOME/.local/share/Steam/steamapps/common/Disney Epic Mickey 2"
    "$HOME/.steam/steam/steamapps/common/Disney Epic Mickey 2"
    "/run/media/mmcblk0p1/steamapps/common/Disney Epic Mickey 2"
)

for path in "${CANDIDATES[@]}"; do
    if [ -f "$path/DEM2.exe.bak" ]; then
        cp "$path/DEM2.exe.bak" "$path/DEM2.exe"
        echo "[+] Restored DEM2.exe"
    fi
    if [ -f "$path/ConfigFiles.ini.bak" ]; then
        cp "$path/ConfigFiles.ini.bak" "$path/ConfigFiles.ini"
        echo "[+] Restored ConfigFiles.ini"
    fi
done

echo "[+] Done restoring original game files."
