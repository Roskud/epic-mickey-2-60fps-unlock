#!/usr/bin/env bash
# ============================================================
# Disney Epic Mickey 2: The Power of Two - 60 FPS Fix
# 1-Click Installer for Linux & SteamOS (Steam Deck)
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================================"
echo "  Disney Epic Mickey 2 - 60 FPS Fix Installer"
echo "  Target: Linux / Steam Deck (SteamOS)"
echo "============================================================"
echo ""

# 1. Search candidate directories
GAME_DIR=""
CANDIDATES=(
    "$SCRIPT_DIR"
    "$HOME/.local/share/Steam/steamapps/common/Disney Epic Mickey 2"
    "$HOME/.steam/steam/steamapps/common/Disney Epic Mickey 2"
    "$HOME/.steam/root/steamapps/common/Disney Epic Mickey 2"
    "/run/media/mmcblk0p1/steamapps/common/Disney Epic Mickey 2"
)

# Search all mounted SD cards under /run/media
if [ -d "/run/media" ]; then
    for sd in /run/media/*/*/steamapps/common/"Disney Epic Mickey 2"; do
        if [ -d "$sd" ]; then
            CANDIDATES+=("$sd")
        fi
    done
fi

for path in "${CANDIDATES[@]}"; do
    if [ -f "$path/DEM2.exe" ]; then
        GAME_DIR="$path"
        break
    fi
done

if [ -z "$GAME_DIR" ]; then
    echo "[-] Could not automatically find Disney Epic Mickey 2."
    echo "    Please enter the full path to your game directory:"
    read -r -p "Game Path: " GAME_DIR
fi

if [ ! -f "$GAME_DIR/DEM2.exe" ]; then
    echo "[-] Error: DEM2.exe not found in $GAME_DIR"
    exit 1
fi

echo "[+] Found game directory: $GAME_DIR"

# 2. Backup and replace DEM2.exe
if [ ! -f "$GAME_DIR/DEM2.exe.bak" ]; then
    cp "$GAME_DIR/DEM2.exe" "$GAME_DIR/DEM2.exe.bak"
    echo "    [+] Created backup: DEM2.exe.bak"
fi

if [ -f "$SCRIPT_DIR/release/DEM2.exe" ]; then
    cp "$SCRIPT_DIR/release/DEM2.exe" "$GAME_DIR/DEM2.exe"
    chmod +x "$GAME_DIR/DEM2.exe"
    echo "    [+] Installed pre-patched 60 FPS DEM2.exe"
elif command -v python3 &>/dev/null; then
    python3 "$SCRIPT_DIR/patcher.py" "$GAME_DIR"
else
    echo "[-] Error: release/DEM2.exe not found and python3 is unavailable."
    exit 1
fi

# 3. Backup and update ConfigFiles.ini
CONFIG_PATH="$GAME_DIR/ConfigFiles.ini"
if [ -f "$CONFIG_PATH" ]; then
    if [ ! -f "$CONFIG_PATH.bak" ]; then
        cp "$CONFIG_PATH" "$CONFIG_PATH.bak"
        echo "    [+] Created backup: ConfigFiles.ini.bak"
    fi

    # Update frame rate locks and VSync
    sed -i -E 's/LockedFrameRate=[0-9.]+/LockedFrameRate=60.0/g' "$CONFIG_PATH"
    sed -i -E 's/LockedFrameRatePAL=[0-9.]+/LockedFrameRatePAL=60.0/g' "$CONFIG_PATH"
    sed -i -E 's/WaitForVSync=true/WaitForVSync=false/gI' "$CONFIG_PATH"

    # Add Oswald toss fix if not present
    if ! grep -q "Height=7.5" "$CONFIG_PATH"; then
        printf "\r\n\r\n[DefaultAbilities_Toss]\r\nHeight=7.5\r\n" >> "$CONFIG_PATH"
        echo "    [+] Added Oswald toss height fix (Height=7.5)"
    fi
    echo "    [+] Updated ConfigFiles.ini"
fi

echo ""
echo "============================================================"
echo "  [SUCCESS] 60 FPS MOD INSTALLED SUCCESSFULLY!"
echo "============================================================"
echo "  Launch the game normally via Steam!"
echo "============================================================"
