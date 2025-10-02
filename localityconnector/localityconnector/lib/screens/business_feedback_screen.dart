import 'package:flutter/material.dart';
import '../models/business.dart';
import '../models/database_helper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class BusinessFeedbackScreen extends StatefulWidget {
  final Business business;

  const BusinessFeedbackScreen({super.key, required this.business});

  @override
  _BusinessFeedbackScreenState createState() => _BusinessFeedbackScreenState();
}

class _BusinessFeedbackScreenState extends State<BusinessFeedbackScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  Map<String, int> _ratingDistribution = {
    '5': 0,
    '4': 0,
    '3': 0,
    '2': 0,
    '1': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await DatabaseHelper.instance.getBusinessReviews(widget.business.id!);
      
      // Calculate rating distribution
      Map<String, int> distribution = {
        '5': 0,
        '4': 0,
        '3': 0,
        '2': 0,
        '1': 0,
      };
      
      for (var review in reviews) {
        int rating = review['rating'].round();
        if (rating >= 1 && rating <= 5) {
          distribution[rating.toString()] = (distribution[rating.toString()] ?? 0) + 1;
        }
      }
      
      setState(() {
        _reviews = reviews;
        _ratingDistribution = distribution;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Feedback'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Overall rating section
                _buildRatingSummary(),
                
                // Reviews list
                Expanded(
                  child: _reviews.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No Reviews Yet',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Your customers haven\'t left any reviews yet.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            return _buildReviewCard(_reviews[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildRatingSummary() {
    final totalReviews = widget.business.totalReviews ?? 0;
    final avgRating = widget.business.averageRating ?? 0.0;
    
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Overall Rating',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingBarIndicator(
                    rating: avgRating,
                    itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 24.0,
                  ),
                  const SizedBox(height: 4),
                  Text('Based on $totalReviews reviews'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Rating distribution bars
          ..._ratingDistribution.entries.toList().reversed.map((entry) {
            final starCount = int.parse(entry.key);
            final count = entry.value;
            final percentage = totalReviews > 0 ? (count / totalReviews) * 100 : 0.0;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text('$starCount★', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 8,
                          width: MediaQuery.of(context).size.width * 0.6 * percentage / 100,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text('$count', textAlign: TextAlign.right),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final DateFormat formatter = DateFormat('MMM d, yyyy');
    final DateTime? createdAt = review['created_at'] != null 
        ? DateTime.parse(review['created_at']) 
        : null;
    final String formattedDate = createdAt != null 
        ? formatter.format(createdAt) 
        : 'Unknown date';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review['username'] ?? 'Anonymous',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RatingBarIndicator(
              rating: review['rating']?.toDouble() ?? 0,
              itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 16.0,
            ),
            if (review['review_text'] != null && review['review_text'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review['review_text']),
            ],
            const SizedBox(height: 8),
            
            // Response section (for future implementation)
            if (review['has_business_response'] == 1) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Your Response:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
              ),
              const SizedBox(height: 4),
              Text(review['business_response'] ?? ''),
            ] else ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: Implement response functionality
                    _showResponseDialog(review);
                  },
                  icon: const Icon(Icons.reply),
                  label: const Text('Respond'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showResponseDialog(Map<String, dynamic> review) {
    final responseController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respond to Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Original Review:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(review['review_text'] ?? '(No review text)'),
            const SizedBox(height: 16),
            TextField(
              controller: responseController,
              decoration: const InputDecoration(
                labelText: 'Your Response',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (responseController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a response')),
                );
                return;
              }
              
              try {
                // TODO: Implement response saving to database
                // For now, just show a message
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Response feature coming soon')),
                );
              } catch (e) {
                print('Error saving response: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error saving response: $e')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
} 