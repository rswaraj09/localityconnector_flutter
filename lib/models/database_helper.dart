import 'dart:async';
import 'business.dart';
import 'item.dart';

// This is a mock implementation of DatabaseHelper for demo purposes
// It doesn't use actual SQLite database to avoid dependency issues
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Mock data storage
  final Map<int, Business> _businesses = {};
  final Map<int, List<Item>> _businessItems = {};

  DatabaseHelper._init() {
    // Initialize with some hardcoded data
    _initMockData();
  }

  void _initMockData() {
    // Metro Medical
    final metroMedical = Business(
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
        distance: 0.22);

    final metroItems = [
      Item(
        id: 1,
        businessId: 15,
        itemName: "Paracetamol",
        itemPrice: 25.0,
        itemDescription: "Fever and pain reliever - 10 tablets",
      ),
      Item(
        id: 2,
        businessId: 15,
        itemName: "Crocin",
        itemPrice: 35.0,
        itemDescription: "Headache and fever medicine - 15 tablets",
      ),
      Item(
        id: 3,
        businessId: 15,
        itemName: "Azithromycin",
        itemPrice: 120.0,
        itemDescription: "Antibiotic for bacterial infections - strip of 6",
      ),
      Item(
        id: 4,
        businessId: 15,
        itemName: "Blood Pressure Monitor",
        itemPrice: 1850.0,
        itemDescription: "Digital BP monitor for home use",
      ),
      Item(
        id: 5,
        businessId: 15,
        itemName: "Vitamin C",
        itemPrice: 150.0,
        itemDescription: "Immunity booster supplement - 60 tablets",
      ),
    ];

    // Khumbhivali Medical Shop
    final khumbhivaliMedical = Business(
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
        distance: 0.35);

    final khumbhivaliItems = [
      Item(
        id: 1,
        businessId: 16,
        itemName: "Ibuprofen",
        itemPrice: 40.0,
        itemDescription: "Pain reliever and fever reducer - 20 tablets",
      ),
      Item(
        id: 2,
        businessId: 16,
        itemName: "Cetrizine",
        itemPrice: 30.0,
        itemDescription: "Allergy relief medication - 10 tablets",
      ),
      Item(
        id: 3,
        businessId: 16,
        itemName: "Bandages",
        itemPrice: 50.0,
        itemDescription: "Sterile bandages - pack of 10",
      ),
      Item(
        id: 4,
        businessId: 16,
        itemName: "Thermometer",
        itemPrice: 120.0,
        itemDescription: "Digital thermometer for accurate temperature reading",
      ),
      Item(
        id: 5,
        businessId: 16,
        itemName: "Cough Syrup",
        itemPrice: 85.0,
        itemDescription: "Effective cough suppressant - 100ml bottle",
      ),
    ];

    // Store in mock database
    _businesses[15] = metroMedical;
    _businesses[16] = khumbhivaliMedical;
    _businessItems[15] = metroItems;
    _businessItems[16] = khumbhivaliItems;
  }

  // Businesses related methods
  Future<Business?> getBusinessById(int id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _businesses[id];
  }

  Future<List<Business>> getAllBusinesses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _businesses.values.toList();
  }

  Future<List<Business>> getBusinessesByCategory(int categoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _businesses.values
        .where((business) => business.categoryId == categoryId)
        .toList();
  }

  // Items related methods
  Future<List<Item>> getItemsByBusinessId(int businessId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _businessItems[businessId] ?? [];
  }
}
