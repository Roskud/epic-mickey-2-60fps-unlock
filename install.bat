@echo off
chcp 65001 >nul
title Disney Epic Mickey 2 - 60 FPS Fix Installer
cls
echo ============================================================
echo   Disney Epic Mickey 2: The Power of Two - 60 FPS Fix
echo   Windows 1-Click Automated Installer
echo ============================================================
echo.

where python >nul 2>nul
if %errorlevel% equ 0 (
    python "%~dp0patcher.py"
    goto finish
)

echo [*] Python not detected. Running native PowerShell installer...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { & '%~dp0patcher.ps1' }"

:finish
echo.
echo Press any key to exit...
pause >nul
