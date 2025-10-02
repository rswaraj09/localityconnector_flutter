import 'package:flutter/material.dart';
import 'models/user.dart';
import 'models/business.dart';
import 'models/item.dart';
import 'screens/location_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_tools_screen.dart';
import 'screens/jarvis_screen.dart';
import 'services/location_service.dart';
import 'services/gemini_service.dart';
import 'services/auth_service.dart';
import 'services/jarvis_service.dart';
import 'widgets/app_layout.dart';
import 'models/database_helper.dart';
import 'main.dart';

void main() {
  runApp(const LocalityConnectorApp());
}

class LocalityConnectorApp extends StatelessWidget {
  const LocalityConnectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Locality Connector',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locality Connector'),
        backgroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://cdn.wallpapersafari.com/31/92/l4E3vA.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const NavigationBar(),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const InfoCard(
                        title: 'Shops',
                        description:
                            'Find the best local shops around you with ease.',
                        route: '/shop_details',
                      ),
                      const SizedBox(height: 20),
                      const InfoCard(
                        title: 'Hospitals',
                        description:
                            'Locate hospitals and medical facilities close to you.',
                        route: '/hospitalhomepage',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomAppBar(
        color: Colors.black87,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            '\u00A9 2024 Locality Connector. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}

class NavigationBar extends StatelessWidget {
  const NavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NavButton(label: 'Shops', route: '/shop_details'),
        SizedBox(width: 10),
        NavButton(label: 'Hospitals', route: '/hospitalhomepage'),
      ],
    );
  }
}

class NavButton extends StatelessWidget {
  final String label;
  final String route;

  const NavButton({super.key, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white24,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      child: Text(
        label,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String route;

  const InfoCard(
      {super.key,
      required this.title,
      required this.description,
      required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Card(
        color: Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserHomePage extends StatefulWidget {
  final User user;

  const UserHomePage({super.key, required this.user});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  bool _isLoading = true;
  List<Business> _nearbyBusinesses = [];
  List<Map<String, dynamic>> _categories = [];
  double? _latitude;
  double? _longitude;
  String _address = 'Loading location...';
  final LocationService _locationService = LocationService();
  final AuthService _authService = AuthService();
  User _currentUser;

  _UserHomePageState() : _currentUser = User();

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;

    // Show the UI immediately, then load data in background
    setState(() {
      _isLoading = false; // Show the UI immediately
    });

    // Initialize data in the background
    Future.microtask(() => _loadData());
  }

  // Separate initialization into multiple concurrent operations
  Future<void> _loadData() async {
    try {
      // Run multiple operations concurrently
      await Future.wait([
        _fetchLocation(),
        _fetchCategories(),
      ]);
    } catch (e) {
      print('Error initializing user home: $e');
    }
  }

  // Fetch location data separately
  Future<void> _fetchLocation() async {
    try {
      final locationData = await _locationService.getCurrentLocation();
      final address = await _locationService.getAddressFromCoordinates(
          locationData.latitude, locationData.longitude);

      if (mounted) {
        setState(() {
          _latitude = locationData.latitude;
          _longitude = locationData.longitude;
          _address = address ?? 'Current Location';
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
      if (mounted) {
        setState(() {
          _address = 'Current Location';
        });
      }
    }
  }

  // Fetch categories data separately
  Future<void> _fetchCategories() async {
    try {
      final categories = await DatabaseHelper.instance.getAllCategories();

      List<Map<String, dynamic>> finalCategories = categories
          .where((category) => category['name'] != 'Services')
          .toList();

      if (!finalCategories.any((category) => category['name'] == 'Education')) {
        finalCategories.add({
          'id': categories.length + 1,
          'name': 'Education',
          'description': 'Find schools, colleges, and educational institutions',
          'icon': 'school'
        });
      }

      if (!finalCategories
          .any((category) => category['name'] == 'Food Items')) {
        finalCategories.add({
          'id': categories.length + 2,
          'name': 'Food Items',
          'description': 'Explore various food items and specialty shops',
          'icon': 'fastfood'
        });
      }

      if (mounted) {
        setState(() {
          _categories = finalCategories;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  // Method for refreshing data
  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });
    await _loadData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LocalityConnectorApp()),
        (route) => false,
      );
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }

  Future<void> _showLogoutConfirmation() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: const Text('Logout'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile() async {
    final updatedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(user: _currentUser),
      ),
    );

    if (updatedUser != null) {
      setState(() {
        _currentUser = updatedUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use regular Scaffold without wrapping in AppLayout
    final scaffold = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Welcome, ${_currentUser.username ?? "User"}'),
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _initialize();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'profile') {
                _navigateToProfile();
              } else if (value == 'logout') {
                _showLogoutConfirmation();
              } else if (value == 'admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminToolsScreen(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Update Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Admin Tools'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Info - Improved UI
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.red, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _address,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh,
                              size: 20, color: Colors.blue),
                          onPressed: _fetchLocation,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Refresh location',
                        ),
                      ],
                    ),
                  ),

                  // Categories Section
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Grid view of categories
                  _categories.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text('No categories available'),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                          ),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return _buildCategoryCard(
                              category['name'] ?? 'Category',
                              category['icon'] ?? 'category',
                              category['id'],
                            );
                          },
                        ),
                ],
              ),
            ),
    );

    // Then wrap it with AppLayout
    return AppLayout(
      contextData: {
        'nearbyBusinesses': _nearbyBusinesses,
        'currentLocation': _address,
      },
      showChatBubble: false,
      child: scaffold,
    );
  }

  // Method to build the category card widget
  Widget _buildCategoryCard(String title, String iconName, int? categoryId) {
    IconData iconData = _getIconData(iconName);

    return Card(
      elevation: 3.0,
      color: Colors.purple.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocationScreen(
                categoryId: categoryId,
                categoryName: title,
              ),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                iconData,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to convert icon name to IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'local_pharmacy':
        return Icons.local_pharmacy;
      case 'restaurant':
        return Icons.restaurant;
      case 'fastfood':
        return Icons.fastfood;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'education':
        return Icons.school;
      case 'food':
        return Icons.fastfood;
      case 'food_items':
        return Icons.restaurant_menu;
      case 'account_balance':
        return Icons.account_balance;
      case 'movie':
        return Icons.movie;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'miscellaneous_services':
        return Icons.miscellaneous_services;
      default:
        return Icons.category;
    }
  }

  // Helper method to get sample items if none are available from database
  List<Item> _getSampleItems(int businessId) {
    return [
      Item(
        id: 1,
        businessId: businessId,
        itemName: "Rice",
        itemPrice: 25.0,
        itemDescription: "Premium quality Rice package - 1kg",
      ),
      Item(
        id: 2,
        businessId: businessId,
        itemName: "Wheat Flour",
        itemPrice: 35.0,
        itemDescription: "Fine ground wheat flour - 2kg bag",
      ),
      Item(
        id: 3,
        businessId: businessId,
        itemName: "Sugar",
        itemPrice: 42.0,
        itemDescription: "Refined white sugar - 1kg",
      ),
      Item(
        id: 4,
        businessId: businessId,
        itemName: "Cooking Oil",
        itemPrice: 120.0,
        itemDescription: "Pure sunflower oil - 1 liter",
      ),
      Item(
        id: 5,
        businessId: businessId,
        itemName: "Dal",
        itemPrice: 65.0,
        itemDescription: "Premium yellow dal - 500g packet",
      ),
    ];
  }

  Widget _buildBusinessCard(Business business) {
    double? distance;
    if (_latitude != null &&
        _longitude != null &&
        business.latitude != null &&
        business.longitude != null) {
      distance = _locationService.calculateDistance(
        _latitude!,
        _longitude!,
        business.latitude!,
        business.longitude!,
      );
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              business.businessName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              business.businessType ?? 'Business',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Replace review section with items section
            FutureBuilder<List<Item>>(
              future:
                  DatabaseHelper.instance.getItemsByBusinessId(business.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                int itemCount = 5; // Default to 5 sample items
                List<Item> items = [];

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  itemCount = snapshot.data!.length;
                  items = snapshot.data!;
                } else {
                  items = _getSampleItems(business.id!);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Items: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const Icon(Icons.shopping_basket,
                            color: Colors.blue, size: 18),
                        Text(' $itemCount items available'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Display first 3 sample items
                    ...items
                        .take(3)
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.itemName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'Rs ${item.itemPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    if (itemCount > 3)
                      Text(
                        '+ ${itemCount - 3} more items...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                  ],
                );
              },
            ),
            if (distance != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.place, color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${distance.toStringAsFixed(1)} km',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Show details in a dialog
                  _showBusinessDetails(business);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBusinessDetails(Business business) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(business.businessName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (business.businessType != null) ...[
                  const Text('Type:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(business.businessType!),
                  const SizedBox(height: 8),
                ],
                if (business.businessDescription != null) ...[
                  const Text('Description:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(business.businessDescription!),
                  const SizedBox(height: 8),
                ],
                const Text('Address:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(business.businessAddress),
                const SizedBox(height: 8),
                if (business.contactNumber != null) ...[
                  const Text('Contact:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(business.contactNumber!),
                  const SizedBox(height: 8),
                ],
                const Text('Email:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(business.email),
                const SizedBox(height: 16),
                FutureBuilder<List<Item>>(
                  future: DatabaseHelper.instance
                      .getItemsByBusinessId(business.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    int itemCount = 5; // Default to 5 sample items
                    List<Item> items = [];

                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      itemCount = snapshot.data!.length;
                      items = snapshot.data!;
                    } else {
                      items = _getSampleItems(business.id!);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Items: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const Icon(Icons.shopping_basket,
                                color: Colors.blue, size: 18),
                            Text(' $itemCount items available'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Display first 3 sample items
                        ...items
                            .take(3)
                            .map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.itemName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        'Rs ${item.itemPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        if (itemCount > 3)
                          Text(
                            '+ ${itemCount - 3} more items...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
