// lib/state/cart_notifier.dart

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_models.dart';

class CartNotifier extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  // ============================
  // 🔥 ADDED: STORAGE KEY
  // ============================
  static const String _cartKey = 'cart_items';

  CartNotifier() {
    _loadCartFromStorage();
  }

  List<CartItem> get cartItems => _cartItems;

  // Alias for compatibility
  List<CartItem> get items => _cartItems;

  int get itemCount => _cartItems.length;

  int get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  int get deliveryFee => _cartItems.isEmpty ? 0 : 40;

  int get discount => _cartItems.isEmpty ? 0 : 0;

  int get total =>
      _cartItems.isEmpty ? 0 : subtotal + deliveryFee - discount;

  void addToCart(CartItem item) {
    final existingIndex = _cartItems.indexWhere(
      (e) =>
          e.name == item.name &&
          _areCustomizationsEqual(e.customizations, item.customizations),
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += item.quantity;
    } else {
      _cartItems.add(item);
    }

    _saveCartToStorage();
    notifyListeners();
  }

  bool _areCustomizationsEqual(List<String>? custom1, List<String>? custom2) {
    if (custom1 == null && custom2 == null) return true;
    if (custom1 == null || custom2 == null) return false;
    if (custom1.length != custom2.length) return false;

    for (int i = 0; i < custom1.length; i++) {
      if (custom1[i] != custom2[i]) return false;
    }
    return true;
  }

  void addItem(CartItem item) => addToCart(item);
  void add(CartItem item) => addToCart(item);

  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      _saveCartToStorage();
      notifyListeners();
    }
  }

  void removeAt(int index) => removeFromCart(index);

  void updateQuantity(int index, int newQty) {
    if (newQty > 0 && index >= 0 && index < _cartItems.length) {
      _cartItems[index].quantity = newQty;
    } else if (newQty <= 0) {
      removeFromCart(index);
      return;
    }

    _saveCartToStorage();
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _saveCartToStorage();
    notifyListeners();
  }

  void clear() => clearCart();

  CartItem? getItem(int index) {
    if (index >= 0 && index < _cartItems.length) {
      return _cartItems[index];
    }
    return null;
  }

  // ============================
  // 🔥 ADDED: SAVE CART
  // ============================
  Future<void> _saveCartToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson =
        _cartItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_cartKey, cartJson);
  }

  // ============================
  // 🔥 ADDED: LOAD CART
  // ============================
  Future<void> _loadCartFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getStringList(_cartKey);

    if (cartJson != null) {
      _cartItems.clear();
      _cartItems.addAll(
        cartJson.map(
          (item) => CartItem.fromJson(jsonDecode(item)),
        ),
      );
      notifyListeners();
    }
  }
}
