import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:localityconnector/models/business.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  final String _apiKey = 'AIzaSyD8E8SVaoNa5xA0KfYjl8Zy2Dsot2aBKv8';

  // Getter to expose API key to other services
  String get apiKey => _apiKey;

  late final GenerativeModel _model;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize the Gemini API with version 0.2.2/0.2.3 structure
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _apiKey,
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(
              HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(
              HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );

      _isInitialized = true;
      print('✅ Gemini API initialized successfully');
    } catch (e) {
      print('⚠️ Warning: Failed to initialize Gemini API: $e');
      // Mark as initialized to prevent repeated attempts
      _isInitialized = true;
    }
  }

  // Ensure Gemini is initialized before each operation
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Get recommendations for businesses based on location and preferences
  Future<List<Map<String, String>>> getLocationBasedRecommendations(
      String location,
      List<String>? categories,
      Map<String, dynamic>? preferences) async {
    // Only initialize when actually needed
    await _ensureInitialized();

    try {
      String prompt = '''
      I need recommendations for local businesses in $location.
      ${categories != null ? 'Categories of interest: ${categories.join(", ")}.' : ''}
      ${preferences != null ? 'Preferences: ${preferences.toString()}.' : ''}
      
      Please provide recommendations in the following JSON format:
      [
        {
          "name": "Business Name",
          "type": "Business Type",
          "description": "Short description",
          "address": "Full address"
        }
      ]
      
      Provide only the JSON without additional text.
      ''';

      final content = [Content.text(prompt)];

      try {
        final response = await _model.generateContent(content);
        final text = response.text;

        if (text == null) return _getDummyRecommendations(location, categories);

        // Parse response as recommendations
        // This is a simplified parsing logic
        final List<Map<String, String>> recommendations = [];

        // Clean up the response to get only the JSON part
        String cleanedText =
            text.replaceAll('```json', '').replaceAll('```', '').trim();

        // Simple parsing logic - in a real app, use proper JSON parsing
        // This is a fallback mechanism when Gemini might not return proper JSON
        RegExp nameRegExp = RegExp(r'"name":\s*"([^"]+)"');
        RegExp typeRegExp = RegExp(r'"type":\s*"([^"]+)"');
        RegExp descRegExp = RegExp(r'"description":\s*"([^"]+)"');
        RegExp addressRegExp = RegExp(r'"address":\s*"([^"]+)"');

        Iterable<RegExpMatch> nameMatches = nameRegExp.allMatches(cleanedText);
        Iterable<RegExpMatch> typeMatches = typeRegExp.allMatches(cleanedText);
        Iterable<RegExpMatch> descMatches = descRegExp.allMatches(cleanedText);
        Iterable<RegExpMatch> addressMatches =
            addressRegExp.allMatches(cleanedText);

        int count = nameMatches.length;

        for (int i = 0; i < count; i++) {
          if (i < nameMatches.length &&
              i < typeMatches.length &&
              i < descMatches.length &&
              i < addressMatches.length) {
            recommendations.add({
              'name': nameMatches.elementAt(i).group(1) ?? '',
              'type': typeMatches.elementAt(i).group(1) ?? '',
              'description': descMatches.elementAt(i).group(1) ?? '',
              'address': addressMatches.elementAt(i).group(1) ?? '',
            });
          }
        }

        return recommendations.isNotEmpty
            ? recommendations
            : _getDummyRecommendations(location, categories);
      } catch (e) {
        print('Error calling Gemini API: $e');
        return _getDummyRecommendations(location, categories);
      }
    } catch (e) {
      print('Error getting recommendations from Gemini: $e');
      return _getDummyRecommendations(location, categories);
    }
  }

  List<Map<String, String>> _getDummyRecommendations(
      String location, List<String>? categories) {
    final List<Map<String, String>> recommendations = [];

    // Default categories if none provided
    final List<String> usedCategories = categories?.isNotEmpty == true
        ? categories!
        : ['Restaurant', 'Grocery', 'Pharmacy', 'Retail'];

    // Sample business names and descriptions for each category
    final Map<String, List<String>> businessNames = {
      'Restaurant': [
        'Local Eats',
        'Family Diner',
        'Quick Bites',
        'Flavor House'
      ],
      'Grocery': [
        'Fresh Market',
        'Daily Grocers',
        'Family Foods',
        'Quick Stop'
      ],
      'Pharmacy': [
        'Health Plus',
        'Care Pharmacy',
        'QuickMeds',
        'Family Pharmacy'
      ],
      'Retail': [
        'Town Shopping',
        'Local Goods',
        'Daily Needs',
        'Variety Store'
      ],
      'Other': [
        'Local Service',
        'Community Shop',
        'Town Business',
        'Neighborhood Store'
      ],
    };

    final Map<String, List<String>> businessDescriptions = {
      'Restaurant': [
        'Local restaurant with great food and atmosphere',
        'Family-owned diner serving homestyle meals',
        'Quick service restaurant with affordable options',
        'Restaurant offering a variety of flavors and cuisines'
      ],
      'Grocery': [
        'Fresh produce and grocery items at competitive prices',
        'Local grocery store with friendly service',
        'Family-owned market with quality products',
        'Convenient grocery store for daily needs'
      ],
      'Pharmacy': [
        'Full-service pharmacy with professional staff',
        'Caring pharmacy offering medications and health advice',
        'Quick and efficient pharmacy services',
        'Family pharmacy serving the community for years'
      ],
      'Retail': [
        'One-stop shop for all your shopping needs',
        'Local retail store with quality products',
        'Store offering daily necessities at good prices',
        'Variety store with diverse product selections'
      ],
      'Other': [
        'Local business serving community needs',
        'Community shop with personalized service',
        'Business providing essential services',
        'Neighborhood store with convenient hours'
      ],
    };

    // Generate recommendations based on categories
    for (String category in usedCategories) {
      final categoryKey =
          businessNames.containsKey(category) ? category : 'Other';
      final names = businessNames[categoryKey]!;
      final descriptions = businessDescriptions[categoryKey]!;

      // Add 1-2 businesses per category
      final count = category == usedCategories.first ? 2 : 1;
      for (int i = 0; i < count && i < names.length; i++) {
        recommendations.add({
          'name': names[i],
          'type': category,
          'description': descriptions[i],
          'address': '$location, Main Street ${100 + recommendations.length}'
        });
      }
    }

    return recommendations;
  }

  // Generate description for a location or business
  Future<String> generateLocationDescription(
      String locationName, String businessType) async {
    // Only initialize when needed
    await _ensureInitialized();

    try {
      String prompt = '''
      Generate a detailed but concise description for a $businessType business called "$locationName".
      Include what services they might offer and why they would be beneficial to the community.
      Keep the description under 100 words and make it engaging.
      ''';

      final content = [Content.text(prompt)];

      try {
        final response = await _model.generateContent(content);
        final text = response.text;
        return text ?? _getDummyDescription(locationName, businessType);
      } catch (e) {
        print('Error calling Gemini API: $e');
        return _getDummyDescription(locationName, businessType);
      }
    } catch (e) {
      print('Error generating description: $e');
      return _getDummyDescription(locationName, businessType);
    }
  }

  String _getDummyDescription(String locationName, String businessType) {
    final Map<String, String> descriptions = {
      'restaurant':
          "$locationName is a welcoming restaurant offering delicious meals made with locally-sourced ingredients. Their diverse menu caters to different tastes and dietary needs, making it a popular spot for families and friends to gather. With excellent service and a cozy atmosphere, they've become an essential part of the community's dining scene.",
      'grocery':
          "$locationName provides fresh produce, pantry staples, and household essentials to the local community. Their well-stocked shelves feature products from local farmers and brands alongside popular national options. Friendly staff and competitive prices make this grocery store a convenient one-stop shop for families and individuals looking for quality food items.",
      'pharmacy':
          "$locationName offers prescription medications, over-the-counter remedies, and professional healthcare advice. Their knowledgeable pharmacists provide personalized service, including medication consultations and health screenings. With quick prescription processing and a wide range of health and wellness products, they've become an essential healthcare resource in the community.",
      'retail':
          "$locationName features a carefully curated selection of products ranging from clothing and accessories to home goods and gifts. Their focus on quality and customer service has made them a favorite shopping destination in the area. By offering unique items not found in big box stores, they provide a refreshing shopping experience for local residents.",
      'default':
          "$locationName is a valued local business serving the community with high-quality products and exceptional service. Their commitment to customer satisfaction and community involvement has made them a trusted name in the area. Whether you're a longtime resident or just visiting, $locationName offers a welcoming environment and products that meet your needs."
    };

    // Normalize business type to match our keys
    final normalizedType = businessType.toLowerCase();

    // Find the best matching description
    for (final key in descriptions.keys) {
      if (normalizedType.contains(key)) {
        return descriptions[key]!;
      }
    }

    // Default description if no match
    return descriptions['default']!;
  }

  // Get suggested nearby businesses based on a location
  Future<List<Business>> getSuggestedBusinesses(double latitude,
      double longitude, String address, String category) async {
    if (!_isInitialized) await initialize();

    try {
      String prompt = '''
      I'm at latitude $latitude, longitude $longitude, near "$address".
      Suggest 5 fictional ${category.isNotEmpty ? category : 'local'} businesses that might be nearby.
      
      Return the results in the following JSON format:
      [
        {
          "businessName": "Name",
          "businessType": "Type",
          "businessDescription": "Description",
          "businessAddress": "Address",
          "contactNumber": "Phone",
          "email": "email@example.com",
          "latitude": latitude_value,
          "longitude": longitude_value,
          "averageRating": rating_between_0_and_5,
          "totalReviews": number_of_reviews
        }
      ]
      
      Make the latitude and longitude values close to my current location but slightly different.
      Provide only the JSON without additional text.
      ''';

      final content = [Content.text(prompt)];

      try {
        final response = await _model.generateContent(content);
        final text = response.text;

        if (text == null) {
          return _getDummyBusinesses(latitude, longitude, address, category);
        }

        // Parse the response to extract business information
        // This is a simplified approach - in a real app, use proper JSON parsing
        List<Business> businesses = [];

        // Clean up the response to get only the JSON part
        String cleanedText =
            text.replaceAll('```json', '').replaceAll('```', '').trim();

        // Simple parsing logic
        RegExp nameRegExp = RegExp(r'"businessName":\s*"([^"]+)"');
        RegExp typeRegExp = RegExp(r'"businessType":\s*"([^"]+)"');
        RegExp descRegExp = RegExp(r'"businessDescription":\s*"([^"]+)"');
        RegExp addressRegExp = RegExp(r'"businessAddress":\s*"([^"]+)"');
        RegExp contactRegExp = RegExp(r'"contactNumber":\s*"([^"]+)"');
        RegExp emailRegExp = RegExp(r'"email":\s*"([^"]+)"');
        RegExp latRegExp = RegExp(r'"latitude":\s*([\d.]+)');
        RegExp lngRegExp = RegExp(r'"longitude":\s*([\d.]+)');
        RegExp ratingRegExp = RegExp(r'"averageRating":\s*([\d.]+)');
        RegExp reviewsRegExp = RegExp(r'"totalReviews":\s*(\d+)');

        Iterable<RegExpMatch> nameMatches = nameRegExp.allMatches(cleanedText);

        for (int i = 0; i < nameMatches.length; i++) {
          try {
            String name =
                nameMatches.elementAt(i).group(1) ?? 'Unknown Business';

            // Extract other fields using regex
            String type =
                _extractMatch(typeRegExp, cleanedText, i) ?? 'Business';
            String desc = _extractMatch(descRegExp, cleanedText, i) ?? '';
            String address = _extractMatch(addressRegExp, cleanedText, i) ??
                'Near $latitude, $longitude';
            String contact = _extractMatch(contactRegExp, cleanedText, i) ?? '';
            String email = _extractMatch(emailRegExp, cleanedText, i) ?? '';

            double? lat = _extractDoubleMatch(latRegExp, cleanedText, i) ??
                latitude + (0.001 * i);
            double? lng = _extractDoubleMatch(lngRegExp, cleanedText, i) ??
                longitude + (0.001 * i);
            double? rating =
                _extractDoubleMatch(ratingRegExp, cleanedText, i) ?? 4.0;
            int? reviews =
                _extractIntMatch(reviewsRegExp, cleanedText, i) ?? 10;

            businesses.add(Business(
                businessName: name,
                businessType: type,
                businessDescription: desc,
                businessAddress: address,
                contactNumber: contact,
                email: email,
                latitude: lat,
                longitude: lng,
                averageRating: rating,
                totalReviews: reviews,
                // Using placeholders for required fields that we don't have values for
                password: 'placeholder'));
          } catch (e) {
            print('Error parsing business $i: $e');
          }
        }

        return businesses.isNotEmpty
            ? businesses
            : _getDummyBusinesses(latitude, longitude, address, category);
      } catch (e) {
        print('Error calling Gemini API: $e');
        return _getDummyBusinesses(latitude, longitude, address, category);
      }
    } catch (e) {
      print('Error getting suggested businesses: $e');
      return _getDummyBusinesses(latitude, longitude, address, category);
    }
  }

  // Provide dummy business data as fallback
  List<Business> _getDummyBusinesses(
      double latitude, double longitude, String address, String category) {
    final List<Business> dummyBusinesses = [];

    // Names based on category
    List<String> businessNames = [];
    List<String> descriptions = [];

    if (category.toLowerCase().contains('grocery') || category.isEmpty) {
      businessNames = [
        'Fresh Market',
        'Daily Grocers',
        'Green Harvest',
        'Family Foods',
        'Quick Stop'
      ];
      descriptions = [
        'A local grocery store with fresh produce and friendly service.',
        'Your one-stop shop for all grocery needs with competitive prices.',
        'Specializing in organic and locally-sourced produce.',
        'Family-owned grocery store serving the community for 25 years.',
        'Convenient grocery store open 24/7 for all your needs.'
      ];
    } else if (category.toLowerCase().contains('restaurant')) {
      businessNames = [
        'Taste of Local',
        'Flavor House',
        'Home Cooking',
        'Spice Garden',
        'Food Fusion'
      ];
      descriptions = [
        'Restaurant serving authentic local cuisine with fresh ingredients.',
        'Casual dining with a diverse menu and great atmosphere.',
        'Family-style restaurant with comfort food and generous portions.',
        'Specializing in spicy cuisines from around the world.',
        'Fusion restaurant combining local flavors with international techniques.'
      ];
    } else if (category.toLowerCase().contains('pharmacy')) {
      businessNames = [
        'Health Plus',
        'Care Pharmacy',
        'QuickMeds',
        'Wellness Drugs',
        'Family Pharmacy'
      ];
      descriptions = [
        'Full-service pharmacy with professional healthcare advice.',
        'Affordable medications with friendly and knowledgeable staff.',
        'Fast service pharmacy with home delivery options.',
        'Pharmacy focusing on wellness products and natural remedies.',
        'Family-owned pharmacy serving all your medication needs.'
      ];
    } else {
      businessNames = [
        'Local Shop',
        'Community Store',
        'Town Services',
        'Neighborhood Hub',
        'City Center'
      ];
      descriptions = [
        'A local business serving community needs.',
        'Family-owned store with personalized service.',
        'Providing essential services to local residents.',
        'Neighborhood favorite with loyal customers.',
        'Centrally located business with convenient hours.'
      ];
    }

    // Generate 5 dummy businesses
    for (int i = 0; i < 5; i++) {
      dummyBusinesses.add(Business(
          businessName: businessNames[i],
          businessType: category.isEmpty ? 'Local Business' : category,
          businessDescription: descriptions[i],
          businessAddress: 'Near $address',
          contactNumber: '+1-555-${100 + i}-${1000 + i}',
          email:
              '${businessNames[i].toLowerCase().replaceAll(' ', '')}@example.com',
          latitude: latitude + (0.001 * (i + 1)),
          longitude: longitude + (0.001 * (i + 1)),
          averageRating: 4.0 + (i * 0.2) % 1.0,
          totalReviews: 10 + (i * 5),
          password: 'placeholder'));
    }

    return dummyBusinesses;
  }

  // Helper method to extract a string match from a RegExp
  String? _extractMatch(RegExp regex, String text, int index) {
    Iterable<RegExpMatch> matches = regex.allMatches(text);
    if (index < matches.length) {
      return matches.elementAt(index).group(1);
    }
    return null;
  }

  // Helper method to extract a double match from a RegExp
  double? _extractDoubleMatch(RegExp regex, String text, int index) {
    String? value = _extractMatch(regex, text, index);
    if (value != null) {
      return double.tryParse(value);
    }
    return null;
  }

  // Helper method to extract an int match from a RegExp
  int? _extractIntMatch(RegExp regex, String text, int index) {
    String? value = _extractMatch(regex, text, index);
    if (value != null) {
      return int.tryParse(value);
    }
    return null;
  }
}
