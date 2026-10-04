# Disney Epic Mickey 2 - 60 FPS Native PowerShell Patcher

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Disney Epic Mickey 2 - 60 FPS Fix (Native PowerShell)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Locate game directory
$gameDir = $null
$candidates = @(
    $scriptDir,
    "C:\Program Files (x86)\Steam\steamapps\common\Disney Epic Mickey 2",
    "C:\Program Files\Steam\steamapps\common\Disney Epic Mickey 2",
    "D:\SteamLibrary\steamapps\common\Disney Epic Mickey 2",
    "E:\SteamLibrary\steamapps\common\Disney Epic Mickey 2"
)

# Registry search
try {
    $steamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue).SteamPath
    if ($steamPath) {
        $candidates = @("$steamPath\steamapps\common\Disney Epic Mickey 2") + $candidates
    }
} catch {}

foreach ($c in $candidates) {
    if (Test-Path "$c\DEM2.exe") {
        $gameDir = $c
        break
    }
}

if (-not $gameDir) {
    Write-Host "[-] Could not find Disney Epic Mickey 2 automatically." -ForegroundColor Red
    Write-Host "    Please copy this script directly into the game folder and run it." -ForegroundColor Yellow
    return
}

Write-Host "[+] Found game directory: $gameDir" -ForegroundColor Green

# 2. Backup and update DEM2.exe
$targetExe = "$gameDir\DEM2.exe"
$bakExe = "$gameDir\DEM2.exe.bak"
if (-not (Test-Path $bakExe)) {
    Copy-Item $targetExe $bakExe
    Write-Host "    [+] Created backup: DEM2.exe.bak" -ForegroundColor Green
}

$releaseExe = "$scriptDir\release\DEM2.exe"
if (Test-Path $releaseExe) {
    Copy-Item $releaseExe $targetExe -Force
    Write-Host "    [+] Installed pre-patched 60 FPS DEM2.exe" -ForegroundColor Green
} else {
    Write-Host "[-] Error: release\DEM2.exe not found." -ForegroundColor Red
    return
}

# 3. Backup and update ConfigFiles.ini
$targetConfig = "$gameDir\ConfigFiles.ini"
$bakConfig = "$gameDir\ConfigFiles.ini.bak"
if (-not (Test-Path $bakConfig)) {
    Copy-Item $targetConfig $bakConfig
    Write-Host "    [+] Created backup: ConfigFiles.ini.bak" -ForegroundColor Green
}

$content = [System.IO.File]::ReadAllText($targetConfig, [System.Text.Encoding]::GetEncoding("iso-8859-1"))
$content = [System.Text.RegularExpressions.Regex]::Replace($content, "LockedFrameRate\s*=\s*[0-9.]+", "LockedFrameRate=60.0")
$content = [System.Text.RegularExpressions.Regex]::Replace($content, "LockedFrameRatePAL\s*=\s*[0-9.]+", "LockedFrameRatePAL=60.0")
$content = [System.Text.RegularExpressions.Regex]::Replace($content, "WaitForVSync\s*=\s*true", "WaitForVSync=false", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

if ($content -notmatch "\[DefaultAbilities_Toss\][\s\S]*?Height=7\.5") {
    $content += "`r`n`r`n[DefaultAbilities_Toss]`r`nHeight=7.5`r`n"
    Write-Host "    [+] Added Oswald toss height fix (Height=7.5)" -ForegroundColor Green
}

[System.IO.File]::WriteAllText($targetConfig, $content, [System.Text.Encoding]::GetEncoding("iso-8859-1"))
Write-Host "    [+] ConfigFiles.ini updated (60 FPS + Oswald Fix)" -ForegroundColor Green

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  [SUCCESS] 60 FPS MOD INSTALLED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
