import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/homescreen/cart.dart';
import 'package:project/models/category_models.dart';

import 'package:project/state/cart_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../services/upload_image.dart';

// ===== RESTAURANT MODEL =====
class Restaurant {
  final String id;
  final String name;
  final String imagePath;
  final double rating;
  final String time;
  final String category;
  final String location;
  final String offer;

  Restaurant({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.time,
    required this.category,
    required this.location,
    required this.offer,
  });
}

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'restaurant')
            .where('isByodEnabled', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No BYOD restaurants available"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final restaurant = Restaurant(
                id: docs[index].id,
                name: data['fullName'] ?? data['name'] ?? 'Unknown',
                imagePath: data['imageUrl'] ?? '',
                rating:
                    double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
                time: '30-45 mins', // Placeholder as it's not in DB
                category: 'Restaurant',
                location: data['address'] ?? 'Unknown Location',
                offer: 'Special Offers', // Placeholder
              );

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
                        // Restaurant Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: restaurant.imagePath.isNotEmpty
                              ? Image.network(
                                  restaurant.imagePath,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.restaurant,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.restaurant,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      restaurant.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          restaurant.rating.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${restaurant.category} • ${restaurant.location}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    restaurant.time,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.local_offer,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    restaurant.offer,
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
  XFile? _selectedImage;

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
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> addByodToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to order.')),
      );
      return;
    }

    if (recipeNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe name.')),
      );
      return;
    }

    final List<Map<String, dynamic>> ingredientMaps = [];
    for (int i = 0; i < ingredients.length; i++) {
      if (selected[i]) {
        ingredientMaps.add({
          'name': ingredients[i]['name'],
          'quantity': 1, // Assuming quantity is 1 for each selected ingredient
          'price': ingredients[i]['price'],
          'customizations': [],
          'isHealthy': false,
          'imageUrl': '',
          // Add other relevant fields from your ingredient model if needed
        });
      }
    }

    if (ingredientMaps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one ingredient.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String? recipeContent;
      String recipeType = _selectedInputType.name;

      if (_selectedInputType == RecipeInputType.upload &&
          _selectedImage != null) {
        recipeContent = await CloudneryUploader().uploadFile(_selectedImage!);
      } else if (_selectedInputType == RecipeInputType.write) {
        recipeContent = recipeStepsController.text.trim();
      } else if (_selectedInputType == RecipeInputType.link) {
        recipeContent = recipeLinkController.text.trim();
      }

      final cart = Provider.of<CartNotifier>(context, listen: false);

      // Check for cart conflicts and clear if necessary
      if (cart.items.isNotEmpty &&
          cart.items.first.restaurantId != widget.restaurant.id) {
        cart.clearCart();
      }

      // Calculate total price and collect ingredient names
      int totalPrice = 0;
      List<String> ingredientNames = [];
      for (int i = 0; i < ingredients.length; i++) {
        if (selected[i]) {
          totalPrice += (ingredients[i]['price'] as num).toInt();
          ingredientNames.add(ingredients[i]['name']);
        }
      }

      // Create customizations list for the single tile
      List<String> customizations = [];
      
      // Internal tags for logic (will be extracted by cart)
      customizations.add('BYOD_NAME:${recipeNameController.text.trim()}');
      customizations.add('BYOD_TYPE:$recipeType');
      customizations.add('BYOD_CONTENT:${recipeContent ?? ''}');

      // Visible details for Cart and Restaurant
      if (recipeType == 'write' && recipeContent != null && recipeContent.isNotEmpty) {
         customizations.add('Instructions: $recipeContent');
      }
      if (ingredientNames.isNotEmpty) {
         customizations.add('Ingredients: ${ingredientNames.join(', ')}');
      }

      // Create SINGLE CartItem representing the whole dish
      final byodItem = CartItem(
        name: recipeNameController.text.trim(), // Dish Name
        price: totalPrice,
        imageUrl: '', 
        restaurantName: widget.restaurant.name,
        restaurantId: widget.restaurant.id,
        quantity: 1,
        customizations: customizations,
        isHealthy: false, 
      );

      cart.addToCart(byodItem);

      Navigator.pop(context); // pop loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('BYOD recipe added to your cart!')),
      );

      // Navigate to cart
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartScreen()),
      );
    } catch (e) {
      Navigator.pop(context); // pop loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add to cart: $e')));
    }
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
                onPressed: addByodToCart,
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
                ? Image.file(File(_selectedImage!.path), fit: BoxFit.cover)
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
