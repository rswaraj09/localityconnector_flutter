import 'package:flutter/material.dart';
import 'package:localityconnector/services/jarvis_service.dart';
import 'package:localityconnector/services/voice_recognition_service.dart';
import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:localityconnector/services/location_service.dart';
import 'package:localityconnector/services/business_location_service.dart';
import 'package:localityconnector/models/business.dart';

class JarvisScreen extends StatefulWidget {
  const JarvisScreen({Key? key}) : super(key: key);

  @override
  State<JarvisScreen> createState() => _JarvisScreenState();
}

class _JarvisScreenState extends State<JarvisScreen>
    with SingleTickerProviderStateMixin {
  final JarvisService _jarvisService = JarvisService();
  final VoiceRecognitionService _voiceService = VoiceRecognitionService();
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // Add text-to-speech engine
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _enableVoice = true; // Control for voice responses

  // Voice input using Gemini
  bool _isListening = false;
  String _transcription = '';
  Timer? _listeningTimer;
  int _listeningPhase = 0;
  final List<String> _listeningDots = ['', '.', '..', '...'];

  bool _isInitialized = false;
  bool _isTyping = false;
  bool _isProcessing = false;
  bool _useGemini = true;
  String _status = "Initializing...";

  // Animation controller for the Jarvis animation
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Set up animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Initialize text-to-speech
    _initTts();

    // Initialize voice recognition service
    _initVoiceService();

    // Initialize Jarvis service
    _initializeJarvis();
  }

  // Initialize voice recognition service
  Future<void> _initVoiceService() async {
    try {
      await _voiceService.initialize();
    } catch (e) {
      print('Error initializing voice service: $e');
    }
  }

  // Initialize text-to-speech
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); // Slower speech rate for clarity
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Listen for TTS completion
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });
  }

  // Start Gemini-based voice input
  void _startListening() async {
    if (_isProcessing) return;

    setState(() {
      _isListening = true;
      _transcription = '';
      _listeningPhase = 0;
    });

    // Create a listening animation with dots
    _listeningTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && _isListening) {
        setState(() {
          _listeningPhase = (_listeningPhase + 1) % _listeningDots.length;
          _transcription = "Listening${_listeningDots[_listeningPhase]}";
        });
      } else {
        timer.cancel();
      }
    });

    try {
      // Use recent messages to help generate a more contextually relevant query
      List<String> recentMessages =
          _messages.take(6).map((msg) => "${msg.sender}: ${msg.text}").toList();

      // Add a placeholder for the current listening state
      recentMessages.add("User: Listening...");

      // Detect what type of intent the user might have
      final intent = await _voiceService.detectQueryIntent(
          recentMessages, "User is speaking to Jarvis assistant");

      // Generate a simulated voice query based on context
      final generatedQuery = await _voiceService.generateRealisticVoiceQuery(
          intent, recentMessages);

      if (mounted && _isListening) {
        // Show the generated query to the user
        setState(() {
          _isListening = false;
          _transcription = '';
        });

        // Cancel the animation timer
        _listeningTimer?.cancel();

        // Submit the generated query
        _handleSubmitted(generatedQuery);
      }
    } catch (e) {
      print('Error in voice recognition: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
          _transcription = '';
        });
        _listeningTimer?.cancel();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Voice recognition error: $e"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Stop listening
  void _stopListening() {
    _listeningTimer?.cancel();
    setState(() {
      _isListening = false;
      _transcription = '';
    });
  }

  Future<void> _initializeJarvis() async {
    try {
      setState(() {
        _status = "Connecting to Jarvis...";
      });

      final isRunning = await _jarvisService.initialize();

      if (isRunning) {
        setState(() {
          _isInitialized = true;
          _status = "Connected";

          // Add welcome message
          _messages.add(ChatMessage(
            text: "Hello, I'm Jarvis. How can I help you today?",
            sender: "Jarvis",
            isImage: false,
          ));

          // Speak welcome message
          if (_enableVoice) {
            _speakText("Hello, I'm Jarvis. How can I help you today?");
          }
        });
      } else {
        setState(() {
          _status = "Cannot connect to Jarvis API";

          // Add error message
          _messages.add(ChatMessage(
            text:
                "⚠️ Cannot connect to Jarvis API. Make sure the Python API is running on your machine.",
            sender: "System",
            isImage: false,
          ));
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error: $e";
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    _listeningTimer?.cancel();
    super.dispose();
  }

  // Method to speak text
  Future<void> _speakText(String text) async {
    if (text.isEmpty) return;

    // Stop any ongoing speech
    if (_isSpeaking) {
      await _flutterTts.stop();
    }

    setState(() {
      _isSpeaking = true;
    });

    await _flutterTts.speak(text);
  }

  // Method to stop speaking
  Future<void> _stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();

    // Stop any ongoing speech when user submits new query
    await _stopSpeaking();

    // Add user message to chat
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        sender: "You",
        isImage: false,
      ));
      _isTyping = true;
      _isProcessing = true;
    });

    // Start animation
    _animationController.repeat();

    // Scroll to bottom after adding the message
    _scrollToBottom();

    try {
      // Check for special commands first
      if (_handleSpecialCommands(text)) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Process query through Jarvis service
      final response = await _jarvisService.processQuery(text,
          enhanceWithGemini: _useGemini);

      setState(() {
        _isProcessing = false;

        if (response['status'] == 'success') {
          // If query was enhanced by Gemini, add an indicator message
          if (response['enhanced'] == true) {
            _messages.add(ChatMessage(
              text:
                  "Gemini refined your query to: \"${response['processed_query']}\"",
              sender: "System",
              isEnhanced: true,
            ));
          }

          // Add Jarvis response
          _messages.add(ChatMessage(
            text: response['response'],
            sender: "Jarvis",
            isImage: false,
          ));

          // Speak the response
          if (_enableVoice) {
            _speakText(response['response']);
          }
        } else {
          // Add error message
          _messages.add(ChatMessage(
            text: "Error: ${response['response']}",
            sender: "System",
            isImage: false,
          ));
        }

        _isTyping = false;
      });

      // Stop animation
      _animationController.stop();
      _animationController.reset();

      // Scroll to bottom after adding the response
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _isTyping = false;

        // Add error message
        _messages.add(ChatMessage(
          text: "Error: $e",
          sender: "System",
          isImage: false,
        ));
      });

      // Stop animation
      _animationController.stop();
      _animationController.reset();

      // Scroll to bottom after adding the error message
      _scrollToBottom();
    }
  }

  // Handle special commands
  bool _handleSpecialCommands(String text) {
    final lowerText = text.toLowerCase().trim();

    // Check for nearby shops command with many variations
    if (lowerText == 'nearby shops' ||
        lowerText.contains('nearby shop') ||
        lowerText.contains('shops near') ||
        lowerText.contains('stores near') ||
        lowerText.contains('find shop') ||
        lowerText.contains('locate shop') ||
        lowerText.contains('find store') ||
        lowerText.contains('grocery') ||
        lowerText.contains('show me shop') ||
        lowerText.contains('show me store')) {
      _showNearbyShops();
      return true;
    }

    // Add other special commands here if needed

    return false;
  }

  // Show nearby shops
  void _showNearbyShops() async {
    // Add a response message
    setState(() {
      _messages.add(ChatMessage(
        text: "Here are the grocery stores near you:",
        sender: "Jarvis",
        isImage: false,
      ));
    });

    // Speak the response if voice is enabled
    if (_enableVoice) {
      _speakText("Here are the grocery stores near you");
    }

    // Add loading message
    int loadingMessageIndex = _messages.length;
    setState(() {
      _messages.add(ChatMessage(
        text: "Loading nearby shops...",
        sender: "Jarvis",
        isImage: false,
      ));
    });

    // Import the necessary services and models
    final locationService = LocationService();
    final businessLocationService = BusinessLocationService.instance;

    try {
      // Get current location
      final position = await locationService.getCurrentLocation();

      if (position != null) {
        // Get nearby grocery stores
        final businesses = await businessLocationService.getNearbyBusinesses(
          userLatitude: position.latitude,
          userLongitude: position.longitude,
          categoryName: 'Grocery',
          radiusInKm: 1.0,
        );

        // Remove loading message
        if (mounted) {
          setState(() {
            if (loadingMessageIndex < _messages.length) {
              _messages.removeAt(loadingMessageIndex);
            }
          });
        }

        // Display businesses
        if (businesses.isNotEmpty) {
          for (var business in businesses) {
            String message = """
Name: ${business.businessName}
Address: ${business.businessAddress}
Longitude: ${business.longitude}
Latitude: ${business.latitude}
""";
            setState(() {
              _messages.add(ChatMessage(
                text: message,
                sender: "Jarvis",
                isImage: false,
              ));
            });
          }

          setState(() {
            _messages.add(ChatMessage(
              text:
                  "You can tap on 'Locate on map' to see these stores on a map.",
              sender: "Jarvis",
              isImage: false,
            ));
          });
        } else {
          setState(() {
            _messages.add(ChatMessage(
              text: "No grocery stores found nearby.",
              sender: "Jarvis",
              isImage: false,
            ));
          });
        }
      } else {
        // Remove loading message
        if (mounted) {
          setState(() {
            if (loadingMessageIndex < _messages.length) {
              _messages.removeAt(loadingMessageIndex);
            }
          });
        }

        setState(() {
          _messages.add(ChatMessage(
            text:
                "Could not get your current location. Please check your location settings.",
            sender: "Jarvis",
            isImage: false,
          ));
        });
      }
    } catch (e) {
      // Remove loading message
      if (mounted) {
        setState(() {
          if (loadingMessageIndex < _messages.length) {
            _messages.removeAt(loadingMessageIndex);
          }
        });
      }

      setState(() {
        _messages.add(ChatMessage(
          text: "Error finding nearby shops: $e",
          sender: "Jarvis",
          isImage: false,
        ));
      });
    }

    // Scroll to bottom
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Clear Chat"),
          content:
              const Text("Are you sure you want to clear this conversation?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _jarvisService.clearConversation();

                // Stop any ongoing speech
                await _stopSpeaking();

                setState(() {
                  _messages.clear();
                  _messages.add(ChatMessage(
                    text: "Conversation cleared. How can I help you?",
                    sender: "Jarvis",
                    isImage: false,
                  ));
                });

                // Speak the response
                if (_enableVoice) {
                  _speakText("Conversation cleared. How can I help you?");
                }
              },
              child: const Text("Clear"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jarvis Assistant"),
        actions: [
          // Toggle for voice output
          Tooltip(
            message:
                _enableVoice ? "Voice output is ON" : "Voice output is OFF",
            child: IconButton(
              icon: Icon(
                _enableVoice ? Icons.volume_up : Icons.volume_off,
                color: _enableVoice ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _enableVoice = !_enableVoice;
                  if (!_enableVoice) {
                    _stopSpeaking();
                  }
                });
              },
            ),
          ),

          // Toggle for Gemini enhancement
          Tooltip(
            message: _useGemini
                ? "Gemini enhancement is ON"
                : "Gemini enhancement is OFF",
            child: Switch(
              value: _useGemini,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  _useGemini = value;
                });
              },
            ),
          ),

          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
            tooltip: "Clear chat",
          ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          if (!_isInitialized)
            Container(
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    _status,
                    style: TextStyle(color: Colors.amber.shade900),
                  ),
                ],
              ),
            ),

          // Currently speaking indicator
          if (_isSpeaking)
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                children: [
                  Icon(Icons.volume_up, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    "Jarvis is speaking...",
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.stop, size: 16),
                    color: Colors.blue.shade700,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _stopSpeaking,
                  ),
                ],
              ),
            ),

          // Currently listening indicator
          if (_isListening)
            Container(
              color: Colors.green.shade50,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                children: [
                  Icon(Icons.mic, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _transcription.isEmpty
                          ? "Listening..."
                          : "I heard: $_transcription",
                      style: TextStyle(color: Colors.green.shade700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop, size: 16),
                    color: Colors.green.shade700,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _stopListening,
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          // Jarvis animation (while typing)
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Jarvis is thinking",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

          // Input field
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Voice input button with animation
                AvatarGlow(
                  animate: _isListening,
                  glowColor: Colors.blue,
                  endRadius: 25.0,
                  duration: const Duration(milliseconds: 2000),
                  repeatPauseDuration: const Duration(milliseconds: 100),
                  repeat: true,
                  child: IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : null,
                    ),
                    onPressed: _isProcessing
                        ? null
                        : () {
                            if (_isListening) {
                              _stopListening();
                            } else {
                              _startListening();
                            }
                          },
                    tooltip: _isListening ? "Stop listening" : "Voice input",
                  ),
                ),

                // Text input field
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "Ask Jarvis something...",
                      border: InputBorder.none,
                    ),
                    enabled: !_isProcessing && !_isListening,
                    onSubmitted: _isProcessing ? null : _handleSubmitted,
                  ),
                ),

                // Send button
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: (_isProcessing ||
                          _isListening ||
                          _textController.text.isEmpty)
                      ? null
                      : () => _handleSubmitted(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.sender == "You";
    final isSystem = message.sender == "System";
    final isJarvis = message.sender == "Jarvis";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar for non-user messages
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 12.0),
              child: CircleAvatar(
                backgroundColor: isSystem ? Colors.amber : Colors.blue,
                child: Text(
                  isSystem ? "S" : "J",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

          // Message content
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.blue.shade100
                    : isSystem
                        ? (message.isEnhanced == true
                            ? Colors.green.shade50
                            : Colors.amber.shade50)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message sender
                  Text(
                    message.sender,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUser
                          ? Colors.blue.shade800
                          : isSystem
                              ? Colors.amber.shade800
                              : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4.0),

                  // Message text
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isSystem && !message.isEnhanced
                          ? Colors.amber.shade900
                          : Colors.black87,
                      fontStyle: isSystem && message.isEnhanced
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),

                  // Action buttons for non-user messages
                  if (!isUser)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Speak text button (only for Jarvis messages)
                          if (isJarvis && _enableVoice)
                            IconButton(
                              icon: Icon(
                                  _isSpeaking ? Icons.stop : Icons.volume_up,
                                  size: 16),
                              onPressed: () {
                                if (_isSpeaking) {
                                  _stopSpeaking();
                                } else {
                                  _speakText(message.text);
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: Colors.blue,
                            ),

                          // Copy button
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: message.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Copied to clipboard"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Avatar for user messages
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 12.0),
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  "You",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final String sender;
  final bool isImage;
  final bool isEnhanced;

  ChatMessage({
    required this.text,
    required this.sender,
    this.isImage = false,
    this.isEnhanced = false,
  });
}
