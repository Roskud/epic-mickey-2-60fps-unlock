# Disney Epic Mickey 2: The Power of Two — 60 FPS & Physics Fix 🎮

[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20SteamDeck-blue.svg)](#)
[![Game Version](https://img.shields.io/badge/Steam%20AppID-245300-orange.svg)](https://store.steampowered.com/app/245300/Disney_Epic_Mickey_2_The_Power_of_Two/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Полный и стабильный фикс 60 FPS для игры **Disney Epic Mickey 2: The Power of Two** на **Windows** и **Steam Deck (SteamOS / Linux)** с сохранением оверлея Steam, достижений, времени игры и статуса в сети.

---

## 🌟 Возможности / Features

- ⚡ **Настоящие 60 FPS** без ускорения анимаций и багов таймера.
- 🎯 **Исправление физики броска Освальда (Oswald Toss Fix)**: на 60 FPS высота подбрасывания Микки скорректирована до `7.5`, что предотвращает непроходимый софтлок во 2-м эпизоде.
- 🛡️ **Steam Overlay, Friends & Achievements**: игра запускается через обычный Steam — статус "В игре", оверлей (`Shift+Tab`), достижения и счётчик часов работают штатно.
- 📦 **Автоматические установщики в 1 клик**:
  - `install.bat` / `patcher.ps1` для Windows
  - `install.sh` для Linux и Steam Deck
- 🔄 **Автобэкап и откат в 1 клик**: оригинальные файлы сохраняются в `.bak`, вернуть игру в исходное состояние можно через `restore.bat` / `restore.sh`.

---

## 🚀 Быстрая установка (1 клик) / Quick Install

### 🪟 Windows:
1. Скачайте архив репозитория (или склонируйте его).
2. Запустите **`install.bat`** (или `patcher.ps1`).
3. Скрипт сам найдёт папку со стимовской копией игры, сделает бэкапы, применит фикс и настроит конфигурацию.
4. Запустите игру как обычно через библиотеку **Steam**.

### 🎮 Steam Deck (SteamOS / Linux):
1. Перейдите в **Desktop Mode** (Режим рабочего стола).
2. Скачайте папку мода на Steam Deck.
3. Откройте терминал Konsole в папке с модом (или нажмите правой кнопкой на `install.sh` → **Run in Konsole**) и выполните:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
4. Скрипт автоматически найдёт игру (на внутреннем SSD или microSD карте) и применит фикс.
5. Возвращайтесь в **Gaming Mode** и запускайте игру!

---

## 🖐️ Ручная установка / Manual Install

Если вы хотите установить всё вручную без скриптов:

1. Откройте папку с игрой:
   - **Windows:** `...\Steam\steamapps\common\Disney Epic Mickey 2\`
   - **Steam Deck:** `~/.local/share/Steam/steamapps/common/Disney Epic Mickey 2/` (или на microSD)
2. Сделайте копии оригинальных файлов `DEM2.exe` и `ConfigFiles.ini` (переименуйте их в `.bak`).
3. Скопируйте пропатченный `DEM2.exe` из папки `release/` в папку с игрой.
4. Откройте `ConfigFiles.ini` в блокноте / текстовом редакторе и измените параметры:
   ```ini
   WaitForVSync=false
   LockedFrameRate=60.0
   LockedFrameRatePAL=60.0
   ```
5. В самый конец файла `ConfigFiles.ini` добавьте блок (критично для физики броска):
   ```ini
   [DefaultAbilities_Toss]
   Height=7.5
   ```
6. Сохраните файл и запускайте игру через Steam.

---

## ↩️ Удаление / Откат к 30 FPS (Uninstall)

- **Windows:** запустите `restore.bat`.
- **Linux / Steam Deck:** запустите `./restore.sh`.
- Либо вручную верните файлы `DEM2.exe.bak` и `ConfigFiles.ini.bak`, переименовав их обратно.

---

## 🔬 Технические подробности (Почему обычный Hex-редактор не работал?)

1. **Steam DRM / SteamStub Variant 3.1 (x86)**:
   При обычной ручной замене байт в `DEM2.exe` игра выдавала ошибку:
   `Application load error 3:0000065432`
   Это происходило из-за встроенной защиты SteamStub, сверяющей контрольную сумму секции `.text`.
2. **Решение DRM**:
   С помощью инструмента **Steamless** защита SteamStub была корректно снята с сохранением интерфейса `steam_api.dll` (благодаря чему Steam-функции не теряются).
3. **Патч ограничителя кадров**:
   В секции памяти по смещению `0xE3F736` последовательность float:
   - Было: `F0 C1 00 00 F0 41 00 00` (`-30.0f`, `+30.0f`)
   - Стало: `F0 C1 00 00 70 42 00 00` (`-30.0f`, `+60.0f`)
4. **Физика Освальда**:
   Движок игры (Gamebryo) частично завязан на частоту кадров. При 60 FPS прыжок Микки при подбрасывании Освальдом становится ниже, из-за чего игрок не может запрыгнуть на уступ во втором эпизоде. Параметр `[DefaultAbilities_Toss] Height=7.5` в `ConfigFiles.ini` полностью решает эту проблему.

---

## 📄 Лицензия

Распространяется под лицензией MIT. Подробнее см. в файле [LICENSE](LICENSE).
