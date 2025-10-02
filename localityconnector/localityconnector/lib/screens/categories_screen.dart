import 'package:flutter/material.dart';
import '../models/database_helper.dart';
import 'nearby_businesses_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await DatabaseHelper.instance.getAllCategories();

      // Filter out Services category and prepare the filtered list
      List<Map<String, dynamic>> filteredCategories = categories
          .where((category) => category['name'] != 'Services')
          .toList();

      // Check if Education category exists, if not add it
      if (!filteredCategories
          .any((category) => category['name'] == 'Education')) {
        filteredCategories.add({
          'id': categories.length + 1,
          'name': 'Education',
          'description': 'Find schools, colleges, and educational institutions',
          'icon': 'school'
        });
      }

      // Check if Food Items category exists, if not add it
      if (!filteredCategories
          .any((category) => category['name'] == 'Food Items')) {
        filteredCategories.add({
          'id': categories.length + 2,
          'name': 'Food Items',
          'description': 'Explore various food items and specialty shops',
          'icon': 'food_items'
        });
      }

      setState(() {
        _categories = filteredCategories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get icon data from string name
  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'local_pharmacy':
        return Icons.local_pharmacy;
      case 'restaurant':
        return Icons.restaurant;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text('No categories available'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NearbyBusinessesScreen(
                              selectedCategory: category['name'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getIconData(category['icon']),
                              size: 48,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              category['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (category['description'] != null) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  category['description'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
