import 'package:cloud_firestore/cloud_firestore.dart';

// Main MenuItem Model
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? nutrition;
  final bool isAvailable;
  final bool isHealthy;
  final bool isVeg;
  final String restaurantId;
  final String? restaurantName;
  final bool isCustomizable;
  final List<VariantGroup> variantGroups;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.nutrition,
    this.isAvailable = true,
    this.isHealthy = false,
    this.isVeg = true,
    required this.restaurantId,
    this.restaurantName,
    this.isCustomizable = false,
    this.variantGroups = const [],
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
      "isHealthy": isHealthy, // ⭐ ADDED - This was missing!
      "isVeg": isVeg,
      "createdAt": FieldValue.serverTimestamp(),
      "restaurantId": restaurantId,
      "restaurantName": restaurantName, // ⭐ This will now be saved
      "isCustomizable": isCustomizable,
      "variantGroups": variantGroups.map((e) => e.toMap()).toList(),
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      description: map["description"] ?? "",
      price: (map["price"] ?? 0).toDouble(),
      imageUrl: map["imageUrl"],
      nutrition: map["nutrition"],
      isAvailable: map["isAvailable"] ?? true,
      isHealthy: map["isHealthy"] ?? false, // ⭐ ADDED
      isVeg: map["isVeg"] ?? true,
      restaurantId: map["restaurantId"] ?? "",
      restaurantName: map["restaurantName"],
      isCustomizable: map["isCustomizable"] ?? false,
      variantGroups:
          (map["variantGroups"] as List<dynamic>?)
              ?.map((e) => VariantGroup.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// Variant Group (e.g., "Size", "Add-ons", "Spice Level")
class VariantGroup {
  final String id;
  final String name;
  bool isHealthy;
  final bool isRequired;
  final bool allowMultiple;
  final int? minSelection;
  final int? maxSelection;
  final List<VariantOption> options;

  VariantGroup({
    required this.id,
    required this.name,
    this.isRequired = false,
    this.allowMultiple = false,
    this.minSelection,
    this.maxSelection,
    this.isHealthy = false,
    this.options = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "isRequired": isRequired,
      "allowMultiple": allowMultiple,
      "minSelection": minSelection,
      "maxSelection": maxSelection,
      "isHealthy": isHealthy,
      "options": options.map((e) => e.toMap()).toList(),
    };
  }

  factory VariantGroup.fromMap(Map<String, dynamic> map) {
    return VariantGroup(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      isRequired: map["isRequired"] ?? false,
      allowMultiple: map["allowMultiple"] ?? false,
      minSelection: map["minSelection"],
      maxSelection: map["maxSelection"],
      isHealthy: map["isHealthy"] ?? false,
      options:
          (map["options"] as List<dynamic>?)
              ?.map((e) => VariantOption.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// Individual Variant Option (e.g., "Large", "Extra Cheese", "Spicy")
class VariantOption {
  final String id;
  final String name;
  final double priceModifier;
  final bool isAvailable;

  VariantOption({
    required this.id,
    required this.name,
    this.priceModifier = 0.0,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "priceModifier": priceModifier,
      "isAvailable": isAvailable,
    };
  }

  factory VariantOption.fromMap(Map<String, dynamic> map) {
    return VariantOption(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      priceModifier: (map["priceModifier"] ?? 0).toDouble(),
      isAvailable: map["isAvailable"] ?? true,
    );
  }
}
