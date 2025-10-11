import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// --- 1. Enhanced Ingredient Data Model (IMMUTABLE) ---
class Ingredient {
  final String name;
  final IconData icon;
  final double price;
  final String category;
  final Map<String, String> nutritionalValue;

  // FINAL for immutability and safety - must always be provided
  final double quantityAvailable;

  // Getter for availability check
  bool get isAvailable => quantityAvailable > 0;

  Ingredient({
    required this.name,
    required this.icon,
    required this.price,
    required this.category,
    required this.nutritionalValue,
    required this.quantityAvailable,
  });

  // **Critical Fix: copyWith method for safe state updates**
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

// --- 2. Ingredient List Widget ---
class IngredientPage extends StatefulWidget {
  const IngredientPage({super.key});

  @override
  State<IngredientPage> createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  // --- Combined and Corrected Mock Ingredient Data ---
  final List<Ingredient> _ingredients = [
    // Vegetables
    Ingredient(
      name: 'Carrot',
      icon: FontAwesomeIcons.carrot,
      price: 50,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '41', 'Protein': '0.9g'},
      quantityAvailable: 15.5,
    ),
    Ingredient(
      name: 'Broccoli',
      icon: FontAwesomeIcons.seedling,
      price: 70,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '55', 'Protein': '3.7g'},
      quantityAvailable: 2.0,
    ),
    Ingredient(
      name: 'Spinach',
      icon: FontAwesomeIcons.leaf,
      price: 40,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '23', 'Protein': '2.9g'},
      quantityAvailable: 0.0,
    ),
    Ingredient(
      name: 'Tomato',
      icon: FontAwesomeIcons.appleWhole,
      price: 30,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '18', 'Protein': '0.9g'},
      quantityAvailable: 40.8,
    ),
    Ingredient(
      name: 'Cucumber',
      icon: FontAwesomeIcons.seedling,
      price: 25,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '16', 'Protein': '0.7g'},
      quantityAvailable: 12.3,
    ),
    Ingredient(
      name: 'Onion',
      icon: FontAwesomeIcons.hand,
      price: 35,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '40', 'Protein': '1.1g'},
      quantityAvailable: 55.0,
    ),
    Ingredient(
      name: 'Garlic',
      icon: FontAwesomeIcons.circleDot,
      price: 100,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '149', 'Protein': '6.4g'},
      quantityAvailable: 5.5,
    ),
    Ingredient(
      name: 'Potato',
      icon: FontAwesomeIcons.solidCircle,
      price: 20,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '77', 'Protein': '2g'},
      quantityAvailable: 80.0,
    ),
    Ingredient(
      name: 'Bell Pepper',
      icon: FontAwesomeIcons.pepperHot,
      price: 60,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '31', 'Protein': '1g'},
      quantityAvailable: 10.0,
    ),
    Ingredient(
      name: 'Lettuce',
      icon: FontAwesomeIcons.leaf,
      price: 45,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '15', 'Protein': '1.4g'},
      quantityAvailable: 3.2,
    ),
    Ingredient(
      name: 'Zucchini',
      icon: FontAwesomeIcons.seedling,
      price: 55,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '17', 'Protein': '1.2g'},
      quantityAvailable: 1.5,
    ),
    Ingredient(
      name: 'Eggplant',
      icon: FontAwesomeIcons.seedling,
      price: 45,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '25', 'Protein': '1g'},
      quantityAvailable: 4.0,
    ),
    Ingredient(
      name: 'Cabbage',
      icon: FontAwesomeIcons.leaf,
      price: 30,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '25', 'Protein': '1.3g'},
      quantityAvailable: 20.0,
    ),
    Ingredient(
      name: 'Cauliflower',
      icon: FontAwesomeIcons.seedling,
      price: 65,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '25', 'Protein': '1.9g'},
      quantityAvailable: 1.0,
    ),
    Ingredient(
      name: 'Mushroom',
      icon: FontAwesomeIcons.seedling,
      price: 85,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '22', 'Protein': '3.1g'},
      quantityAvailable: 0.5,
    ),
    Ingredient(
      name: 'Radish',
      icon: FontAwesomeIcons.seedling,
      price: 25,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '16', 'Protein': '0.7g'},
      quantityAvailable: 5.0,
    ),
    Ingredient(
      name: 'Sweet Potato',
      icon: FontAwesomeIcons.seedling,
      price: 35,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '86', 'Protein': '1.6g'},
      quantityAvailable: 10.0,
    ),
    Ingredient(
      name: 'Artichoke',
      icon: FontAwesomeIcons.seedling,
      price: 95,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '47', 'Protein': '3.3g'},
      quantityAvailable: 0.0,
    ),
    Ingredient(
      name: 'Asparagus',
      icon: FontAwesomeIcons.seedling,
      price: 110,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '20', 'Protein': '2.2g'},
      quantityAvailable: 0.8,
    ),
    Ingredient(
      name: 'Beetroot',
      icon: FontAwesomeIcons.seedling,
      price: 40,
      category: 'Vegetables',
      nutritionalValue: {'Calories': '43', 'Protein': '1.6g'},
      quantityAvailable: 6.0,
    ),

    // Fruits
    Ingredient(
      name: 'Apple',
      icon: FontAwesomeIcons.appleWhole,
      price: 120,
      category: 'Fruits',
      nutritionalValue: {'Calories': '52', 'Protein': '0.3g'},
      quantityAvailable: 30.0,
    ),
    Ingredient(
      name: 'Banana',
      icon: FontAwesomeIcons.appleWhole,
      price: 40,
      category: 'Fruits',
      nutritionalValue: {'Calories': '89', 'Protein': '1.1g'},
      quantityAvailable: 50.0,
    ),
    Ingredient(
      name: 'Orange',
      icon: FontAwesomeIcons.appleWhole,
      price: 80,
      category: 'Fruits',
      nutritionalValue: {'Calories': '47', 'Protein': '0.9g'},
      quantityAvailable: 22.0,
    ),
    Ingredient(
      name: 'Grapes',
      icon: FontAwesomeIcons.appleWhole,
      price: 90,
      category: 'Fruits',
      nutritionalValue: {'Calories': '69', 'Protein': '0.7g'},
      quantityAvailable: 18.0,
    ),
    Ingredient(
      name: 'Strawberry',
      icon: FontAwesomeIcons.appleWhole,
      price: 150,
      category: 'Fruits',
      nutritionalValue: {'Calories': '32', 'Protein': '0.7g'},
      quantityAvailable: 0.2,
    ),
    Ingredient(
      name: 'Mango',
      icon: FontAwesomeIcons.appleWhole,
      price: 100,
      category: 'Fruits',
      nutritionalValue: {'Calories': '60', 'Protein': '0.8g'},
      quantityAvailable: 5.0,
    ),
    Ingredient(
      name: 'Pineapple',
      icon: FontAwesomeIcons.appleWhole,
      price: 70,
      category: 'Fruits',
      nutritionalValue: {'Calories': '50', 'Protein': '0.5g'},
      quantityAvailable: 8.0,
    ),
    Ingredient(
      name: 'Watermelon',
      icon: FontAwesomeIcons.appleWhole,
      price: 50,
      category: 'Fruits',
      nutritionalValue: {'Calories': '30', 'Protein': '0.6g'},
      quantityAvailable: 15.0,
    ),
    Ingredient(
      name: 'Kiwi',
      icon: FontAwesomeIcons.appleWhole,
      price: 130,
      category: 'Fruits',
      nutritionalValue: {'Calories': '61', 'Protein': '1.1g'},
      quantityAvailable: 2.0,
    ),
    Ingredient(
      name: 'Blueberry',
      icon: FontAwesomeIcons.appleWhole,
      price: 200,
      category: 'Fruits',
      nutritionalValue: {'Calories': '57', 'Protein': '0.7g'},
      quantityAvailable: 0.1,
    ),
    Ingredient(
      name: 'Peach',
      icon: FontAwesomeIcons.appleWhole,
      price: 110,
      category: 'Fruits',
      nutritionalValue: {'Calories': '39', 'Protein': '0.9g'},
      quantityAvailable: 3.5,
    ),
    Ingredient(
      name: 'Plum',
      icon: FontAwesomeIcons.appleWhole,
      price: 100,
      category: 'Fruits',
      nutritionalValue: {'Calories': '46', 'Protein': '0.7g'},
      quantityAvailable: 4.0,
    ),
    Ingredient(
      name: 'Cherry',
      icon: FontAwesomeIcons.appleWhole,
      price: 180,
      category: 'Fruits',
      nutritionalValue: {'Calories': '50', 'Protein': '1g'},
      quantityAvailable: 0.0,
    ),
    Ingredient(
      name: 'Pomegranate',
      icon: FontAwesomeIcons.appleWhole,
      price: 140,
      category: 'Fruits',
      nutritionalValue: {'Calories': '83', 'Protein': '1.7g'},
      quantityAvailable: 6.0,
    ),
    Ingredient(
      name: 'Fig',
      icon: FontAwesomeIcons.appleWhole,
      price: 160,
      category: 'Fruits',
      nutritionalValue: {'Calories': '74', 'Protein': '0.8g'},
      quantityAvailable: 1.0,
    ),
    Ingredient(
      name: 'Guava',
      icon: FontAwesomeIcons.appleWhole,
      price: 60,
      category: 'Fruits',
      nutritionalValue: {'Calories': '68', 'Protein': '2.6g'},
      quantityAvailable: 10.0,
    ),
    Ingredient(
      name: 'Lychee',
      icon: FontAwesomeIcons.appleWhole,
      price: 170,
      category: 'Fruits',
      nutritionalValue: {'Calories': '66', 'Protein': '0.8g'},
      quantityAvailable: 0.5,
    ),
    Ingredient(
      name: 'Papaya',
      icon: FontAwesomeIcons.appleWhole,
      price: 55,
      category: 'Fruits',
      nutritionalValue: {'Calories': '43', 'Protein': '0.5g'},
      quantityAvailable: 7.0,
    ),
    Ingredient(
      name: 'Raspberry',
      icon: FontAwesomeIcons.appleWhole,
      price: 220,
      category: 'Fruits',
      nutritionalValue: {'Calories': '52', 'Protein': '1.2g'},
      quantityAvailable: 0.0,
    ),
    Ingredient(
      name: 'Blackberry',
      icon: FontAwesomeIcons.appleWhole,
      price: 210,
      category: 'Fruits',
      nutritionalValue: {'Calories': '43', 'Protein': '1.4g'},
      quantityAvailable: 0.1,
    ),

    // Grains
    Ingredient(
      name: 'Rice',
      icon: FontAwesomeIcons.bowlRice,
      price: 80,
      category: 'Grains',
      nutritionalValue: {'Calories': '130', 'Protein': '2.7g'},
      quantityAvailable: 500.0,
    ),
    Ingredient(
      name: 'Wheat',
      icon: FontAwesomeIcons.wheatAwn,
      price: 60,
      category: 'Grains',
      nutritionalValue: {'Calories': '329', 'Protein': '13.2g'},
      quantityAvailable: 300.0,
    ),
    Ingredient(
      name: 'Oats',
      icon: FontAwesomeIcons.bowlFood,
      price: 100,
      category: 'Grains',
      nutritionalValue: {'Calories': '68', 'Protein': '2.4g'},
      quantityAvailable: 15.0,
    ),
    Ingredient(
      name: 'Quinoa',
      icon: FontAwesomeIcons.bowlFood,
      price: 250,
      category: 'Grains',
      nutritionalValue: {'Calories': '120', 'Protein': '4.1g'},
      quantityAvailable: 5.0,
    ),
    Ingredient(
      name: 'Barley',
      icon: FontAwesomeIcons.wheatAwn,
      price: 70,
      category: 'Grains',
      nutritionalValue: {'Calories': '123', 'Protein': '2.3g'},
      quantityAvailable: 10.0,
    ),
    Ingredient(
      name: 'Corn',
      icon: FontAwesomeIcons.seedling,
      price: 40,
      category: 'Grains',
      nutritionalValue: {'Calories': '86', 'Protein': '3.2g'},
      quantityAvailable: 20.0,
    ),
    Ingredient(
      name: 'Millet',
      icon: FontAwesomeIcons.bowlFood,
      price: 90,
      category: 'Grains',
      nutritionalValue: {'Calories': '378', 'Protein': '11g'},
      quantityAvailable: 8.0,
    ),
    Ingredient(
      name: 'Rye',
      icon: FontAwesomeIcons.wheatAwn,
      price: 85,
      category: 'Grains',
      nutritionalValue: {'Calories': '338', 'Protein': '10g'},
      quantityAvailable: 12.0,
    ),
    Ingredient(
      name: 'Buckwheat',
      icon: FontAwesomeIcons.bowlFood,
      price: 150,
      category: 'Grains',
      nutritionalValue: {'Calories': '343', 'Protein': '13g'},
      quantityAvailable: 4.0,
    ),
    Ingredient(
      name: 'Sorghum',
      icon: FontAwesomeIcons.bowlFood,
      price: 75,
      category: 'Grains',
      nutritionalValue: {'Calories': '329', 'Protein': '11g'},
      quantityAvailable: 9.0,
    ),

    // Proteins
    Ingredient(
      name: 'Chicken Breast',
      icon: FontAwesomeIcons.drumstickBite,
      price: 250,
      category: 'Proteins',
      nutritionalValue: {'Calories': '165', 'Protein': '31g'},
      quantityAvailable: 30.0,
    ),
    Ingredient(
      name: 'Salmon',
      icon: FontAwesomeIcons.fish,
      price: 500,
      category: 'Proteins',
      nutritionalValue: {'Calories': '208', 'Protein': '20g'},
      quantityAvailable: 8.0,
    ),
    Ingredient(
      name: 'Eggs (Dozen)',
      icon: FontAwesomeIcons.egg,
      price: 60,
      category: 'Proteins',
      nutritionalValue: {'Calories': '155', 'Protein': '13g'},
      quantityAvailable: 50.0,
    ),
    Ingredient(
      name: 'Tofu',
      icon: FontAwesomeIcons.cube,
      price: 120,
      category: 'Proteins',
      nutritionalValue: {'Calories': '76', 'Protein': '8g'},
      quantityAvailable: 10.0,
    ),
    Ingredient(
      name: 'Lentils',
      icon: FontAwesomeIcons.seedling,
      price: 90,
      category: 'Proteins',
      nutritionalValue: {'Calories': '116', 'Protein': '9g'},
      quantityAvailable: 40.0,
    ),
    Ingredient(
      name: 'Chickpeas',
      icon: FontAwesomeIcons.seedling,
      price: 80,
      category: 'Proteins',
      nutritionalValue: {'Calories': '364', 'Protein': '19g'},
      quantityAvailable: 35.0,
    ),
    Ingredient(
      name: 'Beef',
      icon: FontAwesomeIcons.drumstickBite,
      price: 400,
      category: 'Proteins',
      nutritionalValue: {'Calories': '250', 'Protein': '26g'},
      quantityAvailable: 15.0,
    ),
    Ingredient(
      name: 'Pork',
      icon: FontAwesomeIcons.drumstickBite,
      price: 350,
      category: 'Proteins',
      nutritionalValue: {'Calories': '242', 'Protein': '27g'},
      quantityAvailable: 12.0,
    ),
    Ingredient(
      name: 'Shrimp',
      icon: FontAwesomeIcons.shrimp,
      price: 450,
      category: 'Proteins',
      nutritionalValue: {'Calories': '99', 'Protein': '24g'},
      quantityAvailable: 5.0,
    ),
    Ingredient(
      name: 'Almonds',
      icon: FontAwesomeIcons.seedling,
      price: 600,
      category: 'Proteins',
      nutritionalValue: {'Calories': '579', 'Protein': '21g'},
      quantityAvailable: 2.0,
    ),

    // Dairy
    Ingredient(
      name: 'Milk',
      icon: FontAwesomeIcons.mugHot,
      price: 50,
      category: 'Dairy',
      nutritionalValue: {'Calories': '42', 'Protein': '3.4g'},
      quantityAvailable: 100.0,
    ),
    Ingredient(
      name: 'Cheese',
      icon: FontAwesomeIcons.cheese,
      price: 200,
      category: 'Dairy',
      nutritionalValue: {'Calories': '402', 'Protein': '25g'},
      quantityAvailable: 5.0,
    ),
    Ingredient(
      name: 'Yogurt',
      icon: FontAwesomeIcons.bowlFood,
      price: 70,
      category: 'Dairy',
      nutritionalValue: {'Calories': '59', 'Protein': '10g'},
      quantityAvailable: 20.0,
    ),
    Ingredient(
      name: 'Butter',
      icon: FontAwesomeIcons.solidHand,
      price: 150,
      category: 'Dairy',
      nutritionalValue: {'Calories': '717', 'Protein': '0.9g'},
      quantityAvailable: 3.0,
    ),
    Ingredient(
      name: 'Cream',
      icon: FontAwesomeIcons.solidHand,
      price: 180,
      category: 'Dairy',
      nutritionalValue: {'Calories': '205', 'Protein': '2.1g'},
      quantityAvailable: 5.0,
    ),
    Ingredient(
      name: 'Paneer',
      icon: FontAwesomeIcons.cube,
      price: 220,
      category: 'Dairy',
      nutritionalValue: {'Calories': '265', 'Protein': '18g'},
      quantityAvailable: 15.0,
    ),
    Ingredient(
      name: 'Ghee',
      icon: FontAwesomeIcons.solidHand,
      price: 300,
      category: 'Dairy',
      nutritionalValue: {'Calories': '900', 'Protein': '0g'},
      quantityAvailable: 2.0,
    ),
    Ingredient(
      name: 'Buttermilk',
      icon: FontAwesomeIcons.mugHot,
      price: 40,
      category: 'Dairy',
      nutritionalValue: {'Calories': '40', 'Protein': '3.3g'},
      quantityAvailable: 10.0,
    ),
    Ingredient(
      name: 'Sour Cream',
      icon: FontAwesomeIcons.solidHand,
      price: 160,
      category: 'Dairy',
      nutritionalValue: {'Calories': '198', 'Protein': '2.4g'},
      quantityAvailable: 1.0,
    ),
    Ingredient(
      name: 'Cottage Cheese',
      icon: FontAwesomeIcons.cheese,
      price: 180,
      category: 'Dairy',
      nutritionalValue: {'Calories': '98', 'Protein': '11g'},
      quantityAvailable: 8.0,
    ),

    // Spices
    Ingredient(
      name: 'Turmeric',
      icon: FontAwesomeIcons.mortarPestle,
      price: 50,
      category: 'Spices',
      nutritionalValue: {'Calories': '354', 'Protein': '8g'},
      quantityAvailable: 1.0,
    ),
    Ingredient(
      name: 'Cumin',
      icon: FontAwesomeIcons.mortarPestle,
      price: 70,
      category: 'Spices',
      nutritionalValue: {'Calories': '375', 'Protein': '18g'},
      quantityAvailable: 0.8,
    ),
    Ingredient(
      name: 'Coriander',
      icon: FontAwesomeIcons.mortarPestle,
      price: 60,
      category: 'Spices',
      nutritionalValue: {'Calories': '298', 'Protein': '12g'},
      quantityAvailable: 1.2,
    ),
    Ingredient(
      name: 'Chili Powder',
      icon: FontAwesomeIcons.pepperHot,
      price: 80,
      category: 'Spices',
      nutritionalValue: {'Calories': '282', 'Protein': '13g'},
      quantityAvailable: 0.5,
    ),
    Ingredient(
      name: 'Ginger',
      icon: FontAwesomeIcons.mortarPestle,
      price: 40,
      category: 'Spices',
      nutritionalValue: {'Calories': '80', 'Protein': '1.8g'},
      quantityAvailable: 2.5,
    ),
    Ingredient(
      name: 'Cinnamon',
      icon: FontAwesomeIcons.mortarPestle,
      price: 100,
      category: 'Spices',
      nutritionalValue: {'Calories': '247', 'Protein': '4g'},
      quantityAvailable: 0.3,
    ),
    Ingredient(
      name: 'Cloves',
      icon: FontAwesomeIcons.mortarPestle,
      price: 120,
      category: 'Spices',
      nutritionalValue: {'Calories': '274', 'Protein': '6g'},
      quantityAvailable: 0.1,
    ),
    Ingredient(
      name: 'Cardamom',
      icon: FontAwesomeIcons.mortarPestle,
      price: 200,
      category: 'Spices',
      nutritionalValue: {'Calories': '311', 'Protein': '11g'},
      quantityAvailable: 0.2,
    ),
    Ingredient(
      name: 'Black Pepper',
      icon: FontAwesomeIcons.mortarPestle,
      price: 90,
      category: 'Spices',
      nutritionalValue: {'Calories': '251', 'Protein': '10g'},
      quantityAvailable: 0.4,
    ),
    Ingredient(
      name: 'Mustard Seeds',
      icon: FontAwesomeIcons.seedling,
      price: 50,
      category: 'Spices',
      nutritionalValue: {'Calories': '508', 'Protein': '26g'},
      quantityAvailable: 1.5,
    ),
  ];

  List<Ingredient> _filteredIngredients = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _filteredIngredients = _ingredients;
    _searchController.addListener(_filterIngredients);
    _expandedCategories = {
      for (var category in _ingredients.map((e) => e.category).toSet())
        category: true,
    };
  }

  // --- Real-Time Update Logic (Add/Remove) ---
  void _updateQuantity(Ingredient ingredient, double amount) {
    setState(() {
      final index = _ingredients.indexWhere((i) => i.name == ingredient.name);

      if (index != -1) {
        final currentIngredient = _ingredients[index];

        // Calculate the new quantity, ensuring it doesn't go below zero
        final newQuantity = (currentIngredient.quantityAvailable + amount)
            .clamp(0.0, double.infinity);

        // Use copyWith to replace the old Ingredient object with a new one
        _ingredients[index] = currentIngredient.copyWith(
          quantityAvailable: newQuantity,
        );

        _filterIngredients();
      }
    });
  }

  void _filterIngredients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredIngredients = _ingredients.where((ingredient) {
        return ingredient.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<Ingredient>> _groupIngredientsByCategory(
    List<Ingredient> ingredients,
  ) {
    final Map<String, List<Ingredient>> grouped = {};
    for (final ingredient in ingredients) {
      if (!grouped.containsKey(ingredient.category)) {
        grouped[ingredient.category] = [];
      }
      grouped[ingredient.category]!.add(ingredient);
    }
    return grouped;
  }

  // --- Widget to display availability and quantity controls ---
  Widget _buildInventoryControls(Ingredient ingredient) {
    Color statusColor;
    String statusText;

    // Determine status based on quantity
    if (ingredient.quantityAvailable <= 0.1) {
      statusColor = Colors.red;
      statusText = 'OUT OF STOCK';
    } else if (ingredient.quantityAvailable <= 5.0) {
      statusColor = Colors.orange;
      statusText = 'LOW STOCK';
    } else {
      statusColor = Colors.green;
      statusText = 'IN STOCK';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Availability Status and Quantity Available
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor, width: 0.5),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),

            Text(
              'Qty: ${ingredient.quantityAvailable.toStringAsFixed(1)} kg/L',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Add/Remove Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Remove Quantity
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.redAccent,
              ),
              iconSize: 20,
              onPressed: () => _updateQuantity(ingredient, -1.0),
              tooltip: 'Remove 1 kg/L',
            ),

            // Add Quantity
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              iconSize: 20,
              onPressed: () => _updateQuantity(ingredient, 1.0),
              tooltip: 'Add 1 kg/L',
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedIngredients = _groupIngredientsByCategory(
      _filteredIngredients,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dynamic Food Inventory',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Ingredients...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 15.0,
                ),
              ),
            ),
          ),
          // Ingredient List
          Expanded(
            child: ListView.builder(
              itemCount: groupedIngredients.keys.length,
              itemBuilder: (context, index) {
                final category = groupedIngredients.keys.elementAt(index);
                final ingredients = groupedIngredients[category]!;

                if (ingredients.isEmpty && _searchController.text.isNotEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ExpansionTile(
                    key: PageStorageKey(category),
                    title: Text(
                      category,
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    initiallyExpanded: _expandedCategories[category] ?? true,
                    onExpansionChanged: (isExpanded) {
                      setState(() {
                        _expandedCategories[category] = isExpanded;
                      });
                    },
                    children: ingredients.map((ingredient) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: FaIcon(
                                    ingredient.icon,
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                    ingredient.name,
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    // Display nutritional values
                                    '${ingredient.nutritionalValue.entries.map((e) => '${e.key}: ${e.value}').join(' | ')}',
                                    style: GoogleFonts.lato(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        // Display the calculated price per 100g
                                        '₹${ingredient.pricePer100g.toStringAsFixed(2)}',
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      Text(
                                        '/ 100g', // Unit of measure
                                        style: GoogleFonts.lato(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: _buildInventoryControls(ingredient),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. Main Application Runner ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Inventory App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.lato().fontFamily,
        useMaterial3: true,
      ),
      home: const IngredientPage(),
    );
  }
}
