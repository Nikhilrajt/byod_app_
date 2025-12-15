// import 'package:cloud_firestore/cloud_firestore.dart';

// class MenuItem {
//   final String id;
//   final String name;
//   final String description;
//   final double price;
//   final String? imageUrl;
//   final String? nutrition;
//   final bool isAvailable;
//   final bool isVeg;
//   final String restaurantId; // Add this field

//   MenuItem({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     this.imageUrl,
//     this.nutrition,
//     this.isAvailable = true,
//     this.isVeg = true,
//     required this.restaurantId, // Default to veg
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       "id": id,
//       "name": name,
//       "description": description,
//       "price": price,
//       "imageUrl": imageUrl,
//       "nutrition": nutrition,
//       "isAvailable": isAvailable,
//       "isVeg": isVeg, // Add this
//       "createdAt": FieldValue.serverTimestamp(),
//       "restaurantId": restaurantId, // Add this
//     };
//   }

//   factory MenuItem.fromMap(Map<String, dynamic> map) {
//     return MenuItem(
//       id: map["id"],
//       name: map["name"],
//       description: map["description"],
//       price: (map["price"] ?? 0).toDouble(),
//       imageUrl: map["imageUrl"],
//       nutrition: map["nutrition"],
//       isAvailable: map["isAvailable"] ?? true,
//       isVeg: map["isVeg"] ?? true,
//       restaurantId: map["restaurantId"], // Add this
//     );
//   }
// }
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
  final bool isHealthy; // Add this line

  final bool isVeg;
  final String restaurantId;
  final bool isCustomizable; // NEW: Can this item be customized?
  final List<VariantGroup> variantGroups; // NEW: Customization options

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.nutrition,
    this.isAvailable = true,
    this.isHealthy = false, // Add this line
    this.isVeg = true,
    required this.restaurantId,
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
      "isVeg": isVeg,
      "createdAt": FieldValue.serverTimestamp(),
      "restaurantId": restaurantId,
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
      isVeg: map["isVeg"] ?? true,
      restaurantId: map["restaurantId"] ?? "",
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
  final String name; // e.g., "Size", "Toppings", "Spice Level"
  bool isHealthy;
  final bool isRequired; // Must customer select at least one?
  final bool allowMultiple; // Can customer select multiple options?
  final int? minSelection; // Minimum selections required
  final int? maxSelection; // Maximum selections allowed
  final List<VariantOption> options; // The actual options

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
  final String name; // e.g., "Large", "Medium", "Extra Cheese"
  final double
  priceModifier; // Additional price (can be 0, positive, or negative)
  final bool isAvailable; // Is this option currently available?

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
