# Locality Connector

A Flutter application that helps users find local businesses, vendors, and essential services when moving to a new city. This app has been converted from a Java-based backend to Flutter using Dart.

## Features

- **User Authentication**: Secure login and signup system for both businesses and users
- **Location-Based Services**: Find nearby businesses and services based on your current location
- **AI-Powered Recommendations**: Discover businesses using Gemini AI integration
- **AI Chat Assistant**: Get help and information through a conversational interface
- **Category-Based Search**: Browse businesses by categories (grocery, pharmacy, restaurants, etc.)
- **Reviews & Ratings**: Read and write reviews for businesses
- **Business Management**: Register and manage your business listings

## Technology Stack

- **Frontend**: Flutter/Dart
- **Database**: Local SQLite database with Firebase integration
- **Authentication**: Custom authentication with Firebase Auth support
- **AI Integration**: Google Gemini API for smart recommendations and chat assistant
- **Location Services**: Geolocation and address lookup

## Implementation Details

- The app uses a local SQLite database via the sqflite package for persistent storage
- User preferences and reviews are stored locally and used for personalized recommendations
- The Gemini API is used to generate business suggestions, descriptions, and power the AI chat assistant
- Location services provide real-time business discovery
- The AI Assistant uses context-aware conversation with fallback handling when API connectivity is limited

## Getting Started

1. Clone the repository
2. Ensure Flutter is installed on your machine
3. Run `flutter pub get` to install dependencies
4. Configure your Gemini API key in `lib/services/gemini_service.dart`
5. Run `flutter run` to launch the application

## API Keys Required

- Gemini API key for AI-based recommendations and chat assistant (currently set to: `AIzaSyD8E8SVaoNa5xA0KfYjl8Zy2Dsot2aBKv8`)
- Firebase project configuration (follow Firebase setup documentation)

## Screenshots

[Include screenshots here]

## Future Enhancements

- Integration with real-time cloud databases
- Push notifications for promotions and new businesses
- Enhanced AI-based recommendations using historical data
- Social features for sharing and following businesses
- Voice input for the AI assistant

## License

This project is licensed under the MIT License - see the LICENSE file for details.
