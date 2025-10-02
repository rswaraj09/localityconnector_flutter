import 'package:flutter/material.dart';
import 'package:localityconnector/models/database_helper.dart';
import 'package:localityconnector/models/user.dart' as app;
import 'package:localityconnector/models/business.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localityconnector/widgets/google_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // Import Facebook Auth
import 'signin.dart'; // Import SignIn Page

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isUserSignup = true;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessLocationController = TextEditingController();

  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signup() async {
    // Validate required fields
    if (isUserSignup) {
      if (_usernameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _addressController.text.isEmpty) {
        _showErrorDialog("Please fill all required fields");
        return;
      }
    } else {
      if (_businessNameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _businessLocationController.text.isEmpty) {
        _showErrorDialog("Please fill all required fields");
        return;
      }
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      _showErrorDialog("Please enter a valid email address");
      return;
    }

    // Validate password length
    if (_passwordController.text.length < 6) {
      _showErrorDialog("Password must be at least 6 characters long");
      return;
    }

    try {
      if (isUserSignup) {
        // Create User object
        final user = app.User(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          address: _addressController.text,
        );

        // Insert User Data
        int id = await dbHelper.insertUser(user);

        if (id > 0) {
          print("User registered: ID $id");
          List<app.User> users = await dbHelper.getAllUsers();
          print("User Database: $users");
          _showSuccessDialog("User registered successfully!", isUser: true);
        }
      } else {
        // Create Business object
        final business = Business(
          businessName: _businessNameController.text,
          businessType: "Local Business", // Default value
          businessDescription: "Business description", // Default value
          businessAddress: _businessLocationController.text,
          contactNumber: "", // Default empty value
          email: _emailController.text,
          password: _passwordController.text,
          longitude: 0.0, // Default value
          latitude: 0.0, // Default value
          distance: 0.0, // Default distance value
        );

        // Insert Business Data
        int id = await dbHelper.insertBusiness(business);

        if (id > 0) {
          print("Business registered: ID $id");
          List<Business> businesses = await dbHelper.getAllBusinesses();
          print("Business Database: $businesses");
          _showSuccessDialog("Business registered successfully in Firebase!",
              isUser: false);
        }
      }
    } catch (e) {
      _showErrorDialog("Registration failed: ${e.toString()}");
    }
  }

  // Method to log messages to a file for debugging
  Future<void> logToFile(String message) async {
    try {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory?.path}/google_signin_log.txt');
      final timestamp = DateTime.now().toString();
      await file.writeAsString('[$timestamp] $message\n',
          mode: FileMode.append);
      print("DEBUG: Logged to file: $message");
    } catch (e) {
      print("DEBUG: Failed to log to file: $e");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      print("DEBUG: Starting Google Sign-in process");
      await logToFile("Starting Google Sign-in process");

      // Check Firebase initialization status
      print("DEBUG: Checking Firebase initialization status");
      await logToFile("Checking Firebase initialization status");
      try {
        final firebaseApps = FirebaseAuth.instance.app.options;
        print("DEBUG: Firebase initialized: ${firebaseApps != null}");
        await logToFile(
            "Firebase initialized with project ID: ${firebaseApps.projectId}");
      } catch (e) {
        print("DEBUG: Firebase initialization check error: $e");
        await logToFile("Firebase initialization check error: $e");
      }

      // Initialize GoogleSignIn without explicit client ID
      final GoogleSignIn googleSignIn = GoogleSignIn();

      print("DEBUG: GoogleSignIn initialized using default configurations");
      await logToFile("GoogleSignIn initialized with default settings");

      // Attempt to sign in with Google
      print("DEBUG: Calling googleSignIn.signIn()");
      await logToFile("Calling googleSignIn.signIn()");
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (account == null) {
        // User canceled the sign-in process
        print("DEBUG: Google sign-in was canceled by user (account is null)");
        await logToFile(
            "Google sign-in was canceled by user (account is null)");
        return;
      }

      print(
          "DEBUG: Got Google account: ${account.email}, ${account.displayName}");
      await logToFile(
          "Got Google account: ${account.email}, ${account.displayName}");

      try {
        print("DEBUG: Getting authentication tokens");
        await logToFile("Getting authentication tokens");
        final GoogleSignInAuthentication authentication =
            await account.authentication;

        print(
            "DEBUG: Auth tokens - Access token exists: ${authentication.accessToken != null}, ID token exists: ${authentication.idToken != null}");
        await logToFile(
            "Auth tokens - Access token exists: ${authentication.accessToken != null}, ID token exists: ${authentication.idToken != null}");

        // Create credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: authentication.accessToken,
          idToken: authentication.idToken,
        );

        print(
            "DEBUG: Created Firebase credential, attempting sign-in with Firebase");
        await logToFile(
            "Created Firebase credential, attempting sign-in with Firebase");

        // Sign in with Firebase
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          print(
              "DEBUG: Google sign-in successful: ${user.displayName}, ${user.email}");
          await logToFile(
              "Google sign-in successful: ${user.displayName}, ${user.email}");

          // Check if user already exists in the database
          final existingUsers = await dbHelper.getAllUsers();
          final userExists = existingUsers.any((u) => u.email == user.email);

          if (!userExists) {
            // Create a new user entry in the database
            final newUser = app.User(
              username: user.displayName ?? 'Google User',
              email: user.email ?? '',
              password: '', // Google users don't need a local password
              address: '', // Address can be updated later
            );

            int id = await dbHelper.insertUser(newUser);
            print("DEBUG: Google user added to database with ID: $id");
            await logToFile("Google user added to database with ID: $id");
          } else {
            print("DEBUG: User already exists in database");
            await logToFile("User already exists in database");
          }

          _showSuccessDialog("Google sign-in successful!", isUser: true);
        }
      } catch (firebaseError) {
        print("DEBUG: Firebase authentication error: $firebaseError");
        print("DEBUG: Error details: ${firebaseError.toString()}");
        await logToFile(
            "Firebase authentication error: ${firebaseError.toString()}");

        String errorMessage =
            _getReadableErrorMessage(firebaseError.toString());
        print("DEBUG: User-friendly error message: $errorMessage");
        await logToFile("User-friendly error message: $errorMessage");

        _showErrorDialog("Authentication failed: $errorMessage");
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print("DEBUG: Google sign-in error: $e");
      print("DEBUG: Error type: ${e.runtimeType}");
      print("DEBUG: Error details: ${e.toString()}");
      await logToFile("Google sign-in error: ${e.toString()}");
      await logToFile("Error type: ${e.runtimeType}");

      String errorMessage = _getReadableErrorMessage(e.toString());
      print("DEBUG: User-friendly error message: $errorMessage");
      await logToFile("User-friendly error message: $errorMessage");

      _showErrorDialog("Google sign-in failed: $errorMessage");
    }
  }

  String _getReadableErrorMessage(String errorMessage) {
    // Print the raw error for debugging
    print("DEBUG: Raw error message: $errorMessage");

    // Convert technical error messages to user-friendly messages
    if (errorMessage.contains('network_error') ||
        errorMessage.contains('NetworkError')) {
      return "Network error. Please check your internet connection.";
    } else if (errorMessage.contains('popup_closed') ||
        errorMessage.contains('popup_blocked')) {
      return "Sign-in process was interrupted. Please try again.";
    } else if (errorMessage.contains('cancelled') ||
        errorMessage.contains('canceled')) {
      return "Sign-in was cancelled.";
    } else if (errorMessage.contains('ERROR_INVALID_CREDENTIAL') ||
        errorMessage.contains('invalid-credential')) {
      return "Invalid credentials. Please try again.";
    } else if (errorMessage
        .contains('account-exists-with-different-credential')) {
      return "An account already exists with the same email but different sign-in credentials.";
    } else if (errorMessage.contains('developer_error') ||
        errorMessage.contains('10')) {
      return "Google Sign-In configuration error. Please contact support.";
    } else if (errorMessage.contains('sign_in_failed') ||
        errorMessage.contains('sign_in_canceled')) {
      return "Google Sign-In failed. Please try again.";
    } else if (errorMessage.contains('12500')) {
      return "Google Play Services error. Please update Google Play Services on your device.";
    } else if (errorMessage.contains('12501')) {
      return "The user canceled the sign-in flow.";
    } else if (errorMessage.contains('12502')) {
      return "The client attempted to connect to the service but the user is not signed in.";
    } else if (errorMessage.contains('oauth_client')) {
      return "Missing or invalid OAuth client ID in the Firebase configuration.";
    } else if (errorMessage.contains('SHA-1') ||
        errorMessage.contains('SHA1')) {
      return "App not properly registered with Firebase. Please contact support.";
    }

    // Return a simplified error message if we can't identify the specific error
    return "An error occurred during sign-in. Please try again later.";
  }

  Future<void> _signInWithFacebook() async {
    // Firebase Facebook Authentication commented out for now
    _showErrorDialog("Facebook sign-in is temporarily disabled");
  }

  void _showSuccessDialog(String message, {required bool isUser}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignInPage(isBusiness: !isUser)));
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allow the screen to resize when keyboard appears
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Sign Up",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () => setState(() => isUserSignup = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isUserSignup ? Colors.blue : Colors.orange,
                        ),
                        child: const Text("Sign Up as User",
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () => setState(() => isUserSignup = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              !isUserSignup ? Colors.blue : Colors.orange,
                        ),
                        child: const Text("Sign Up as Business",
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                isUserSignup ? buildUserForm() : buildBusinessForm(),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    isUserSignup ? "Sign Up as User" : "Sign Up as Business",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(color: Colors.white54, thickness: 1),
                const SizedBox(height: 10),
                // Google Sign-In Button
                GoogleSignInButton(
                  onPressed: _signInWithGoogle,
                ),
                const SizedBox(height: 10),
                // Facebook Sign-In Button
                ElevatedButton.icon(
                  onPressed: _signInWithFacebook,
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_%282019%29.png/1200px-Facebook_Logo_%282019%29.png',
                    height: 24,
                    width: 24,
                  ),
                  label: const Text('Sign in with Facebook'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2), // Facebook blue
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 20),
                // Already have an account link
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SignInPage(isBusiness: !isUserSignup)));
                  },
                  child: const Text(
                    "Already have an account? Sign in here",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                // Add extra padding at the bottom for keyboard
                SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom > 0
                        ? 200
                        : 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUserForm() {
    return Column(
      children: [
        buildTextField("Username", _usernameController),
        buildTextField("Email", _emailController),
        buildTextField("Password", _passwordController, isPassword: true),
        buildTextField("Address", _addressController),
      ],
    );
  }

  Widget buildBusinessForm() {
    return Column(
      children: [
        buildTextField("Business Name", _businessNameController),
        buildTextField("Email", _emailController),
        buildTextField("Password", _passwordController, isPassword: true),
        buildTextField("Business Location", _businessLocationController),
      ],
    );
  }

  Widget buildTextField(String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
