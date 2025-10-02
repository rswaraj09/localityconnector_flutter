import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:localityconnector/models/business.dart';
import 'gemini_service.dart';

class ChatbotService {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal();

  final GeminiService _geminiService = GeminiService();
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  bool _isInitialized = false;
  List<Map<String, String>> _sessionHistory = [];

  // Initialize the chatbot
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Make sure GeminiService is initialized
      await _geminiService.initialize();

      // Initialize our dedicated chat model
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _geminiService.apiKey,
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(
              HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(
              HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );

      // Create initial chat history
      _sessionHistory = [];

      // Start a new chat session with initial system prompt
      _chatSession = _model.startChat(
        history: [
          Content.text(
              'You are a helpful assistant for a location-based business app called "Locality Connector". '
              'You can provide information about local businesses, services, and locations. '
              'Answer questions briefly and helpfully. When asked about specific businesses, '
              'focus on providing relevant information about services, locations, hours, etc. '
              'Maintain a friendly and professional tone. '
              'If you cannot answer a specific question about a business, suggest that the user check '
              'the business details page in the app for the most current information.'),
        ],
      );

      _isInitialized = true;
      print('✅ Chatbot initialized successfully');
    } catch (e) {
      print('⚠️ Warning: Failed to initialize Chatbot: $e');
      // Mark as initialized to prevent repeated attempts
      _isInitialized = true;
    }
  }

  // Reset chat session
  Future<void> resetChat() async {
    if (!_isInitialized) await initialize();

    try {
      _sessionHistory = [];

      // Create a new chat session
      _chatSession = _model.startChat(
        history: [
          Content.text(
              'You are a helpful assistant for a location-based business app called "Locality Connector". '
              'You can provide information about local businesses, services, and locations. '
              'Answer questions briefly and helpfully. When asked about specific businesses, '
              'focus on providing relevant information about services, locations, hours, etc. '
              'Maintain a friendly and professional tone. '
              'If you cannot answer a specific question about a business, suggest that the user check '
              'the business details page in the app for the most current information.'),
        ],
      );
    } catch (e) {
      print('⚠️ Error resetting chat: $e');
    }
  }

  // Send message to chatbot and get response
  Future<String> sendMessage(String userMessage,
      {List<Business>? availableBusinesses, String? currentLocation}) async {
    if (!_isInitialized) await initialize();

    try {
      // Add context about available businesses if provided
      String businessContext = '';
      if (availableBusinesses != null && availableBusinesses.isNotEmpty) {
        businessContext = '\n\nSome businesses near the user: ';
        for (var business in availableBusinesses.take(3)) {
          businessContext +=
              '\n- ${business.businessName} (${business.businessType}): ${business.businessAddress}';
        }
      }

      // Add location context if provided
      String locationContext = currentLocation != null
          ? '\n\nUser\'s current location: $currentLocation'
          : '';

      // Combine message with context
      String contextualizedMessage = userMessage;
      if (businessContext.isNotEmpty || locationContext.isNotEmpty) {
        contextualizedMessage +=
            '\n[CONTEXT: This is background information only, don\'t mention it directly in your response.$businessContext$locationContext]';
      }

      // Save message to history
      _sessionHistory.add({
        'role': 'user',
        'message': userMessage,
      });

      try {
        // FIRST: Try using the Gemini API
        try {
          final response = await _chatSession.sendMessage(
            Content.text(contextualizedMessage),
          );

          final responseText = response.text;

          if (responseText != null && responseText.isNotEmpty) {
            // API worked correctly
            _sessionHistory.add({
              'role': 'assistant',
              'message': responseText,
            });
            return responseText;
          } else {
            // Text was null or empty, use smart fallback
            throw Exception("Empty response from API");
          }
        } catch (apiError) {
          print('Warning: API call failed, using smart fallback: $apiError');
          // Use our smart fallback system instead
          final fallbackResponse = _getSmartFallbackResponse(userMessage,
              businesses: availableBusinesses, location: currentLocation);

          _sessionHistory.add({
            'role': 'assistant',
            'message': fallbackResponse,
          });

          return fallbackResponse;
        }
      } catch (e) {
        print('Error in chat process: $e');
        final fallback = _getSmartFallbackResponse(userMessage,
            businesses: availableBusinesses, location: currentLocation);

        _sessionHistory.add({
          'role': 'assistant',
          'message': fallback,
        });

        return fallback;
      }
    } catch (e) {
      print('Error in sendMessage: $e');
      return _getSmartFallbackResponse(userMessage,
          businesses: availableBusinesses, location: currentLocation);
    }
  }

  // Smart fallback response based on the user's query
  String _getSmartFallbackResponse(String query,
      {List<Business>? businesses, String? location}) {
    // Normalize query to lowercase for easier matching
    final lowerQuery = query.toLowerCase();

    // Check if the query mentions a specific business name
    if (businesses != null && businesses.isNotEmpty) {
      for (var business in businesses) {
        if (lowerQuery.contains(business.businessName.toLowerCase())) {
          // Provide detailed information about this specific business
          String response =
              "Here are the details for ${business.businessName}:\n\n";

          if (business.businessType != null &&
              business.businessType!.isNotEmpty) {
            response += "📋 Type: ${business.businessType}\n";
          }

          response += "📍 Address: ${business.businessAddress}\n";

          if (business.contactNumber != null &&
              business.contactNumber!.isNotEmpty) {
            response += "📞 Contact: ${business.contactNumber}\n";
          }

          if (business.email.isNotEmpty) {
            response += "📧 Email: ${business.email}\n";
          }

          if (business.averageRating != null) {
            response +=
                "⭐ Rating: ${business.averageRating!.toStringAsFixed(1)}";
            if (business.totalReviews != null) {
              response += " (${business.totalReviews} reviews)";
            }
            response += "\n";
          }

          if (business.businessDescription != null &&
              business.businessDescription!.isNotEmpty) {
            response += "\n📝 Description: ${business.businessDescription}\n";
          }

          return response;
        }
      }
    }

    // Handle direct request to display business names from database
    if (lowerQuery.contains('display business') ||
        lowerQuery.contains('show business') ||
        lowerQuery.contains('list business') ||
        lowerQuery.contains('see business') ||
        lowerQuery.contains('display all business') ||
        lowerQuery.contains('business names') ||
        query == 'Show all businesses') {
      if (businesses != null && businesses.isNotEmpty) {
        // Filter businesses with coordinates
        final businessesWithCoordinates = businesses
            .where((b) => b.longitude != null && b.latitude != null)
            .toList();

        if (businessesWithCoordinates.isEmpty) {
          return "I couldn't find any businesses with location coordinates in your immediate area.";
        }

        // Group businesses alphabetically
        final sortedBusinesses = List<Business>.from(businessesWithCoordinates)
          ..sort((a, b) => a.businessName.compareTo(b.businessName));

        // Build response with all businesses
        String response =
            "Here are all the businesses with coordinates near you:\n\n";
        for (var business in sortedBusinesses.take(10)) {
          response += "Name: ${business.businessName}\n";
          response += "Address: ${business.businessAddress}\n";
          response += "Longitude: ${business.longitude}\n";
          response += "Latitude: ${business.latitude}\n\n";
        }
        if (sortedBusinesses.length > 10) {
          response +=
              "There are ${sortedBusinesses.length - 10} more businesses nearby.";
        }
        return response;
      }
      return "I couldn't find any businesses with location coordinates in your immediate area.";
    }

    // Handle "Show all categories" button
    if (query == 'Show all categories') {
      if (businesses != null && businesses.isNotEmpty) {
        // Group businesses by category
        final Map<String, List<Business>> businessesByCategory = {};

        for (var business in businesses) {
          final category = business.businessType ?? 'Uncategorized';
          if (!businessesByCategory.containsKey(category)) {
            businessesByCategory[category] = [];
          }
          businessesByCategory[category]!.add(business);
        }

        // Build a formatted response with businesses grouped by category
        String response = "Here are all the shops by category near you:\n\n";

        businessesByCategory.forEach((category, businessList) {
          response += "📍 $category:\n";
          for (var business in businessList.take(3)) {
            String ratingInfo = '';
            if (business.averageRating != null) {
              ratingInfo = " ⭐ ${business.averageRating!.toStringAsFixed(1)}";
            }
            response += "• ${business.businessName}$ratingInfo\n";
          }
          if (businessList.length > 3) {
            response += "• And ${businessList.length - 3} more...\n";
          }
          response += "\n";
        });

        return response;
      }
      return "You can view businesses by category using the 'Categories' tab in the main menu. Each category will show you relevant businesses in your area.";
    }

    // Category-specific queries for displaying shop names
    if (lowerQuery.contains('category') ||
        lowerQuery.contains('shop names') ||
        lowerQuery.contains('list of shops') ||
        lowerQuery.contains('display shops')) {
      if (businesses != null && businesses.isNotEmpty) {
        // Group businesses by category
        final Map<String, List<Business>> businessesByCategory = {};

        for (var business in businesses) {
          final category = business.businessType ?? 'Uncategorized';
          if (!businessesByCategory.containsKey(category)) {
            businessesByCategory[category] = [];
          }
          businessesByCategory[category]!.add(business);
        }

        // Build a formatted response with businesses grouped by category
        String response = "Here are the shops by category:\n\n";

        businessesByCategory.forEach((category, businessList) {
          response += "📍 $category:\n";
          for (var business in businessList.take(5)) {
            String ratingInfo = '';
            if (business.averageRating != null) {
              ratingInfo = " ⭐ ${business.averageRating!.toStringAsFixed(1)}";
            }
            response +=
                "• ${business.businessName}$ratingInfo: ${business.businessAddress}\n";
          }
          if (businessList.length > 5) {
            response += "• And ${businessList.length - 5} more...\n";
          }
          response += "\n";
        });

        return response;
      }
      return "You can view shops by category in the 'Categories' section. Each category contains relevant businesses in your area.";
    }

    // Handle specific category queries from the quick reply buttons
    if (query == 'Grocery') {
      if (businesses != null && businesses.isNotEmpty) {
        final groceries = businesses
            .where((b) =>
                b.businessType?.toLowerCase().contains('grocery') == true ||
                b.businessType?.toLowerCase().contains('supermarket') == true ||
                b.businessType?.toLowerCase().contains('market') == true ||
                (b.categoryId != null && b.categoryId == 1))
            .toList();

        if (groceries.isNotEmpty) {
          String response = "Here are the grocery stores near you:\n\n";
          for (var grocery in groceries.take(6)) {
            response += "Name: ${grocery.businessName}\n";
            response += "Address: ${grocery.businessAddress}\n";
            response += "Longitude: ${grocery.longitude}\n";
            response += "Latitude: ${grocery.latitude}\n\n";
          }
          if (groceries.length > 6) {
            response +=
                "There are ${groceries.length - 6} more grocery stores nearby.";
          }
          return response;
        }
      }
      return "I couldn't find any grocery stores in your immediate area.";
    }

    // Handle restaurants from quick reply
    if (query == 'Restaurants') {
      if (businesses != null && businesses.isNotEmpty) {
        final restaurants = businesses
            .where((b) =>
                (b.businessType?.toLowerCase().contains('restaurant') == true ||
                    b.businessType?.toLowerCase().contains('cafe') == true ||
                    b.businessType?.toLowerCase().contains('food') == true ||
                    b.businessType?.toLowerCase().contains('diner') == true ||
                    b.businessType?.toLowerCase().contains('canteen') == true ||
                    b.businessType?.toLowerCase().contains('dining') == true ||
                    (b.categoryId != null && b.categoryId == 3)) &&
                b.longitude != null &&
                b.latitude != null)
            .toList();

        if (restaurants.isNotEmpty) {
          String response = "Here are the restaurants near you:\n\n";
          for (var restaurant in restaurants.take(6)) {
            response += "Name: ${restaurant.businessName}\n";
            response += "Address: ${restaurant.businessAddress}\n";
            response += "Longitude: ${restaurant.longitude}\n";
            response += "Latitude: ${restaurant.latitude}\n\n";
          }
          if (restaurants.length > 6) {
            response +=
                "There are ${restaurants.length - 6} more restaurants nearby.";
          }
          return response;
        }
      }
      return "I couldn't find any restaurants with location coordinates in your immediate area.";
    }

    // Handle pharmacies from quick reply
    if (query == 'Pharmacies') {
      if (businesses != null && businesses.isNotEmpty) {
        final pharmacies = businesses
            .where((b) =>
                (b.businessType?.toLowerCase().contains('pharmacy') == true ||
                    b.businessType?.toLowerCase().contains('drug') == true ||
                    b.businessType?.toLowerCase().contains('health') == true ||
                    b.businessType?.toLowerCase().contains('medicine') ==
                        true ||
                    (b.categoryId != null && b.categoryId == 2)) &&
                b.longitude != null &&
                b.latitude != null)
            .toList();

        if (pharmacies.isNotEmpty) {
          String response = "Here are the pharmacies near you:\n\n";
          for (var pharmacy in pharmacies.take(6)) {
            response += "Name: ${pharmacy.businessName}\n";
            response += "Address: ${pharmacy.businessAddress}\n";
            response += "Longitude: ${pharmacy.longitude}\n";
            response += "Latitude: ${pharmacy.latitude}\n\n";
          }
          if (pharmacies.length > 6) {
            response +=
                "There are ${pharmacies.length - 6} more pharmacies nearby.";
          }
          return response;
        }
      }
      return "I couldn't find any pharmacies with location coordinates in your immediate area.";
    }

    // Handle retail stores from quick reply
    if (query == 'Retail stores') {
      if (businesses != null && businesses.isNotEmpty) {
        final stores = businesses
            .where((b) =>
                b.businessType?.toLowerCase().contains('retail') == true ||
                b.businessType?.toLowerCase().contains('shop') == true ||
                b.businessType?.toLowerCase().contains('store') == true ||
                b.businessType?.toLowerCase().contains('mall') == true ||
                (b.categoryId != null && b.categoryId == 8))
            .toList();

        if (stores.isNotEmpty) {
          String response = "Here are the retail stores near you:\n\n";
          for (var store in stores.take(6)) {
            response += "Name: ${store.businessName}\n";
            response += "Address: ${store.businessAddress}\n";
            response += "Longitude: ${store.longitude}\n";
            response += "Latitude: ${store.latitude}\n\n";
          }
          if (stores.length > 6) {
            response +=
                "There are ${stores.length - 6} more retail stores nearby.";
          }
          return response;
        }
      }
      return "I couldn't find any retail stores in your immediate area.";
    }

    // Restaurant/food related queries
    if (lowerQuery.contains('restaurant') ||
        lowerQuery.contains('food') ||
        lowerQuery.contains('eat') ||
        lowerQuery.contains('dining')) {
      if (businesses != null && businesses.isNotEmpty) {
        final restaurants = businesses
            .where((b) =>
                b.businessType?.toLowerCase().contains('restaurant') == true ||
                b.businessType?.toLowerCase().contains('food') == true)
            .toList();

        if (restaurants.isNotEmpty) {
          return "Based on your location, I found these restaurants nearby: \n\n${restaurants.take(3).map((r) => "• ${r.businessName}: ${r.businessAddress}").join("\n")}";
        }
      }

      return "There are several restaurants in this area. I recommend checking out the local diners and cafes. You can use the 'Nearby' feature to see restaurants closest to your location.";
    }

    // Pharmacy/healthcare related queries
    if (lowerQuery.contains('pharmacy') ||
        lowerQuery.contains('medicine') ||
        lowerQuery.contains('drug') ||
        lowerQuery.contains('hospital') ||
        lowerQuery.contains('health')) {
      if (businesses != null && businesses.isNotEmpty) {
        final pharmacies = businesses
            .where((b) =>
                b.businessType?.toLowerCase().contains('pharmacy') == true ||
                b.businessType?.toLowerCase().contains('health') == true)
            .toList();

        if (pharmacies.isNotEmpty) {
          return "Here are the pharmacies and healthcare providers nearby: \n\n${pharmacies.take(3).map((p) => "• ${p.businessName}: ${p.businessAddress}").join("\n")}";
        }
      }
      return "For pharmacies and healthcare providers, I recommend using the 'Categories' section and selecting 'Healthcare'. This will show you all nearby pharmacies, clinics, and hospitals with their contact information.";
    }

    // Shopping related queries
    if (lowerQuery.contains('shop') ||
        lowerQuery.contains('store') ||
        lowerQuery.contains('mall') ||
        lowerQuery.contains('supermarket') ||
        lowerQuery.contains('buy') ||
        lowerQuery.contains('grocery')) {
      if (businesses != null && businesses.isNotEmpty) {
        final shops = businesses
            .where((b) =>
                b.businessType?.toLowerCase().contains('retail') == true ||
                b.businessType?.toLowerCase().contains('shop') == true ||
                b.businessType?.toLowerCase().contains('store') == true ||
                b.businessType?.toLowerCase().contains('grocery') == true)
            .toList();

        if (shops.isNotEmpty) {
          return "Here are the shopping options nearby: \n\n${shops.take(3).map((s) => "• ${s.businessName}: ${s.businessAddress}").join("\n")}";
        }
      }
      return "You can find various shopping options using the 'Categories' feature. If you're looking for groceries, there are several markets and supermarkets that should be listed on the map view.";
    }

    // App usage related queries
    if (lowerQuery.contains('how to') ||
        lowerQuery.contains('app') ||
        lowerQuery.contains('use') ||
        lowerQuery.contains('help me') ||
        lowerQuery.contains('find') ||
        lowerQuery.contains('navigate')) {
      return "To get the most out of Locality Connector, try using the 'Nearby' feature to discover businesses around you. You can filter by category to narrow down results. For specific businesses, you can tap on their card to see more details including contact information.";
    }

    // Location related queries
    if (lowerQuery.contains('where') ||
        lowerQuery.contains('location') ||
        lowerQuery.contains('address') ||
        lowerQuery.contains('near') ||
        lowerQuery.contains('close') ||
        lowerQuery.contains('around')) {
      final locationStr = location != null ? "near $location" : "in this area";
      return "There are various businesses and services $locationStr. You can use the map view to see what's closest to you, or browse by category to find specific types of businesses.";
    }

    // Business specific info
    if (lowerQuery.contains('business') ||
        lowerQuery.contains('hours') ||
        lowerQuery.contains('open') ||
        lowerQuery.contains('service') ||
        lowerQuery.contains('offer') ||
        lowerQuery.contains('provide')) {
      return "For specific business information like hours, services offered, or contact details, tap on the business card in the app. You'll find all available information there, including reviews from other users.";
    }

    // Handle greetings
    if (lowerQuery.contains('hi') ||
        lowerQuery.contains('hello') ||
        lowerQuery.contains('hey') ||
        lowerQuery == 'hi' ||
        lowerQuery == 'hello') {
      return "Hello! I'm your Locality Connector Assistant. How can I help you find local businesses or services today?";
    }

    // Default response for other queries
    return "I can help you find local businesses and services. Try asking about restaurants, pharmacies, or shops nearby. Or, you can ask for help with using specific features of the app.";
  }

  // Get chat history
  List<Map<String, String>> getChatHistory() {
    return List.from(_sessionHistory);
  }

  // Fallback response when API fails completely
  String _getFallbackResponse() {
    List<String> responses = [
      "I'm sorry, I'm having trouble connecting at the moment. Please try asking about nearby businesses or how to use specific features of the app.",
      "While my connection is limited, I can still help you find local businesses using the app's 'Nearby' or 'Categories' features. What type of business are you looking for?",
      "I'm experiencing a brief technical hiccup with detailed responses. In the meantime, you can browse local businesses by tapping the 'Nearby' button in the app.",
      "Connection issues are affecting my responses. Try using the map view or categories section to find businesses near you while I recover."
    ];

    // Return a random response
    responses.shuffle();
    return responses.first;
  }
}
