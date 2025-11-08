import 'package:flutter/material.dart';

class Ingredient {
  final String name;
  final IconData icon;
  final double price;
  final String category;
  final Map<String, String> nutritionalValue;

  // Mutable quantity represented as double (kg/L or units)
  final double quantityAvailable;

  Ingredient({
    required this.name,
    required this.icon,
    required this.price,
    required this.category,
    required this.nutritionalValue,
    required this.quantityAvailable,
  });

  Ingredient copyWith({
    String? name,
    IconData? icon,
    double? price,
    String? category,
    Map<String, String>? nutritionalValue,
    double? quantityAvailable,
  }) {
    return Ingredient(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      price: price ?? this.price,
      category: category ?? this.category,
      nutritionalValue: nutritionalValue ?? this.nutritionalValue,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
    );
  }

  double get pricePer100g => price / 10.0;
}
