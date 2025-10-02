import 'package:flutter/material.dart';
import 'package:localityconnector/services/chatbot_service.dart';
import 'package:localityconnector/models/business.dart';
import 'package:localityconnector/models/database_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatbotScreen extends StatefulWidget {
  final List<Business>? nearbyBusinesses;
  final String? currentLocation;

  const ChatbotScreen({
    super.key,
    this.nearbyBusinesses,
    this.currentLocation,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotService _chatbotService = ChatbotService();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _chatMessages = [];
  bool _isTyping = false;
  bool _isInitializing = true;
  List<Business> _businessList = [];
  // Map to store category IDs by name
  final Map<String, int> _categoryIds = {
    'Grocery': 1,
    'Pharmacy': 2,
    'Restaurant': 3,
    'Healthcare': 4,
    'Retail stores': 8, // Using Shopping category ID
  };

  // Common categories for quick replies
  final List<String> _quickReplyCategories = [
    'Grocery',
    'Restaurants',
    'Pharmacies',
    'Food Items'
  ];

  @override
  void initState() {
    super.initState();
    _initializeChat();
    // Initialize with nearby businesses if provided
    if (widget.nearbyBusinesses != null) {
      _businessList = widget.nearbyBusinesses!;
    }
    // Load all businesses from database to ensure we have complete data
    _loadAllBusinessesFromDatabase();
  }

  Future<void> _initializeChat() async {
    setState(() {
      _isInitializing = true;
    });

    await _chatbotService.initialize();

    // Add welcome message
    setState(() {
      _chatMessages.add({
        'role': 'assistant',
        'message':
            "Hello! I'm your Locality Connector Assistant. How can I help you find local services today?"
      });
      _isInitializing = false;
    });
  }

  // Method to load all businesses from database
  Future<void> _loadAllBusinessesFromDatabase() async {
    try {
      List<Business> allBusinesses =
          await DatabaseHelper.instance.getAllBusinesses();

      // Filter out businesses without coordinates
      allBusinesses = allBusinesses
          .where((business) =>
              business.longitude != null && business.latitude != null)
          .toList();

      if (allBusinesses.isNotEmpty) {
        setState(() {
          // Merge with existing businesses to ensure comprehensive coverage
          if (_businessList.isNotEmpty) {
            // Combine lists and remove duplicates by ID
            final Map<int?, Business> businessMap = {};
            for (var business in [..._businessList, ...allBusinesses]) {
              if (business.id != null) {
                businessMap[business.id] = business;
              }
            }
            _businessList = businessMap.values.toList();
          } else {
            _businessList = allBusinesses;
          }
        });
      }
    } catch (e) {
      print('Error loading all businesses: $e');
    }
  }

  // Method to handle quick reply button presses
  void _handleQuickReply(String category) async {
    // If user wants to show Food Items
    if (category == 'Food Items') {
      // Add user message to chat
      setState(() {
        _chatMessages.add({
          'role': 'user',
          'message': category,
        });
      });

      // Display hardcoded food items businesses
      setState(() {
        _chatMessages.add({
          'role': 'assistant',
          'message': "Here are the food items businesses near you:\n\n"
              "Name: Vimeet Hostel Shop\n"
              "Address: Girls Hostel Vimeet Campus\n"
              "Longitude: 73.2718681\n"
              "Latitude: 18.821721\n\n"
              "Name: Vimeet Canteen\n"
              "Address: Vimeet Campus\n"
              "Longitude: 73.2710238\n"
              "Latitude: 18.8217548\n\n"
              "Name: Rohit Tapri\n"
              "Address: In front of Vimeet Dhamini, Khalapur, Maharashtra\n"
              "Longitude: 73.2704106\n"
              "Latitude: 18.8217713\n\n"
              "Name: Sanjay Tapri\n"
              "Address: Dhamini, Khalapur, Maharashtra\n"
              "Longitude: 73.2747899\n"
              "Latitude: 18.8180540\n\n"
              "Name: Siya Bakery\n"
              "Address: Dhamini, Khalapur, Maharashtra\n"
              "Longitude: 73.2754474\n"
              "Latitude: 18.8173170\n\n"
              "Name: OmDhaba\n"
              "Address: Dhamini, Khalapur, Maharashtra\n"
              "Longitude: 73.2764527\n"
              "Latitude: 18.8168918\n",
        });
      });

      _scrollToBottom();
      return;
    }
    // For Grocery category, display hardcoded grocery stores
    else if (category == 'Grocery') {
      // Add user message to chat
      setState(() {
        _chatMessages.add({
          'role': 'user',
          'message': category,
        });
      });

      // Display hardcoded grocery stores
      setState(() {
        _chatMessages.add({
          'role': 'assistant',
          'message': "Here are the grocery stores near you:\n\n"
              "Name: Vishal General Store\n"
              "Address: Dhamini, Khalapur, Raigad, Maharashtra\n"
              "Longitude: 73.2694553\n"
              "Latitude: 18.8208955\n\n"
              "Name: Aniket Kirana\n"
              "Address: Dhamini, Khalapur, Maharashtra\n"
              "Longitude: 73.2754436\n"
              "Latitude: 18.8171782\n\n"
              "Name: Vishal General Store\n"
              "Address: Dhamini, Khalapur, Raigad, Maharashtra\n"
              "Longitude: 73.2757571\n"
              "Latitude: 18.8170367\n\n"
              "Name: Lotta General Store\n"
              "Address: Dhamini, Khalapur, Maharashtra\n"
              "Longitude: 73.2750096\n"
              "Latitude: 18.8176347\n\n"
              "Name: HariNam Kirana\n"
              "Address: Khumbhivali, Maharashtra\n"
              "Longitude: 73.2614682\n"
              "Latitude: 18.8228121\n",
        });
      });

      _scrollToBottom();
      return;
    }
    // For Pharmacies category, display hardcoded pharmacies
    else if (category == 'Pharmacies') {
      // Add user message to chat
      setState(() {
        _chatMessages.add({
          'role': 'user',
          'message': category,
        });
      });

      // Display hardcoded pharmacies
      setState(() {
        _chatMessages.add({
          'role': 'assistant',
          'message': "Here are the pharmacies near you:\n\n"
              "Name: Metro Medical\n"
              "Address: Dhamini, Khalapur, Maharashtra\n"
              "Longitude: 73.2755938\n"
              "Latitude: 18.8169348\n\n"
              "Name: Khumbhivali Medical Shop\n"
              "Address: Khumbhivali, Maharashtra\n"
              "Longitude: 73.2621109\n"
              "Latitude: 18.8228731\n",
        });
      });

      _scrollToBottom();
      return;
    }
    // If it's a specific category, fetch businesses
    else {
      await _fetchBusinessesByCategory(category);

      // If it's Restaurants, show in a specific format
      if (category == 'Restaurants') {
        _displayBusinessResultsFromCategory(category);
        return;
      }
    }
    _sendMessageWithText(category);
  }

  // Method to fetch businesses by category name
  Future<void> _fetchBusinessesByCategory(String categoryQuery) async {
    setState(() {
      _isTyping = true;
    });

    try {
      int? categoryId;

      // Map the query to a category ID
      if (categoryQuery == 'Grocery') {
        categoryId = _categoryIds['Grocery'];
      } else if (categoryQuery == 'Restaurants') {
        categoryId = _categoryIds['Restaurant'];
      } else if (categoryQuery == 'Pharmacies') {
        categoryId = _categoryIds['Pharmacy'];
      } else if (categoryQuery == 'Retail stores') {
        categoryId = _categoryIds['Retail stores'];
      }

      if (categoryId != null) {
        // Show loading message
        setState(() {
          _chatMessages.add({
            'role': 'user',
            'message': categoryQuery,
          });
          _chatMessages.add({
            'role': 'assistant',
            'message': 'Fetching ${categoryQuery.toLowerCase()}...',
          });
        });

        // Scroll to bottom to show loading message
        _scrollToBottom();

        // Fetch businesses from the database
        List<Business> businesses = [];
        try {
          businesses =
              await DatabaseHelper.instance.getBusinessesByCategory(categoryId);
          // Filter out businesses without coordinates
          businesses = businesses
              .where((b) => b.longitude != null && b.latitude != null)
              .toList();
        } catch (e) {
          print('Error fetching businesses by category ID: $e');
          // Will fall back to filtering existing businesses
        }

        // If we got businesses, update the list
        if (businesses.isNotEmpty) {
          setState(() {
            _businessList = businesses;
            // Remove the loading message
            if (_chatMessages.isNotEmpty &&
                _chatMessages.last['role'] == 'assistant' &&
                _chatMessages.last['message']!.contains('Fetching')) {
              _chatMessages.removeLast();
              _chatMessages.removeLast(); // Remove user message too
            }
          });
        } else {
          // Fall back to nearby businesses filtered by category type
          String categoryType = categoryQuery.toLowerCase();
          if (categoryQuery == 'Grocery') categoryType = 'grocery';
          if (categoryQuery == 'Restaurants') categoryType = 'restaurant';
          if (categoryQuery == 'Pharmacies') categoryType = 'pharmacy';
          if (categoryQuery == 'Retail stores') categoryType = 'retail';

          final filteredBusinesses = _businessList.isNotEmpty
              ? _businessList
                  .where((b) =>
                      (b.businessType?.toLowerCase().contains(categoryType) ==
                              true ||
                          (categoryQuery == 'Grocery' && b.categoryId == 1) ||
                          (categoryQuery == 'Restaurants' &&
                              (b.categoryId == 3 ||
                                  b.businessType
                                          ?.toLowerCase()
                                          .contains('canteen') ==
                                      true ||
                                  b.businessType
                                          ?.toLowerCase()
                                          .contains('dining') ==
                                      true)) ||
                          (categoryQuery == 'Pharmacies' &&
                              b.categoryId == 2)) &&
                      b.longitude != null &&
                      b.latitude != null)
                  .toList()
              : <Business>[];

          setState(() {
            if (filteredBusinesses.isNotEmpty) {
              _businessList = filteredBusinesses;
            }
            // Remove the loading message
            if (_chatMessages.isNotEmpty &&
                _chatMessages.last['role'] == 'assistant' &&
                _chatMessages.last['message']!.contains('Fetching')) {
              _chatMessages.removeLast();
              _chatMessages.removeLast(); // Remove user message too
            }
          });

          // If still no businesses found, load all businesses as fallback
          if (filteredBusinesses.isEmpty) {
            await _loadAllBusinessesFromDatabase();
            // Filter out businesses without coordinates
            setState(() {
              _businessList = _businessList
                  .where((b) => b.longitude != null && b.latitude != null)
                  .toList();
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching businesses by category: $e');
      // Remove loading message in case of error
      setState(() {
        if (_chatMessages.isNotEmpty &&
            _chatMessages.last['role'] == 'assistant' &&
            _chatMessages.last['message']!.contains('Fetching')) {
          _chatMessages.removeLast();
          _chatMessages.removeLast(); // Remove user message too
        }
      });
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  // Method to display business results directly from category
  void _displayBusinessResultsFromCategory(String category) {
    if (_businessList.isEmpty) {
      // No businesses found
      setState(() {
        _chatMessages.add({
          'role': 'user',
          'message': category,
        });
        _chatMessages.add({
          'role': 'assistant',
          'message': 'No ${category.toLowerCase()} found in the database.',
        });
      });
      return;
    }

    // First filter businesses by category
    List<Business> categoryBusinesses = [];

    if (category == 'Grocery') {
      categoryBusinesses = _businessList
          .where((b) =>
              b.businessType?.toLowerCase().contains('grocery') == true ||
              b.businessType?.toLowerCase().contains('supermarket') == true ||
              b.categoryId == _categoryIds['Grocery'])
          .toList();
    } else if (category == 'Restaurants') {
      categoryBusinesses = _businessList
          .where((b) =>
              b.businessType?.toLowerCase().contains('restaurant') == true ||
              b.businessType?.toLowerCase().contains('food') == true ||
              b.businessType?.toLowerCase().contains('cafe') == true ||
              b.businessType?.toLowerCase().contains('canteen') == true ||
              b.businessType?.toLowerCase().contains('dining') == true ||
              b.categoryId == _categoryIds['Restaurant'])
          .toList();
    } else if (category == 'Pharmacies') {
      categoryBusinesses = _businessList
          .where((b) =>
              b.businessType?.toLowerCase().contains('pharmacy') == true ||
              b.businessType?.toLowerCase().contains('drug') == true ||
              b.businessType?.toLowerCase().contains('medicine') == true ||
              b.categoryId == _categoryIds['Pharmacy'])
          .toList();
    } else {
      // Default: use all businesses if category doesn't match
      categoryBusinesses = _businessList;
    }

    if (categoryBusinesses.isEmpty) {
      setState(() {
        _chatMessages.add({
          'role': 'user',
          'message': category,
        });
        _chatMessages.add({
          'role': 'assistant',
          'message': 'No ${category.toLowerCase()} found in the database.',
        });
      });
      return;
    }

    // Then filter businesses that have both longitude and latitude
    final businessesWithCoordinates = categoryBusinesses
        .where((business) =>
            business.longitude != null && business.latitude != null)
        .toList();

    if (businessesWithCoordinates.isEmpty) {
      setState(() {
        _chatMessages.add({
          'role': 'user',
          'message': category,
        });
        _chatMessages.add({
          'role': 'assistant',
          'message':
              'No ${category.toLowerCase()} with location coordinates found in the database.',
        });
      });
      return;
    }

    // Build a formatted response with business details
    String response =
        "Here are the ${category.toLowerCase()} in your area:\n\n";
    for (var business in businessesWithCoordinates.take(6)) {
      response += "Name: ${business.businessName}\n";
      response += "Address: ${business.businessAddress}\n";
      response += "Longitude: ${business.longitude}\n";
      response += "Latitude: ${business.latitude}\n\n";
    }

    if (businessesWithCoordinates.length > 6) {
      response +=
          "There are ${businessesWithCoordinates.length - 6} more ${category.toLowerCase()} nearby.";
    }

    // Add the message to chat
    setState(() {
      _chatMessages.add({
        'role': 'user',
        'message': category,
      });
      _chatMessages.add({
        'role': 'assistant',
        'message': response,
      });
    });

    // Scroll to bottom
    _scrollToBottom();
  }

  // Modified to allow programmatic sending of messages
  Future<void> _sendMessageWithText(String message) async {
    if (message.trim().isEmpty) return;

    // Don't add message to chat if we're already showing a loading message for category fetching
    if (!(_chatMessages.isNotEmpty &&
        _chatMessages.last['role'] == 'assistant' &&
        _chatMessages.last['message']!.contains('Fetching'))) {
      setState(() {
        _chatMessages.add({
          'role': 'user',
          'message': message,
        });
        _isTyping = true;
      });
    }

    // Scroll to bottom
    _scrollToBottom();

    // Get response from chatbot
    final response = await _chatbotService.sendMessage(
      message,
      availableBusinesses:
          _businessList.isNotEmpty ? _businessList : widget.nearbyBusinesses,
      currentLocation: widget.currentLocation,
    );

    setState(() {
      _chatMessages.add({
        'role': 'assistant',
        'message': response,
      });
      _isTyping = false;
    });

    // Scroll to bottom again
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Show login popup dialog
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login as user to locate the shop'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/signin');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetChat() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Chat'),
        content:
            const Text('Are you sure you want to reset this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isInitializing = true;
                _chatMessages.clear();
                // Reset business list to original nearby businesses
                if (widget.nearbyBusinesses != null) {
                  _businessList = widget.nearbyBusinesses!;
                } else {
                  _businessList = [];
                }
              });
              await _chatbotService.resetChat();
              setState(() {
                _chatMessages.add({
                  'role': 'assistant',
                  'message':
                      'Hello! I\'m your Locality Connector Assistant. How can I help you find local businesses or services today?'
                });
                _isInitializing = false;
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // Custom widget to display business information with locate button
  Widget _buildBusinessMessageContent(String message) {
    // First check if this is a message that contains business listings
    if (!message.contains('Here are the') &&
        !message.contains('Name:') &&
        !message.contains('Address:')) {
      // Return as plain text for messages that don't contain business info
      return Text(message);
    }

    // For messages with Longitude and Latitude (new format for grocery stores)
    if (message.contains('Longitude:') && message.contains('Latitude:')) {
      List<String> businessEntries = message.split('\n\n');
      List<Widget> contentWidgets = [];

      // Add heading text
      if (message.startsWith('Here are the')) {
        String headingText = message.split('\n').first;
        contentWidgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            headingText,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ));
      }

      // Process each business entry
      for (String entry in businessEntries) {
        if (entry.contains('Name:') && entry.contains('Address:')) {
          // Extract business info
          String name = '';
          String address = '';
          double? longitude;
          double? latitude;

          List<String> lines = entry.split('\n');
          for (String line in lines) {
            if (line.startsWith('Name:')) {
              name = line.substring('Name:'.length).trim();
            } else if (line.startsWith('Address:')) {
              address = line.substring('Address:'.length).trim();
            } else if (line.startsWith('Longitude:')) {
              longitude =
                  double.tryParse(line.substring('Longitude:'.length).trim());
            } else if (line.startsWith('Latitude:')) {
              latitude =
                  double.tryParse(line.substring('Latitude:'.length).trim());
            }
          }

          contentWidgets.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: $name',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Address: $address'),
                  const SizedBox(height: 4),
                  if (longitude != null) Text('Longitude: $longitude'),
                  if (latitude != null) Text('Latitude: $latitude'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.location_on),
                      label: const Text('Locate on map'),
                      onPressed: longitude != null && latitude != null
                          ? () {
                              if (_isLoginRequired(name, null, message)) {
                                _showLoginDialog();
                              } else {
                                _navigateToLocation(
                                    longitude!, latitude!, name);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (entry.isNotEmpty && !entry.startsWith('Here are')) {
          // Add other non-business text
          contentWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(entry.trim()),
            ),
          );
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contentWidgets,
      );
    }

    // Special handling for the bullet point format shown in the screenshot
    if (message.contains('• ')) {
      List<Widget> contentWidgets = [];

      // Add the heading text
      String headingText = '';
      if (message.startsWith('Here are the')) {
        headingText = message.split('\n').first;
        contentWidgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            headingText,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ));
      }

      // Process each business entry (lines starting with bullet points)
      List<String> lines = message.split('\n');
      for (String line in lines) {
        if (line.trim().startsWith('• ') || line.trim().startsWith('📍')) {
          // This is a business entry
          contentWidgets.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.trim()),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.location_on),
                      label: const Text('Locate on map'),
                      onPressed: () {
                        // Extract business name from the line text
                        String name = '';
                        if (line.contains('Name:')) {
                          name =
                              line.substring(line.indexOf('Name:') + 5).trim();
                        } else {
                          // Try to extract the business name from the line
                          name = line
                              .replaceAll('•', '')
                              .replaceAll('📍', '')
                              .trim();
                        }

                        if (_isLoginRequired(name, null, message)) {
                          _showLoginDialog();
                        } else {
                          // Try to extract latitude and longitude if available in the text
                          double? lat, lng;
                          // Look for coordinates in siblings of this line
                          for (String sibling in message.split('\n')) {
                            if (sibling.contains('Latitude:')) {
                              lat = double.tryParse(sibling
                                  .substring(sibling.indexOf('Latitude:') + 9)
                                  .trim());
                            } else if (sibling.contains('Longitude:')) {
                              lng = double.tryParse(sibling
                                  .substring(sibling.indexOf('Longitude:') + 10)
                                  .trim());
                            }
                          }

                          if (lat != null && lng != null) {
                            _navigateToLocation(lng, lat, name);
                          } else {
                            // Fallback: show a toast that location data is not available
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Location coordinates not available')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (!line.contains(headingText) && line.trim().isNotEmpty) {
          // Other non-business, non-heading lines
          contentWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(line.trim()),
            ),
          );
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contentWidgets,
      );
    }
    // For the original format that uses Name: and Address:
    else if (message.contains('Name:') || message.contains('Address:')) {
      List<String> businessEntries = message.split('\n\n');
      List<Widget> contentWidgets = [];

      // Add heading text if present
      if (message.startsWith('Here are the')) {
        String headingText = message.split('\n').first;
        contentWidgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            headingText,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ));
      }

      // Process each business entry
      for (String entry in businessEntries) {
        if (entry.contains('Name:') || entry.contains('Address:')) {
          // Extract business info
          String name = '';
          String address = '';
          double? longitude;
          double? latitude;

          List<String> lines = entry.split('\n');
          for (String line in lines) {
            if (line.startsWith('Name:')) {
              name = line.substring('Name:'.length).trim();
            } else if (line.startsWith('Address:')) {
              address = line.substring('Address:'.length).trim();
            } else if (line.startsWith('Longitude:')) {
              longitude =
                  double.tryParse(line.substring('Longitude:'.length).trim());
            } else if (line.startsWith('Latitude:')) {
              latitude =
                  double.tryParse(line.substring('Latitude:'.length).trim());
            }
          }

          contentWidgets.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? 'Name: $name' : entry,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Address: $address'),
                  ],
                  if (longitude != null) ...[
                    const SizedBox(height: 4),
                    Text('Longitude: $longitude'),
                  ],
                  if (latitude != null) ...[
                    const SizedBox(height: 4),
                    Text('Latitude: $latitude'),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.location_on),
                      label: const Text('Locate on map'),
                      onPressed: longitude != null && latitude != null
                          ? () {
                              if (_isLoginRequired(name, null, message)) {
                                _showLoginDialog();
                              } else {
                                _navigateToLocation(
                                    longitude!, latitude!, name);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (!entry.startsWith('Here are') && entry.trim().isNotEmpty) {
          // Other text
          contentWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(entry.trim()),
            ),
          );
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contentWidgets,
      );
    } else {
      // Return as plain text for any other messages
      return Text(message);
    }
  }

  // Open map with business location
  void _openMap(
      double latitude, double longitude, String businessName, String address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(businessName),
          ),
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: MarkerId(businessName),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(
                  title: businessName,
                  snippet: address,
                ),
              ),
            },
          ),
        ),
      ),
    );
  }

  // Navigate to business location without login for food items
  void _navigateToLocation(double longitude, double latitude, String name) {
    // Handle navigation to the location here
    // You can implement this based on your app's navigation requirements
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    try {
      launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Could not open the map: $e');
    }
  }

  // Determine if login is required based on business type
  bool _isLoginRequired(
      String businessName, String? businessType, String messageContext) {
    // Food items and restaurants don't require login
    if (messageContext.contains('food items businesses near you') ||
        messageContext.contains('restaurants') ||
        businessName.contains('Vimeet') ||
        businessName.contains('Tapri') ||
        businessName.contains('Bakery') ||
        businessName.contains('Dhaba') ||
        (businessType != null && businessType == "Food Items") ||
        (businessType != null && businessType == "Restaurant")) {
      return false;
    }

    // Only grocery stores and pharmacies require login
    return messageContext.contains('grocery stores') ||
        messageContext.contains('pharmacies') ||
        (businessType != null && businessType == "Grocery") ||
        (businessType != null && businessType == "Pharmacy");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetChat,
            tooltip: 'Reset conversation',
          ),
        ],
      ),
      body: _isInitializing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing AI Assistant...'),
                ],
              ),
            )
          : Column(
              children: [
                // Chat messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = _chatMessages[index];
                      final isUser = message['role'] == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                            left: isUser ? 64 : 0,
                            right: isUser ? 0 : 64,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: isUser
                              ? Text(
                                  message['message'] ?? '',
                                  style: TextStyle(
                                    color:
                                        isUser ? Colors.white : Colors.black87,
                                  ),
                                )
                              : _buildBusinessMessageContent(
                                  message['message'] ?? ''),
                        ),
                      );
                    },
                  ),
                ),

                // Quick reply buttons (only show when not typing)
                if (!_isTyping &&
                    _chatMessages.isNotEmpty &&
                    _chatMessages.last['role'] == 'assistant')
                  Container(
                    height: 50,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickReplyCategories.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            onPressed: () =>
                                _handleQuickReply(_quickReplyCategories[index]),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(_quickReplyCategories[index]),
                          ),
                        );
                      },
                    ),
                  ),

                // Typing indicator
                if (_isTyping)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Assistant is typing...',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
