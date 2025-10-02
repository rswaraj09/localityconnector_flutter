class Review {
  final int? id;
  final int businessId;
  final int userId;
  final double rating;
  final String? reviewText;
  final String? createdAt;
  final String? username; // Used when fetching review with username

  Review({
    this.id,
    required this.businessId,
    required this.userId,
    required this.rating,
    this.reviewText,
    this.createdAt,
    this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'user_id': userId,
      'rating': rating,
      'review_text': reviewText,
      'created_at': createdAt,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      businessId: map['business_id'],
      userId: map['user_id'],
      rating: map['rating']?.toDouble() ?? 0.0,
      reviewText: map['review_text'],
      createdAt: map['created_at'],
      username: map['username'],
    );
  }
} 