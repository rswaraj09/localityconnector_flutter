import 'package:flutter/material.dart';
import 'screens/nearby_businesses_screen.dart';
import 'screens/business_detail_screen.dart';
import 'models/cart_item.dart';
import 'utils/provider.dart';
import 'screens/cart_screen.dart';
import 'screens/chatbot_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Cart>(
      create: (context) => Cart(),
      child: MaterialApp(
        title: 'Locality Connector',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
        routes: {
          '/cart': (context) => const CartScreen(),
          '/aiassistant': (context) => const ChatbotScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locality Connector'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (Provider.of<Cart>(context).itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '${Provider.of<Cart>(context).itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/aiassistant');
              },
              child: const Text('AI Assistant'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NearbyBusinessesScreen(
                      category: 'Pharmacy',
                    ),
                  ),
                );
              },
              child: const Text('Find Nearby Pharmacies'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BusinessDetailScreen(
                      businessId: 15,
                    ),
                  ),
                );
              },
              child: const Text('Metro Medical Details'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BusinessDetailScreen(
                      businessId: 5,
                    ),
                  ),
                );
              },
              child: const Text('Vimeet Hostel Shop'),
            ),
          ],
        ),
      ),
    );
  }
}
