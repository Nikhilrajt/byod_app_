// lib/state/cart_notifier.dart

import 'package:flutter/foundation.dart';
import '../models/category_models.dart'; 
// Use our CartItem from category_models

class CartNotifier extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;
  
  // Alias for compatibility
  List<CartItem> get items => _cartItems;

  int get itemCount => _cartItems.length;

  int get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  int get deliveryFee => _cartItems.isEmpty ? 0 : 40;

  int get discount => _cartItems.isEmpty ? 0 : 0; // Can be updated for promo codes

  int get total =>
      _cartItems.isEmpty ? 0 : subtotal + deliveryFee - discount;

  void addToCart(CartItem item) {
    // Check if item with same name and same customizations exists
    final existingIndex = _cartItems.indexWhere((e) => 
      e.name == item.name && 
      _areCustomizationsEqual(e.customizations, item.customizations)
    );

    if (existingIndex != -1) {
      // If item exists with same customizations, increase quantity
      _cartItems[existingIndex].quantity += item.quantity;
    } else {
      // If item doesn't exist or has different customizations, add as new item
      _cartItems.add(item);
    }

    notifyListeners();
  }

  // Helper to compare customizations
  bool _areCustomizationsEqual(List<String>? custom1, List<String>? custom2) {
    if (custom1 == null && custom2 == null) return true;
    if (custom1 == null || custom2 == null) return false;
    if (custom1.length != custom2.length) return false;
    
    for (int i = 0; i < custom1.length; i++) {
      if (custom1[i] != custom2[i]) return false;
    }
    return true;
  }

  // Alias methods for compatibility
  void addItem(CartItem item) => addToCart(item);
  
  void add(CartItem item) => addToCart(item);

  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  void removeAt(int index) => removeFromCart(index);

  void updateQuantity(int index, int newQty) {
    if (newQty > 0 && index >= 0 && index < _cartItems.length) {
      _cartItems[index].quantity = newQty;
      notifyListeners();
    } else if (newQty <= 0) {
      // If quantity is 0 or less, remove the item
      removeFromCart(index);
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void clear() => clearCart();

  // Get cart item by index
  CartItem? getItem(int index) {
    if (index >= 0 && index < _cartItems.length) {
      return _cartItems[index];
    }
    return null;
  }
}