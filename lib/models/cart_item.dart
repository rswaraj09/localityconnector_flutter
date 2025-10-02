import 'package:flutter/foundation.dart';

class CartItem {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });
}

class Cart with ChangeNotifier {
  Map<int, CartItem> _items = {};

  Map<int, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(int productId, String name, double price, String imageUrl) {
    if (_items.containsKey(productId)) {
      // Increase quantity
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      // Add new item
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          name: name,
          price: price,
          quantity: 1,
          imageUrl: imageUrl,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(int productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
