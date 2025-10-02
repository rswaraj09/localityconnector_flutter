@echo off
echo Determining your local IP address for Jarvis API configuration...
echo.

ipconfig | findstr /i "IPv4"

echo.
echo -----------------------------------------------
echo To use this IP address with your mobile device:
echo 1. Open lib/config/app_config.dart
echo 2. Replace "YOUR_IP_ADDRESS" with your IP address
echo 3. Change jarvisApiBaseUrl to jarvisApiDeviceIp
echo -----------------------------------------------
echo.
pause 