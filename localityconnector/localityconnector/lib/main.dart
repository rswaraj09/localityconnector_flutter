import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'signup_page.dart';
import 'signin.dart';
import 'models/database_helper.dart';
import 'models/user.dart';
import 'models/business.dart';
import 'services/gemini_service.dart';
import 'services/chatbot_service.dart';
import 'services/jarvis_service.dart';
import 'screens/jarvis_screen.dart';
import 'widgets/app_layout.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures async runs before runApp()

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");

    // Print Firebase options for debugging
    final FirebaseOptions options = DefaultFirebaseOptions.currentPlatform;
    print("🔑 Firebase project ID: ${options.projectId}");
    print("🔑 Firebase API key: ${options.apiKey}");

    // Save SHA-1 instructions to a file
    if (!kIsWeb) {
      try {
        final directory = await getExternalStorageDirectory();
        final file = File('${directory?.path}/firebase_setup_help.txt');

        await file.writeAsString('''
FIREBASE SETUP INSTRUCTIONS
==========================

To fix Google Sign-In, you need to add your SHA-1 certificate fingerprint to Firebase:

1. Get your SHA-1 fingerprint:
   - Open Command Prompt as administrator
   - Navigate to your project directory: cd ${directory?.path.split('/Android')[0]}
   - Run: cd android && ./gradlew signingReport
   - Look for "SHA1:" under "Variant: debug"

2. Add SHA-1 to Firebase:
   - Go to Firebase Console: https://console.firebase.google.com/
   - Open your project: ${options.projectId}
   - Click ⚙️ (Settings) > Project Settings
   - Under "Your apps", find your Android app
   - Add the SHA-1 fingerprint
   - Download new google-services.json and replace it in android/app/

3. Rebuild the app:
   - Run: flutter clean
   - Run: flutter pub get
   - Run: flutter run
''');

        print("📝 Saved Firebase setup help to: ${file.path}");
      } catch (e) {
        print("⚠️ Could not create help file: $e");
      }
    }

    // Initialize Gemini service
    await GeminiService().initialize();

    // Initialize Chatbot service
    await ChatbotService().initialize();
    print("✅ AI Chatbot Assistant initialized successfully");

    // Initialize Jarvis service (note: this will not block app startup if Jarvis API is not running)
    try {
      final isRunning = await JarvisService().initialize();
      if (isRunning) {
        print("✅ Jarvis AI Assistant connected successfully");
      } else {
        print("⚠️ Jarvis AI Assistant API is not running");
      }
    } catch (e) {
      print("⚠️ Failed to initialize Jarvis: $e");
    }

    // Web-specific initialization
    if (kIsWeb) {
      print("✅ Web platform detected - using in-memory database");

      // Add some sample data for web demo
      try {
        // Add a sample user
        await DatabaseHelper.instance.insertUser(User(
            username: "demouser",
            email: "demo@example.com",
            password: "password123",
            address: "123 Main St, Anytown, USA"));

        // Add a sample business
        await DatabaseHelper.instance.insertBusiness(Business(
            businessName: "Demo Business",
            businessType: "Retail",
            businessDescription: "A demo business for testing",
            businessAddress: "456 Market St, Anytown, USA",
            contactNumber: "555-123-4567",
            email: "business@example.com",
            password: "business123",
            latitude: 37.7749,
            longitude: -122.4194));

        print("✅ Sample data added to in-memory database");
      } catch (e) {
        print("⚠️ Error adding sample data: $e");
      }
    } else {
      // Native platform initialization
      try {
        final db = await DatabaseHelper.instance.database;
        print("✅ Database initialized successfully");

        // Fetch and print users and businesses to check if database is connected
        List<User> users = await DatabaseHelper.instance.getAllUsers();
        print("👤 Users in Database: ${users.length} users found");

        List<Business> businesses =
            await DatabaseHelper.instance.getAllBusinesses();
        print(
            "🏢 Businesses in Database: ${businesses.length} businesses found");
      } catch (e) {
        print("⚠️ Database Error: $e");
      }
    }

    // Initialize database helper with Firebase
    await DatabaseHelper.instance.initFirebase();
  } catch (e) {
    print("⚠️ Setup Error: $e");
  }

  // Initialize database
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;

  // Print database contents
  await dbHelper.printDatabaseContents();

  runApp(const LocalityConnectorApp());
}

class LocalityConnectorApp extends StatelessWidget {
  const LocalityConnectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locality Connector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/signup': (context) => const SignupPage(),
        '/signin': (context) => const SignInPage(isBusiness: false),
        '/signin_business': (context) => const SignInPage(isBusiness: true),
        // Routes for screens will be built dynamically using MaterialPageRoute
        // because they need parameters (business or user objects)
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  bool _isLoading = false;

  Future<void> _resetDatabase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await dbHelper.deleteDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database reset successfully. Please restart the app.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting database: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('Locality Connector'),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy, color: Colors.white),
            tooltip: 'Jarvis AI Assistant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JarvisScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://static.vecteezy.com/system/resources/previews/022/732/731/non_2x/global-network-connection-world-map-point-and-line-composition-concept-of-global-business-illustration-vector.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  color: Colors.black.withOpacity(0.6),
                ),
                const Positioned(
                  top: 100,
                  left: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WELCOME TO LOCALITY CONNECTOR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'EXPLORE AND NAVIGATE THE WORLD',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Text(
                    'Get Started with Locality Connector',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(context, 'Sign Up', Colors.orange, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      }),
                      const SizedBox(width: 20),
                      _buildButton(context, 'Sign In', Colors.blue, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SignInPage(isBusiness: false),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Why Choose Locality Connector?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      _buildFeature(
                          'Find Local Shops',
                          'Discover shops in your area that offer essential products and services just a click away.',
                          Colors.green),
                      _buildFeature(
                          'Access to Healthcare',
                          'Easily locate nearby hospitals and clinics for all your medical needs.',
                          Colors.blue),
                      _buildFeature(
                          'Support Local Vendors',
                          'Connect with local vendors and support small businesses in your community.',
                          Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'About Locality Connector',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Locality Connector is a platform designed to bridge the gap between communities and essential services. We help people find local shops, healthcare providers, and vendors with ease, improving access to vital resources in underserved areas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black,
              child: const Center(
                child: Text(
                  '\u00a9 2024 Locality Connector. All Rights Reserved.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Database Troubleshooting',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _resetDatabase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Reset Database'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return AppLayout(
      contextData: const {},
      showChatBubble: true,
      child: scaffold,
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildFeature(String title, String description, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
