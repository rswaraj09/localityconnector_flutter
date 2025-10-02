import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localityconnector/services/gemini_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:localityconnector/config/app_config.dart';

class JarvisService {
  static final JarvisService _instance = JarvisService._internal();
  factory JarvisService() => _instance;
  JarvisService._internal();

  // API endpoint configurations (from AppConfig)
  final String _baseUrl = AppConfig.jarvisApiBaseUrl;
  final String _queryEndpoint = AppConfig.jarvisApiQueryEndpoint;
  final String _conversationEndpoint = AppConfig.jarvisApiConversationEndpoint;
  final String _clearEndpoint = AppConfig.jarvisApiClearEndpoint;
  final String _healthEndpoint = AppConfig.jarvisApiHealthEndpoint;

  // Gemini service for enhancing queries
  final GeminiService _geminiService = GeminiService();
  late final GenerativeModel _model;
  bool _isInitialized = false;

  // Initialize the service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Make sure GeminiService is initialized
      await _geminiService.initialize();

      // Initialize our dedicated model for query enhancement
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _geminiService.apiKey,
      );

      // Check if Jarvis API is running
      final isRunning = await checkJarvisRunning();
      _isInitialized = true;

      return isRunning;
    } catch (e) {
      print('⚠️ Error initializing JarvisService: $e');
      return false;
    }
  }

  // Check if Jarvis API is running
  Future<bool> checkJarvisRunning() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl$_healthEndpoint'),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ Jarvis API is not running: $e');
      return false;
    }
  }

  // Process a user query through Gemini first, then send to Jarvis
  Future<Map<String, dynamic>> processQuery(String query,
      {bool enhanceWithGemini = true}) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return {
          'status': 'error',
          'response':
              'Jarvis is not running. Please start the Python API first.',
        };
      }
    }

    try {
      String processedQuery = query;
      String originalQuery = query;

      // Optionally enhance the query with Gemini
      if (enhanceWithGemini) {
        try {
          final content = [
            Content.text(
                'You are an AI assistant helping process user queries before sending them to a '
                'voice assistant named Jarvis. Your task is to refine this query to be more clear '
                'and actionable, but maintain the original intent. If it\'s already clear, return it unchanged. '
                'Do not add explanations or summaries, just return the refined query. Input: "$query"')
          ];

          final response = await _model.generateContent(content);
          final enhancedQuery = response.text;

          if (enhancedQuery != null &&
              enhancedQuery.isNotEmpty &&
              enhancedQuery.length < 500) {
            // Clean up any quotes or formatting that Gemini might add
            processedQuery = enhancedQuery.replaceAll('"', '').trim();

            // Log the enhancement for debugging
            print('Original query: $originalQuery');
            print('Enhanced query: $processedQuery');
          } else {
            // Use original if enhancement failed or was too long
            processedQuery = originalQuery;
          }
        } catch (e) {
          print('Query enhancement failed: $e');
          processedQuery = originalQuery;
        }
      }

      // Send the query to Jarvis API
      final response = await http
          .post(
            Uri.parse('$_baseUrl$_queryEndpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'query': processedQuery}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'success',
          'response': data['response'],
          'enhanced': enhanceWithGemini && processedQuery != originalQuery,
          'original_query': originalQuery,
          'processed_query': processedQuery,
        };
      } else {
        return {
          'status': 'error',
          'response': 'Error communicating with Jarvis: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'response': 'Failed to communicate with Jarvis: $e',
      };
    }
  }

  // Get the full conversation history
  Future<List<Map<String, String>>> getConversationHistory() async {
    if (!_isInitialized) await initialize();

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl$_conversationEndpoint'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, String>>.from(
            data['conversation'].map((item) => {
                  'role': item['role'],
                  'content': item['content'],
                }));
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching conversation history: $e');
      return [];
    }
  }

  // Clear the conversation history
  Future<bool> clearConversation() async {
    if (!_isInitialized) await initialize();

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$_clearEndpoint'),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Error clearing conversation: $e');
      return false;
    }
  }
}
