@echo off
echo Starting Jarvis application...

title Jarvis Launcher

:: Start Python API server in a new window
echo Starting Jarvis API server on http://localhost:5000...
start "Jarvis API Server" cmd /c "cd api && python app.py"

:: Give the API server some time to start
echo Waiting for API server to initialize...
timeout /t 5 /nobreak >nul

:: Start Flutter app
echo Starting Flutter application...
flutter run

echo Shutting down services...
:: Try to find and close the API server window gracefully
taskkill /FI "WINDOWTITLE eq Jarvis API Server*" /T /F >nul 2>&1

echo Done.
pause 