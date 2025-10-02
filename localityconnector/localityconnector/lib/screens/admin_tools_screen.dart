import 'package:flutter/material.dart';
import '../utils/update_business_data.dart';

class AdminToolsScreen extends StatefulWidget {
  const AdminToolsScreen({Key? key}) : super(key: key);

  @override
  State<AdminToolsScreen> createState() => _AdminToolsScreenState();
}

class _AdminToolsScreenState extends State<AdminToolsScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> _updateBusinessCategories() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Updating business categories...';
    });

    try {
      await UpdateBusinessData.updateBusinessCategories();
      setState(() {
        _statusMessage = 'Successfully updated business categories!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error updating categories: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBusinessLocations() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Updating business locations...';
    });

    try {
      await UpdateBusinessData.updateBusinessLocations();
      setState(() {
        _statusMessage = 'Successfully updated business locations!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error updating locations: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAllBusinessData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Updating all business data...';
    });

    try {
      await UpdateBusinessData.updateAllBusinessData();
      setState(() {
        _statusMessage = 'Successfully updated all business data!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error updating data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Tools'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Business Data Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.category),
              label: const Text('Update Business Categories'),
              onPressed: _isLoading ? null : _updateBusinessCategories,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Update Business Locations'),
              onPressed: _isLoading ? null : _updateBusinessLocations,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('Update All Business Data'),
              onPressed: _isLoading ? null : _updateAllBusinessData,
            ),
            const SizedBox(height: 24),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('Error')
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage.contains('Error')
                        ? Colors.red.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('Error')
                        ? Colors.red.shade800
                        : Colors.green.shade800,
                  ),
                ),
              ),
            const Spacer(),
            const Text(
              'Note: These tools update business data in the Firebase database. Use with caution.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
