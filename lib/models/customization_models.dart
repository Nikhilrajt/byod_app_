// lib/models/customization_models.dart

enum CustomizationType { singleChoice, multiChoice }

class CustomizationStep {
  final String title;
  final List<String> options;
  final CustomizationType type;

  const CustomizationStep(this.title, this.type, this.options);

  CustomizationStep.singleChoice(this.title, this.options)
      : type = CustomizationType.singleChoice;

  CustomizationStep.multiChoice(this.title, this.options)
      : type = CustomizationType.multiChoice;
}

class CategoryItem {
  final String name;
  final String imagePath;
  final double price;
  final double rating;
  final String restaurantName;
  final String description;

  CategoryItem(
    this.name,
    this.imagePath,
    this.price,
    this.rating, [
    this.restaurantName = '',
    this.description = 'A delicious food item waiting for your personal touch.',
  ]);

  // Method to generate a customizable item variant
  CustomizableItem toCustomizableItem(List<CustomizationStep> steps) {
    return CustomizableItem(
      baseItem: this,
      customizationSteps: steps,
      selectedOptions: {},
    );
  }
}

class CustomizableItem {
  final CategoryItem baseItem;
  final List<CustomizationStep> customizationSteps;
  Map<String, List<String>> selectedOptions; // Key: Step Title, Value: Selected Choices

  CustomizableItem({
    required this.baseItem,
    required this.customizationSteps,
    required this.selectedOptions,
  });

  // Calculate the estimated price based on selections
  double get calculatedPrice {
    double extraCost = 0.0;
    
    // Simple logic: assume extra toppings/premium choices add a small cost
    for (var step in customizationSteps) {
      final selections = selectedOptions[step.title] ?? [];
      if (selections.isNotEmpty) {
        // Single choice: check if a non-default/first option was chosen
        if (step.type == CustomizationType.singleChoice && selections.first != step.options.first) {
          extraCost += 5.0; 
        } 
        // Multi-choice: charge a small fee for each add-on topping/sauce
        else if (step.type == CustomizationType.multiChoice) {
           extraCost += selections.length * 5.0; 
        }
      }
    }
    return baseItem.price + extraCost;
  }
}