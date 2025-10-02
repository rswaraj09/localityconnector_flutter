class Item {
  final int? id;
  final int businessId;
  final String itemName;
  final double itemPrice;
  final String? itemDescription;

  Item({
    this.id,
    required this.businessId,
    required this.itemName,
    required this.itemPrice,
    this.itemDescription,
  });

  Item copyWith({
    int? id,
    int? businessId,
    String? itemName,
    double? itemPrice,
    String? itemDescription,
  }) {
    return Item(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      itemName: itemName ?? this.itemName,
      itemPrice: itemPrice ?? this.itemPrice,
      itemDescription: itemDescription ?? this.itemDescription,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'item_name': itemName,
      'item_price': itemPrice,
      'item_description': itemDescription,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      businessId: map['business_id'],
      itemName: map['item_name'],
      itemPrice: map['item_price'].toDouble(),
      itemDescription: map['item_description'],
    );
  }
} 