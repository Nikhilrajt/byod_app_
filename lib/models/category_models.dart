// lib/models/category_models.dart

class CategoryItem {
  final String name;
  final String imageUrl;
  final int price;
  final double rating;
  final String restaurantId;
  final String restaurantName;
  final bool isAvailable;
  final bool isCustomizable;
  final bool isHealthy;
  final String? description;
  final String? categoryKey; // Used for customization template lookup

  CategoryItem(
    this.name,
    this.imageUrl,
    this.price,
    this.rating,
    this.restaurantId,
    this.restaurantName,
    this.categoryKey,
    this.description,
    this.isAvailable,
    this.isCustomizable,
    this.isHealthy,
  );

  // Convert to CartItem for non-customizable items
  CartItem toCartItem() {
    return CartItem(
      name: name,
      price: price,
      imageUrl: imageUrl,
      restaurantName: restaurantName,
    );
  }
}

class CartItem {
  final String name;
  final int price;
  final String imageUrl;
  final String restaurantName;
  final List<String>? customizations;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restaurantName,
    this.customizations,
    this.quantity = 1,
  });

  int get totalPrice => price * quantity;

  // Create a display-friendly summary of customizations
  String get customizationSummary {
    if (customizations == null || customizations!.isEmpty) {
      return '';
    }
    return customizations!.join(' • ');
  }
}

class CustomizationStep {
  final String title;
  final List<dynamic> options; // Can be String or CustomizationOption
  final bool isSingleChoice;
  final bool isRequired;

  CustomizationStep({
    required this.title,
    required this.options,
    this.isSingleChoice = true,
    this.isRequired = false,
  });

  // Factory for single-choice steps
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

  // Factory for multiple-choice steps
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
