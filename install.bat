@echo off
echo ==========================================================
echo  Running agy-auto-accept Windows Installer...
echo ==========================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
echo.
pause
