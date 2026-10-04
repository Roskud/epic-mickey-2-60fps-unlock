@echo off
chcp 65001 >nul
title Disney Epic Mickey 2 - Restore Original (30 FPS)
cls
echo ============================================================
echo   Disney Epic Mickey 2: Restore Original Files
echo ============================================================
echo.

where python >nul 2>nul
if %errorlevel% equ 0 (
    python "%~dp0patcher.py" --restore
    goto finish
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "& {
    $scriptDir = '%~dp0';
    $candidates = @('C:\Program Files (x86)\Steam\steamapps\common\Disney Epic Mickey 2', 'C:\Program Files\Steam\steamapps\common\Disney Epic Mickey 2');
    foreach ($c in $candidates) {
        if (Test-Path \"$c\DEM2.exe.bak\") {
            Copy-Item \"$c\DEM2.exe.bak\" \"$c\DEM2.exe\" -Force;
            Write-Host 'Restored DEM2.exe' -ForegroundColor Green;
        }
        if (Test-Path \"$c\ConfigFiles.ini.bak\") {
            Copy-Item \"$c\ConfigFiles.ini.bak\" \"$c\ConfigFiles.ini\" -Force;
            Write-Host 'Restored ConfigFiles.ini' -ForegroundColor Green;
        }
    }
}"

:finish
echo.
echo Press any key to exit...
pause >nul
