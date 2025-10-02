import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business.dart';
import 'location_service.dart';
import '../utils/geolocation_utils.dart';

class BusinessLocationService {
  static final BusinessLocationService instance =
      BusinessLocationService._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  BusinessLocationService._init();

  // Get businesses by category within a specified radius
  Future<List<Business>> getNearbyBusinesses({
    required double userLatitude,
    required double userLongitude,
    required String categoryName,
    double radiusInKm = 1.0,
  }) async {
    try {
      // Use the bounding box approach to narrow down initial query
      Map<String, double> boundingBox = GeolocationUtils.getBoundingBox(
        userLatitude,
        userLongitude,
        radiusInKm,
      );

      List<Business> businesses = [];

      // Try to get businesses with location filter first
      try {
        // Initial query with bounding box to reduce data transfer
        Query query = _firestore
            .collection('businesses')
            .where('latitude', isGreaterThanOrEqualTo: boundingBox['minLat'])
            .where('latitude', isLessThanOrEqualTo: boundingBox['maxLat']);

        // Execute query
        QuerySnapshot snapshot = await query.get();

        // Process each business and calculate exact distance for filtering
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Skip businesses without location data
          if (data['latitude'] == null || data['longitude'] == null) {
            continue;
          }

          double businessLat = data['latitude']?.toDouble() ?? 0.0;
          double businessLng = data['longitude']?.toDouble() ?? 0.0;

          // Additional longitude filter (can't do compound queries on different fields in Firestore)
          double minLon = boundingBox['minLon'] ?? 0.0;
          double maxLon = boundingBox['maxLon'] ?? 0.0;

          if ((businessLng < minLon) || (businessLng > maxLon)) {
            continue;
          }

          // Apply category filter here (case insensitive)
          if (categoryName.isNotEmpty) {
            String? businessType = data['business_type'] as String?;
            int? categoryId = data['category_id'] as int?;

            // Skip if business type doesn't match
            if (businessType == null) {
              continue;
            }

            bool matchesCategory = false;
            String categoryNameLower = categoryName.toLowerCase();
            String businessTypeLower = businessType.toLowerCase();

            // Check for different category types
            if (categoryName == 'Grocery') {
              matchesCategory = businessTypeLower.contains('grocery') ||
                  businessTypeLower.contains('supermarket') ||
                  businessTypeLower.contains('market') ||
                  categoryId == 1;
            } else if (categoryName == 'Pharmacy') {
              matchesCategory = businessTypeLower.contains('pharmacy') ||
                  businessTypeLower.contains('drug') ||
                  businessTypeLower.contains('medicine') ||
                  categoryId == 2;
            } else if (categoryName == 'Restaurant') {
              matchesCategory = businessTypeLower.contains('restaurant') ||
                  businessTypeLower.contains('food') ||
                  businessTypeLower.contains('cafe') ||
                  businessTypeLower.contains('dining') ||
                  categoryId == 3;
            } else if (categoryName == 'Education') {
              matchesCategory = businessTypeLower.contains('education') ||
                  businessTypeLower.contains('school') ||
                  businessTypeLower.contains('college') ||
                  categoryId == 4;
            } else if (categoryName == 'Food Items') {
              matchesCategory = businessTypeLower.contains('food') ||
                  businessTypeLower.contains('canteen') ||
                  businessTypeLower.contains('restaurant') ||
                  categoryId == 3;
            } else {
              // Exact match or contains for other categories
              matchesCategory = businessTypeLower == categoryNameLower ||
                  businessTypeLower.contains(categoryNameLower);
            }

            if (!matchesCategory) {
              continue;
            }
          }

          // Calculate exact distance between user and business
          double distance = GeolocationUtils.calculateDistance(
            userLatitude,
            userLongitude,
            businessLat,
            businessLng,
          );

          // Only include businesses within the specified radius
          if (distance <= radiusInKm) {
            // Add Firestore document ID and distance to the map
            data['id'] = data['local_id'] ?? int.tryParse(doc.id) ?? 0;
            data['distance'] = distance;

            // Create business object
            Business business = Business.fromMap(data);
            businesses.add(business);
          }
        }
      } catch (e) {
        print('Error with location-based query: $e');
        // Location-based query failed, will try fallback
      }

      // If no businesses found with location filtering, try fallback to category-only filtering
      if (businesses.isEmpty) {
        Query fallbackQuery = _firestore.collection('businesses');

        // Execute fallback query without category filter - we'll filter client-side
        QuerySnapshot fallbackSnapshot = await fallbackQuery.get();

        for (var doc in fallbackSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Apply category filter here for the fallback query
          if (categoryName.isNotEmpty) {
            String? businessType = data['business_type'] as String?;
            int? categoryId = data['category_id'] as int?;

            if (businessType == null) {
              continue;
            }

            bool matchesCategory = false;
            String categoryNameLower = categoryName.toLowerCase();
            String businessTypeLower = businessType.toLowerCase();

            // Check for different category types
            if (categoryName == 'Grocery') {
              matchesCategory = businessTypeLower.contains('grocery') ||
                  businessTypeLower.contains('supermarket') ||
                  businessTypeLower.contains('market') ||
                  categoryId == 1;
            } else if (categoryName == 'Pharmacy') {
              matchesCategory = businessTypeLower.contains('pharmacy') ||
                  businessTypeLower.contains('drug') ||
                  businessTypeLower.contains('medicine') ||
                  categoryId == 2;
            } else if (categoryName == 'Restaurant') {
              matchesCategory = businessTypeLower.contains('restaurant') ||
                  businessTypeLower.contains('food') ||
                  businessTypeLower.contains('cafe') ||
                  businessTypeLower.contains('dining') ||
                  categoryId == 3;
            } else if (categoryName == 'Education') {
              matchesCategory = businessTypeLower.contains('education') ||
                  businessTypeLower.contains('school') ||
                  businessTypeLower.contains('college') ||
                  categoryId == 4;
            } else if (categoryName == 'Food Items') {
              matchesCategory = businessTypeLower.contains('food') ||
                  businessTypeLower.contains('canteen') ||
                  businessTypeLower.contains('restaurant') ||
                  categoryId == 3;
            } else {
              // Exact match or contains for other categories
              matchesCategory = businessTypeLower == categoryNameLower ||
                  businessTypeLower.contains(categoryNameLower);
            }

            if (!matchesCategory) {
              continue;
            }
          }

          // Add Firestore document ID to the map
          data['id'] = data['local_id'] ?? int.tryParse(doc.id) ?? 0;

          // Add a dummy distance for UI display purposes
          data['distance'] =
              0.0; // Shown as "nearby" or we could use a default value

          // Create business object
          Business business = Business.fromMap(data);
          businesses.add(business);
        }
      }

      // Sort businesses by distance (closest first), or by name if distances are equal
      businesses.sort((a, b) {
        final distanceA = a.distance ?? double.infinity;
        final distanceB = b.distance ?? double.infinity;
        int distanceCompare = distanceA.compareTo(distanceB);

        // If distances are the same, sort by business name
        if (distanceCompare == 0) {
          return a.businessName.compareTo(b.businessName);
        }

        return distanceCompare;
      });

      // Add hardcoded grocery stores when Grocery category is selected
      if (categoryName == 'Grocery') {
        // Check if hardcoded businesses already exist in the list
        bool vishalGeneralStoreExists = businesses
            .any((business) => business.businessName == "Vishal General Store");

        bool lottaGeneralStoreExists = businesses
            .any((business) => business.businessName == "Lotta General Store");

        bool aniketKiranaExists = businesses
            .any((business) => business.businessName == "Aniket Kirana");

        bool hariNamKiranaExists = businesses
            .any((business) => business.businessName == "HariNam Kirana");

        // Add Vishal General Store if not exists
        if (!vishalGeneralStoreExists) {
          businesses.add(Business(
              id: 9,
              businessName: "Vishal General Store",
              businessType: "Grocery",
              businessDescription:
                  "General grocery store with daily necessities",
              businessAddress: "Dhamini, Khalapur, Raigad, Maharashtra",
              contactNumber: "",
              email: "vishalstore@gmail.com",
              password: "123456",
              longitude: 73.27575712390647,
              latitude: 18.817036731846635,
              categoryId: 1,
              averageRating: null,
              totalReviews: null,
              distance: 0.1));
        }

        // Add Lotta General Store if not exists
        if (!lottaGeneralStoreExists) {
          businesses.add(Business(
              id: 10,
              businessName: "Lotta General Store",
              businessType: "Grocery",
              businessDescription:
                  "Local grocery shop serving the neighborhood",
              businessAddress: "Dhamini, Khalapur, Maharashtra",
              contactNumber: "",
              email: "lottastore@gmail.com",
              password: "123456",
              longitude: 73.27500964972695,
              latitude: 18.81763470287621,
              categoryId: 1,
              averageRating: null,
              totalReviews: null,
              distance: 0.15));
        }

        // Add Aniket Kirana if not exists
        if (!aniketKiranaExists) {
          businesses.add(Business(
              id: 11,
              businessName: "Aniket Kirana",
              businessType: "Grocery",
              businessDescription:
                  "Family-owned grocery store with fresh produce",
              businessAddress: "Dhamini, Khalapur, Maharashtra",
              contactNumber: "",
              email: "aniketkirana@gmail.com",
              password: "123456",
              longitude: 73.27544366699958,
              latitude: 18.81717823664992,
              categoryId: 1,
              averageRating: null,
              totalReviews: null,
              distance: 0.18));
        }

        // Add HariNam Kirana if not exists
        if (!hariNamKiranaExists) {
          businesses.add(Business(
              id: 12,
              businessName: "HariNam Kirana",
              businessType: "Grocery",
              businessDescription:
                  "Traditional grocery store with wide selection",
              businessAddress: "Khumbhivali, Maharashtra",
              contactNumber: "",
              email: "harinamkirana@gmail.com",
              password: "123456",
              longitude: 73.26146824521275,
              latitude: 18.82281217056494,
              categoryId: 1,
              averageRating: null,
              totalReviews: null,
              distance: 0.25));
        }

        // Re-sort after adding hardcoded businesses
        businesses.sort((a, b) {
          final distanceA = a.distance ?? double.infinity;
          final distanceB = b.distance ?? double.infinity;
          return distanceA.compareTo(distanceB);
        });
      }

      // Add hardcoded pharmacy stores when Pharmacy category is selected
      if (categoryName == 'Pharmacy') {
        // Check if hardcoded businesses already exist in the list
        bool metroMedicalExists = businesses
            .any((business) => business.businessName == "Metro Medical");

        bool khumbhivaliMedicalExists = businesses.any(
            (business) => business.businessName == "Khumbhivali Medical Shop");

        // Add Metro Medical if not exists
        if (!metroMedicalExists) {
          businesses.add(Business(
              id: 15,
              businessName: "Metro Medical",
              businessType: "Pharmacy",
              businessDescription:
                  "Modern pharmacy offering a wide range of medicines and healthcare products",
              businessAddress: "Dhamini, Khalapur, Maharashtra",
              contactNumber: "",
              email: "metromedical@gmail.com",
              password: "123456",
              longitude: 73.27559385321833,
              latitude: 18.816934811518898,
              categoryId: 2,
              averageRating: null,
              totalReviews: null,
              distance: 0.22));
        }

        // Add Khumbhivali Medical Shop if not exists
        if (!khumbhivaliMedicalExists) {
          businesses.add(Business(
              id: 16,
              businessName: "Khumbhivali Medical Shop",
              businessType: "Pharmacy",
              businessDescription:
                  "Local pharmacy providing essential medications and health supplies",
              businessAddress: "Khumbhivali, Maharashtra",
              contactNumber: "",
              email: "khumbhivalimed@gmail.com",
              password: "123456",
              longitude: 73.26211099260537,
              latitude: 18.822873137516815,
              categoryId: 2,
              averageRating: null,
              totalReviews: null,
              distance: 0.35));
        }

        // Re-sort after adding hardcoded businesses
        businesses.sort((a, b) {
          final distanceA = a.distance ?? double.infinity;
          final distanceB = b.distance ?? double.infinity;
          return distanceA.compareTo(distanceB);
        });
      }

      // Add Vimeet Canteen to the results when Food Items category is selected
      if (categoryName == 'Food Items') {
        // Check if hardcoded businesses already exist in the list
        bool vimeetCanteenExists = businesses
            .any((business) => business.businessName == "Vimeet Canteen");

        bool vimeetHostelShopExists = businesses
            .any((business) => business.businessName == "Vimeet Hostel Shop");

        bool rohitTapriExists = businesses
            .any((business) => business.businessName == "Rohit Tapri");

        bool sanjayTapriExists = businesses
            .any((business) => business.businessName == "Sanjay Tapri");

        bool siyaBakeryExists = businesses
            .any((business) => business.businessName == "Siya Bakery");

        bool omDhabaExists =
            businesses.any((business) => business.businessName == "OmDhaba");

        // Add Vimeet Canteen if not exists
        if (!vimeetCanteenExists) {
          businesses.add(Business(
              id: 5,
              businessName: "Vimeet Canteen",
              businessType: "Food Items",
              businessDescription:
                  "Cafeteria serving meals and snacks to students and staff",
              businessAddress: "Vimeet Campus",
              contactNumber: "",
              email: "vimeetcanteen@gmail.com",
              password: "123456",
              longitude: 73.27102381093584,
              latitude: 18.82175489022846,
              categoryId: 5,
              averageRating: null,
              totalReviews: null,
              distance: 0.17));
        }

        // Add Vimeet Hostel Shop if not exists
        if (!vimeetHostelShopExists) {
          businesses.add(Business(
              id: 6,
              businessName: "Vimeet Hostel Shop",
              businessType: "Food Items",
              businessDescription: "Convenience store for hostel residents",
              businessAddress: "Girls Hostel Vimeet Campus",
              contactNumber: "",
              email: "vimeethostelshop@gmail.com",
              password: "123456",
              longitude: 73.2718681,
              latitude: 18.821721,
              categoryId: 5,
              averageRating: null,
              totalReviews: null,
              distance: 0.15));
        }

        // Add Rohit Tapri if not exists
        if (!rohitTapriExists) {
          businesses.add(Business(
              id: 7,
              businessName: "Rohit Tapri",
              businessType: "Food Items",
              businessDescription: "Tea stall with snacks and refreshments",
              businessAddress:
                  "In front of Vimeet Dhamini, Kahalpur, Maharashtra",
              contactNumber: "",
              email: "rohittapri@gmail.com",
              password: "123456",
              longitude: 73.27041060118721,
              latitude: 18.82177130388928,
              categoryId: 5,
              averageRating: null,
              totalReviews: null,
              distance: 0.22));
        }

        // Add Sanjay Tapri if not exists
        if (!sanjayTapriExists) {
          businesses.add(Business(
              id: 8,
              businessName: "Sanjay Tapri",
              businessType: "Food Items",
              businessDescription: "Local tea and snack stall",
              businessAddress: "Dhamini, Kahalpur, Maharashtra",
              contactNumber: "",
              email: "sanjaytapri@gmail.com",
              password: "123456",
              longitude: 73.27478996472767,
              latitude: 18.81805404203425,
              categoryId: 5,
              averageRating: null,
              totalReviews: null,
              distance: 0.28));
        }

        // Add Siya Bakery if not exists
        if (!siyaBakeryExists) {
          businesses.add(Business(
              id: 13,
              businessName: "Siya Bakery",
              businessType: "Food Items",
              businessDescription: "Fresh baked goods and pastries",
              businessAddress: "Dhamini, Kahalpur, Maharashtra",
              contactNumber: "",
              email: "siyabakery@gmail.com",
              password: "123456",
              longitude: 73.27544740910682,
              latitude: 18.8173170173419,
              categoryId: 5,
              averageRating: null,
              totalReviews: null,
              distance: 0.32));
        }

        // Add OmDhaba if not exists
        if (!omDhabaExists) {
          businesses.add(Business(
              id: 14,
              businessName: "OmDhaba",
              businessType: "Food Items",
              businessDescription:
                  "Traditional roadside eatery with authentic dishes",
              businessAddress: "Dhamini, Kahalpur, Maharashtra",
              contactNumber: "",
              email: "omdhaba@gmail.com",
              password: "123456",
              longitude: 73.27645270671975,
              latitude: 18.816891887388632,
              categoryId: 5,
              averageRating: null,
              totalReviews: null,
              distance: 0.35));
        }

        // Re-sort after adding hardcoded businesses
        businesses.sort((a, b) {
          final distanceA = a.distance ?? double.infinity;
          final distanceB = b.distance ?? double.infinity;
          return distanceA.compareTo(distanceB);
        });
      }

      return businesses;
    } catch (e) {
      print('Error getting nearby businesses: $e');
      return [];
    }
  }

  // Get businesses with multiple category filter
  Future<List<Business>> getBusinessesByCategories({
    required double userLatitude,
    required double userLongitude,
    required List<String> categoryNames,
    double radiusInKm = 1.0,
  }) async {
    if (categoryNames.isEmpty) {
      return getNearbyBusinesses(
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        categoryName: '',
        radiusInKm: radiusInKm,
      );
    }

    try {
      List<Business> allBusinesses = [];

      // Query businesses for each category
      for (String category in categoryNames) {
        List<Business> categoryBusinesses = await getNearbyBusinesses(
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          categoryName: category,
          radiusInKm: radiusInKm,
        );

        allBusinesses.addAll(categoryBusinesses);
      }

      // Remove duplicates (if a business belongs to multiple categories)
      final Map<int, Business> uniqueBusinesses = {};
      for (var business in allBusinesses) {
        if (business.id != null) {
          uniqueBusinesses[business.id!] = business;
        }
      }

      // Sort businesses by distance (closest first)
      List<Business> result = uniqueBusinesses.values.toList();
      result.sort((a, b) {
        final distanceA = a.distance ?? double.infinity;
        final distanceB = b.distance ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });

      return result;
    } catch (e) {
      print('Error getting businesses by categories: $e');
      return [];
    }
  }
}
