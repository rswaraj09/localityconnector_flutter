import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';
import '../models/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  String _statusMessage = '';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username ?? '';
    _emailController.text = widget.user.email ?? '';
    _addressController.text = widget.user.address ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      // Create updated user object
      final updatedUser = User(
        id: widget.user.id,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: widget.user.password, // Keep existing password
        address: _addressController.text.trim(),
      );

      // Update in database
      await DatabaseHelper.instance.updateUser(updatedUser);

      // Update in Firestore if available
      try {
        await FirestoreService.instance.updateUser(updatedUser);
      } catch (e) {
        print('Error updating user in Firestore: $e');
        // Continue since local update was successful
      }

      setState(() {
        _isLoading = false;
        _statusMessage = 'Profile updated successfully!';
        _isSuccess = true;
      });

      // Return the updated user to the previous screen
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, updatedUser);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error updating profile: ${e.toString()}';
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Profile Icon
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Address field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Update button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Profile',
                          style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 20),

              // Status message
              if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isSuccess
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _isSuccess
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
