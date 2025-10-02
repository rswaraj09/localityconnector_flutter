import 'package:flutter/material.dart';
import '../models/business.dart';
import 'business_detail_screen.dart';

class NearbyBusinessesScreen extends StatefulWidget {
  final String? category;
  final double? latitude;
  final double? longitude;

  const NearbyBusinessesScreen({
    super.key,
    this.category,
    this.latitude,
    this.longitude,
  });

  @override
  _NearbyBusinessesScreenState createState() => _NearbyBusinessesScreenState();
}

class _NearbyBusinessesScreenState extends State<NearbyBusinessesScreen> {
  String _currentCategory = 'Pharmacy';
  bool _isLoading = true;
  String _error = '';
  List<Business> _businesses = [];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _currentCategory = widget.category!;
    }
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    // For demo purposes, we're using hardcoded data
    _fetchNearbyBusinesses();
  }

  Future<void> _fetchNearbyBusinesses() async {
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
  }

  // Add a method to directly navigate to Metro Medical
  void _openMetroMedical() {
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
      distance: 0.22,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessDetailScreen(businessId: 15),
      ),
    );
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
                        ? _buildEmptyState()
                        : _buildBusinessList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Grocery'),
              selected: _currentCategory == 'Grocery',
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentCategory = 'Grocery';
                  });
                  _fetchNearbyBusinesses();
                }
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Pharmacy'),
              selected: _currentCategory == 'Pharmacy',
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentCategory = 'Pharmacy';
                  });
                  _fetchNearbyBusinesses();
                }
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Restaurant'),
              selected: _currentCategory == 'Restaurant',
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentCategory = 'Restaurant';
                  });
                  _fetchNearbyBusinesses();
                }
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Education'),
              selected: _currentCategory == 'Education',
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentCategory = 'Education';
                  });
                  _fetchNearbyBusinesses();
                }
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Food Items'),
              selected: _currentCategory == 'Food Items',
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentCategory = 'Food Items';
                  });
                  _fetchNearbyBusinesses();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    // For Pharmacy category, directly show the hardcoded businesses
    if (_currentCategory == 'Pharmacy') {
      // Create a mock list of pharmacy businesses
      List<Business> pharmacyBusinesses = [
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

      return ListView.builder(
        itemCount: pharmacyBusinesses.length,
        itemBuilder: (context, index) {
          final business = pharmacyBusinesses[index];
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
                // Directly use businessId as 15 for Metro Medical, 16 for Khumbhivali
                if (business.businessName == "Metro Medical") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BusinessDetailScreen(businessId: 15),
                    ),
                  );
                } else if (business.businessName ==
                    "Khumbhivali Medical Shop") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BusinessDetailScreen(businessId: 16),
                    ),
                  );
                }
              },
            ),
          );
        },
      );
    }

    // For other categories, show the default empty message
    return Center(
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
                _currentCategory = 'Pharmacy';
              });
              _fetchNearbyBusinesses();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessList() {
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
              // Directly use businessId as 15 for Metro Medical, 16 for Khumbhivali
              if (business.businessName == "Metro Medical") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessDetailScreen(businessId: 15),
                  ),
                );
              } else if (business.businessName == "Khumbhivali Medical Shop") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessDetailScreen(businessId: 16),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
