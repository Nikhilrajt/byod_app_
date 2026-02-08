import 'cart_item.dart';
export 'cart_item.dart';

class CategoryItem {
  final String name;
  final String imageUrl;
  final num price;
  final double rating;
  final String restaurantId;
  final String restaurantName;
  final bool isAvailable;
  final bool isCustomizable;
  final bool isHealthy;
  final String? description;
  final String? categoryKey;
  final String? calories;

  final List<CustomizationStep>? customizationSteps;

  CategoryItem(
    this.name,
    this.imageUrl,
    this.price,
    this.rating,
    this.restaurantId,
    this.restaurantName, {
    // ------------------------------------------
    // CURLY BRACES START HERE (Named Parameters)
    // ------------------------------------------
    this.categoryKey,
    this.description,
    this.isAvailable = true, // Added default value
    this.isCustomizable = false, // Added default value
    this.isHealthy = false, // Added default value
    this.customizationSteps,
    this.calories,
  });

  // Convert to CartItem for non-customizable items
  CartItem toCartItem() {
    return CartItem(
      name: name,
      imageUrl: imageUrl,
      price: price.toInt(),
      quantity: 1,
      restaurantName: restaurantName,
      restaurantId: restaurantId,
      isByod: false,
      isHealthy: isHealthy,
    );
  }
}

// Keep your CustomizationStep classes as they were (they looked correct)
class CustomizationStep {
  final String title;
  final List<dynamic> options;
  final bool isSingleChoice;
  final bool isRequired;

  CustomizationStep({
    required this.title,
    required this.options,
    this.isSingleChoice = true,
    this.isRequired = false,
  });

  factory CustomizationStep.singleChoice(
    String title,
    List<dynamic> options, {
    bool isRequired = false,
  }) {
    return CustomizationStep(
      title: title,
      options: options,
      isSingleChoice: true,
      isRequired: isRequired,
    );
  }

  factory CustomizationStep.multipleChoice(
    String title,
    List<dynamic> options, {
    bool isRequired = false,
  }) {
    return CustomizationStep(
      title: title,
      options: options,
      isSingleChoice: false,
      isRequired: isRequired,
    );
  }
}

class CustomizationOption {
  final String name;
  final int additionalPrice;

  CustomizationOption(this.name, this.additionalPrice);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomizationOption &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          additionalPrice == other.additionalPrice;

  @override
  int get hashCode => name.hashCode ^ additionalPrice.hashCode;
}
