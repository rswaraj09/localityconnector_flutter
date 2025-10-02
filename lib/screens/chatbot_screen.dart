import 'package:flutter/material.dart';
import '../models/business.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  String _currentCategory = 'Grocery';
  bool _showGroceryStores = false;
  bool _showGroceryMessage = false;
  List<Business> _groceryStores = [];

  @override
  void initState() {
    super.initState();
    _initializeGroceryStores();
  }

  void _initializeGroceryStores() {
    // Hardcoded grocery stores data as shown in the screenshots
    _groceryStores = [
      Business(
        id: 1,
        businessName: "Vishal General Store",
        businessType: "Grocery",
        businessDescription: "General grocery store with wide variety of items",
        businessAddress: "Dhamini, Khalapur, Raigad, Maharashtra",
        email: "vishalstore@example.com",
        password: "password",
        longitude: 73.2694553,
        latitude: 18.8208955,
        distance: 0.00,
      ),
      Business(
        id: 2,
        businessName: "Aniket Kirana",
        businessType: "Grocery",
        businessDescription: "Local grocery store with daily essentials",
        businessAddress: "Dhamini, Khalapur, Maharashtra",
        email: "aniketkirana@example.com",
        password: "password",
        longitude: 73.26945,
        latitude: 18.82085,
        distance: 0.00,
      ),
      Business(
        id: 3,
        businessName: "Vishal General Store",
        businessType: "Grocery",
        businessDescription: "Another branch of Vishal General Store",
        businessAddress: "Dhamini, Khalapur, Raigad, Maharashtra",
        email: "vishalstore2@example.com",
        password: "password",
        longitude: 73.269,
        latitude: 18.820,
        distance: 0.10,
      ),
      Business(
        id: 4,
        businessName: "Lotta General Store",
        businessType: "Grocery",
        businessDescription: "Family-owned general store with groceries",
        businessAddress: "Dhamini, Khalapur, Maharashtra",
        email: "lottastore@example.com",
        password: "password",
        longitude: 73.268,
        latitude: 18.819,
        distance: 0.15,
      ),
      Business(
        id: 5,
        businessName: "HariNam Kirana",
        businessType: "Grocery",
        businessDescription: "Traditional grocery store with local products",
        businessAddress: "Khumbhivali, Maharashtra",
        email: "harinamkirana@example.com",
        password: "password",
        longitude: 73.265,
        latitude: 18.816,
        distance: 0.25,
      ),
    ];
  }

  void _showSelectedCategory(String category) {
    setState(() {
      _currentCategory = category;
      if (category == 'Grocery') {
        _showGroceryMessage = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _showGroceryStores = true;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _showGroceryStores = false;
                _showGroceryMessage = false;
              });
            },
          ),
        ],
      ),
      body: _showGroceryStores
          ? _buildGroceryStoresList()
          : _buildChatInterface(),
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Hello! I'm your Locality Connector Assistant. How can I help you find local services today?",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                if (_showGroceryMessage)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: const Text(
                            "Grocery",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Here are the grocery stores near you:",
                              style: TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 16.0),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Name: Vishal General Store",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                      "Address: Dhamini, Khalapur, Raigad, Maharashtra"),
                                  const Text("Longitude: 73.2694553"),
                                  const Text("Latitude: 18.8208955"),
                                  const SizedBox(height: 8.0),
                                  Center(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        // Handle locate on map
                                      },
                                      icon: const Icon(Icons.location_on),
                                      label: const Text("Locate on map"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const Spacer(),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _categoryButton('Grocery', Colors.deepPurple),
              _categoryButton('Restaurants', Colors.blue.shade700),
              _categoryButton('Pharmacies', Colors.green.shade700),
              _categoryButton('Shops', Colors.orange.shade700),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoryButton(String label, Color color) {
    final isSelected = label == _currentCategory;

    return ElevatedButton(
      onPressed: () {
        _showSelectedCategory(label);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      child: Text(label),
    );
  }

  Widget _buildGroceryStoresList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  selected: true,
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.deepPurple.shade100,
                  checkmarkColor: Colors.deepPurple,
                  label: const Text('Grocery'),
                  onSelected: (selected) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  selected: false,
                  backgroundColor: Colors.grey.shade200,
                  label: const Text('Pharmacy'),
                  onSelected: (selected) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  selected: false,
                  backgroundColor: Colors.grey.shade200,
                  label: const Text('Restaurant'),
                  onSelected: (selected) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  selected: false,
                  backgroundColor: Colors.grey.shade200,
                  label: const Text('Education'),
                  onSelected: (selected) {},
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: FilterChip(
                    selected: false,
                    backgroundColor: Colors.white,
                    label: const Text('Food Items'),
                    onSelected: (selected) {},
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _groceryStores.length,
            itemBuilder: (context, index) {
              final store = _groceryStores[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    store.businessName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.businessAddress),
                      Text('Category: ${store.businessType}'),
                      Text(
                        store.distance == 0.0
                            ? 'Distance: 0.00 km'
                            : 'Distance: ${store.distance?.toStringAsFixed(2)} km',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Handle navigation to business details
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
