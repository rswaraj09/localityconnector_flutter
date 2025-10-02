import 'package:flutter/material.dart';
import '../models/business.dart';
import '../models/database_helper.dart';
import '../services/location_service.dart';
import '../services/firestore_service.dart';

class BusinessProfileScreen extends StatefulWidget {
  final Business business;

  const BusinessProfileScreen({super.key, required this.business});

  @override
  _BusinessProfileScreenState createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _businessTypeController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  bool _isLoading = false;
  final _categories = [
    'Grocery',
    'Food Items',
    'Restaurant',
    'Education',
    'Pharmacy',
    'Local Business'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing business data
    _businessNameController =
        TextEditingController(text: widget.business.businessName);
    _businessTypeController =
        TextEditingController(text: _determineBusinessTypeFromCategory());
    _descriptionController =
        TextEditingController(text: widget.business.businessDescription ?? '');
    _addressController =
        TextEditingController(text: widget.business.businessAddress);
    _contactNumberController =
        TextEditingController(text: widget.business.contactNumber ?? '');
    _emailController = TextEditingController(text: widget.business.email);
  }

  @override
  void dispose() {
    // Dispose controllers when no longer needed
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateBusinessProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get coordinates from address
      final locationService = LocationService();
      final coordinates = await locationService
          .getCoordinatesFromAddress(_addressController.text);

      // Determine category ID based on selected business type
      int? categoryId;
      switch (_businessTypeController.text) {
        case 'Grocery':
          categoryId = 1;
          break;
        case 'Pharmacy':
          categoryId = 2;
          break;
        case 'Restaurant':
          categoryId = 3;
          break;
        case 'Education':
          categoryId = 4;
          break;
        case 'Food Items':
          categoryId = 5;
          break;
        case 'Local Business':
          categoryId = 8;
          break;
        default:
          categoryId =
              widget.business.categoryId; // Maintain current if not changed
      }

      // Create updated business object
      final updatedBusiness = widget.business.copyWith(
        businessName: _businessNameController.text,
        businessType: _businessTypeController.text.isEmpty
            ? null
            : _businessTypeController.text,
        businessDescription: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        businessAddress: _addressController.text,
        contactNumber: _contactNumberController.text.isEmpty
            ? null
            : _contactNumberController.text,
        email: _emailController.text,
        latitude: coordinates?.latitude,
        longitude: coordinates?.longitude,
        categoryId: categoryId,
      );

      // Update in local database
      await DatabaseHelper.instance.updateBusiness(updatedBusiness);

      // Update in Firebase in real-time
      await FirestoreService.instance.updateBusiness(updatedBusiness);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      // Navigate back
      Navigator.pop(context, updatedBusiness);
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to determine business type from category id or existing business type
  String _determineBusinessTypeFromCategory() {
    // First check if we already have a business type that matches our categories
    if (widget.business.businessType != null &&
        _categories.contains(widget.business.businessType)) {
      return widget.business.businessType!;
    }

    // If no matching business type, try to determine from category ID
    if (widget.business.categoryId != null) {
      switch (widget.business.categoryId) {
        case 1:
          return 'Grocery';
        case 2:
          return 'Pharmacy';
        case 3:
          return 'Restaurant';
        case 4:
          return 'Education';
        case 5:
          return 'Food Items';
        case 8:
          return 'Local Business';
      }
    }

    // If no match, return the original business type or empty string
    return widget.business.businessType ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Business Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Business Logo/Image Placeholder
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business,
                          size: 60,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Business Name
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter business name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Business Type
                    DropdownButtonFormField<String>(
                      value: _businessTypeController.text.isEmpty
                          ? null
                          : _categories.contains(_businessTypeController.text)
                              ? _businessTypeController.text
                              : null,
                      decoration: const InputDecoration(
                        labelText: 'Business Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: Theme.of(context).textTheme.bodyMedium,
                      hint: const Text('Select a category'),
                      borderRadius: BorderRadius.circular(8),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _businessTypeController.text = newValue ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Business Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Business Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Business Address
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Business Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter business address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Contact Number
                    TextFormField(
                      controller: _contactNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }

                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Update Button
                    ElevatedButton(
                      onPressed: _updateBusinessProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
