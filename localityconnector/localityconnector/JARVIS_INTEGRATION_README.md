# Jarvis AI Assistant Integration with Flutter

This project integrates the Python-based Jarvis AI assistant with a Flutter application, using Google's Gemini AI for query enhancement.

## Overview

The integration follows a client-server architecture:

1. The Python-based Jarvis assistant runs as a Flask API server
2. The Flutter application connects to this API over HTTP
3. Google's Gemini AI is used to enhance user queries before they are sent to Jarvis

## Setup Instructions

### Step 1: Install Python Dependencies

First, install the Python dependencies for the Jarvis API:

```bash
cd JARVIS
pip install -r requirements_api.txt
```

### Step 2: Start the Jarvis API Server

Run the Jarvis API server:

**Windows:**
```bash
cd JARVIS
start_jarvis_api.bat
```

**macOS/Linux:**
```bash
cd JARVIS
python jarvis_api.py
```

The API server will run on http://localhost:5000 by default.

### Step 3: Run the Flutter Application

Make sure you have Flutter installed, then run:

```bash
flutter pub get
flutter run
```

## Architecture Details

### Python (Jarvis) Side

- `jarvis_api.py`: Flask API that wraps the original Jarvis Python code
- The API exposes endpoints for querying Jarvis, managing conversation history, etc.
- All original Jarvis functionality is preserved

### Flutter Side

- `lib/services/jarvis_service.dart`: Service that communicates with the Jarvis API
- `lib/screens/jarvis_screen.dart`: UI for interacting with Jarvis
- Gemini AI integration for enhancing queries

## API Endpoints

- `GET /api/health`: Check if the API is running
- `POST /api/query`: Send a query to Jarvis
- `GET /api/conversation`: Get the conversation history
- `POST /api/clear`: Clear the conversation history

## Gemini Integration

The integration uses Google's Gemini AI for:

1. Enhancing user queries before sending them to Jarvis
2. This can be toggled on/off in the UI

## Troubleshooting

- **API Connection Issues**: Make sure the Jarvis API server is running on port 5000
- **Gemini API Issues**: Check the Gemini API key in `lib/services/gemini_service.dart`
- **Missing Dependencies**: Run `pip install -r requirements_api.txt` and `flutter pub get`

## Development

To modify the integration:

- Python API: Edit `JARVIS/jarvis_api.py`
- Flutter UI: Edit `lib/screens/jarvis_screen.dart`
- Gemini Enhancement: Edit the `processQuery` method in `lib/services/jarvis_service.dart`

## Future Improvements

- Implement voice input using Gemini for speech-to-text
- Add voice output for Jarvis responses
- Improve error handling and reconnection logic
- Add authentication to the API 