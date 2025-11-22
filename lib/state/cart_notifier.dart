import 'package:flutter/foundation.dart';

class CartItem {
  final String name;
  final String image;
  final int price;
  final double rating;
  final String restaurantName;
  int qty;

  CartItem({
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.restaurantName,
    this.qty = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'price': price,
      'rating': rating,
      'restaurantName': restaurantName,
      'qty': qty,
    };
  }
}

class CartNotifier extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  double get subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.qty));

  double get deliveryFee => _cartItems.isEmpty ? 0.0 : 3.50;

  double get discount => _cartItems.isEmpty ? 0.0 : 5.00;

  double get total =>
      _cartItems.isEmpty ? 0.0 : subtotal + deliveryFee - discount;

  void addToCart(CartItem item) {
    // Check if item already exists
    final existingIndex = _cartItems.indexWhere((e) => e.name == item.name);

    if (existingIndex != -1) {
      // If item exists, increase quantity
      _cartItems[existingIndex].qty += item.qty;
    } else {
      // If item doesn't exist, add it
      _cartItems.add(item);
    }

    notifyListeners();
  }

  void removeFromCart(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int newQty) {
    if (newQty > 0) {
      _cartItems[index].qty = newQty;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
