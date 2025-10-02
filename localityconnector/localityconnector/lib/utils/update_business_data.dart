import '../services/firestore_service.dart';

/// Utility class to update business data in Firestore
class UpdateBusinessData {
  static final FirestoreService _firestoreService = FirestoreService.instance;

  /// Updates business categories for known businesses
  static Future<void> updateBusinessCategories() async {
    // Update business types based on business names
    Map<String, String> businessTypeMappings = {
      'Rohit Tapri': 'Restaurant',
      'Vimeet Canteen': 'Restaurant',
      'Vimeet Hostel Shop': 'Grocery',
      'Vishal General Store': 'Grocery',
      'Aniket Kirana': 'Grocery',
      'Metro Medical': 'Pharmacy',
    };

    for (var entry in businessTypeMappings.entries) {
      String businessName = entry.key;
      String businessType = entry.value;

      bool success = await _firestoreService.updateBusinessType(
          businessName, businessType);
      print(
          'Updated ${businessName} to type ${businessType}: ${success ? 'Success' : 'Failed'}');
    }
  }

  /// Adds mock location data to businesses
  static Future<void> updateBusinessLocations() async {
    // Sample coordinates for demonstration
    // These would ideally be real coordinates from Google Maps or similar
    Map<String, Map<String, double>> businessLocationMappings = {
      'Rohit Tapri': {'latitude': 18.815352, 'longitude': 73.289597},
      'Vimeet Canteen': {'latitude': 18.815230, 'longitude': 73.289823},
      'Vimeet Hostel Shop': {'latitude': 18.814952, 'longitude': 73.290210},
      'Vishal General Store': {'latitude': 18.815701, 'longitude': 73.289012},
      'Aniket Kirana': {'latitude': 18.814503, 'longitude': 73.289345},
      'Metro Medical': {'latitude': 18.815125, 'longitude': 73.289765},
    };

    for (var entry in businessLocationMappings.entries) {
      String businessName = entry.key;
      double latitude = entry.value['latitude']!;
      double longitude = entry.value['longitude']!;

      bool success = await _firestoreService.setBusinessCoordinates(
          businessName, latitude, longitude);
      print(
          'Updated ${businessName} location: ${success ? 'Success' : 'Failed'}');
    }
  }

  /// Run all updates
  static Future<void> updateAllBusinessData() async {
    await updateBusinessCategories();
    await updateBusinessLocations();
    print('All business data updates completed');
  }
}
