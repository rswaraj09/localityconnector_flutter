class AppConfig {
  // Jarvis API Configuration

  // Local development - use this when testing on emulator
  static const String jarvisApiLocalhost = 'http://localhost:5000/api';

  // For physical device testing - replace with your computer's IP address
  // Example: 'http://192.168.1.100:5000/api'
  static const String jarvisApiDeviceIp = 'http://192.168.0.104:5000/api';

  // Production API (if you deploy the API to a server)
  static const String jarvisApiProduction =
      'https://your-production-server.com/api';

  // ACTIVE CONFIGURATION - Change this line to switch between configurations
  static const String jarvisApiBaseUrl = jarvisApiDeviceIp;

  // API Endpoints
  static const String jarvisApiQueryEndpoint = '/query';
  static const String jarvisApiConversationEndpoint = '/conversation';
  static const String jarvisApiClearEndpoint = '/clear';
  static const String jarvisApiHealthEndpoint = '/health';
}
