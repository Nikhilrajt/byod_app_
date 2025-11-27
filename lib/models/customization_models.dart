// class CustomizationOption {
//   final String name;
//   final double priceModifier;
  
//   CustomizationOption(this.name, [this.priceModifier = 0.0]);
// }

// class CustomizationStep {
//   final String title;
//   final List<CustomizationOption> options;
//   final bool isMultipleChoice;
//   final bool isRequired;
  
//   CustomizationStep({
//     required this.title,
//     required this.options,
//     this.isMultipleChoice = false,
//     this.isRequired = false,
//   });
  
//   factory CustomizationStep.singleChoice(
//     String title, 
//     List<dynamic> options, 
//     {bool isRequired = false}
//   ) {
//     return CustomizationStep(
//       title: title,
//       options: options.map((o) => 
//         o is CustomizationOption ? o : CustomizationOption(o.toString())
//       ).toList(),
//       isMultipleChoice: false,
//       isRequired: isRequired,
//     );
//   }
  
//   factory CustomizationStep.multipleChoice(
//     String title, 
//     List<dynamic> options,
//   ) {
//     return CustomizationStep(
//       title: title,
//       options: options.map((o) => 
//         o is CustomizationOption ? o : CustomizationOption(o.toString())
//       ).toList(),
//       isMultipleChoice: true,
//       isRequired: false,
//     );
//   }
// }

// class CustomizationTemplates {
//   static final Map<String, List<CustomizationStep>> templates = {
//     'burger': [
//       CustomizationStep.singleChoice('Choose Your Bun', [
//         CustomizationOption('Sesame Seed Bun', 0),
//         CustomizationOption('Brioche Bun', 10),
//         CustomizationOption('Whole Wheat Bun', 15),
//         CustomizationOption('Gluten-Free Bun', 25),
//       ], isRequired: true),
//       CustomizationStep.singleChoice('Patty Choice', [
//         CustomizationOption('Regular Patty', 0),
//         CustomizationOption('Cheese-Stuffed Patty', 30),
//         CustomizationOption('Veggie Patty', 0),
//         CustomizationOption('Paneer Patty', 20),
//       ], isRequired: true),
//       CustomizationStep.multipleChoice('Toppings', [
//         CustomizationOption('Lettuce', 0),
//         CustomizationOption('Tomato', 0),
//         CustomizationOption('Onion', 0),
//         CustomizationOption('Pickles', 5),
//         CustomizationOption('Jalapeños', 10),
//         CustomizationOption('Extra Cheese', 20),
//         CustomizationOption('Bacon', 30),
//         CustomizationOption('Avocado', 25),
//       ]),
//       CustomizationStep.multipleChoice('Sauces', [
//         CustomizationOption('Ketchup', 0),
//         CustomizationOption('Mustard', 0),
//         CustomizationOption('Mayo', 5),
//         CustomizationOption('BBQ Sauce', 10),
//         CustomizationOption('Hot Sauce', 10),
//         CustomizationOption('Garlic Aioli', 15),
//       ]),
//     ],
    
//     'pizza': [
//       CustomizationStep.singleChoice('Choose Your Crust', [
//         CustomizationOption('Classic Hand-Tossed', 0),
//         CustomizationOption('Thin & Crispy', 0),
//         CustomizationOption('Thick Crust', 20),
//         CustomizationOption('Stuffed Crust', 40),
//       ], isRequired: true),
//       CustomizationStep.singleChoice('Size', [
//         CustomizationOption('Small (8")', -50),
//         CustomizationOption('Medium (10")', 0),
//         CustomizationOption('Large (12")', 50),
//         CustomizationOption('Extra Large (14")', 100),
//       ], isRequired: true),
//       CustomizationStep.singleChoice('Sauce', [
//         CustomizationOption('Tomato Sauce', 0),
//         CustomizationOption('White Sauce', 10),
//         CustomizationOption('Pesto', 20),
//         CustomizationOption('BBQ Sauce', 15),
//       ], isRequired: true),
//       CustomizationStep.multipleChoice('Vegetable Toppings', [
//         CustomizationOption('Mushrooms', 15),
//         CustomizationOption('Onions', 10),
//         CustomizationOption('Bell Peppers', 15),
//         CustomizationOption('Olives', 15),
//         CustomizationOption('Tomatoes', 10),
//         CustomizationOption('Jalapeños', 15),
//       ]),
//       CustomizationStep.multipleChoice('Non-Veg Toppings', [
//         CustomizationOption('Pepperoni', 40),
//         CustomizationOption('Chicken', 40),
//         CustomizationOption('Bacon', 45),
//       ]),
//     ],
    
//     'pasta': [
//       CustomizationStep.singleChoice('Choose Your Pasta', [
//         CustomizationOption('Spaghetti', 0),
//         CustomizationOption('Penne', 0),
//         CustomizationOption('Fusilli', 5),
//         CustomizationOption('Fettuccine', 5),
//       ], isRequired: true),
//       CustomizationStep.singleChoice('Sauce Choice', [
//         CustomizationOption('Tomato Marinara', 0),
//         CustomizationOption('Alfredo', 20),
//         CustomizationOption('Pesto', 25),
//         CustomizationOption('Arrabbiata', 15),
//       ], isRequired: true),
//       CustomizationStep.multipleChoice('Add Protein', [
//         CustomizationOption('Grilled Chicken', 50),
//         CustomizationOption('Prawns', 70),
//         CustomizationOption('Paneer', 40),
//       ]),
//     ],
    
//     'drink': [
//       CustomizationStep.singleChoice('Size', [
//         CustomizationOption('Small (200ml)', -20),
//         CustomizationOption('Medium (300ml)', 0),
//         CustomizationOption('Large (500ml)', 30),
//       ], isRequired: true),
//       CustomizationStep.singleChoice('Ice Level', [
//         CustomizationOption('No Ice', 0),
//         CustomizationOption('Less Ice', 0),
//         CustomizationOption('Regular Ice', 0),
//         CustomizationOption('Extra Ice', 0),
//       ]),
//     ],
//   };
  
//   static List<CustomizationStep>? getTemplate(String? templateKey) {
//     if (templateKey == null) return null;
//     return templates[templateKey.toLowerCase()];
//   }
// }