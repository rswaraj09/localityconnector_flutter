@echo off
echo Starting Jarvis application...

:: Set terminal title
title Jarvis Launcher

:: Check if Python is installed
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Python is not installed or not in PATH. Please install Python first.
    pause
    exit /b 1
)

:: Check if Flutter is installed
flutter --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Flutter is not installed or not in PATH. Please install Flutter first.
    pause
    exit /b 1
)

:: Setup environment - modify paths as needed
set JARVIS_API_PATH=api
set FLUTTER_APP_PATH=.

:: Start Python API server in a new window
echo Starting Jarvis API server on http://localhost:5000...
start "Jarvis API Server" cmd /c "cd %JARVIS_API_PATH% && python app.py"

:: Give the API server some time to start
echo Waiting for API server to initialize...
timeout /t 5 /nobreak >nul

:: Start Flutter app
echo Starting Flutter application...
cd %FLUTTER_APP_PATH%
flutter run -d windows

echo Shutting down services...
:: Try to find and close the API server window gracefully
taskkill /FI "WINDOWTITLE eq Jarvis API Server*" /T /F >nul 2>&1

echo Done.
pause 