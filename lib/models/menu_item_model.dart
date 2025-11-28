import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? nutrition;
  final bool isAvailable;
  final bool isVeg;
  final String restaurantId; // Add this field

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.nutrition,
    this.isAvailable = true,
    this.isVeg = true,
    required this.restaurantId, // Default to veg
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "imageUrl": imageUrl,
      "nutrition": nutrition,
      "isAvailable": isAvailable,
      "isVeg": isVeg, // Add this
      "createdAt": FieldValue.serverTimestamp(),
      "restaurantId": restaurantId, // Add this
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map["id"],
      name: map["name"],
      description: map["description"],
      price: (map["price"] ?? 0).toDouble(),
      imageUrl: map["imageUrl"],
      nutrition: map["nutrition"],
      isAvailable: map["isAvailable"] ?? true,
      isVeg: map["isVeg"] ?? true,
      restaurantId: map["restaurantId"], // Add this
    );
  }
}
