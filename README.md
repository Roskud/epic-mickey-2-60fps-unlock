# Disney Epic Mickey 2: The Power of Two — 60 FPS & Physics Fix 🎮

<div align="center">

[![Language: English](https://img.shields.io/badge/Language-English-blue.svg)](README.md)
[![Language: Russian](https://img.shields.io/badge/Язык-Русский-red.svg)](README_RU.md)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20SteamDeck-brightgreen.svg)](#)
[![Game Version](https://img.shields.io/badge/Steam%20AppID-245300-orange.svg)](https://store.steampowered.com/app/245300/Disney_Epic_Mickey_2_The_Power_of_Two/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**[English](README.md) | [Русский](README_RU.md)**

*A complete, stable, and automated 60 FPS unlocker & physics fix for Disney Epic Mickey 2 on Windows and Steam Deck (SteamOS / Linux).*

</div>

---

## ✨ Features

- ⚡ **True 60 FPS Gameplay**: Unlocks the game engine from its hardcoded 30 FPS cap.
- 🎯 **Oswald Toss Fix (No Softlocks)**: At 60 FPS, the physics timestep alters jump height. This fix calibrates Mickey's toss height to `7.5`, preventing the game-breaking softlock in Episode 2 where Mickey cannot reach high platforms.
- 🛡️ **Steam Features 100% Intact**:
  - Full **Steam Overlay** (`Shift+Tab`) support.
  - Active **"In-Game" Status** visible to friends.
  - **Achievements** and **Playtime Tracking** work normally.
- 🚀 **1-Click Automated Installers**:
  - **Windows**: `install.bat` (supports native PowerShell, no Python required).
  - **Linux / Steam Deck**: `install.sh` (auto-detects internal SSD and microSD cards).
- 🔄 **Safe Backups & 1-Click Restore**: Automatically creates `.bak` files. Revert to 30 FPS anytime using `restore.bat` or `restore.sh`.

---

## 📥 Installation

### 🪟 Windows (1-Click)

1. [Download the latest release ZIP](https://github.com/Roskud/epic-mickey-2-60fps-unlock/releases) (or clone the repository).
2. Extract the archive.
3. Double-click **`install.bat`**.
   - *The script automatically locates your Steam game installation, creates backups, installs the patched 60 FPS binary, and updates the configuration.*
4. Launch the game normally via **Steam**!

---

### 🎮 Steam Deck (SteamOS / Linux) (1-Click)

1. Switch your Steam Deck to **Desktop Mode** (*Power → Switch to Desktop*).
2. Download or copy the mod folder onto your Steam Deck.
3. Open the folder, right-click **`install.sh`** → **Run in Konsole** (or open terminal in that folder and run):
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
   - *The script scans internal storage (`~/.local/share/Steam/...`) and all mounted microSD cards (`/run/media/...`), applies the fix, and sets execute permissions.*
4. Switch back to **Gaming Mode** and launch Epic Mickey 2 from your library!

---

## 🖐️ Manual Installation

If you prefer to apply files manually:

1. Open the game directory:
   - **Windows**: `C:\Program Files (x86)\Steam\steamapps\common\Disney Epic Mickey 2`
   - **Steam Deck**: `~/.local/share/Steam/steamapps/common/Disney Epic Mickey 2` (or on your SD card)
2. Back up existing `DEM2.exe` and `ConfigFiles.ini` (e.g. rename them with `.bak` extension).
3. Copy `release/DEM2.exe` from this repository into the game directory, replacing the original.
4. Open `ConfigFiles.ini` with any text editor:
   - Find and edit the following values:
     ```ini
     WaitForVSync=false
     LockedFrameRate=60.0
     LockedFrameRatePAL=60.0
     ```
   - Scroll to the bottom and add the toss physics correction:
     ```ini
     [DefaultAbilities_Toss]
     Height=7.5
     ```
5. Save the file and launch the game via Steam.

---

## ↩️ Uninstallation / Revert to 30 FPS

- **Windows**: Run **`restore.bat`**.
- **Linux / Steam Deck**: Run **`./restore.sh`**.
- Or restore manually by replacing `DEM2.exe` and `ConfigFiles.ini` with your `.bak` backups.

---

## 🔬 Technical Explanation (Why previous Hex patches failed)

 многих пользователей при попытке отредактировать `DEM2.exe` возникала ошибка:
```
Application load error 3:0000065432
```

### Why did this happen?
1. **SteamStub DRM (Variant 3.1 x86)**:
   The official Steam release of `DEM2.exe` contains a SteamStub protection envelope. When you hex-edit the binary on disk without removing the wrapper, Steam's integrity verification fails and blocks execution.
2. **The Clean Solution**:
   Using **Steamless**, the SteamStub DRM envelope was unpacked while keeping full linkage to `steam_api.dll`.
3. **The 60 FPS Float Patch**:
   At file offset `0xE3F736`, the engine's hardcoded frame rate limiter was modified:
   - **Original**: `F0 C1 00 00 F0 41 00 00` (`-30.0f`, `+30.0f`)
   - **Patched**: `F0 C1 00 00 70 42 00 00` (`-30.0f`, `+60.0f`)
4. **Oswald Physics Adjustment**:
   The Gamebryo engine's physics steps are tied to frame delta. At 60 FPS, Oswald's coop toss height is halved relative to velocity ticks, causing Mickey to fall short of reachable ledges in Episode 2. Setting `[DefaultAbilities_Toss] Height=7.5` in `ConfigFiles.ini` restores the original intended jump trajectory.

---

## 📁 Repository Structure

```
epic-mickey-2-60fps-unlock/
├── README.md               # English Documentation
├── README_RU.md            # Russian Documentation
├── install.bat             # 1-Click Windows Batch Installer
├── patcher.ps1             # Native PowerShell Installer (No Python required)
├── restore.bat             # 1-Click Windows Uninstaller
├── install.sh              # 1-Click Linux / Steam Deck Bash Installer
├── restore.sh              # 1-Click Linux / Steam Deck Uninstaller
├── patcher.py              # Universal Cross-Platform Python Patcher
├── release/                # Pre-patched binaries ready to drop in
│   ├── DEM2.exe            # 60 FPS Patched Binary
│   └── ConfigFiles.ini     # Optimized Config with Oswald Fix
├── tools/                  # DRM unpacker utilities
└── LICENSE                 # MIT License
```

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).
