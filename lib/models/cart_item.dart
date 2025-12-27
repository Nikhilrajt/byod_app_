// lib/models/cart_item.dart

class CartItem {
  final String name;
  final String imageUrl;
  final int price;
  int quantity;
  final String restaurantName;
  final String restaurantId;
  final List<String>? customizations;

  CartItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.restaurantName,
    required this.restaurantId,
    this.customizations,
  });

  int get totalPrice => price * quantity;

  // ============================
  // 🔥 ADDED FOR PERSISTENCE
  // ============================
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'restaurantName': restaurantName,
      'restaurantId': restaurantId,
      'customizations': customizations,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      quantity: json['quantity'],
      restaurantName: json['restaurantName'],
      restaurantId: json['restaurantId'],
      customizations:
          json['customizations'] != null
              ? List<String>.from(json['customizations'])
              : null,
    );
  }
}
