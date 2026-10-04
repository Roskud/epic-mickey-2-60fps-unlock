#!/usr/bin/env python3
"""
Disney Epic Mickey 2: The Power of Two - 60 FPS & Physics Fix Patcher
Cross-platform auto-patcher for Windows and Linux (Steam Deck).
"""

import sys
import os
import re
import shutil
import subprocess
import platform

APP_ID = "245300"
GAME_NAME = "Disney Epic Mickey 2"
FLOAT_30 = bytes([0xF0, 0xC1, 0x00, 0x00, 0xF0, 0x41, 0x00, 0x00])
FLOAT_60 = bytes([0xF0, 0xC1, 0x00, 0x00, 0x70, 0x42, 0x00, 0x00])


def print_banner():
    print("=" * 60)
    print("  Disney Epic Mickey 2 - 60 FPS & Physics Fix Patcher")
    print("  Compatible with Windows & Linux / SteamOS (Steam Deck)")
    print("=" * 60)


def find_game_dir():
    # 1. Current directory or parent directory
    for check_dir in [os.getcwd(), os.path.dirname(os.path.abspath(__file__))]:
        if os.path.exists(os.path.join(check_dir, "DEM2.exe")):
            return check_dir

    # 2. Check candidate paths based on OS
    system = platform.system()
    candidates = []

    if system == "Windows":
        candidates.extend([
            r"C:\Program Files (x86)\Steam\steamapps\common\Disney Epic Mickey 2",
            r"C:\Program Files\Steam\steamapps\common\Disney Epic Mickey 2",
            r"D:\SteamLibrary\steamapps\common\Disney Epic Mickey 2",
            r"E:\SteamLibrary\steamapps\common\Disney Epic Mickey 2",
            r"F:\SteamLibrary\steamapps\common\Disney Epic Mickey 2",
            r"G:\SteamLibrary\steamapps\common\Disney Epic Mickey 2",
        ])
        # Try finding Steam path via Windows Registry
        try:
            import winreg
            with winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\Valve\Steam") as key:
                steam_path = winreg.QueryValueEx(key, "SteamPath")[0]
                candidates.insert(0, os.path.join(steam_path, "steamapps", "common", GAME_NAME))
                parse_library_folders(os.path.join(steam_path, "steamapps", "libraryfolders.vdf"), candidates)
        except Exception:
            pass

    elif system == "Linux" or "bsd" in system.lower():
        home = os.path.expanduser("~")
        candidates.extend([
            os.path.join(home, ".local/share/Steam/steamapps/common", GAME_NAME),
            os.path.join(home, ".steam/steam/steamapps/common", GAME_NAME),
            os.path.join(home, ".steam/root/steamapps/common", GAME_NAME),
            f"/run/media/mmcblk0p1/steamapps/common/{GAME_NAME}",
        ])
        # Check Steam Deck SD card mounts
        media_root = "/run/media"
        if os.path.exists(media_root):
            for user in os.listdir(media_root):
                user_path = os.path.join(media_root, user)
                if os.path.isdir(user_path):
                    for drive in os.listdir(user_path):
                        candidates.append(os.path.join(user_path, drive, "steamapps", "common", GAME_NAME))

        # Check libraryfolders.vdf on Linux
        for base in [os.path.join(home, ".local/share/Steam"), os.path.join(home, ".steam/steam")]:
            vdf = os.path.join(base, "steamapps", "libraryfolders.vdf")
            parse_library_folders(vdf, candidates)

    for c in candidates:
        if os.path.exists(os.path.join(c, "DEM2.exe")):
            return c

    return None


def parse_library_folders(vdf_path, candidates):
    if not os.path.exists(vdf_path):
        return
    try:
        with open(vdf_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                match = re.search(r'"path"\s+"([^"]+)"', line)
                if match:
                    lib_path = match.group(1).replace("\\\\", "\\")
                    candidates.append(os.path.join(lib_path, "steamapps", "common", GAME_NAME))
    except Exception:
        pass


def patch_config_files(config_path):
    print(f"\n[*] Updating ConfigFiles.ini at: {config_path}")
    bak_path = config_path + ".bak"
    if not os.path.exists(bak_path):
        shutil.copy2(config_path, bak_path)
        print(f"    [+] Created backup: {os.path.basename(bak_path)}")

    with open(config_path, "r", encoding="latin-1", errors="ignore") as f:
        content = f.read()

    # Modify FPS lock and VSync
    content = re.sub(r"LockedFrameRate\s*=\s*[0-9.]+", "LockedFrameRate=60.0", content)
    content = re.sub(r"LockedFrameRatePAL\s*=\s*[0-9.]+", "LockedFrameRatePAL=60.0", content)
    content = re.sub(r"WaitForVSync\s*=\s*true", "WaitForVSync=false", content, flags=re.IGNORECASE)

    # Oswald toss height fix (prevents softlock in Episode 2 where Mickey can't reach high ledges at 60 FPS)
    toss_fix = "\n\n[DefaultAbilities_Toss]\nHeight=7.5\n"
    if "Height=7.5" not in content:
        content += toss_fix
        print("    [+] Added Oswald toss height fix (Height=7.5) to prevent softlocks")

    with open(config_path, "w", encoding="latin-1") as f:
        f.write(content)
    print("    [+] ConfigFiles.ini successfully updated (LockedFrameRate=60.0, WaitForVSync=false)")


def patch_executable(exe_path, script_dir):
    print(f"\n[*] Processing executable: {exe_path}")
    bak_path = exe_path + ".bak"
    if not os.path.exists(bak_path):
        shutil.copy2(exe_path, bak_path)
        print(f"    [+] Created backup: {os.path.basename(bak_path)}")

    # Check if a pre-patched release binary is available in the mod directory
    release_binary = os.path.join(script_dir, "release", "DEM2.exe")
    if os.path.exists(release_binary):
        print("    [*] Found verified pre-patched 60 FPS executable in release/...")
        shutil.copy2(release_binary, exe_path)
        print("    [+] Successfully installed pre-patched 60 FPS DEM2.exe!")
        return True

    with open(exe_path, "rb") as f:
        data = bytearray(f.read())

    # Check if already patched
    if FLOAT_60 in data:
        print("    [+] DEM2.exe is already patched for 60 FPS!")
        return True

    # Check if DRM-unpacked
    if FLOAT_30 not in data:
        print("    [*] Executable has SteamStub DRM. Unpacking with Steamless...")
        steamless_cli = os.path.join(script_dir, "tools", "Steamless", "Steamless.CLI.exe")
        if not os.path.exists(steamless_cli):
            print(f"    [-] Error: Steamless.CLI.exe not found at: {steamless_cli}")
            return False

        if platform.system() == "Windows":
            cmd = [steamless_cli, exe_path]
        else:
            cmd = ["wine", steamless_cli, exe_path]

        try:
            res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=60)
            if res.returncode != 0 and not os.path.exists(exe_path + ".unpacked.exe"):
                print(f"    [-] Steamless failed:\n{res.stdout}\n{res.stderr}")
                return False
        except Exception as e:
            print(f"    [-] Error running Steamless: {e}")
            return False

        unpacked_path = exe_path + ".unpacked.exe"
        if not os.path.exists(unpacked_path):
            print("    [-] Error: Unpacked executable was not generated.")
            return False

        with open(unpacked_path, "rb") as f:
            data = bytearray(f.read())

    # Now apply the float patch
    idx = data.find(FLOAT_30)
    if idx == -1:
        print("    [-] Error: Could not find 30.0f frame limiter sequence in unpacked binary.")
        return False

    print(f"    [*] Found frame limiter at offset 0x{idx:X}. Applying 60.0f patch...")
    data[idx:idx + len(FLOAT_60)] = FLOAT_60

    with open(exe_path, "wb") as f:
        f.write(data)
    print("    [+] DEM2.exe successfully patched to 60 FPS!")
    return True


def restore_backups(game_dir):
    print(f"\n[*] Restoring original backups in: {game_dir}")
    restored = 0
    for name in ["DEM2.exe", "ConfigFiles.ini"]:
        target = os.path.join(game_dir, name)
        bak = target + ".bak"
        if os.path.exists(bak):
            shutil.copy2(bak, target)
            print(f"    [+] Restored {name} from {name}.bak")
            restored += 1
        else:
            print(f"    [-] No backup found for {name}")
    if restored > 0:
        print("\n[+] Restoration complete! The game is now in its original state.")
    else:
        print("\n[-] Nothing to restore.")


def main():
    print_banner()
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Check for uninstall / restore flag
    is_restore = "--restore" in sys.argv or "--uninstall" in sys.argv

    game_dir = None
    for arg in sys.argv[1:]:
        if not arg.startswith("--") and os.path.isdir(arg):
            game_dir = os.path.abspath(arg)
            break

    if not game_dir:
        print("[*] Searching for Disney Epic Mickey 2 installation...")
        game_dir = find_game_dir()

    if not game_dir or not os.path.exists(game_dir):
        print("\n[-] Could not locate Disney Epic Mickey 2 directory automatically.")
        print("    Please provide the path as an argument, for example:")
        print(f'    python patcher.py "C:\\Program Files (x86)\\Steam\\steamapps\\common\\{GAME_NAME}"')
        sys.exit(1)

    print(f"[+] Found game directory: {game_dir}")

    if is_restore:
        restore_backups(game_dir)
        sys.exit(0)

    exe_path = os.path.join(game_dir, "DEM2.exe")
    config_path = os.path.join(game_dir, "ConfigFiles.ini")

    if not os.path.exists(exe_path) or not os.path.exists(config_path):
        print("[-] Error: DEM2.exe or ConfigFiles.ini not found in the game folder.")
        sys.exit(1)

    ok = patch_executable(exe_path, script_dir)
    if not ok:
        print("\n[-] Executable patching failed.")
        sys.exit(1)

    patch_config_files(config_path)

    print("\n" + "=" * 60)
    print("  [SUCCESS] 60 FPS MOD INSTALLED SUCCESSFULLY!")
    print("=" * 60)
    print("  - Frame limit unlocked to 60 FPS")
    print("  - VSync wait disabled for reduced input lag")
    print("  - Oswald toss height adjusted to 7.5 (no softlocks)")
    print("  - Steam Overlay & Playtime Tracking 100% preserved")
    print("  - Backups created (.bak)")
    print("=" * 60)


if __name__ == "__main__":
    main()
