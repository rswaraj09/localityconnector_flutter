import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/business.dart';
import '../models/item.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService._init();

  // Collections
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get businessesCollection =>
      _firestore.collection('businesses');
  CollectionReference get itemsCollection => _firestore.collection('items');
  CollectionReference get reviewsCollection => _firestore.collection('reviews');
  CollectionReference get categoriesCollection =>
      _firestore.collection('categories');

  // User operations
  Future<String> insertUser(User user) async {
    try {
      // Convert int id to String for Firestore
      Map<String, dynamic> userData = user.toMap();
      if (userData['id'] != null) {
        userData['local_id'] = userData['id'];
        userData.remove('id');
      }

      DocumentReference docRef = await usersCollection.add(userData);
      return docRef.id;
    } catch (e) {
      print('Error inserting user to Firestore: $e');
      rethrow;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await usersCollection.get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Add Firestore document ID to the map
        data['id'] = data['local_id'] ?? int.tryParse(doc.id) ?? 0;
        return User.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting all users from Firestore: $e');
      return [];
    }
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      QuerySnapshot snapshot =
          await usersCollection.where('email', isEqualTo: email).limit(1).get();

      if (snapshot.docs.isEmpty) return null;

      Map<String, dynamic> data =
          snapshot.docs.first.data() as Map<String, dynamic>;
      // Add Firestore document ID to the map
      data['id'] =
          data['local_id'] ?? int.tryParse(snapshot.docs.first.id) ?? 0;
      return User.fromMap(data);
    } catch (e) {
      print('Error getting user by email from Firestore: $e');
      return null;
    }
  }

  Future<User?> loginUser(String username, String password) async {
    try {
      QuerySnapshot snapshot = await usersCollection
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      Map<String, dynamic> data =
          snapshot.docs.first.data() as Map<String, dynamic>;
      // Add Firestore document ID to the map
      data['id'] =
          data['local_id'] ?? int.tryParse(snapshot.docs.first.id) ?? 0;
      return User.fromMap(data);
    } catch (e) {
      print('Error logging in user from Firestore: $e');
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      // Find the user document by email or username
      QuerySnapshot snapshot;
      if (user.email != null && user.email!.isNotEmpty) {
        snapshot = await usersCollection
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
      } else {
        snapshot = await usersCollection
            .where('username', isEqualTo: user.username)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isEmpty) {
        print('User not found in Firestore');
        // If user not found, insert instead of update
        await insertUser(user);
        return;
      }

      // Found user document, update it
      String docId = snapshot.docs.first.id;

      // Convert int id to String for Firestore
      Map<String, dynamic> userData = user.toMap();
      if (userData['id'] != null) {
        userData['local_id'] = userData['id'];
        userData.remove('id');
      }

      await usersCollection.doc(docId).update(userData);
      print('User updated in Firestore with ID: $docId');
    } catch (e) {
      print('Error updating user in Firestore: $e');
      rethrow;
    }
  }

  // Business operations
  Future<String> insertBusiness(Business business) async {
    try {
      // Convert int id to String for Firestore
      Map<String, dynamic> businessData = business.toMap();
      if (businessData['id'] != null) {
        businessData['local_id'] = businessData['id'];
        businessData.remove('id');
      }

      DocumentReference docRef = await businessesCollection.add(businessData);
      return docRef.id;
    } catch (e) {
      print('Error inserting business to Firestore: $e');
      rethrow;
    }
  }

  Future<List<Business>> getAllBusinesses() async {
    try {
      QuerySnapshot snapshot = await businessesCollection.get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Add Firestore document ID to the map
        data['id'] = data['local_id'] ?? int.tryParse(doc.id) ?? 0;
        return Business.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting all businesses from Firestore: $e');
      return [];
    }
  }

  Future<Business?> getBusinessByLocalId(int localId) async {
    try {
      QuerySnapshot snapshot = await businessesCollection
          .where('local_id', isEqualTo: localId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      Map<String, dynamic> data =
          snapshot.docs.first.data() as Map<String, dynamic>;
      // Add Firestore document ID to the map
      data['id'] =
          data['local_id'] ?? int.tryParse(snapshot.docs.first.id) ?? 0;
      return Business.fromMap(data);
    } catch (e) {
      print('Error getting business by local ID from Firestore: $e');
      return null;
    }
  }

  Future<Business?> loginBusiness(String businessName, String password) async {
    try {
      QuerySnapshot snapshot = await businessesCollection
          .where('business_name', isEqualTo: businessName)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      Map<String, dynamic> data =
          snapshot.docs.first.data() as Map<String, dynamic>;
      // Add Firestore document ID to the map
      data['id'] =
          data['local_id'] ?? int.tryParse(snapshot.docs.first.id) ?? 0;
      return Business.fromMap(data);
    } catch (e) {
      print('Error logging in business from Firestore: $e');
      return null;
    }
  }

  Future<int> updateBusiness(Business business) async {
    try {
      // Find business by local_id
      QuerySnapshot snapshot = await businessesCollection
          .where('local_id', isEqualTo: business.id)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // If not found by local_id, try to find by name and email
        snapshot = await businessesCollection
            .where('business_name', isEqualTo: business.businessName)
            .where('email', isEqualTo: business.email)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isEmpty) return 0;

      // Convert int id to String for Firestore
      Map<String, dynamic> businessData = business.toMap();
      if (businessData['id'] != null) {
        businessData['local_id'] = businessData['id'];
        businessData.remove('id');
      }

      // Remove distance field as it's not needed in Firestore
      businessData.remove('distance');

      await businessesCollection
          .doc(snapshot.docs.first.id)
          .update(businessData);
      return 1; // Success
    } catch (e) {
      print('Error updating business in Firestore: $e');
      return 0;
    }
  }

  // Method to update just the business coordinates in real-time
  Future<int> updateBusinessLocation(
      int businessId, double latitude, double longitude,
      {String? businessEmail}) async {
    try {
      print(
          'Updating Firebase coordinates for business $businessId: lat=$latitude, lng=$longitude, email=$businessEmail');

      QuerySnapshot snapshot;

      // Try finding by email first if provided (most reliable for identifying the business)
      if (businessEmail != null && businessEmail.isNotEmpty) {
        print('Searching for business document by email: $businessEmail');
        snapshot = await businessesCollection
            .where('email', isEqualTo: businessEmail)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          String docId = snapshot.docs.first.id;
          print(
              'Found document with ID: $docId by email, updating coordinates...');

          await businessesCollection.doc(docId).update({
            'latitude': latitude,
            'longitude': longitude,
          });
          print(
              'Coordinates updated successfully for business with email: $businessEmail');
          return 1; // Success
        } else {
          print('No document found with email: $businessEmail');
        }
      }

      // If email search failed or wasn't provided, try by local_id
      print('Searching for business document by local_id: $businessId');
      snapshot = await businessesCollection
          .where('local_id', isEqualTo: businessId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No document found with local_id: $businessId');

        // Try finding by ID as a fallback
        print('Searching for business document by id: $businessId');
        snapshot = await businessesCollection
            .where('id', isEqualTo: businessId)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) {
          print('No document found with id: $businessId either');
          return 0;
        }
      }

      String docId = snapshot.docs.first.id;
      print('Found document with ID: $docId, updating coordinates...');

      // Update just the coordinates
      await businessesCollection.doc(docId).update({
        'latitude': latitude,
        'longitude': longitude,
      });
      print('Coordinates updated successfully');
      return 1; // Success
    } catch (e) {
      print('Error updating business location in Firestore: $e');
      return 0;
    }
  }

  // Method to force update or create business coordinates in Firebase
  Future<int> forceUpdateBusinessLocation(Business business) async {
    try {
      print(
          'Force updating business location in Firebase: id=${business.id}, name=${business.businessName}, email=${business.email}');

      // Try to find the business document by email first (most reliable)
      print('Searching for business document by email: ${business.email}');
      QuerySnapshot snapshot = await businessesCollection
          .where('email', isEqualTo: business.email)
          .limit(1)
          .get();

      // If not found by email, try by business name
      if (snapshot.docs.isEmpty) {
        print(
            'Business not found by email, trying by business name: ${business.businessName}');
        snapshot = await businessesCollection
            .where('business_name', isEqualTo: business.businessName)
            .limit(1)
            .get();

        // If still not found, try by local_id if available
        if (snapshot.docs.isEmpty && business.id != null) {
          print(
              'Business not found by name, trying by local_id: ${business.id}');
          snapshot = await businessesCollection
              .where('local_id', isEqualTo: business.id)
              .limit(1)
              .get();
        }
      }

      if (snapshot.docs.isEmpty) {
        print(
            'No existing business document found, creating new one in Firebase');
        // Create a new document with the business data
        Map<String, dynamic> businessData = business.toMap();
        if (businessData['id'] != null) {
          businessData['local_id'] = businessData['id'];
          businessData.remove('id');
        }

        DocumentReference docRef = await businessesCollection.add(businessData);
        print('Created new business document with ID: ${docRef.id}');
        return 1;
      } else {
        // Update existing document
        String docId = snapshot.docs.first.id;
        print('Found existing business document with ID: $docId');

        await businessesCollection.doc(docId).update({
          'latitude': business.latitude,
          'longitude': business.longitude,
        });

        print('Updated business location in existing document');
        return 1;
      }
    } catch (e) {
      print('Error force updating business location: $e');
      return 0;
    }
  }

  // Item operations
  Future<String> insertItem(Item item) async {
    try {
      // Convert int id to String for Firestore
      Map<String, dynamic> itemData = item.toMap();
      if (itemData['id'] != null) {
        itemData['local_id'] = itemData['id'];
        itemData.remove('id');
      }

      DocumentReference docRef = await itemsCollection.add(itemData);
      return docRef.id;
    } catch (e) {
      print('Error inserting item to Firestore: $e');
      rethrow;
    }
  }

  Future<List<Item>> getItemsByBusinessId(int businessId) async {
    try {
      QuerySnapshot snapshot = await itemsCollection
          .where('business_id', isEqualTo: businessId)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Add Firestore document ID to the map
        data['id'] = data['local_id'] ?? int.tryParse(doc.id) ?? 0;
        return Item.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting items by business ID from Firestore: $e');
      return [];
    }
  }

  Future<int> updateItem(Item item) async {
    try {
      // Find item by local_id
      QuerySnapshot snapshot = await itemsCollection
          .where('local_id', isEqualTo: item.id)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      // Convert int id to String for Firestore
      Map<String, dynamic> itemData = item.toMap();
      if (itemData['id'] != null) {
        itemData['local_id'] = itemData['id'];
        itemData.remove('id');
      }

      await itemsCollection.doc(snapshot.docs.first.id).update(itemData);
      return 1; // Success
    } catch (e) {
      print('Error updating item in Firestore: $e');
      return 0;
    }
  }

  Future<int> deleteItem(int itemId) async {
    try {
      // Find item by local_id
      QuerySnapshot snapshot = await itemsCollection
          .where('local_id', isEqualTo: itemId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      await itemsCollection.doc(snapshot.docs.first.id).delete();
      return 1; // Success
    } catch (e) {
      print('Error deleting item from Firestore: $e');
      return 0;
    }
  }

  Future<Business?> loginBusinessWithEmail(
      String email, String password) async {
    try {
      QuerySnapshot snapshot = await businessesCollection
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      Map<String, dynamic> data =
          snapshot.docs.first.data() as Map<String, dynamic>;
      // Add Firestore document ID to the map
      data['id'] =
          data['local_id'] ?? int.tryParse(snapshot.docs.first.id) ?? 0;
      return Business.fromMap(data);
    } catch (e) {
      print('Error logging in business with email from Firestore: $e');
      return null;
    }
  }

  // Update business type for existing businesses
  Future<bool> updateBusinessType(String businessName, String newType) async {
    try {
      // Find the business document by name
      QuerySnapshot snapshot = await businessesCollection
          .where('business_name', isEqualTo: businessName)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No business found with name: $businessName');
        return false;
      }

      // Update the document with the new business type
      String docId = snapshot.docs.first.id;
      await businessesCollection.doc(docId).update({
        'business_type': newType,
      });

      print('Updated business type for $businessName to $newType');
      return true;
    } catch (e) {
      print('Error updating business type: $e');
      return false;
    }
  }

  // Update business location with coordinates
  Future<bool> setBusinessCoordinates(
      String businessName, double latitude, double longitude) async {
    try {
      // Find the business document by name
      QuerySnapshot snapshot = await businessesCollection
          .where('business_name', isEqualTo: businessName)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No business found with name: $businessName');
        return false;
      }

      // Update the document with the new coordinates
      String docId = snapshot.docs.first.id;
      await businessesCollection.doc(docId).update({
        'latitude': latitude,
        'longitude': longitude,
      });

      print(
          'Updated location for $businessName: lat=$latitude, lng=$longitude');
      return true;
    } catch (e) {
      print('Error updating business location: $e');
      return false;
    }
  }
}
