import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

// Main App definition (can be removed if this is part of a larger app)
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant BYOD App',
      theme: ThemeData(primarySwatch: Colors.deepOrange, fontFamily: 'Roboto'),
      home: const RestaurantListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ===== RESTAURANT MODEL =====
class Restaurant {
  final String name;
  final String imagePath;
  final double rating;
  final String time;
  final String category;
  final String location;
  final String offer;

  Restaurant({
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.time,
    required this.category,
    required this.location,
    required this.offer,
  });
}

// Hardcoded list of restaurants
final List<Restaurant> restaurants = [
  Restaurant(
    name: 'Nigs Hut',
    imagePath: 'assets/images/res1.jpg',
    rating: 4.3,
    time: '65-90 mins',
    category: 'Restaurant',
    location: 'Mannarkkad',
    offer: 'ITEMS AT ₹99',
  ),
  Restaurant(
    name: 'FoodFlex',
    imagePath: 'assets/images/res2.jpeg',
    rating: 4.5,
    time: '40-55 mins',
    category: 'Healthy',
    location: 'Palakkad',
    offer: 'UPTO 50% OFF',
  ),
  // ... other restaurants
];

// ===== RESTAURANT LIST SCREEN =====
class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Restaurant'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RestaurantDetailScreen(restaurant: restaurant),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... restaurant card UI
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===== RESTAURANT DETAIL SCREEN =====
class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantDetailScreen({required this.restaurant, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... restaurant detail UI
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ByodPage(restaurant: restaurant),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Build Your Own Dish',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enum for recipe input type
enum RecipeInputType { write, upload, link }

// ===== BYOD PAGE - Enhanced with Restaurant Context =====
class ByodPage extends StatefulWidget {
  final Restaurant restaurant;

  const ByodPage({required this.restaurant, super.key});

  @override
  _ByodPageState createState() => _ByodPageState();
}

class _ByodPageState extends State<ByodPage> {
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController recipeStepsController = TextEditingController();
  final TextEditingController recipeLinkController = TextEditingController();

  RecipeInputType _selectedInputType = RecipeInputType.write;
  File? _selectedImage;

  final List<Map<String, dynamic>> ingredients = [
    // ... ingredients list
  ];

  List<bool> selected = [];
  int totalCalories = 0,
      totalProtein = 0,
      totalCarbs = 0,
      totalFat = 0,
      totalPrice = 0;

  Map<String, List<int>> categorizedIngredients = {};

  @override
  void initState() {
    super.initState();
    selected = List.generate(ingredients.length, (index) => false);

    for (int i = 0; i < ingredients.length; i++) {
      final category = ingredients[i]['category'] as String;
      if (!categorizedIngredients.containsKey(category)) {
        categorizedIngredients[category] = [];
      }
      categorizedIngredients[category]!.add(i);
    }
  }

  void calculateNutrition() {
    int cal = 0, protein = 0, carbs = 0, fat = 0, price = 0;
    for (int i = 0; i < ingredients.length; i++) {
      if (selected[i]) {
        cal += (ingredients[i]["cal"] as num).toInt();
        protein += (ingredients[i]["protein"] as num).toInt();
        carbs += (ingredients[i]["carbs"] as num).toInt();
        fat += (ingredients[i]["fat"] as num).toInt();
        price += (ingredients[i]["price"] as num).toInt();
      }
    }
    setState(() {
      totalCalories = cal;
      totalProtein = protein;
      totalCarbs = carbs;
      totalFat = fat;
      totalPrice = price;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void submitRecipe() {
    // ... submit recipe logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "BYOD - Build Your Own Dish",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'for ${widget.restaurant.name}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Input Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "How would you like to add your recipe?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInputTypeChip(
                          "Write",
                          Icons.edit,
                          RecipeInputType.write,
                        ),
                        _buildInputTypeChip(
                          "Upload",
                          Icons.photo,
                          RecipeInputType.upload,
                        ),
                        _buildInputTypeChip(
                          "Link",
                          Icons.link,
                          RecipeInputType.link,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInputWidget(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ingredients Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... ingredients selection UI
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nutrition Summary
            Card(
              elevation: 2,
              color: Colors.orange[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... nutrition summary UI
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitRecipe,
                // ... button style
                child: const Text("Send Recipe to Kitchen"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputTypeChip(
    String label,
    IconData icon,
    RecipeInputType type,
  ) {
    final isSelected = _selectedInputType == type;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, color: isSelected ? Colors.white : Colors.deepOrange),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedInputType = type;
          });
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.deepOrange,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _buildInputWidget() {
    switch (_selectedInputType) {
      case RecipeInputType.write:
        return Column(
          children: [
            TextField(
              controller: recipeNameController,
              decoration: const InputDecoration(
                hintText: "Enter your recipe name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: recipeStepsController,
              decoration: const InputDecoration(
                hintText: "Enter steps/instructions (optional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.list_alt),
              ),
              maxLines: 3,
            ),
          ],
        );
      case RecipeInputType.upload:
        return GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey, width: 2),
            ),
            clipBehavior: Clip.hardEdge,
            child: _selectedImage != null
                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Tap to upload a photo"),
                      ],
                    ),
                  ),
          ),
        );
      case RecipeInputType.link:
        return TextField(
          controller: recipeLinkController,
          decoration: const InputDecoration(
            hintText: "Paste a link to your recipe",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
        );
    }
  }

  Widget _buildNutritionItem(String label, String value, String unit) {
    // ... nutrition item UI
    return Container();
  }
}
