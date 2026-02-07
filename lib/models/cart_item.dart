// lib/models/cart_item.dart

class CartItem {
  final String name;
  final String imageUrl;
  final int price;
  int quantity;
  final String restaurantName;
  final String restaurantId;
  final List<String>? customizations;
  final bool isByod;
  final bool isHealthy;

  CartItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
    required this.restaurantName,
    required this.restaurantId,
    this.customizations,
    this.isByod = true,
    this.isHealthy = false,
  });

  int get totalPrice => price * quantity;

  String get customizationSummary {
    if (customizations == null || customizations!.isEmpty) {
      return '';
    }
    return customizations!.join(' • ');
  }

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
      'isByod': isByod,
      'isHealthy': isHealthy,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      quantity: json['quantity'] ?? 1,
      restaurantName: json['restaurantName'],
      restaurantId: json['restaurantId'],
      customizations: json['customizations'] != null
          ? List<String>.from(json['customizations'])
          : null,
      isByod: json['isByod'] ?? false,
      isHealthy: json['isHealthy'] ?? false,
    );
  }
}
