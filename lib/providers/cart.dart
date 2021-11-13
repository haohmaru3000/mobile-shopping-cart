import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
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

  void addItem(
    String productId,
    double price,
    String title,
  ) {
    if (_items.containsKey(productId)) {
      // change quantity...
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners(); // Notify the listeners about the update
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners(); // Notify the listeners about the update
  }

  /* 
   *  Remove the latest item in the list
   */
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      // Checking whether it's actually part of the cart
      return;
    }
    if (_items[productId]!.quantity > 1) {
      // Only reduce the quantity if >1
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else // If = 1, remove the entire item from the map
    {
      // Remove the entire key, also the value mapped to the key from the map
      _items.remove(productId);
    }
    notifyListeners(); // Notify the listeners about the update
  }

  void clear() {
    _items = {};
    notifyListeners(); // Notify the listeners about the update
  }
}
