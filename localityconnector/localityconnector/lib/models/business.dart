class Business {
  final int? id;
  final String businessName;
  final String? businessType;
  final String? businessDescription;
  final String businessAddress;
  final String? contactNumber;
  final String email;
  final String password;
  final double? longitude;
  final double? latitude;
  final int? categoryId;
  final double? averageRating;
  final int? totalReviews;
  final double? distance; // Distance from user's location (in kilometers)

  Business({
    this.id,
    required this.businessName,
    this.businessType,
    this.businessDescription,
    required this.businessAddress,
    this.contactNumber,
    required this.email,
    required this.password,
    this.longitude,
    this.latitude,
    this.categoryId,
    this.averageRating,
    this.totalReviews,
    this.distance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_name': businessName,
      'business_type': businessType,
      'business_description': businessDescription,
      'business_address': businessAddress,
      'contact_number': contactNumber,
      'email': email,
      'password': password,
      'longitude': longitude,
      'latitude': latitude,
      'category_id': categoryId,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'distance': distance,
    };
  }

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id']?.toString() ?? ''),
      businessName: map['business_name'] ?? 'Unnamed Business',
      businessType: map['business_type'],
      businessDescription: map['business_description'],
      businessAddress: map['business_address'] ?? 'No address provided',
      contactNumber: map['contact_number'],
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      longitude: map['longitude'] is double
          ? map['longitude']
          : map['longitude'] != null
              ? double.tryParse(map['longitude'].toString())
              : null,
      latitude: map['latitude'] is double
          ? map['latitude']
          : map['latitude'] != null
              ? double.tryParse(map['latitude'].toString())
              : null,
      categoryId: map['category_id'] is int
          ? map['category_id']
          : map['category_id'] != null
              ? int.tryParse(map['category_id'].toString())
              : null,
      averageRating: map['average_rating'] is double
          ? map['average_rating']
          : map['average_rating'] != null
              ? double.tryParse(map['average_rating'].toString())
              : null,
      totalReviews: map['total_reviews'] is int
          ? map['total_reviews']
          : map['total_reviews'] != null
              ? int.tryParse(map['total_reviews'].toString())
              : null,
      distance: map['distance'] is double
          ? map['distance']
          : map['distance'] != null
              ? double.tryParse(map['distance'].toString())
              : null,
    );
  }

  Business copyWith({
    int? id,
    String? businessName,
    String? businessType,
    String? businessDescription,
    String? businessAddress,
    String? contactNumber,
    String? email,
    String? password,
    double? longitude,
    double? latitude,
    int? categoryId,
    double? averageRating,
    int? totalReviews,
    double? distance,
  }) {
    return Business(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      businessDescription: businessDescription ?? this.businessDescription,
      businessAddress: businessAddress ?? this.businessAddress,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      categoryId: categoryId ?? this.categoryId,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      distance: distance ?? this.distance,
    );
  }
}
