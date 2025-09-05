@echo off
title Start Server
color 0D

echo ================================================
echo    Starting UID Bypass Server
echo    IP: 192.168.1.163:8080
echo ================================================
echo.

REM Check if virtual environment exists
if not exist "venv\Scripts\activate.bat" (
    echo Error: Virtual environment not found!
    echo Please run install.BAT first.
    pause
    exit /b 1
)

echo Starting server...
call venv\Scripts\activate.bat
venv\Scripts\mitmdump -s bypass.py --listen-host 192.168.1.163 --listen-port 8080 --set confdir=. --set ssl_insecure=true

call venv\Scripts\deactivate.bat
