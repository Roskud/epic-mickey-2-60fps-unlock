# Disney Epic Mickey 2 - 60 FPS Universal PowerShell Installer
$ErrorActionPreference = "Continue"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Disney Epic Mickey 2: 60 FPS Fix (Universal Installer)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$gameDir = $null
$candidates = [System.Collections.Generic.List[string]]::new()

# 1. Current script directory or parent
$candidates.Add($scriptDir)
$candidates.Add((Split-Path -Parent $scriptDir))

# 2. Check Steam Registry and libraryfolders.vdf
try {
    $steamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue).SteamPath
    if ($steamPath) {
        $candidates.Add("$steamPath\steamapps\common\Disney Epic Mickey 2")
        $vdf = "$steamPath\steamapps\libraryfolders.vdf"
        if (Test-Path $vdf) {
            $vdfContent = Get-Content $vdf -Raw
            $vdfMatches = [regex]::Matches($vdfContent, '"path"\s+"([^"]+)"')
            foreach ($m in $vdfMatches) {
                $libPath = $m.Groups[1].Value.Replace("\\", "\")
                $candidates.Add("$libPath\steamapps\common\Disney Epic Mickey 2")
            }
        }
    }
} catch {}

# 3. Check all active drive letters for standard library locations
try {
    $drives = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Root
    foreach ($d in $drives) {
        $candidates.Add("$d\SteamLibrary\steamapps\common\Disney Epic Mickey 2")
        $candidates.Add("$d\Steam\steamapps\common\Disney Epic Mickey 2")
        $candidates.Add("$d\Games\SteamLibrary\steamapps\common\Disney Epic Mickey 2")
        $candidates.Add("$d\Games\Steam\steamapps\common\Disney Epic Mickey 2")
        $candidates.Add("${d}Program Files (x86)\Steam\steamapps\common\Disney Epic Mickey 2")
        $candidates.Add("${d}Program Files\Steam\steamapps\common\Disney Epic Mickey 2")
    }
} catch {}

# Check candidates
foreach ($c in $candidates) {
    if ($c -and (Test-Path "$c\DEM2.exe")) {
        $gameDir = (Resolve-Path $c).Path
        break
    }
}

# 4. If still not found, ask user (Console + Folder Browser Dialog)
if (-not $gameDir) {
    Write-Host "[!] Game folder was not detected automatically in common Steam paths." -ForegroundColor Yellow
    Write-Host "    Opening folder selection window..." -ForegroundColor Cyan
    
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Item-Object -TypeName System.Windows.Forms.FolderBrowserDialog -ErrorAction SilentlyContinue
    if (-not $dialog) {
        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    }
    $dialog.Description = "Выберите папку с игрой Disney Epic Mickey 2 (где находится DEM2.exe):"
    $dialog.ShowNewFolderButton = $false
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK -and (Test-Path "$($dialog.SelectedPath)\DEM2.exe")) {
        $gameDir = $dialog.SelectedPath
    } else {
        $inputPath = Read-Host "Либо введите полный путь к папке игры вручную"
        if ($inputPath -and (Test-Path "$inputPath\DEM2.exe")) {
            $gameDir = $inputPath
        }
    }
}

if (-not $gameDir -or -not (Test-Path "$gameDir\DEM2.exe")) {
    Write-Host "[-] Ошибка: Файл DEM2.exe не найден. Установка прервана." -ForegroundColor Red
    return
}

Write-Host "[+] Найдена папка с игрой: $gameDir" -ForegroundColor Green

# 5. Backup & update DEM2.exe
$targetExe = "$gameDir\DEM2.exe"
$bakExe = "$gameDir\DEM2.exe.bak"
if (-not (Test-Path $bakExe)) {
    Copy-Item $targetExe $bakExe
    Write-Host "    [+] Создан бэкап: DEM2.exe.bak" -ForegroundColor Green
}

$releaseExe = "$scriptDir\release\DEM2.exe"
if (-not (Test-Path $releaseExe)) {
    $releaseExe = "$scriptDir\DEM2.exe"
}

if (Test-Path $releaseExe) {
    Copy-Item $releaseExe $targetExe -Force
    Write-Host "    [+] Установлен пропатченный бинарник 60 FPS DEM2.exe" -ForegroundColor Green
} else {
    Write-Host "[-] Ошибка: Файл release\DEM2.exe не найден." -ForegroundColor Red
    return
}

# 6. Backup & update ConfigFiles.ini
$targetConfig = "$gameDir\ConfigFiles.ini"
$bakConfig = "$gameDir\ConfigFiles.ini.bak"
if (-not (Test-Path $bakConfig)) {
    Copy-Item $targetConfig $bakConfig
    Write-Host "    [+] Создан бэкап: ConfigFiles.ini.bak" -ForegroundColor Green
}

$content = [System.IO.File]::ReadAllText($targetConfig, [System.Text.Encoding]::GetEncoding("iso-8859-1"))
$content = [System.Text.RegularExpressions.Regex]::Replace($content, "LockedFrameRate\s*=\s*[0-9.]+", "LockedFrameRate=60.0")
$content = [System.Text.RegularExpressions.Regex]::Replace($content, "LockedFrameRatePAL\s*=\s*[0-9.]+", "LockedFrameRatePAL=60.0")
$content = [System.Text.RegularExpressions.Regex]::Replace($content, "WaitForVSync\s*=\s*true", "WaitForVSync=false", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

if ($content -notmatch "\[DefaultAbilities_Toss\][\s\S]*?Height=7\.5") {
    $content += "`r`n`r`n[DefaultAbilities_Toss]`r`nHeight=7.5`r`n"
    Write-Host "    [+] Добавлен фикс высоты броска Освальда (Height=7.5)" -ForegroundColor Green
}

[System.IO.File]::WriteAllText($targetConfig, $content, [System.Text.Encoding]::GetEncoding("iso-8859-1"))
Write-Host "    [+] Настройки ConfigFiles.ini обновлены (60 FPS + Oswald Fix)" -ForegroundColor Green

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  [УСПЕХ] МОД 60 FPS УСПЕШНО УСТАНОВЛЕН!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Запускайте игру через Steam как обычно." -ForegroundColor White
