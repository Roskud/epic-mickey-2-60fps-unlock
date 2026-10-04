# Disney Epic Mickey 2: The Power of Two — Фикс 60 FPS и Физики 🎮

<div align="center">

[![Language: English](https://img.shields.io/badge/Language-English-blue.svg)](README.md)
[![Language: Russian](https://img.shields.io/badge/Язык-Русский-red.svg)](README_RU.md)
[![Platform](https://img.shields.io/badge/Платформа-Windows%20%7C%20Linux%20%7C%20SteamDeck-brightgreen.svg)](#)
[![Game Version](https://img.shields.io/badge/Steam%20AppID-245300-orange.svg)](https://store.steampowered.com/app/245300/Disney_Epic_Mickey_2_The_Power_of_Two/)
[![License: MIT](https://img.shields.io/badge/Лицензия-MIT-yellow.svg)](LICENSE)

**[English](README.md) | [Русский](README_RU.md)**

*Полноценный, стабильный и автоматический разблокировщик 60 FPS с исправлением физики для Disney Epic Mickey 2 на Windows и Steam Deck (SteamOS / Linux).*

</div>

---

## ✨ Особенности

- ⚡ **Настоящие плавные 60 FPS**: снятие встроенного лимита в 30 кадров движка.
- 🎯 **Исправление физики подбрасывания Освальда (Oswald Toss Fix)**: при 60 FPS физика игры меняет высоту прыжка. Данный фикс калибрует высоту подбрасывания Микки до значения `7.5`, что устраняет непроходимый софтлок во 2-м эпизоде, где Микки не мог допрыгнуть до верхнего уступа.
- 🛡️ **Полное сохранение функционала Steam**:
  - Работающий **Steam Overlay** (`Shift+Tab`).
  - Статус **«В игре»** виден друзьям.
  - **Достижения (Achievements)** и **счётчик часов** работают штатно.
- 🚀 **Автоматические установщики в 1 клик**:
  - **Windows**: `install.bat` (поддерживает встроенный PowerShell, Python не требуется).
  - **Linux / Steam Deck**: `install.sh` (автоматически сканирует внутренний SSD и карты памяти microSD).
- 🔄 **Автобэкап и откат в 1 клик**: перед изменениями создаются копии `.bak`. Вернуться к 30 FPS можно в любой момент через `restore.bat` или `restore.sh`.

---

## 📥 Скачать (Раздельные архивы без лишнего кода)

Выберите нужный архив для вашей системы:

| Версия / Назначение | Что внутри | Ссылка на скачивание |
| :--- | :--- | :--- |
| 🪟 **Для Windows** | Авто-установщик (`install.bat` + `patcher.ps1` + файлы мода) | [**Скачать ZIP для Windows (7.7 MB)**](https://github.com/Roskud/epic-mickey-2-60fps-unlock/raw/main/downloads/EpicMickey2_60FPS_Windows.zip) |
| 🎮 **Для Steam Deck / Linux** | Скрипт в 1 клик для SteamOS (`install.sh` + файлы мода) | [**Скачать ZIP для Steam Deck (7.7 MB)**](https://github.com/Roskud/epic-mickey-2-60fps-unlock/raw/main/downloads/EpicMickey2_60FPS_SteamDeck.zip) |
| 🖐️ **Только готовые файлы** | Только готовые `DEM2.exe` и `ConfigFiles.ini` (для ручной замены) | [**Скачать ZIP готовых файлов (7.7 MB)**](https://github.com/Roskud/epic-mickey-2-60fps-unlock/raw/main/downloads/EpicMickey2_60FPS_Manual_Files.zip) |

---

## 🚀 Инструкция по установке

### 🪟 Windows (В 1 клик)

1. Скачайте **[EpicMickey2_60FPS_Windows.zip](https://github.com/Roskud/epic-mickey-2-60fps-unlock/raw/main/downloads/EpicMickey2_60FPS_Windows.zip)**.
2. Распакуйте архив в любое место.
3. Запустите двойным кликом **`install.bat`**.
   - *Скрипт сам найдёт путь к установленной в Steam игре, сделает резервные копии, установит пропатченный бинарник 60 FPS и обновит настройки.*
4. Запустите игру как обычно через **Steam**!

---

### 🎮 Steam Deck (SteamOS / Linux) (В 1 клик)

1. Переведите Steam Deck в **Desktop Mode** (*Питание → Переключиться на рабочий стол*).
2. Скачайте **[EpicMickey2_60FPS_SteamDeck.zip](https://github.com/Roskud/epic-mickey-2-60fps-unlock/raw/main/downloads/EpicMickey2_60FPS_SteamDeck.zip)**.
3. Распакуйте архив, нажмите правой кнопкой мыши на **`install.sh`** → **Run in Konsole** (или откройте терминал и выполните `./install.sh`).
   - *Скрипт автоматически найдёт игру на встроенной памяти или на карте microSD, применит фикс и выставит права.*
4. Переключитесь обратно в **Gaming Mode** и играйте!

---

## 🖐️ Ручная установка

Если вы предпочитаете скопировать файлы вручную:

1. Откройте корневую папку с игрой:
   - **Windows**: `C:\Program Files (x86)\Steam\steamapps\common\Disney Epic Mickey 2`
   - **Steam Deck**: `~/.local/share/Steam/steamapps/common/Disney Epic Mickey 2` (или на microSD)
2. Создайте резервные копии оригинальных файлов `DEM2.exe` и `ConfigFiles.ini` (например, добавьте расширение `.bak`).
3. Скопируйте файл `release/DEM2.exe` из этого репозитория в папку игры с заменой.
4. Откройте файл `ConfigFiles.ini` в любом текстовом редакторе:
   - Найдите и измените строки:
     ```ini
     WaitForVSync=false
     LockedFrameRate=60.0
     LockedFrameRatePAL=60.0
     ```
   - Прокрутите в самый конец файла и добавьте блок исправления физики:
     ```ini
     [DefaultAbilities_Toss]
     Height=7.5
     ```
5. Сохраните файл и запустите игру через Steam.

---

## ↩️ Удаление / Возврат к 30 FPS

- **Windows**: Запустите **`restore.bat`**.
- **Linux / Steam Deck**: Запустите **`./restore.sh`**.
- Либо восстановите вручную файлы `DEM2.exe.bak` и `ConfigFiles.ini.bak`, убрав расширение `.bak`.

---

## 🔬 Технические подробности (Почему старый метод с Hex-редактором не работал?)

У многих игроков при ручном редактировании `DEM2.exe` игра завершалась ошибкой:
```
Application load error 3:0000065432
```

### В чём была причина?
1. **SteamStub DRM (Variant 3.1 x86)**:
   Официальный файл `DEM2.exe` из Steam упакован защитой SteamStub. При прямой модификации байтов на диске Steam обнаруживает нарушение целостности секции `.text` и блокирует запуск.
2. **Чистое решение**:
   С помощью инструмента **Steamless** обёртка SteamStub была корректно снята с сохранением всех вызовов `steam_api.dll` (благодаря чему оверлей, друзья и ачивки остаются активными).
3. **Патч float 60 FPS**:
   По смещению `0xE3F736` модифицирован ограничитель частоты кадров движка:
   - **Оригинал**: `F0 C1 00 00 F0 41 00 00` (`-30.0f`, `+30.0f`)
   - **Патч**: `F0 C1 00 00 70 42 00 00` (`-30.0f`, `+60.0f`)
4. **Коррекция физики Освальда**:
   Физический цикл движка Gamebryo привязан к дельте кадров. При 60 FPS импульс подбрасывания Микки Освальдом срезается, из-за чего игрок не долетает до ключевых платформ во 2-м эпизоде. Добавление `[DefaultAbilities_Toss] Height=7.5` в `ConfigFiles.ini` полностью возвращает правильную высоту полета.

---

## 📁 Структура репозитория

```
epic-mickey-2-60fps-unlock/
├── README.md               # Документация на английском
├── README_RU.md            # Документация на русском
├── install.bat             # Установщик в 1 клик для Windows (Batch)
├── patcher.ps1             # Нативный установщик PowerShell (без необходимости Python)
├── restore.bat             # Скрипт отката для Windows
├── install.sh              # Установщик в 1 клик для Linux / Steam Deck (Bash)
├── restore.sh              # Скрипт отката для Linux / Steam Deck
├── patcher.py              # Универсальный кроссплатформенный Python-патчер
├── release/                # Готовые к использованию файлы
│   ├── DEM2.exe            # Пропатченный бинарник 60 FPS
│   └── ConfigFiles.ini     # Конфигурация с исправлением Освальда
├── tools/                  # Утилиты для снятия DRM
└── LICENSE                 # Лицензия MIT
```

---

## 📜 Лицензия

Проект распространяется под лицензией [MIT](LICENSE).
