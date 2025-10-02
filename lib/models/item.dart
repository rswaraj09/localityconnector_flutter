class Item {
  final int? id;
  final int businessId;
  final String itemName;
  final double itemPrice;
  final String itemDescription;
  final String? imageUrl;

  Item({
    this.id,
    required this.businessId,
    required this.itemName,
    required this.itemPrice,
    required this.itemDescription,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'item_name': itemName,
      'item_price': itemPrice,
      'item_description': itemDescription,
      'image_url': imageUrl,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id']?.toString() ?? ''),
      businessId: map['business_id'] is int
          ? map['business_id']
          : int.parse(map['business_id'].toString()),
      itemName: map['item_name'] ?? 'Unnamed Item',
      itemPrice: map['item_price'] is double
          ? map['item_price']
          : double.parse(map['item_price'].toString()),
      itemDescription: map['item_description'] ?? '',
      imageUrl: map['image_url'],
    );
  }
}
