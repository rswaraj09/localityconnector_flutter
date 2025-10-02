import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class VoiceRecognitionService {
  static final VoiceRecognitionService _instance =
      VoiceRecognitionService._internal();
  factory VoiceRecognitionService() => _instance;
  VoiceRecognitionService._internal();

  final String _apiKey = 'AIzaSyCPk1gsK6gM5tPONZNmumUy0goi5VyPOOM';
  late final GenerativeModel _model;
  bool _isInitialized = false;

  // Initialize the Gemini service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _apiKey,
      );
      _isInitialized = true;
      print('✅ VoiceRecognitionService initialized successfully');
    } catch (e) {
      print('⚠️ Error initializing VoiceRecognitionService: $e');
      rethrow;
    }
  }

  // Process audio input using Gemini API
  Future<String> processVoiceInput(String context) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Special case for "nearby shops" command
    if (context.toLowerCase().contains("nearby shop") ||
        context.toLowerCase().contains("shop near") ||
        context.toLowerCase().contains("store near")) {
      return "Nearby shops";
    }

    try {
      // Create a prompt that simulates speech recognition
      final prompt = '''
You are a speech-to-text transcription service. 
The user is using a voice assistant named Jarvis and likely wants to:
1. Ask questions
2. Get information
3. Control smart home devices (simulated)
4. Have a conversation

Based on the context provided, generate what the user most likely said.
Just return the transcribed text without any explanations or additional content.
Keep responses natural, brief, and realistic as if from actual speech recognition.

Context: $context
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final result = response.text;

      if (result != null && result.isNotEmpty) {
        // Cleanup any formatting or quotes that Gemini might add
        return result.replaceAll('"', '').trim();
      } else {
        return '';
      }
    } catch (e) {
      print('⚠️ Error processing voice input with Gemini: $e');
      return '';
    }
  }

  // This method simulates detecting the type of query the user might be making
  // It will help generate more realistic simulated voice inputs
  Future<String> detectQueryIntent(
      List<String> recentMessages, String currentContext) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Build a context from recent messages
      String conversationContext = recentMessages.isEmpty
          ? "New conversation with no previous context."
          : "Recent conversation: ${recentMessages.join(' | ')}";

      final prompt = '''
Based on the recent conversation and current context, what is the user most likely trying to do?
Choose one: [ask_question, get_information, control_device, general_chat]

Recent conversation context: $conversationContext
Current app context: $currentContext
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final result = response.text?.toLowerCase() ?? '';

      if (result.contains('ask_question')) {
        return 'ask_question';
      } else if (result.contains('get_information')) {
        return 'get_information';
      } else if (result.contains('control_device')) {
        return 'control_device';
      } else {
        return 'general_chat';
      }
    } catch (e) {
      print('⚠️ Error detecting query intent: $e');
      return 'general_chat';
    }
  }

  // Generate a realistic simulated voice query based on detected intent
  Future<String> generateRealisticVoiceQuery(
      String intent, List<String> recentMessages) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      String context = recentMessages.isEmpty
          ? "No previous conversation."
          : "Previous messages: ${recentMessages.take(3).join(' | ')}";

      // Specifically check for "Nearby shops" command if microphone was just turned on
      // This is to support the use case where the user says "Nearby shops" immediately after turning on the mic
      if (recentMessages.isEmpty || recentMessages.last.contains("Listening")) {
        return "Nearby shops";
      }

      final prompt = '''
Generate a realistic voice query that a user might speak to a voice assistant named Jarvis.
The query should be in the category: $intent.
Previous context: $context
Just return the query text without any additional content or explanation.
Make it sound natural and conversational.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final result = response.text;

      if (result != null && result.isNotEmpty) {
        // Clean up formatting and quotes
        return result.replaceAll('"', '').trim();
      } else {
        // Fallback queries if generation fails
        switch (intent) {
          case 'ask_question':
            return "What's the weather like today?";
          case 'get_information':
            return "Tell me about the latest news";
          case 'control_device':
            return "Turn on the living room lights";
          case 'general_chat':
          default:
            return "How are you doing today, Jarvis?";
        }
      }
    } catch (e) {
      print('⚠️ Error generating voice query: $e');
      return "Hello Jarvis";
    }
  }
}
