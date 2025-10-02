import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/business.dart';

class BusinessOrderDetailsScreen extends StatelessWidget {
  final Business business;

  const BusinessOrderDetailsScreen({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOrderSummary(),
          const SizedBox(height: 16),
          _buildOrderCard(
            orderNumber: 1,
            name: 'Swaraj',
            item: 'VadaPav',
            quantity: '1',
            latitude: 18.820624343935005,
            longitude: 73.27126336196883,
          ),
          const SizedBox(height: 16),
          _buildOrderCard(
            orderNumber: 2,
            name: 'Shubham',
            item: 'Dal',
            quantity: '1KG',
            latitude: 18.820624343935005,
            longitude: 73.27126336196883,
          ),
          const SizedBox(height: 16),
          _buildOrderCard(
            orderNumber: 3,
            name: 'Ritik',
            item: 'Rice Basmati',
            quantity: '1KG',
            latitude: 18.820624343935005,
            longitude: 73.27126336196883,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(Icons.receipt, 'Total Orders', '3'),
              _buildSummaryItem(Icons.pending_actions, 'Pending', '0'),
              _buildSummaryItem(Icons.check_circle, 'Completed', '3'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue[700]),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildOrderCard({
    required int orderNumber,
    required String name,
    required String item,
    required String quantity,
    required double latitude,
    required double longitude,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #$orderNumber',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildOrderDetail('Name', name),
            _buildOrderDetail('Item', item),
            _buildOrderDetail('Quantity', quantity),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _launchMapsUrl(latitude, longitude),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'View Location',
                      style: TextStyle(
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchMapsUrl(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
