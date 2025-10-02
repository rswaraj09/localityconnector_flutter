// // Method to fetch businesses by category name
// Future<void> _fetchBusinessesByCategory(String categoryQuery) async {
//   setState(() {
//     _isTyping = true;
//   });
//
//   try {
//     int? categoryId;
//
//     // Map the query to a category ID
//     if (categoryQuery == 'Grocery') {
//       categoryId = _categoryIds['Grocery'];
//     } else if (categoryQuery == 'Restaurants') {
//       categoryId = _categoryIds['Restaurant'];
//     } else if (categoryQuery == 'Pharmacies') {
//       categoryId = _categoryIds['Pharmacy'];
//     } else if (categoryQuery == 'Retail stores') {
//       categoryId = _categoryIds['Retail stores'];
//     }
//
//     if (categoryId != null) {
//       // Show loading message
//       setState(() {
//         _chatMessages.add({
//           'role': 'user',
//           'message': categoryQuery,
//         });
//         _chatMessages.add({
//           'role': 'assistant',
//           'message': 'Fetching ${categoryQuery.toLowerCase()}...',
//         });
//       });
//
//       // Scroll to bottom to show loading message
//       _scrollToBottom();
//
//       // Fetch businesses from the database
//       List<Business> businesses = [];
//       try {
//         // First try to get businesses by their category ID
//         businesses =
//             await DatabaseHelper.instance.getBusinessesByCategory(categoryId);
//       } catch (e) {
//         print('Error fetching businesses by category ID: $e');
//         // Will fall back to filtering existing businesses
//       }
//
//       // If we got businesses, update the list
//       if (businesses.isNotEmpty) {
//         setState(() {
//           _businessList = businesses;
//           // Remove the loading message
//           if (_chatMessages.isNotEmpty &&
//               _chatMessages.last['role'] == 'assistant' &&
//               _chatMessages.last['message']!.contains('Fetching')) {
//             _chatMessages.removeLast();
//             _chatMessages.removeLast(); // Remove user message too
//           }
//         });
//       } else {
//         // Fall back to all businesses filtered by category type
//         String categoryType = categoryQuery.toLowerCase();
//         if (categoryQuery == 'Grocery') categoryType = 'grocery';
//         if (categoryQuery == 'Restaurants') categoryType = 'restaurant';
//         if (categoryQuery == 'Pharmacies') categoryType = 'pharmacy';
//         if (categoryQuery == 'Retail stores') categoryType = 'retail';
//
//         // Load all businesses if our current list is empty
//         if (_businessList.isEmpty) {
//           await _loadAllBusinessesFromDatabase();
//         }
//
//         final filteredBusinesses = _businessList.isNotEmpty
//             ? _businessList
//                 .where((b) =>
//                     (b.businessType?.toLowerCase().contains(categoryType) ==
//                         true) ||
//                     (categoryQuery == 'Grocery' && b.categoryId == 1) ||
//                     (categoryQuery == 'Restaurants' && b.categoryId == 3) ||
//                     (categoryQuery == 'Pharmacies' && b.categoryId == 2))
//                 .toList()
//             : <Business>[];
//
//         setState(() {
//           if (filteredBusinesses.isNotEmpty) {
//             _businessList = filteredBusinesses;
//           }
//           // Remove the loading message
//           if (_chatMessages.isNotEmpty &&
//               _chatMessages.last['role'] == 'assistant' &&
//               _chatMessages.last['message']!.contains('Fetching')) {
//             _chatMessages.removeLast();
//             _chatMessages.removeLast(); // Remove user message too
//           }
//         });
//       }
//     }
//   } catch (e) {
//     print('Error fetching businesses by category: $e');
//     // Remove loading message in case of error
//     setState(() {
//       if (_chatMessages.isNotEmpty &&
//           _chatMessages.last['role'] == 'assistant' &&
//           _chatMessages.last['message']!.contains('Fetching')) {
//         _chatMessages.removeLast();
//         _chatMessages.removeLast(); // Remove user message too
//       }
//     });
//   } finally {
//     setState(() {
//       _isTyping = false;
//     });
//   }
// }
