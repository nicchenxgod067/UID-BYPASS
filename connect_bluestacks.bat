@echo off
title Connect BlueStacks
color 0B

echo ================================================
echo    Connecting to BlueStacks
echo    IP: 192.168.1.163:8080
echo ================================================
echo.

REM Check if ADB exists
where adb >nul 2>&1
if errorlevel 1 (
    echo Error: ADB not found in PATH!
    pause
    exit /b 1
)

echo Connecting to BlueStacks...
adb.exe connect 127.0.0.1:5555

echo.
echo Setting proxy to 192.168.1.163:8080...
adb.exe -s 127.0.0.1:5555 shell settings put global http_proxy 192.168.1.163:8080

echo.
echo Checking proxy setting...
adb.exe -s 127.0.0.1:5555 shell settings get global http_proxy

echo.
echo BlueStacks connected and proxy set!
echo Now run start_server.bat in another window.
pause
