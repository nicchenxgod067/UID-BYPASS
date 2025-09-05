@echo off
title Install Certificate in BlueStacks
color 0E

echo ================================================
echo    Installing Certificate in BlueStacks
echo    Using PowerShell Script
echo ================================================
echo.

echo Running PowerShell certificate installer...
powershell -ExecutionPolicy Bypass -File "%~dp0install_cert.ps1"

echo.
echo Certificate installation completed!
pause
