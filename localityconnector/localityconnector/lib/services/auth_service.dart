import '../models/database_helper.dart';
import '../models/user.dart';
import '../models/business.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  // User Authentication
  Future<User?> loginUser(String username, String password) async {
    return await _dbHelper.loginUser(username, password);
  }

  Future<bool> registerUser(User user) async {
    try {
      await _dbHelper.insertUser(user);
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  Future<bool> isUserEmailExists(String email) async {
    final user = await _dbHelper.getUserByEmail(email);
    return user != null;
  }

  // Google Authentication
  Future<User?> signInWithGoogle() async {
    try {
      // Display a message that this functionality is coming soon
      print("Google Sign In is currently under maintenance");

      // Add a small delay to make the UI feedback smoother
      await Future.delayed(const Duration(seconds: 1));

      // Instead of trying to sign in with Google and causing a 404 error,
      // we'll return null with a specific error message
      throw Exception(
          "The Google sign-in service is currently unavailable. We're working on implementing this feature.");
    } catch (e) {
      print('Google Sign In info: ${e.toString()}');
      rethrow; // Re-throw to let the UI layer handle the error message
    }
  }

  // Facebook Authentication
  Future<User?> signInWithFacebook() async {
    try {
      // Display a message that this functionality is coming soon
      print("Facebook Sign In is currently under maintenance");

      // Add a small delay to make the UI feedback smoother
      await Future.delayed(const Duration(seconds: 1));

      // Instead of trying to sign in with Facebook and causing potential errors,
      // we'll return null with a specific error message
      throw Exception(
          "The Facebook sign-in service is currently unavailable. We're working on implementing this feature.");
    } catch (e) {
      print('Facebook Sign In info: ${e.toString()}');
      rethrow; // Re-throw to let the UI layer handle the error message
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await _facebookAuth.logOut();
  }

  // Business Authentication
  Future<Business?> loginBusiness(String businessName, String password) async {
    return await _dbHelper.loginBusiness(businessName, password);
  }

  Future<Business?> loginBusinessWithEmail(
      String email, String password) async {
    return await _dbHelper.loginBusinessWithEmail(email, password);
  }

  Future<bool> registerBusiness(Business business) async {
    try {
      await _dbHelper.insertBusiness(business);
      return true;
    } catch (e) {
      print('Error registering business: $e');
      return false;
    }
  }

  Future<bool> isBusinessEmailExists(String email) async {
    final business = await _dbHelper.getBusinessByEmail(email);
    return business != null;
  }

  // Business Profile Management
  Future<bool> updateBusinessProfile(Business business) async {
    try {
      await _dbHelper.updateBusiness(business);
      return true;
    } catch (e) {
      print('Error updating business profile: $e');
      return false;
    }
  }

  Future<Business?> getBusinessById(int id) async {
    return await _dbHelper.getBusinessById(id);
  }

  // Location-based Services
  Future<List<Business>> findNearbyBusinesses(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    return await _dbHelper.findNearbyBusinesses(
        latitude, longitude, radiusInKm);
  }
}
