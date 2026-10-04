#!/usr/bin/env bash
# ============================================================
# Disney Epic Mickey 2: The Power of Two — 60 FPS Fix
# Universal 1-Click Installer for Linux & SteamOS (Steam Deck)
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================================"
echo "  Disney Epic Mickey 2: 60 FPS Fix (Steam Deck / Linux)"
echo "============================================================"
echo ""

GAME_NAME="Disney Epic Mickey 2"
GAME_DIR=""
CANDIDATES=()

# 1. Current directory and parent
CANDIDATES+=("$SCRIPT_DIR")
CANDIDATES+=("$(dirname "$SCRIPT_DIR")")

# 2. Parse Steam libraryfolders.vdf in all known Steam root locations
STEAM_ROOTS=(
    "$HOME/.local/share/Steam"
    "$HOME/.steam/steam"
    "$HOME/.steam/root"
    "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"
    "$HOME/.var/app/com.valvesoftware.Steam/.steam/steam"
)

for root in "${STEAM_ROOTS[@]}"; do
    CANDIDATES+=("$root/steamapps/common/$GAME_NAME")
    vdf="$root/steamapps/libraryfolders.vdf"
    if [ -f "$vdf" ]; then
        while IFS= read -r line; do
            if [[ "$line" =~ \"path\"[[:space:]]+\"([^\"]+)\" ]]; then
                lib_path="${BASH_REMATCH[1]}"
                lib_path="${lib_path//\\\\/\/}"
                CANDIDATES+=("$lib_path/steamapps/common/$GAME_NAME")
            fi
        done < "$vdf"
    fi
done

# 3. Scan all mounted MicroSD and external drives
if [ -d "/run/media" ]; then
    for path in /run/media/*/*/steamapps/common/"$GAME_NAME"; do
        [ -d "$path" ] && CANDIDATES+=("$path")
    done
    for path in /run/media/*/steamapps/common/"$GAME_NAME"; do
        [ -d "$path" ] && CANDIDATES+=("$path")
    done
fi

if [ -d "/media" ]; then
    for path in /media/*/*/steamapps/common/"$GAME_NAME"; do
        [ -d "$path" ] && CANDIDATES+=("$path")
    done
fi

# 4. Check candidates
for path in "${CANDIDATES[@]}"; do
    if [ -n "$path" ] && [ -f "$path/DEM2.exe" ]; then
        GAME_DIR="$path"
        break
    fi
done

# 5. If not found, ask user (GUI Zenity or terminal input)
if [ -z "$GAME_DIR" ] || [ ! -f "$GAME_DIR/DEM2.exe" ]; then
    echo "[!] Игра не найдена автоматически в стандартных папках Steam."
    if command -v zenity &>/dev/null; then
        echo "[*] Открываю окно выбора папки..."
        SELECTED=$(zenity --file-selection --directory --title="Выберите папку с игрой Disney Epic Mickey 2" 2>/dev/null || true)
        if [ -n "$SELECTED" ] && [ -f "$SELECTED/DEM2.exe" ]; then
            GAME_DIR="$SELECTED"
        fi
    fi

    if [ -z "$GAME_DIR" ] || [ ! -f "$GAME_DIR/DEM2.exe" ]; then
        echo "Пожалуйста, введите полный путь к папке игры (где находится DEM2.exe):"
        read -r -p "Путь к игре: " USER_INPUT
        if [ -n "$USER_INPUT" ] && [ -f "$USER_INPUT/DEM2.exe" ]; then
            GAME_DIR="$USER_INPUT"
        fi
    fi
fi

if [ -z "$GAME_DIR" ] || [ ! -f "$GAME_DIR/DEM2.exe" ]; then
    echo "[-] Ошибка: DEM2.exe не найден. Установка отменена."
    exit 1
fi

echo "[+] Найдена папка с игрой: $GAME_DIR"

# 6. Backup & replace DEM2.exe
if [ ! -f "$GAME_DIR/DEM2.exe.bak" ]; then
    cp "$GAME_DIR/DEM2.exe" "$GAME_DIR/DEM2.exe.bak"
    echo "    [+] Создан бэкап: DEM2.exe.bak"
fi

SOURCE_EXE=""
if [ -f "$SCRIPT_DIR/release/DEM2.exe" ]; then
    SOURCE_EXE="$SCRIPT_DIR/release/DEM2.exe"
elif [ -f "$SCRIPT_DIR/DEM2.exe" ]; then
    SOURCE_EXE="$SCRIPT_DIR/DEM2.exe"
fi

if [ -n "$SOURCE_EXE" ]; then
    cp "$SOURCE_EXE" "$GAME_DIR/DEM2.exe"
    chmod +x "$GAME_DIR/DEM2.exe"
    echo "    [+] Установлен пропатченный бинарник 60 FPS DEM2.exe"
elif [ -f "$SCRIPT_DIR/patcher.py" ] && command -v python3 &>/dev/null; then
    python3 "$SCRIPT_DIR/patcher.py" "$GAME_DIR"
else
    echo "[-] Ошибка: Файл DEM2.exe для установки не найден."
    exit 1
fi

# 7. Backup & update ConfigFiles.ini
CONFIG_PATH="$GAME_DIR/ConfigFiles.ini"
if [ -f "$CONFIG_PATH" ]; then
    if [ ! -f "$CONFIG_PATH.bak" ]; then
        cp "$CONFIG_PATH" "$CONFIG_PATH.bak"
        echo "    [+] Создан бэкап: ConfigFiles.ini.bak"
    fi

    # Update frame rate locks and VSync
    sed -i -E 's/LockedFrameRate=[0-9.]+/LockedFrameRate=60.0/g' "$CONFIG_PATH"
    sed -i -E 's/LockedFrameRatePAL=[0-9.]+/LockedFrameRatePAL=60.0/g' "$CONFIG_PATH"
    sed -i -E 's/WaitForVSync=true/WaitForVSync=false/gI' "$CONFIG_PATH"

    # Add Oswald toss fix if not present
    if ! grep -q "Height=7.5" "$CONFIG_PATH"; then
        printf "\r\n\r\n[DefaultAbilities_Toss]\r\nHeight=7.5\r\n" >> "$CONFIG_PATH"
        echo "    [+] Добавлен фикс высоты броска Освальда (Height=7.5)"
    fi
    echo "    [+] Файл ConfigFiles.ini успешно настроен (60 FPS + Oswald Fix)"
fi

# 8. Auto-configure native Steam Deck 1280x800 resolution in Proton prefix (eliminates black bars)
COMPAT_PATHS=(
    "$HOME/.local/share/Steam/steamapps/compatdata/245300/pfx/drive_c/users/steamuser/AppData/Roaming/Disney Interactive Studios/Epic Mickey 2"
    "$HOME/.steam/steam/steamapps/compatdata/245300/pfx/drive_c/users/steamuser/AppData/Roaming/Disney Interactive Studios/Epic Mickey 2"
    "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/compatdata/245300/pfx/drive_c/users/steamuser/AppData/Roaming/Disney Interactive Studios/Epic Mickey 2"
)

for cpath in "${COMPAT_PATHS[@]}"; do
    if [ -d "$cpath" ]; then
        APP_INI="$cpath/AppSettings.ini"
        if [ ! -f "$APP_INI" ]; then
            cat << 'EOF' > "$APP_INI"
[Renderer]
WindowWidth=1280
WindowHeight=800
WindowDisplayMode=2
VSync=0
AntiAliasing=1
DynamicShadowQuality=3
GroundingShadowQuality=3

[Launcher]
Language=1
EOF
            echo "    [+] Создан AppSettings.ini с нативным разрешением 1280x800 (без черных полос)"
        else
            sed -i -E 's/WindowWidth=[0-9]+/WindowWidth=1280/g' "$APP_INI"
            sed -i -E 's/WindowHeight=[0-9]+/WindowHeight=800/g' "$APP_INI"
            sed -i -E 's/WindowDisplayMode=[0-9]+/WindowDisplayMode=2/g' "$APP_INI"
            sed -i -E 's/VSync=[0-9]+/VSync=0/g' "$APP_INI"
            echo "    [+] Настроено нативное разрешение Steam Deck 1280x800 в AppSettings.ini"
        fi
        break
    fi
done

echo ""
echo "============================================================"
echo "  [УСПЕХ] МОД 60 FPS УСПЕШНО УСТАНОВЛЕН!"
echo "============================================================"
echo "  Возвращайтесь в Gaming Mode и запускайте игру через Steam!"
echo "============================================================"

