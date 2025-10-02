import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/business.dart';
import '../services/location_service.dart';
import '../services/business_location_service.dart';
import 'business_detail_screen.dart';

class NearbyBusinessesScreen extends StatefulWidget {
  final String? selectedCategory;

  const NearbyBusinessesScreen({
    Key? key,
    this.selectedCategory,
  }) : super(key: key);

  @override
  State<NearbyBusinessesScreen> createState() => _NearbyBusinessesScreenState();
}

class _NearbyBusinessesScreenState extends State<NearbyBusinessesScreen> {
  final LocationService _locationService = LocationService();
  final BusinessLocationService _businessService =
      BusinessLocationService.instance;

  List<Business> _businesses = [];
  bool _isLoading = true;
  String _error = '';
  Position? _currentPosition;
  String? _currentCategory;
  double _radius = 1.0; // Default radius in km

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory ?? 'Grocery';
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
        });
        return;
      }

      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });

      await _fetchNearbyBusinesses();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error getting location: $e';
      });
    }
  }

  Future<void> _fetchNearbyBusinesses() async {
    if (_currentPosition == null) {
      setState(() {
        _isLoading = false;
        _error = 'Location not available';
      });
      return;
    }

    try {
      // Set fixed radius (since we removed the slider)
      _radius = 1.0;

      // For Grocery category, directly add hardcoded businesses
      if (_currentCategory == 'Grocery') {
        setState(() {
          _businesses = [
            Business(
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
                distance: 0.00),
            Business(
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
                distance: 0.00),
            Business(
                id: 9,
                businessName: "Vishal General Store",
                businessType: "Grocery",
                businessDescription:
                    "General grocery store with daily necessities",
                businessAddress: "Dhamini, Khalapur, Raigad, Maharashtra",
                contactNumber: "",
                email: "vishalstore@gmail.com",
                password: "123456",
                longitude: 73.26945532390647,
                latitude: 18.82089551846635,
                categoryId: 1,
                averageRating: null,
                totalReviews: null,
                distance: 0.10),
            Business(
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
                distance: 0.15),
            Business(
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
                distance: 0.25)
          ];
          _isLoading = false;
        });
        return;
      }

      // For Pharmacy category, directly add hardcoded businesses
      if (_currentCategory == 'Pharmacy') {
        setState(() {
          _businesses = [
            Business(
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
                distance: 0.22),
            Business(
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
                distance: 0.35)
          ];
          _isLoading = false;
        });
        return;
      }

      // For Food Items category, directly add hardcoded businesses
      if (_currentCategory == 'Food Items') {
        setState(() {
          _businesses = [
            Business(
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
                distance: 0.15),
            Business(
                id: 5,
                businessName: "Vimeet Canteen",
                businessType: "Restaurant",
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
                distance: 0.17),
            Business(
                id: 7,
                businessName: "Rohit Tapri",
                businessType: "Food Items",
                businessDescription: "Tea stall with snacks and refreshments",
                businessAddress:
                    "In front of Vimeet Dhamini, Khalapur, Maharashtra",
                contactNumber: "",
                email: "rohittapri@gmail.com",
                password: "123456",
                longitude: 73.27041060118721,
                latitude: 18.82177130388928,
                categoryId: 5,
                averageRating: null,
                totalReviews: null,
                distance: 0.22),
            Business(
                id: 8,
                businessName: "Sanjay Tapri",
                businessType: "Food Items",
                businessDescription: "Local tea and snack stall",
                businessAddress: "Dhamini, Khalapur, Maharashtra",
                contactNumber: "",
                email: "sanjaytapri@gmail.com",
                password: "123456",
                longitude: 73.27478996472767,
                latitude: 18.81805404203425,
                categoryId: 5,
                averageRating: null,
                totalReviews: null,
                distance: 0.28),
            Business(
                id: 13,
                businessName: "Siya Bakery",
                businessType: "Food Items",
                businessDescription: "Fresh baked goods and pastries",
                businessAddress: "Dhamini, Khalapur, Maharashtra",
                contactNumber: "",
                email: "siyabakery@gmail.com",
                password: "123456",
                longitude: 73.27544740910682,
                latitude: 18.8173170173419,
                categoryId: 5,
                averageRating: null,
                totalReviews: null,
                distance: 0.32),
            Business(
                id: 14,
                businessName: "OmDhaba",
                businessType: "Food Items",
                businessDescription:
                    "Traditional roadside eatery with authentic dishes",
                businessAddress: "Dhamini, Khalapur, Maharashtra",
                contactNumber: "",
                email: "omdhaba@gmail.com",
                password: "123456",
                longitude: 73.27645270671975,
                latitude: 18.816891887388632,
                categoryId: 5,
                averageRating: null,
                totalReviews: null,
                distance: 0.35)
          ];
          _isLoading = false;
        });
        return;
      }

      // Fetch businesses by category (since 'All' option is removed)
      List<Business> businesses = await _businessService.getNearbyBusinesses(
        userLatitude: _currentPosition!.latitude,
        userLongitude: _currentPosition!.longitude,
        categoryName: _currentCategory!,
        radiusInKm: _radius,
      );

      setState(() {
        _businesses = businesses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error fetching businesses: $e';
      });
    }
  }

  void _updateCategory(String? category) {
    setState(() {
      _currentCategory = category;
      // Set fixed radius
      _radius = 1.0;
    });
    _fetchNearbyBusinesses();
  }

  // Keep this method as a no-op to avoid breaking any references
  void _updateRadius(double radius) {
    // No-op as we've removed the distance slider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.store, size: 22),
            const SizedBox(width: 8),
            Text('Nearby $_currentCategory'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
            tooltip: 'Refresh location and businesses',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterOptions(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text(_error))
                    : _businesses.isEmpty
                        ? Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No $_currentCategory found nearby',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.search),
                                label: const Text('Try Other Categories'),
                                onPressed: () {
                                  setState(() {
                                    _currentCategory = 'Grocery';
                                  });
                                  _fetchNearbyBusinesses();
                                },
                              ),
                            ],
                          ))
                        : _buildBusinessList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            width: double.infinity,
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: [
                FilterChip(
                  label: const Text('Grocery'),
                  selected: _currentCategory == 'Grocery',
                  onSelected: (selected) {
                    if (selected) _updateCategory('Grocery');
                  },
                  selectedColor:
                      Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                FilterChip(
                  label: const Text('Pharmacy'),
                  selected: _currentCategory == 'Pharmacy',
                  onSelected: (selected) {
                    if (selected) _updateCategory('Pharmacy');
                  },
                  selectedColor:
                      Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                FilterChip(
                  label: const Text('Restaurant'),
                  selected: _currentCategory == 'Restaurant',
                  onSelected: (selected) {
                    if (selected) _updateCategory('Restaurant');
                  },
                  selectedColor:
                      Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                FilterChip(
                  label: const Text('Education'),
                  selected: _currentCategory == 'Education',
                  onSelected: (selected) {
                    if (selected) _updateCategory('Education');
                  },
                  selectedColor:
                      Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                FilterChip(
                  label: const Text('Food Items'),
                  selected: _currentCategory == 'Food Items',
                  onSelected: (selected) {
                    if (selected) _updateCategory('Food Items');
                  },
                  selectedColor:
                      Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessList() {
    // For Restaurant category, return a No nearby Restaurants message
    if (_currentCategory == 'Restaurant') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No nearby Restaurants',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no restaurants in your area',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _businesses.length,
      itemBuilder: (context, index) {
        final business = _businesses[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(
              business.businessName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(business.businessAddress),
                if (business.businessType != null &&
                    business.businessType!.isNotEmpty)
                  Text('Category: ${business.businessType}'),
                Text(
                  business.distance == 0.0
                      ? 'Distance: Nearby'
                      : 'Distance: ${(business.distance ?? 0).toStringAsFixed(2)} km',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // All businesses can be accessed directly without login
              if (business.id != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BusinessDetailScreen(businessId: business.id!),
                  ),
                );
              } else {
                _showBusinessDetails(business);
              }
            },
          ),
        );
      },
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
                if (business.distance != null) ...[
                  const Text('Distance:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${business.distance!.toStringAsFixed(2)} km'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
