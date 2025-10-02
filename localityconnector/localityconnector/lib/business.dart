import 'package:flutter/material.dart';
import 'package:localityconnector/models/business.dart';
import 'package:localityconnector/models/database_helper.dart';
import 'package:localityconnector/screens/business_listings_screen.dart';
import 'package:localityconnector/screens/business_profile_screen.dart';
import 'package:localityconnector/screens/business_order_details_screen.dart';
import 'package:localityconnector/services/location_service.dart';
import 'package:localityconnector/widgets/app_layout.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localityconnector/services/firestore_service.dart';

class BusinessDashboard extends StatefulWidget {
  final Business business;

  const BusinessDashboard({super.key, required this.business});

  @override
  _BusinessDashboardState createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  late Business _business;
  final LocationService _locationService = LocationService();
  bool _isLoading = false;
  String _message = '';
  bool _showMessage = false;

  @override
  void initState() {
    super.initState();
    _business = widget.business;
  }

  Future<void> _updateBusinessData() async {
    final updatedBusiness =
        await DatabaseHelper.instance.getBusinessById(_business.id!);
    if (updatedBusiness != null) {
      setState(() {
        _business = updatedBusiness;
      });
    }
  }

  Future<void> _fetchAndSaveLocation() async {
    setState(() {
      _isLoading = true;
      _showMessage = false;
    });

    try {
      // Request location permission and get current position
      Position position = await _locationService.getCurrentLocation();

      print(
          'Got current location: lat=${position.latitude}, lng=${position.longitude}');
      print(
          'Current business: id=${_business.id}, name=${_business.businessName}, email=${_business.email}');

      // Update business with new coordinates
      Business updatedBusiness = Business(
        id: _business.id,
        businessName: _business.businessName,
        businessType: _business.businessType,
        businessDescription: _business.businessDescription,
        businessAddress: _business.businessAddress,
        contactNumber: _business.contactNumber,
        email: _business.email,
        password: _business.password,
        latitude: position.latitude,
        longitude: position.longitude,
        categoryId: _business.categoryId,
        averageRating: _business.averageRating,
        totalReviews: _business.totalReviews,
      );

      // Save to local database
      await DatabaseHelper.instance.updateBusiness(updatedBusiness);
      print('Updated business location in local database');

      // Save to Firebase in real-time - ALWAYS pass the email for reliable identification
      try {
        print(
            'Attempting to update business location in Firebase for ${_business.email}');
        int result = await FirestoreService.instance.updateBusinessLocation(
            _business.id!, position.latitude, position.longitude,
            businessEmail: _business.email);
        print('Firebase location update result: $result');

        if (result == 0) {
          print(
              'Failed to update Firebase: No matching business document found');
          // Try force update as a reliable fallback
          print('Attempting force update for business ${_business.email}');
          result = await FirestoreService.instance
              .forceUpdateBusinessLocation(updatedBusiness);
          print('Firebase force update result: $result');
        }
      } catch (e) {
        print('Firebase update error: $e');
      }

      // Update local business object
      setState(() {
        _business = updatedBusiness;
        _message = 'Location updated successfully!';
        _showMessage = true;
      });
    } catch (e) {
      setState(() {
        _message = 'Error updating location: $e';
        _showMessage = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });

      // Hide message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showMessage = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('Business Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _confirmLogout(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero section
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _business.businessName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCoordinatesDisplay(),
                    ],
                  ),
                ),

                // Content section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Manage Listings
                      _buildGridRow(
                        icon: Icons.list_alt,
                        title: 'Manage Listings',
                        subtitle: 'Add, edit or remove your business listings',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BusinessListingsScreen(business: _business),
                            ),
                          ).then((_) => _updateBusinessData());
                        },
                      ),

                      const SizedBox(height: 16),

                      // Update Location
                      _buildGridRow(
                        icon: Icons.location_on,
                        title: 'Update Location',
                        subtitle: 'Fetch and save your current location',
                        onTap: _fetchAndSaveLocation,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 16),

                      // Update Profile
                      _buildGridRow(
                        icon: Icons.business,
                        title: 'Update Profile',
                        subtitle: 'Edit your business information',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BusinessProfileScreen(business: _business),
                            ),
                          ).then((_) => _updateBusinessData());
                        },
                      ),

                      const SizedBox(height: 16),

                      // View Customer Feedback
                      _buildGridRow(
                        icon: Icons.shopping_bag,
                        title: 'Order Details',
                        subtitle: 'View and manage customer orders',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusinessOrderDetailsScreen(
                                  business: _business),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Message overlay
          if (_showMessage)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _message.contains('Error')
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('Error')
                        ? Colors.red.shade800
                        : Colors.green.shade800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return AppLayout(
      contextData: {
        'currentLocation': _business.businessAddress,
      },
      showChatBubble: false,
      child: scaffold,
    );
  }

  Widget _buildCoordinatesDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Coordinates:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Latitude: ${_business.latitude ?? 'Not set'}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          Text(
            'Longitude: ${_business.longitude ?? 'Not set'}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin_business',
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
