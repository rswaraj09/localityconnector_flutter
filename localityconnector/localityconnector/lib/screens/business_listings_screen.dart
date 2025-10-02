import 'package:flutter/material.dart';
import '../models/business.dart';
import '../models/item.dart';
import '../models/database_helper.dart';

class BusinessListingsScreen extends StatefulWidget {
  final Business business;

  const BusinessListingsScreen({super.key, required this.business});

  @override
  _BusinessListingsScreenState createState() => _BusinessListingsScreenState();
}

class _BusinessListingsScreenState extends State<BusinessListingsScreen> {
  List<Item> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await DatabaseHelper.instance.getItemsByBusinessId(widget.business.id!);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Listings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _buildEmptyState()
              : _buildItemsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        tooltip: 'Add New Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Items Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first item to get started',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddItemDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item info section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (item.itemDescription != null) ...[
                        Text(
                          item.itemDescription!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        '\$${item.itemPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditItemDialog(context, item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context, item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate input
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in required fields')),
                );
                return;
              }

              double? price = double.tryParse(priceController.text);
              if (price == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid price')),
                );
                return;
              }

              try {
                // Create and save the new item
                final newItem = Item(
                  businessId: widget.business.id!,
                  itemName: nameController.text,
                  itemPrice: price,
                  itemDescription: descriptionController.text.isEmpty ? null : descriptionController.text,
                );

                await DatabaseHelper.instance.insertItem(newItem);
                Navigator.pop(context);
                
                // Reload the items list
                _loadItems();
              } catch (e) {
                print('Error adding item: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding item: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditItemDialog(BuildContext context, Item item) async {
    final nameController = TextEditingController(text: item.itemName);
    final priceController = TextEditingController(text: item.itemPrice.toString());
    final descriptionController = TextEditingController(text: item.itemDescription ?? '');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate input
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in required fields')),
                );
                return;
              }

              double? price = double.tryParse(priceController.text);
              if (price == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid price')),
                );
                return;
              }

              try {
                // Update the item
                final updatedItem = Item(
                  id: item.id,
                  businessId: item.businessId,
                  itemName: nameController.text,
                  itemPrice: price,
                  itemDescription: descriptionController.text.isEmpty ? null : descriptionController.text,
                );

                await DatabaseHelper.instance.updateItem(updatedItem);
                Navigator.pop(context);
                
                // Reload the items list
                _loadItems();
              } catch (e) {
                print('Error updating item: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating item: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Item item) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.itemName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await DatabaseHelper.instance.deleteItem(item.id!);
                Navigator.pop(context);
                
                // Reload the items list
                _loadItems();
              } catch (e) {
                print('Error deleting item: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting item: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 