import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/business.dart';
import '../models/database_helper.dart';
import '../models/item.dart';

class BusinessDetailScreen extends StatefulWidget {
  final int businessId;

  const BusinessDetailScreen({super.key, required this.businessId});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Business? _business;
  bool _isLoading = true;
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBusinessData();
  }

  Future<void> _loadBusinessData() async {
    try {
      // Special handling for hardcoded businesses
      if (widget.businessId == 5) {
        // Vimeet Canteen
        setState(() {
          _business = Business(
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
              distance: 0.17);

          // Add custom food items for Vimeet Canteen
          _items = [
            Item(
              id: 1,
              businessId: widget.businessId,
              itemName: "Campus Special Thali",
              itemPrice: 120.0,
              itemDescription: "Rice, Dal, 2 Roti, Sabji, Salad, Papad",
            ),
            Item(
              id: 2,
              businessId: widget.businessId,
              itemName: "Veg Biryani",
              itemPrice: 100.0,
              itemDescription: "Flavorful rice with mixed vegetables",
            ),
            Item(
              id: 3,
              businessId: widget.businessId,
              itemName: "Masala Dosa",
              itemPrice: 80.0,
              itemDescription: "South Indian specialty with potato filling",
            ),
            Item(
              id: 4,
              businessId: widget.businessId,
              itemName: "Cold Coffee",
              itemPrice: 60.0,
              itemDescription: "Chilled coffee with ice cream",
            ),
            Item(
              id: 5,
              businessId: widget.businessId,
              itemName: "Vada Pav",
              itemPrice: 20.0,
              itemDescription: "Classic Mumbai street food",
            ),
          ];

          _isLoading = false;
        });
        return;
      } else if (widget.businessId == 6) {
        // Vimeet Hostel Shop
        setState(() {
          _business = Business(
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
              distance: 0.15);

          // Add custom food items for Vimeet Hostel Shop
          _items = [
            Item(
              id: 1,
              businessId: widget.businessId,
              itemName: "Maggi Noodles",
              itemPrice: 30.0,
              itemDescription: "Instant noodles - spicy masala flavor",
            ),
            Item(
              id: 2,
              businessId: widget.businessId,
              itemName: "Chips & Snacks",
              itemPrice: 20.0,
              itemDescription: "Various brands of potato chips and snacks",
            ),
            Item(
              id: 3,
              businessId: widget.businessId,
              itemName: "Fruit Juice",
              itemPrice: 40.0,
              itemDescription: "Fresh fruit juice (seasonal varieties)",
            ),
            Item(
              id: 4,
              businessId: widget.businessId,
              itemName: "Cold Drinks",
              itemPrice: 25.0,
              itemDescription: "Assorted soft drinks and beverages",
            ),
            Item(
              id: 5,
              businessId: widget.businessId,
              itemName: "Chocolate",
              itemPrice: 30.0,
              itemDescription: "Various chocolate brands available",
            ),
          ];

          _isLoading = false;
        });
        return;
      } else if (widget.businessId == 7) {
        // Rohit Tapri
        setState(() {
          _business = Business(
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
              distance: 0.22);

          // Add custom food items for Rohit Tapri
          _items = [
            Item(
              id: 1,
              businessId: widget.businessId,
              itemName: "Cutting Chai",
              itemPrice: 10.0,
              itemDescription: "Strong, fragrant tea in small glass",
            ),
            Item(
              id: 2,
              businessId: widget.businessId,
              itemName: "Vada Pav",
              itemPrice: 15.0,
              itemDescription: "Spicy potato fritter in a bun",
            ),
            Item(
              id: 3,
              businessId: widget.businessId,
              itemName: "Samosa",
              itemPrice: 15.0,
              itemDescription:
                  "Crispy triangular pastry with spiced potato filling",
            ),
            Item(
              id: 4,
              businessId: widget.businessId,
              itemName: "Kachori",
              itemPrice: 20.0,
              itemDescription: "Deep-fried snack filled with spicy lentils",
            ),
            Item(
              id: 5,
              businessId: widget.businessId,
              itemName: "Bun Maska",
              itemPrice: 25.0,
              itemDescription: "Soft bun with generous butter spread",
            ),
          ];

          _isLoading = false;
        });
        return;
      } else if (widget.businessId == 8) {
        // Sanjay Tapri
        setState(() {
          _business = Business(
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
              distance: 0.28);

          // Add custom food items for Sanjay Tapri
          _items = [
            Item(
              id: 1,
              businessId: widget.businessId,
              itemName: "Masala Chai",
              itemPrice: 12.0,
              itemDescription: "Spiced tea with ginger and cardamom",
            ),
            Item(
              id: 2,
              businessId: widget.businessId,
              itemName: "Bun Muska",
              itemPrice: 18.0,
              itemDescription: "Buttered bun served with chai",
            ),
            Item(
              id: 3,
              businessId: widget.businessId,
              itemName: "Poha",
              itemPrice: 25.0,
              itemDescription: "Flattened rice with onions and spices",
            ),
            Item(
              id: 4,
              businessId: widget.businessId,
              itemName: "Misal Pav",
              itemPrice: 35.0,
              itemDescription: "Spicy curry with sprouts served with bread",
            ),
            Item(
              id: 5,
              businessId: widget.businessId,
              itemName: "Pattice",
              itemPrice: 15.0,
              itemDescription: "Potato patty fried to perfection",
            ),
          ];

          _isLoading = false;
        });
        return;
      } else if (widget.businessId == 9) {
        // Vishal General Store
        setState(() {
          _business = Business(
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
              distance: 0.1);

          // Add grocery items
          _items = [
            Item(
              id: 1,
              businessId: widget.businessId,
              itemName: "Rice (Basmati)",
              itemPrice: 85.0,
              itemDescription: "Premium quality rice - 1kg packet",
            ),
            Item(
              id: 2,
              businessId: widget.businessId,
              itemName: "Tata Salt",
              itemPrice: 20.0,
              itemDescription: "Iodized table salt - 1kg",
            ),
            Item(
              id: 3,
              businessId: widget.businessId,
              itemName: "Sugar",
              itemPrice: 40.0,
              itemDescription: "Refined white sugar - 1kg",
            ),
            Item(
              id: 4,
              businessId: widget.businessId,
              itemName: "Cooking Oil",
              itemPrice: 110.0,
              itemDescription: "Refined sunflower oil - 1L",
            ),
            Item(
              id: 5,
              businessId: widget.businessId,
              itemName: "Wheat Flour",
              itemPrice: 45.0,
              itemDescription: "Whole wheat flour - 1kg packet",
            ),
          ];

          _isLoading = false;
        });
        return;
      } else if (widget.businessId == 10) {
        // Lotta General Store
        setState(() {
          _business = Business(
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
              distance: 0.15);

          // Add grocery items
          _items = [
            Item(
              id: 1,
              businessId: widget.businessId,
              itemName: "Dal",
              itemPrice: 120.0,
              itemDescription: "Toor dal - 1kg packet",
            ),
            Item(
              id: 2,
              businessId: widget.businessId,
              itemName: "Biscuits",
              itemPrice: 15.0,
              itemDescription: "Parle-G glucose biscuits - 200g",
            ),
            Item(
              id: 3,
              businessId: widget.businessId,
              itemName: "Tea Leaves",
              itemPrice: 60.0,
              itemDescription: "Premium tea leaves - 250g packet",
            ),
            Item(
              id: 4,
              businessId: widget.businessId,
              itemName: "Milk",
              itemPrice: 25.0,
              itemDescription: "Pasteurized milk - 500ml",
            ),
            Item(
              id: 5,
              businessId: widget.businessId,
              itemName: "Rice Flour",
              itemPrice: 35.0,
              itemDescription: "Fine ground rice flour - 500g packet",
            ),
          ];

          _isLoading = false;
        });
        return;
      } else if (widget.businessId == 11) {
        // Aniket Kirana
        setState(() {
          _business = Business(
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
              distance: 0.18);

          // Add grocery items
          _items = [
            Item(
              id: 1,
              businessId: widget.businessId,
              itemName: "Vegetables Assorted",
              itemPrice: 50.0,
              itemDescription: "Fresh locally sourced vegetables - 1kg mix",
            ),
            Item(
              id: 2,
              businessId: widget.businessId,
              itemName: "Green Chilies",
              itemPrice: 10.0,
              itemDescription: "Fresh green chilies - 100g",
            ),
            Item(
              id: 3,
              businessId: widget.businessId,
              itemName: "Potatoes",
              itemPrice: 30.0,
              itemDescription: "Fresh potatoes - 1kg",
            ),
            Item(
              id: 4,
              businessId: widget.businessId,
              itemName: "Onions",
              itemPrice: 25.0,
              itemDescription: "Red onions - 1kg",
            ),
            Item(
              id: 5,
              businessId: widget.businessId,
              itemName: "Tomatoes",
              itemPrice: 40.0,
              itemDescription: "Fresh ripe tomatoes - 1kg",
            ),
          ];

          _isLoading = false;
        });
        return;
      } else if (widget.businessId == 12) {
        // HariNam Kirana
        setState(() {
          _business = Business(
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
              distance: 0.25);

          // Add grocery items
          _items = [
            Item(
              id: 1,
              businessId: widget.businessId,
              itemName: "Ghee",
              itemPrice: 250.0,
              itemDescription: "Pure cow ghee - 500g jar",
            ),
            Item(
              id: 2,
              businessId: widget.businessId,
              itemName: "Spices Combo",
              itemPrice: 150.0,
              itemDescription:
                  "Assorted spices pack - contains 10 essential spices",
            ),
            Item(
              id: 3,
              businessId: widget.businessId,
              itemName: "Jaggery",
              itemPrice: 60.0,
              itemDescription: "Natural jaggery block - 500g",
            ),
            Item(
              id: 4,
              businessId: widget.businessId,
              itemName: "Besan Flour",
              itemPrice: 55.0,
              itemDescription: "Gram flour - 500g packet",
            ),
            Item(
              id: 5,
              businessId: widget.businessId,
              itemName: "Poha",
              itemPrice: 40.0,
              itemDescription: "Flattened rice - 500g packet",
            ),
          ];

          _isLoading = false;
        });
        return;
      } else if (widget.businessId == 13) {
        // Siya Bakery
        setState(() {
          _business = Business(
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
              distance: 0.32);

          // Add custom food items for Siya Bakery
          _items = [
            Item(
              id: 1,
              businessId: widget.businessId,
              itemName: "Cake",
              itemPrice: 100.0,
              itemDescription: "Various types of cakes",
            ),
            Item(
              id: 2,
              businessId: widget.businessId,
              itemName: "Pastry",
              itemPrice: 50.0,
              itemDescription: "Various types of pastries",
            ),
            Item(
              id: 3,
              businessId: widget.businessId,
              itemName: "Bread",
              itemPrice: 30.0,
              itemDescription: "Various types of bread",
            ),
            Item(
              id: 4,
              businessId: widget.businessId,
              itemName: "Cookies",
              itemPrice: 20.0,
              itemDescription: "Various types of cookies",
            ),
            Item(
              id: 5,
              businessId: widget.businessId,
              itemName: "Cupcake",
              itemPrice: 50.0,
              itemDescription: "Various types of cupcakes",
            ),
          ];

          _isLoading = false;
        });
        return;
      } else if (widget.businessId == 14) {
        // OmDhaba
        setState(() {
          _business = Business(
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
              distance: 0.35);

          // Add custom food items for OmDhaba
          _items = [
            Item(
              id: 1,
              businessId: widget.businessId,
              itemName: "Punjabi Thali",
              itemPrice: 150.0,
              itemDescription: "Traditional Punjabi meal",
            ),
            Item(
              id: 2,
              businessId: widget.businessId,
              itemName: "Rajma Chawal",
              itemPrice: 100.0,
              itemDescription: "Traditional Rajasthani dish",
            ),
            Item(
              id: 3,
              businessId: widget.businessId,
              itemName: "Butter Chicken",
              itemPrice: 200.0,
              itemDescription: "Creamy chicken dish with rich butter sauce",
            ),
            Item(
              id: 4,
              businessId: widget.businessId,
              itemName: "Paneer Tikka",
              itemPrice: 150.0,
              itemDescription: "Grilled paneer with spices",
            ),
            Item(
              id: 5,
              businessId: widget.businessId,
              itemName: "Dal Makhani",
              itemPrice: 120.0,
              itemDescription: "Black lentils cooked in creamy butter",
            ),
          ];

          _isLoading = false;
        });
        return;
      } else if (widget.businessId == 15) {
        // Metro Medical
        setState(() {
          _business = Business(
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

          // Add pharmacy items
          _items = [
            Item(
              id: 1,
              businessId: widget.businessId,
              itemName: "Paracetamol",
              itemPrice: 25.0,
              itemDescription: "Fever and pain relief tablets - strip of 10",
            ),
            Item(
              id: 2,
              businessId: widget.businessId,
              itemName: "First Aid Kit",
              itemPrice: 150.0,
              itemDescription: "Basic first aid supplies in portable kit",
            ),
            Item(
              id: 3,
              businessId: widget.businessId,
              itemName: "Multivitamin",
              itemPrice: 120.0,
              itemDescription: "Daily multivitamin tablets - bottle of 30",
            ),
            Item(
              id: 4,
              businessId: widget.businessId,
              itemName: "Hand Sanitizer",
              itemPrice: 50.0,
              itemDescription: "Antibacterial hand sanitizer - 100ml",
            ),
            Item(
              id: 5,
              businessId: widget.businessId,
              itemName: "Face Masks",
              itemPrice: 60.0,
              itemDescription: "Disposable face masks - pack of 10",
            ),
          ];

          _isLoading = false;
        });
        return;
      } else if (widget.businessId == 16) {
        // Khumbhivali Medical Shop
        setState(() {
          _business = Business(
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

          // Add pharmacy items
          _items = [
            Item(
              id: 1,
              businessId: widget.businessId,
              itemName: "Cough Syrup",
              itemPrice: 80.0,
              itemDescription: "Relief from cough and cold - 100ml bottle",
            ),
            Item(
              id: 2,
              businessId: widget.businessId,
              itemName: "Bandages",
              itemPrice: 40.0,
              itemDescription: "Adhesive bandages - assorted sizes pack",
            ),
            Item(
              id: 3,
              businessId: widget.businessId,
              itemName: "Antiseptic Cream",
              itemPrice: 65.0,
              itemDescription: "Topical antiseptic for minor cuts - 20g tube",
            ),
            Item(
              id: 4,
              businessId: widget.businessId,
              itemName: "Thermometer",
              itemPrice: 120.0,
              itemDescription: "Digital thermometer for accurate readings",
            ),
            Item(
              id: 5,
              businessId: widget.businessId,
              itemName: "Pain Relief Gel",
              itemPrice: 90.0,
              itemDescription: "Topical pain relief gel - 30g tube",
            ),
          ];

          _isLoading = false;
        });
        return;
      }

      // Original code for other businesses
      final business =
          await DatabaseHelper.instance.getBusinessById(widget.businessId);

      if (business != null) {
        // Load items instead of reviews
        final items = await DatabaseHelper.instance
            .getItemsByBusinessId(widget.businessId);

        setState(() {
          _business = business;

          // If no items found, add hardcoded sample items
          if (items.isEmpty) {
            _items = [
              Item(
                id: 1,
                businessId: widget.businessId,
                itemName: "Rice",
                itemPrice: 25.0,
                itemDescription: "Premium quality Rice package - 1kg",
              ),
              Item(
                id: 2,
                businessId: widget.businessId,
                itemName: "Wheat Flour",
                itemPrice: 35.0,
                itemDescription: "Fine ground wheat flour - 2kg bag",
              ),
              Item(
                id: 3,
                businessId: widget.businessId,
                itemName: "Sugar",
                itemPrice: 42.0,
                itemDescription: "Refined white sugar - 1kg",
              ),
              Item(
                id: 4,
                businessId: widget.businessId,
                itemName: "Cooking Oil",
                itemPrice: 120.0,
                itemDescription: "Pure sunflower oil - 1 liter",
              ),
              Item(
                id: 5,
                businessId: widget.businessId,
                itemName: "Dal",
                itemPrice: 65.0,
                itemDescription: "Premium yellow dal - 500g packet",
              ),
            ];
          } else {
            _items = items;
          }

          _isLoading = false;
        });
      } else {
        // Handle case when business is not found
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading business data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_business == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Business Not Found')),
        body: const Center(child: Text('The business could not be found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_business!.businessName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Info'),
            Tab(icon: Icon(Icons.shopping_basket), text: 'Items'),
            Tab(icon: Icon(Icons.map), text: 'Map'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Info Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Type
                if (_business!.businessType != null) ...[
                  const Text('Type:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_business!.businessType!),
                  const SizedBox(height: 16),
                ],
                // Description
                if (_business!.businessDescription != null) ...[
                  const Text('Description:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_business!.businessDescription!),
                  const SizedBox(height: 16),
                ],
                // Address
                const Text('Address:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_business!.businessAddress),
              ],
            ),
          ),

          // Items Tab
          _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_basket_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No Items Available',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This business hasn\'t added any items yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _business!.businessName == "Vimeet Hostel Shop" ||
                            _business!.businessName == "Vimeet Canteen" ||
                            _business!.businessName == "Rohit Tapri" ||
                            _business!.businessName == "Sanjay Tapri" ||
                            _business!.businessName == "Siya Bakery" ||
                            _business!.businessName == "OmDhaba" ||
                            _business!.businessType == "Food Items" ||
                            _business!.businessName == "Vishal General Store" ||
                            _business!.businessName == "Aniket Kirana" ||
                            _business!.businessName == "Lotta General Store" ||
                            _business!.businessName == "HariNam Kirana" ||
                            _business!.businessType == "Grocery" ||
                            _business!.businessName == "Metro Medical" ||
                            _business!.businessName ==
                                "Khumbhivali Medical Shop" ||
                            _business!.businessType == "Pharmacy"
                        ? Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.itemName,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          'Rs ${item.itemPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item.itemDescription != null &&
                                      item.itemDescription!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      item.itemDescription!,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 45,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.shopping_cart),
                                      label: Text(_business!.businessName ==
                                                  "Vimeet Canteen" ||
                                              _business!
                                                      .businessType ==
                                                  "Restaurant"
                                          ? 'ORDER FOOD'
                                          : _business!
                                                          .businessType ==
                                                      "Grocery" ||
                                                  _business!.businessName
                                                      .contains(
                                                          "General Store") ||
                                                  _business!.businessName
                                                      .contains("Kirana")
                                              ? 'ORDER GROCERY'
                                              : _business!.businessType ==
                                                          "Pharmacy" ||
                                                      _business!.businessName
                                                          .contains("Medical")
                                                  ? 'ORDER MEDICINE'
                                                  : 'ORDER NOW'),
                                      onPressed: () {
                                        _showOrderForm(context, item.itemName,
                                            item.itemPrice);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        elevation: 3,
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                item.itemName,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.itemDescription != null &&
                                      item.itemDescription!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.itemDescription!,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Rs ${item.itemPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                  },
                ),

          // Map Tab
          _business!.latitude != null && _business!.longitude != null
              ? SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        color: Colors.blue.shade50,
                        child: Column(
                          children: [
                            Text(
                              _business!.businessName,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _business!.businessAddress,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            if (_business!.distance != null)
                              Text(
                                "Distance: ${_business!.distance?.toStringAsFixed(2)} km",
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  size: 60,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "View Location",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Click the button below to open this location in Google Maps",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.map),
                          label: const Text("OPEN IN GOOGLE MAPS",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            try {
                              String googleMapsUrl = "";

                              // Set the correct URL based on the business
                              if (_business!.businessName ==
                                  "Vimeet Hostel Shop") {
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=R7C9%2B6WP+Vishwaniketan%27s+Girls+Hostel%2C+Kumbhivali%2C+Maharashtra+410203";
                              } else if (_business!.businessName ==
                                  "Vimeet Canteen") {
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=R7CC%2BG8M+Vishwaniketan%27s+Canteen%2C+Kumbhivali%2C+Maharashtra+410203";
                              } else if (_business!.businessName ==
                                  "Rohit Tapri") {
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=18.82177130388928,73.27041060118721";
                              } else if (_business!.businessName ==
                                  "Sanjay Tapri") {
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=18.81805404203425,73.27478996472767";
                              } else if (_business!.businessName ==
                                  "Metro Medical") {
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=18.816934811518898,73.27559385321833";
                              } else if (_business!.businessName ==
                                  "Khumbhivali Medical Shop") {
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=18.822873137516815,73.26211099260537";
                              } else if (_business!.businessName ==
                                  "Vishal General Store") {
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=18.817036731846635,73.27575712390647";
                              } else if (_business!.businessName ==
                                  "Lotta General Store") {
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=18.81763470287621,73.27500964972695";
                              } else if (_business!.businessName ==
                                  "Aniket Kirana") {
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=18.81717823664992,73.27544366699958";
                              } else if (_business!.businessName ==
                                  "HariNam Kirana") {
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=18.82281217056494,73.26146824521275";
                              } else if (_business!.businessName ==
                                  "Siya Bakery") {
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=18.8173170173419,73.27544740910682";
                              } else if (_business!.businessName == "OmDhaba") {
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=18.816891887388632,73.27645270671975";
                              } else {
                                // For any other business use the latitude/longitude
                                googleMapsUrl =
                                    "https://www.google.com/maps/search/?api=1&query=${_business!.latitude},${_business!.longitude}";
                              }

                              if (await canLaunchUrlString(googleMapsUrl)) {
                                await launchUrlString(googleMapsUrl,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Could not launch Google Maps')),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Error opening maps')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(child: Text('Location not available')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Order form dialog
  void _showOrderForm(BuildContext context, String itemName, double price) {
    int quantity = 1;
    String deliveryAddress = '';
    String contactNumber = '';

    // Set title and icon based on business type
    String dialogTitle = 'Order ${itemName}';
    IconData titleIcon = Icons.shopping_bag;

    if (_business!.businessName == "Vimeet Canteen" ||
        _business!.businessType == "Restaurant") {
      dialogTitle = 'Order Food: ${itemName}';
      titleIcon = Icons.restaurant;
    } else if (_business!.businessName == "Siya Bakery") {
      dialogTitle = 'Order Bakery Item: ${itemName}';
      titleIcon = Icons.cake;
    } else if (_business!.businessName.contains("Tapri")) {
      dialogTitle = 'Order Snack: ${itemName}';
      titleIcon = Icons.emoji_food_beverage;
    } else if (_business!.businessType == "Grocery" ||
        _business!.businessName.contains("General Store") ||
        _business!.businessName.contains("Kirana")) {
      dialogTitle = 'Order Grocery: ${itemName}';
      titleIcon = Icons.shopping_basket;
    } else if (_business!.businessType == "Pharmacy" ||
        _business!.businessName.contains("Medical")) {
      dialogTitle = 'Order Medicine: ${itemName}';
      titleIcon = Icons.medication;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(titleIcon, color: Colors.green),
                SizedBox(width: 10),
                Flexible(
                    child: Text(dialogTitle, overflow: TextOverflow.ellipsis)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Item Price:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                          'Rs ${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Quantity:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline,
                              color: Colors.green),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'Rs ${(price * quantity).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Delivery Details:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      deliveryAddress = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.phone, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      contactNumber = value;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                icon: Icon(Icons.cancel, size: 18),
                label: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.check_circle, size: 18),
                label: Text('Place Order'),
                onPressed: () {
                  // Here you would normally process the order
                  // For now just show a confirmation and close
                  // Customize confirmation message based on business type
                  String confirmMessage;

                  if (_business!.businessName == "Vimeet Canteen" ||
                      _business!.businessType == "Restaurant") {
                    confirmMessage = 'Food order placed: $quantity × $itemName';
                  } else if (_business!.businessName == "Siya Bakery") {
                    confirmMessage =
                        'Bakery order placed: $quantity × $itemName';
                  } else if (_business!.businessName.contains("Tapri")) {
                    confirmMessage =
                        'Snack order placed: $quantity × $itemName';
                  } else if (_business!.businessType == "Grocery" ||
                      _business!.businessName.contains("General Store") ||
                      _business!.businessName.contains("Kirana")) {
                    confirmMessage =
                        'Grocery order placed: $quantity × $itemName';
                  } else if (_business!.businessType == "Pharmacy" ||
                      _business!.businessName.contains("Medical")) {
                    confirmMessage =
                        'Medicine order placed: $quantity × $itemName';
                  } else {
                    confirmMessage = 'Order placed for $quantity $itemName';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 16),
                          Flexible(child: Text(confirmMessage)),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
          );
        });
      },
    );
  }
}
