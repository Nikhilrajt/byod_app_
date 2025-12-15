// models/ingredient_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class IngredientModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final double calories;
  final double protein;
  final String unit;
  final double quantityAvailable;
  final String iconName;
  final String restaurantId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  IngredientModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.calories,
    required this.protein,
    required this.unit,
    required this.quantityAvailable,
    required this.iconName,
    required this.restaurantId,
    required this.createdAt,
    this.updatedAt,
  });

  // Copy with method
  IngredientModel copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    double? calories,
    double? protein,
    String? unit,
    double? quantityAvailable,
    String? iconName,
    String? restaurantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IngredientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      unit: unit ?? this.unit,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      iconName: iconName ?? this.iconName,
      restaurantId: restaurantId ?? this.restaurantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'calories': calories,
      'protein': protein,
      'unit': unit,
      'quantityAvailable': quantityAvailable,
      'iconName': iconName,
      'restaurantId': restaurantId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create from Firestore document
  factory IngredientModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IngredientModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      calories: (data['calories'] ?? 0.0).toDouble(),
      protein: (data['protein'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? '',
      quantityAvailable: (data['quantityAvailable'] ?? 0.0).toDouble(),
      iconName: data['iconName'] ?? 'seedling',
      restaurantId: data['restaurantId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }
}