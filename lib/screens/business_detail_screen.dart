import 'package:flutter/material.dart';
import '../models/business.dart';

class BusinessDetailScreen extends StatefulWidget {
  final int businessId;

  const BusinessDetailScreen({
    Key? key,
    required this.businessId,
  }) : super(key: key);

  @override
  _BusinessDetailScreenState createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  bool _isLoading = true;
  Business? _business;
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _loadBusinessDetails();
  }

  Future<void> _loadBusinessDetails() async {
    // This is a simplified implementation with hardcoded data
    if (widget.businessId == 15) {
      // Metro Medical
      setState(() {
        _business = Business(
          id: 15,
          businessName: "Metro Medical",
          businessType: "Pharmacy",
          businessDescription:
              "Modern pharmacy offering a wide range of medicines and healthcare products",
          businessAddress: "Dhamini, Khalapur, Maharashtra",
          email: "metromedical@gmail.com",
          password: "123456",
          longitude: 73.27559385321833,
          latitude: 18.816934811518898,
          distance: 0.22,
        );

        _items = [
          Item(
            id: 1,
            businessId: widget.businessId,
            itemName: "Paracetamol",
            itemPrice: 25.0,
            itemDescription: "Fever and pain reliever - 10 tablets",
          ),
          Item(
            id: 2,
            businessId: widget.businessId,
            itemName: "Crocin",
            itemPrice: 35.0,
            itemDescription: "Headache and fever medicine - 15 tablets",
          ),
        ];

        _isLoading = false;
      });
    } else if (widget.businessId == 5) {
      // Vimeet Hostel Shop
      setState(() {
        _business = Business(
          id: 5,
          businessName: "Vimeet Hostel Shop",
          businessType: "Grocery",
          businessDescription:
              "Small store providing essentials to hostel students",
          businessAddress: "VIMEET Campus, Khalapur, Maharashtra",
          email: "vimeethostel@gmail.com",
          password: "123456",
          longitude: 73.2743,
          latitude: 18.8189,
          distance: 0.1,
        );

        _items = [
          Item(
            id: 1,
            businessId: widget.businessId,
            itemName: "Notebooks",
            itemPrice: 30.0,
            itemDescription: "College notebooks - pack of 5",
          ),
          Item(
            id: 2,
            businessId: widget.businessId,
            itemName: "Snacks",
            itemPrice: 20.0,
            itemDescription: "Variety of snacks",
          ),
        ];

        _isLoading = false;
      });
    } else {
      // Default case
      setState(() {
        _business = Business(
          id: widget.businessId,
          businessName: "Business #${widget.businessId}",
          businessType: "General",
          businessDescription: "Business description unavailable",
          businessAddress: "Address unavailable",
          email: "email@example.com",
          password: "password",
          distance: 0.0,
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_business?.businessName ?? 'Business Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Header
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _business?.businessName ?? 'Unnamed Business',
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _business?.businessType ?? 'Unknown Type',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _business?.businessAddress ?? 'Address unavailable',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    _business?.businessDescription ??
                        'No description available',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),

            // Items List
            if (_items.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Available Items',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        item.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item.itemDescription),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${item.itemPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Add to cart functionality would go here
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${item.itemName} added to cart'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class Item {
  final int id;
  final int businessId;
  final String itemName;
  final double itemPrice;
  final String itemDescription;

  Item({
    required this.id,
    required this.businessId,
    required this.itemName,
    required this.itemPrice,
    required this.itemDescription,
  });
}
