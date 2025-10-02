import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'business.dart';
import 'user.dart';
import 'item.dart';
import '../services/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';

/// A helper class for database operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // In-memory storage for web platform
  static final List<User> _webUsers = [];
  static final List<Business> _webBusinesses = [];
  static int _nextUserId = 1;
  static int _nextBusinessId = 1;
  static final List<Item> _webItems = [];
  static int _nextItemId = 1;
  static final List<Map<String, dynamic>> _webReviews = [];
  static int _nextReviewId = 1;

  // Flag to check if we're running on web
  final bool isWebPlatform = kIsWeb;

  // Flag to use Firestore when available
  bool _useFirestore = false;

  DatabaseHelper._init();

  // Initialize and check Firebase availability
  Future<void> initFirebase() async {
    try {
      // Check if Firebase is initialized
      if (Firebase.apps.isNotEmpty) {
        _useFirestore = true;
        print("Using Firestore for persistent storage");
      }
    } catch (e) {
      print("Firestore not available: $e");
      _useFirestore = false;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Try to initialize Firebase if not done yet
    await initFirebase();

    if (isWebPlatform) {
      // Return a dummy database for web
      print("Using in-memory database for web platform");
      return Future.value(null as Database);
    }

    _database = await _initDB('locality_connector.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (isWebPlatform) {
      // Return dummy for web
      return Future.value(null as Database);
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5, // Incremented version for updating the businesses table
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Add new tables
      await _addReviewsTable(db);
      await _addCategoriesTable(db);
      await _addUserPreferencesTable(db);
    }

    if (oldVersion < 5) {
      // Update businesses table if needed
      await _updateBusinessesTable(db);
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        address TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS businesses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_name TEXT NOT NULL UNIQUE,
        business_type TEXT,
        business_description TEXT,
        business_address TEXT NOT NULL,
        contact_number TEXT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        longitude REAL,
        latitude REAL,
        category_id INTEGER,
        average_rating REAL DEFAULT 0,
        total_reviews INTEGER DEFAULT 0,
        distance REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        item_price REAL NOT NULL,
        item_description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (business_id) REFERENCES businesses (id)
      )
    ''');

    await _addReviewsTable(db);
    await _addCategoriesTable(db);
    await _addUserPreferencesTable(db);
  }

  Future<void> _addReviewsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        rating REAL NOT NULL,
        review_text TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (business_id) REFERENCES businesses (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _addCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        icon TEXT
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _addUserPreferencesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        preference_weight INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (category_id) REFERENCES categories (id),
        UNIQUE(user_id, category_id)
      )
    ''');
  }

  Future<void> _updateBusinessesTable(Database db) async {
    // Check if the column exists
    var result = await db.rawQuery('PRAGMA table_info(businesses)');
    bool hasCategory = result.any((column) => column['name'] == 'category_id');
    bool hasRating = result.any((column) => column['name'] == 'average_rating');
    bool hasDistance = result.any((column) => column['name'] == 'distance');

    if (!hasCategory) {
      await db.execute('ALTER TABLE businesses ADD COLUMN category_id INTEGER');
    }

    if (!hasRating) {
      await db.execute(
          'ALTER TABLE businesses ADD COLUMN average_rating REAL DEFAULT 0');
      await db.execute(
          'ALTER TABLE businesses ADD COLUMN total_reviews INTEGER DEFAULT 0');
    }

    if (!hasDistance) {
      await db.execute('ALTER TABLE businesses ADD COLUMN distance REAL');
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    List<Map<String, dynamic>> categories = [
      {
        'name': 'Grocery',
        'description': 'Grocery stores and supermarkets',
        'icon': 'shopping_cart'
      },
      {
        'name': 'Pharmacy',
        'description': 'Pharmacies and medical supplies',
        'icon': 'local_pharmacy'
      },
      {
        'name': 'Restaurant',
        'description': 'Restaurants and food services',
        'icon': 'restaurant'
      },
      {
        'name': 'Services',
        'description': 'General services',
        'icon': 'miscellaneous_services'
      }
    ];

    Batch batch = db.batch();
    for (var category in categories) {
      batch.insert('categories', category,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  // User operations
  Future<int> insertUser(User user) async {
    if (_useFirestore) {
      try {
        // Store in Firestore first
        String firestoreId = await FirestoreService.instance.insertUser(user);
        print("User saved to Firestore with ID: $firestoreId");

        // Still save locally for offline access
        if (!isWebPlatform) {
          final db = await instance.database;
          return await db.insert('users', user.toMap());
        } else {
          // In-memory storage for web
          user = user.copyWith(id: _nextUserId++);
          _webUsers.add(user);
          return user.id!;
        }
      } catch (e) {
        print("Error saving user to Firestore: $e");
        // Fallback to local storage only
      }
    }

    if (isWebPlatform) {
      // In-memory storage for web
      user = user.copyWith(id: _nextUserId++);
      _webUsers.add(user);
      return user.id!;
    }

    final db = await instance.database;
    try {
      return await db.insert('users', user.toMap());
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Email already exists');
      }
      rethrow;
    }
  }

  Future<List<User>> getAllUsers() async {
    if (_useFirestore) {
      try {
        // Try to get from Firestore first
        List<User> users = await FirestoreService.instance.getAllUsers();
        if (users.isNotEmpty) {
          return users;
        }
      } catch (e) {
        print("Error fetching users from Firestore: $e");
        // Fallback to local storage
      }
    }

    if (isWebPlatform) {
      // Return in-memory users for web
      return _webUsers;
    }

    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<User?> getUserByEmail(String email) async {
    if (_useFirestore) {
      try {
        // Try to get from Firestore first
        User? user = await FirestoreService.instance.getUserByEmail(email);
        if (user != null) {
          return user;
        }
      } catch (e) {
        print("Error fetching user from Firestore: $e");
        // Fallback to local storage
      }
    }

    if (isWebPlatform) {
      // Search in-memory users for web
      try {
        return _webUsers.firstWhere(
          (user) => user.email == email,
          orElse: () => null as User,
        );
      } catch (e) {
        return null;
      }
    }

    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return results.isNotEmpty ? User.fromMap(results.first) : null;
  }

  Future<User?> loginUser(String username, String password) async {
    if (isWebPlatform) {
      // Search in-memory users for web
      try {
        return _webUsers.firstWhere(
          (user) => user.username == username && user.password == password,
          orElse: () => null as User,
        );
      } catch (e) {
        return null;
      }
    }

    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    return results.isNotEmpty ? User.fromMap(results.first) : null;
  }

  // Add updateUser method
  Future<int> updateUser(User user) async {
    if (_useFirestore) {
      try {
        // Update in Firestore first
        await FirestoreService.instance.updateUser(user);
        print("User updated in Firestore");
      } catch (e) {
        print("Error updating user in Firestore: $e");
        // Continue with local update
      }
    }

    if (isWebPlatform) {
      // Update in-memory user for web
      final index = _webUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _webUsers[index] = user;
        return 1; // Success
      }
      return 0; // Failed
    }

    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Business operations
  Future<int> insertBusiness(Business business) async {
    if (_useFirestore) {
      try {
        // Store in Firestore first
        String firestoreId =
            await FirestoreService.instance.insertBusiness(business);
        print("Business saved to Firestore with ID: $firestoreId");

        // Still save locally for offline access
        if (!isWebPlatform) {
          final db = await instance.database;
          return await db.insert('businesses', business.toMap());
        } else {
          // In-memory storage for web
          business = business.copyWith(id: _nextBusinessId++);
          _webBusinesses.add(business);
          return business.id!;
        }
      } catch (e) {
        print("Error saving business to Firestore: $e");
        // Fallback to local storage only
      }
    }

    if (isWebPlatform) {
      // In-memory storage for web
      business = business.copyWith(id: _nextBusinessId++);
      _webBusinesses.add(business);
      return business.id!;
    }

    final db = await instance.database;
    try {
      return await db.insert('businesses', business.toMap());
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Email or business name already exists');
      }
      rethrow;
    }
  }

  Future<List<Business>> getAllBusinesses() async {
    if (isWebPlatform) {
      // Return in-memory businesses for web
      return _webBusinesses;
    }

    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('businesses');
    return List.generate(maps.length, (i) => Business.fromMap(maps[i]));
  }

  Future<Business?> getBusinessByEmail(String email) async {
    if (isWebPlatform) {
      // Search in-memory businesses for web
      try {
        return _webBusinesses.firstWhere(
          (business) => business.email == email,
          orElse: () => null as Business,
        );
      } catch (e) {
        return null;
      }
    }

    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'businesses',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return results.isNotEmpty ? Business.fromMap(results.first) : null;
  }

  Future<Business?> loginBusiness(String businessName, String password) async {
    if (isWebPlatform) {
      // Search in-memory businesses for web
      try {
        return _webBusinesses.firstWhere(
          (business) =>
              business.businessName == businessName &&
              business.password == password,
          orElse: () => null as Business,
        );
      } catch (e) {
        print("Web login error: $e");
        return null;
      }
    }

    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'businesses',
      where: 'business_name = ? AND password = ?',
      whereArgs: [businessName, password],
      limit: 1,
    );
    return results.isNotEmpty ? Business.fromMap(results.first) : null;
  }

  Future<Business?> loginBusinessWithEmail(
      String email, String password) async {
    if (_useFirestore) {
      try {
        // Try to get from Firestore first
        Business? business = await FirestoreService.instance
            .loginBusinessWithEmail(email, password);
        if (business != null) {
          return business;
        }
      } catch (e) {
        print("Error logging in business from Firestore: $e");
        // Fallback to local storage
      }
    }

    if (isWebPlatform) {
      // Search in-memory businesses for web
      try {
        return _webBusinesses.firstWhere(
          (business) =>
              business.email == email && business.password == password,
          orElse: () => null as Business,
        );
      } catch (e) {
        print("Web login error: $e");
        return null;
      }
    }

    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'businesses',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    return results.isNotEmpty ? Business.fromMap(results.first) : null;
  }

  Future<Business?> getBusinessById(int id) async {
    if (isWebPlatform) {
      // Search in-memory businesses for web
      try {
        return _webBusinesses.firstWhere(
          (business) => business.id == id,
          orElse: () => null as Business,
        );
      } catch (e) {
        return null;
      }
    }

    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'businesses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? Business.fromMap(results.first) : null;
  }

  Future<int> updateBusiness(Business business) async {
    if (isWebPlatform) {
      // Update in-memory business for web
      try {
        int index = _webBusinesses.indexWhere((b) => b.id == business.id);
        if (index != -1) {
          _webBusinesses[index] = business;
          return 1; // Return 1 for success
        }
        return 0; // Return 0 for no updates
      } catch (e) {
        print("Web update business error: $e");
        return 0;
      }
    }

    final db = await instance.database;
    // Use the business map directly since distance column is now in the table
    return await db.update(
      'businesses',
      business.toMap(),
      where: 'id = ?',
      whereArgs: [business.id],
    );
  }

  // Item operations
  Future<int> insertItem(Item item) async {
    if (_useFirestore) {
      try {
        // Store in Firestore first
        String firestoreId = await FirestoreService.instance.insertItem(item);
        print("Item saved to Firestore with ID: $firestoreId");

        // Still save locally for offline access
        if (!isWebPlatform) {
          final db = await instance.database;
          return await db.insert('items', item.toMap());
        } else {
          // In-memory storage for web
          item = item.copyWith(id: _nextItemId++);
          _webItems.add(item);
          return item.id!;
        }
      } catch (e) {
        print("Error saving item to Firestore: $e");
        // Fallback to local storage only
      }
    }

    if (isWebPlatform) {
      // In-memory storage for web
      item = item.copyWith(id: _nextItemId++);
      _webItems.add(item);
      return item.id!;
    }

    final db = await instance.database;
    return await db.insert('items', item.toMap());
  }

  Future<List<Item>> getItemsByBusinessId(int businessId) async {
    if (_useFirestore) {
      try {
        // Try to get from Firestore first
        List<Item> items =
            await FirestoreService.instance.getItemsByBusinessId(businessId);
        if (items.isNotEmpty) {
          return items;
        }
      } catch (e) {
        print("Error fetching items from Firestore: $e");
        // Fallback to local storage
      }
    }

    if (isWebPlatform) {
      // Filter in-memory items for web
      return _webItems.where((item) => item.businessId == businessId).toList();
    }

    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'business_id = ?',
      whereArgs: [businessId],
    );
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }

  Future<int> updateItem(Item item) async {
    if (isWebPlatform) {
      // Update in-memory item for web
      try {
        int index = _webItems.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _webItems[index] = item;
          return 1; // Return 1 for success
        }
        return 0; // Return 0 for no updates
      } catch (e) {
        print("Web update item error: $e");
        return 0;
      }
    }

    final db = await instance.database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int itemId) async {
    if (isWebPlatform) {
      // Delete from in-memory items for web
      try {
        int initialLength = _webItems.length;
        _webItems.removeWhere((item) => item.id == itemId);
        return initialLength -
            _webItems.length; // Return number of items removed
      } catch (e) {
        print("Web delete item error: $e");
        return 0;
      }
    }

    final db = await instance.database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<List<Business>> findNearbyBusinesses(
      double latitude, double longitude, double radiusInKm) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('businesses');
    final List<Business> businesses =
        List.generate(maps.length, (i) => Business.fromMap(maps[i]));

    // Filter businesses within radius
    return businesses.where((business) {
      if (business.latitude == null || business.longitude == null) return false;
      final distance = calculateDistance(
          latitude, longitude, business.latitude!, business.longitude!);
      return distance <= radiusInKm;
    }).toList();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  // Utility methods
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // Method to print database contents for debugging
  Future<void> printDatabaseContents() async {
    try {
      if (isWebPlatform) {
        print("WEB DATABASE CONTENTS:");
        print("Users: ${_webUsers.length}");
        print("Businesses: ${_webBusinesses.length}");
        print("Items: ${_webItems.length}");
        return;
      }

      if (_database == null || !(_database!.isOpen)) {
        print("Database is not open, cannot print contents");
        return;
      }

      print("SQLite DATABASE CONTENTS:");

      // Print database schema
      print("Database Schema:");
      var tables = await _database!
          .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      for (var table in tables) {
        String tableName = table['name'] as String;
        print("Table: $tableName");
        var schema = await _database!.rawQuery("PRAGMA table_info($tableName)");
        for (var column in schema) {
          print("  - ${column['name']} (${column['type']})");
        }
      }

      // Print table counts
      print("\nTable Counts:");
      for (var table in tables) {
        String tableName = table['name'] as String;
        if (tableName != 'android_metadata' && tableName != 'sqlite_sequence') {
          var count = await _database!
              .rawQuery("SELECT COUNT(*) as count FROM $tableName");
          print("$tableName: ${count.first['count']}");
        }
      }
    } catch (e) {
      print("Error printing database contents: $e");
    }
  }

  // Review operations
  Future<int> insertReview(Map<String, dynamic> review) async {
    if (isWebPlatform) {
      // In-memory storage for web
      review = Map<String, dynamic>.from(review);
      review['id'] = _nextReviewId++;
      review['created_at'] = DateTime.now().toIso8601String();
      _webReviews.add(review);

      // Update business average rating (simplified for web)
      await _updateBusinessRating(review['business_id']);

      return review['id'];
    }

    final db = await instance.database;
    int reviewId = await db.insert('reviews', review);

    // Update business average rating
    await _updateBusinessRating(review['business_id']);

    return reviewId;
  }

  Future<void> _updateBusinessRating(int businessId) async {
    if (isWebPlatform) {
      // Calculate new rating average for web
      final relevantReviews =
          _webReviews.where((r) => r['business_id'] == businessId).toList();
      double avgRating = 0.0;
      int count = relevantReviews.length;

      if (count > 0) {
        double totalRating = 0.0;
        for (var r in relevantReviews) {
          totalRating += r['rating'];
        }
        avgRating = totalRating / count;
      }

      // Update business record in memory
      int index = _webBusinesses.indexWhere((b) => b.id == businessId);
      if (index != -1) {
        _webBusinesses[index] = _webBusinesses[index]
            .copyWith(averageRating: avgRating, totalReviews: count);
      }

      return;
    }

    final db = await instance.database;

    // Calculate new rating average
    final result = await db.rawQuery('''
      SELECT AVG(rating) as avg_rating, COUNT(*) as count
      FROM reviews
      WHERE business_id = ?
    ''', [businessId]);

    double avgRating = result.first['avg_rating'] as double? ?? 0.0;
    int count = result.first['count'] as int? ?? 0;

    // Update business record
    await db.update(
        'businesses', {'average_rating': avgRating, 'total_reviews': count},
        where: 'id = ?', whereArgs: [businessId]);
  }

  Future<List<Map<String, dynamic>>> getBusinessReviews(int businessId) async {
    if (isWebPlatform) {
      // Filter in-memory reviews for web
      final reviews =
          _webReviews.where((r) => r['business_id'] == businessId).toList();

      // Sort by created_at DESC
      reviews.sort((a, b) =>
          (b['created_at'] as String).compareTo(a['created_at'] as String));

      // Add username from users table
      for (var review in reviews) {
        try {
          User? user = _webUsers.firstWhere((u) => u.id == review['user_id']);
          review['username'] = user.username;
        } catch (e) {
          review['username'] = 'Unknown User';
        }
      }

      return reviews;
    }

    final db = await instance.database;
    return await db.rawQuery('''
      SELECT r.*, u.username 
      FROM reviews r
      JOIN users u ON r.user_id = u.id
      WHERE r.business_id = ?
      ORDER BY r.created_at DESC
    ''', [businessId]);
  }

  // Category operations
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await instance.database;
    return await db.query('categories');
  }

  Future<List<Business>> getBusinessesByCategory(int categoryId) async {
    if (isWebPlatform) {
      // Filter in-memory businesses for web platform
      return _webBusinesses.where((b) => b.categoryId == categoryId).toList();
    }

    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'businesses',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => Business.fromMap(maps[i]));
  }

  // AI Recommendations
  Future<List<Business>> getRecommendedBusinesses(
      int userId, double latitude, double longitude) async {
    final db = await instance.database;

    // Get user preferences
    List<Map<String, dynamic>> preferences = await db
        .query('user_preferences', where: 'user_id = ?', whereArgs: [userId]);

    // If no preferences, get businesses based on location
    if (preferences.isEmpty) {
      return await findNearbyBusinesses(latitude, longitude, 5.0);
    }

    // Get all businesses
    List<Business> allBusinesses = await getAllBusinesses();

    // Score and sort businesses by preference weight and distance
    List<Map<String, dynamic>> scoredBusinesses = [];

    for (var business in allBusinesses) {
      if (business.latitude == null || business.longitude == null) continue;

      // Calculate distance
      double distance = calculateDistance(
          latitude, longitude, business.latitude!, business.longitude!);

      // Find preference weight if category matches
      double preferenceWeight = 1.0;
      var preference = preferences.firstWhere(
          (p) => p['category_id'] == business.categoryId,
          orElse: () => {'preference_weight': 1});

      preferenceWeight = (preference['preference_weight'] ?? 1) * 1.0;

      // Calculate score (higher is better)
      // Consider: category preference, rating, distance, and number of reviews
      double score = (preferenceWeight * 2.0) +
          (business.averageRating ?? 0) -
          (distance * 0.2) +
          (business.totalReviews ?? 0) * 0.1;

      scoredBusinesses.add({'business': business, 'score': score});
    }

    // Sort by score (descending)
    scoredBusinesses.sort((a, b) => b['score'].compareTo(a['score']));

    // Return top businesses
    return scoredBusinesses
        .take(10)
        .map((item) => item['business'] as Business)
        .toList();
  }

  // Update business coordinates
  Future<int> updateBusinessLocation(
      int businessId, double latitude, double longitude) async {
    if (isWebPlatform) {
      // Update in-memory business for web
      final index = _webBusinesses.indexWhere((b) => b.id == businessId);
      if (index != -1) {
        _webBusinesses[index] = _webBusinesses[index].copyWith(
          latitude: latitude,
          longitude: longitude,
        );
        return 1;
      }
      return 0;
    }

    final db = await instance.database;
    return await db.update(
      'businesses',
      {
        'latitude': latitude,
        'longitude': longitude,
      },
      where: 'id = ?',
      whereArgs: [businessId],
    );
  }

  // Add a method to delete the database
  Future<void> deleteDatabase() async {
    if (isWebPlatform) {
      // Clear in-memory storage for web
      _webUsers.clear();
      _webBusinesses.clear();
      _webItems.clear();
      _webReviews.clear();
      _nextUserId = 1;
      _nextBusinessId = 1;
      _nextItemId = 1;
      _nextReviewId = 1;
      return;
    }

    try {
      // Close the database connection
      if (_database != null && _database!.isOpen) {
        await _database!.close();
        _database = null;
      }

      // Delete the database file
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'locality_connector.db');
      await databaseFactory.deleteDatabase(path);
      print("Database deleted successfully");
    } catch (e) {
      print("Error deleting database: $e");
    }
  }
}

extension DatabaseExceptionExtension on DatabaseException {
  bool isUniqueConstraintError() {
    return toString().contains('UNIQUE constraint failed');
  }
}
