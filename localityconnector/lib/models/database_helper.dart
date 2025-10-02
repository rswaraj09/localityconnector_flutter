Future<List<Business>> getAllBusinesses() async {
  if (_useFirestore) {
    try {
      // Try to get from Firestore first
      List<Business> businesses =
          await FirestoreService.instance.getAllBusinesses();
      if (businesses.isNotEmpty) {
        return businesses;
      }
    } catch (e) {
      print("Error fetching businesses from Firestore: $e");
      // Fallback to local storage
    }
  }

  if (isWebPlatform) {
    // Return in-memory businesses for web
    return _webBusinesses;
  }

  final db = await instance.database;
  final List<Map<String, dynamic>> maps = await db.query('businesses');
  return List.generate(maps.length, (i) => Business.fromMap(maps[i]));
}
