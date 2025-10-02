import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import 'nearby_businesses_screen.dart';

class LocationScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const LocationScreen({
    Key? key,
    this.categoryId,
    this.categoryName,
  }) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final LocationService _locationService = LocationService();
  bool _isLoading = true;
  String _locationText = 'Fetching your location...';
  Position? _currentPosition;
  String? _currentAddress;
  String _error = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryName;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      bool permissionGranted = await _locationService.requestPermission();
      if (!permissionGranted) {
        setState(() {
          _isLoading = false;
          _error = 'Location permission denied';
          _locationText = 'Unable to access location';
        });
        return;
      }

      final position = await _locationService.getCurrentLocation();
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentPosition = position;
        _currentAddress = address;
        _locationText = address ?? 'Location found';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error getting location: $e';
        _locationText = 'Error fetching location';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Location information card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.red, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isLoading
                            ? const Text('Fetching your location...')
                            : _error.isNotEmpty
                                ? Text(_error,
                                    style: const TextStyle(color: Colors.red))
                                : Text(
                                    _locationText,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                      ),
                    ],
                  ),
                  if (_currentPosition != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Coordinates: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Category buttons
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Find Nearby Businesses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _getCurrentLocation,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _buildCategoryGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'All Businesses',
        'icon': Icons.business,
        'category': '',
      },
      {
        'name': 'Grocery',
        'icon': Icons.shopping_cart,
        'category': 'Grocery',
      },
      {
        'name': 'Pharmacy',
        'icon': Icons.local_pharmacy,
        'category': 'Pharmacy',
      },
      {
        'name': 'Restaurant',
        'icon': Icons.restaurant,
        'category': 'Restaurant',
      },
      {
        'name': 'Education',
        'icon': Icons.school,
        'category': 'Education',
      },
      {
        'name': 'Food Items',
        'icon': Icons.fastfood,
        'category': 'Food Items',
      },
    ];

    // If a category is already selected from constructor, highlight it
    if (widget.categoryName != null) {
      return _buildSelectedCategoryView();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () {
            if (_currentPosition != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NearbyBusinessesScreen(
                    selectedCategory: category['category'],
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location not available. Please try again.'),
                ),
              );
            }
          },
          child: Card(
            elevation: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'],
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedCategoryView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Selected Category: ${widget.categoryName ?? 'All Businesses'}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text("View Nearby Businesses"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            if (_currentPosition != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NearbyBusinessesScreen(
                    selectedCategory: widget.categoryName,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location not available. Please try again.'),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          icon: const Icon(Icons.category),
          label: const Text("Change Category"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            setState(() {
              _selectedCategory = null;
            });
          },
        ),
      ],
    );
  }
}
