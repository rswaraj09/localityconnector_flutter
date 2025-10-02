# Jarvis Assistant Setup Guide

This guide will help you set up and run the Jarvis Assistant app along with its Python API backend.

## Prerequisites

- Python 3.7 or later
- Flutter SDK installed and configured
- Android Studio or VS Code with Flutter extensions (for development)

## Setup Instructions

### 1. API Configuration

The Jarvis Assistant requires a Python API to be running. 

#### For Emulator/Desktop Testing:
The default configuration uses `localhost:5000` which works fine for emulator and desktop testing.

#### For Physical Mobile Device Testing:
You need to update the configuration with your computer's IP address:

1. Run the `find_ip_address.bat` script to find your computer's IP address
2. Open `lib/config/app_config.dart`
3. Update the `jarvisApiDeviceIp` value with your computer's IP address
4. Change the `jarvisApiBaseUrl` to use `jarvisApiDeviceIp`

```dart
// Example:
static const String jarvisApiDeviceIp = 'http://192.168.1.100:5000/api';
static const String jarvisApiBaseUrl = jarvisApiDeviceIp; // Change this line
```

### 2. Running the Application

You have two ways to run the application:

#### Option 1: Automatic Launcher (Recommended)

1. Make sure your Python API code is in the `api` folder in the project root
2. Run the `start_jarvis_app.bat` script (Windows) or `start_jarvis_app.ps1` (PowerShell)
   - This will automatically start both the Python API and Flutter app

#### Option 2: Manual Startup

1. Start the Python API server:
   ```
   cd api
   python app.py
   ```

2. Start the Flutter app in a separate terminal:
   ```
   flutter run
   ```

### 3. Troubleshooting

If you see connection errors like this:
```
Error: Failed to communicate with Jarvis: ClientException with SocketException: 
Connection refused (OS Error: Connection refused, errno = 111), 
address = localhost, port = XXXXX, uri=http://localhost:5000/api/query
```

Check the following:
1. Is the Python API server running?
2. If using a physical device, did you update the IP address in the configuration?
3. Is there a firewall blocking the connection to port 5000?
4. Try running `curl http://localhost:5000/api/health` to check if the API is accessible

## Development

### Adding Speech Recognition

The current implementation uses a simulated speech input. To implement actual speech recognition:

1. Add a speech recognition package to your project
   ```
   flutter pub add speech_to_text
   ```

2. Replace the simulation code in `lib/screens/jarvis_screen.dart` with actual speech recognition implementation

### Project Structure

- `lib/screens/jarvis_screen.dart` - The main Jarvis UI
- `lib/services/jarvis_service.dart` - Service to communicate with the Python API
- `lib/config/app_config.dart` - Configuration for API endpoints

## License

This project is proprietary software. 