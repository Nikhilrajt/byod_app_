// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';
import '../../models/category_models.dart';
import '../../state/cart_notifier.dart';
import '../cart.dart';
import '../../services/upload_image.dart';

// void main() => runApp(const MyApp());

// ================= APP =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TasteHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSwatch(
              primarySwatch: Colors.deepOrange,
              accentColor: Colors.deepOrangeAccent,
            ).copyWith(
              primary: Colors.deepOrange,
              secondary: Colors.deepOrangeAccent,
            ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      ),
      home: const RestaurentListScreen(),
    );
  }
}

// ================= RESTAURANT MODEL & DATA =================
class Restaurant {
  final String id;
  final String name;
  final String imagePath; // asset image path
  final double rating;
  final String time;
  final String category;
  final String location;
  final String offer;
  const Restaurant({
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

// ================= RESTAURANT LIST =================
class RestaurentListScreen extends StatelessWidget {
  const RestaurentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TasteHub Restaurants',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
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
              final r = Restaurant(
                id: docs[index].id,
                name: data['fullName'] ?? data['name'] ?? 'Unknown',
                imagePath: data['imageUrl'] ?? '',
                rating:
                    double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
                time: '30-45 mins',
                category: 'Restaurant',
                location: data['address'] ?? 'Unknown Location',
                offer: 'Special Offers',
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailScreen(restaurant: r),
                    ),
                  ),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: r.imagePath.isNotEmpty
                                  ? Image.network(
                                      r.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.image, size: 40),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons.restaurant,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                            ),
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  r.offer,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${r.rating} • ${r.time}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                r.category,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                r.location,
                                style: TextStyle(color: Colors.grey[700]),
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

// ================= RESTAURANT DETAIL =================
class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantDetailScreen({required this.restaurant, super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          restaurant.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: restaurant.imagePath.isNotEmpty
                ? Image.network(
                    restaurant.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '${restaurant.rating} Rating (${restaurant.category})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      restaurant.location,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Delivery Time: ${restaurant.time}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primary),
                  ),
                  child: Text(
                    '🔥 Current Offer: ${restaurant.offer} 🔥',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ByodPage(restaurant: restaurant),
                      ),
                    ),
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('Build Your Own Dish'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= BYOD =================
enum RecipeInputType { write, upload, link }

class ByodPage extends StatefulWidget {
  final Restaurant restaurant;
  const ByodPage({required this.restaurant, super.key});
  @override
  State<ByodPage> createState() => _ByodPageState();
}

class _ByodPageState extends State<ByodPage> {
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController recipeStepsController = TextEditingController();
  final TextEditingController recipeLinkController = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();

  RecipeInputType _mode = RecipeInputType.write;
  XFile? _selectedImage;

  // Data is now fetched from Firestore
  List<Map<String, dynamic>> ingredients = [];
  bool _isLoadingIngredients = true;

  Map<String, List<int>> categorized = {};
  late List<int> quantities; // quantity per ingredient (0 = not selected)

  final Map<String, bool> expand = {};
  int totalCalories = 0,
      totalProtein = 0,
      totalCarbs = 0,
      totalFat = 0,
      totalPrice = 0;

  @override
  void initState() {
    super.initState();
    quantities = [];
    _fetchIngredients();
  }

  Future<void> _fetchIngredients() async {
    if (!mounted) return;
    try {
      // Fetch ingredients from the global collection, filtered by restaurant ID
      final snapshot = await FirebaseFirestore.instance
          .collection('ingredients')
          .where('restaurantId', isEqualTo: widget.restaurant.id)
          .get();

      final fetchedIngredients = snapshot.docs
          .map((doc) => doc.data())
          .toList();

      // Group ingredients by their 'category' field
      final newCategorized = <String, List<int>>{};
      for (int i = 0; i < fetchedIngredients.length; i++) {
        final c =
            fetchedIngredients[i]['category'] as String? ?? 'Uncategorized';
        newCategorized.putIfAbsent(c, () => []).add(i);
        expand.putIfAbsent(c, () => true);
      }

      if (mounted) {
        setState(() {
          ingredients = fetchedIngredients;
          categorized = newCategorized;
          quantities = List<int>.filled(ingredients.length, 0);
          _isLoadingIngredients = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingIngredients = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load ingredients: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    recipeNameController.dispose();
    recipeStepsController.dispose();
    recipeLinkController.dispose();
    searchCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    int cal = 0, pro = 0, carb = 0, fat = 0, price = 0;
    for (int i = 0; i < ingredients.length; i++) {
      final q = quantities[i];
      if (q > 0) {
        cal += (((ingredients[i]['calories'] ?? 0) as num) * q).round();
        pro += (((ingredients[i]['protein'] ?? 0) as num) * q).round();
        carb += (((ingredients[i]['carbs'] ?? 0) as num) * q).round();
        fat += (((ingredients[i]['fat'] ?? 0) as num) * q).round();
        price += (((ingredients[i]['price'] ?? 0) as num) * q).round();
      }
    }
    setState(() {
      totalCalories = cal;
      totalProtein = pro;
      totalCarbs = carb;
      totalFat = fat;
      totalPrice = price;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) setState(() => _selectedImage = picked);
  }

  void _submit() {
    final cart = context.read<CartNotifier>();
    final name = recipeNameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give your dish a name.')),
      );
      return;
    }

    // Collect ingredient details
    List<String> ingredientDetails = [];
    for (int i = 0; i < ingredients.length; i++) {
      final q = quantities[i];
      if (q > 0) {
        final ing = ingredients[i];
        final ingName = ing['name'] ?? 'Unnamed';
        ingredientDetails.add('$ingName x$q');
      }
    }

    if (ingredientDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one ingredient.')),
      );
      return;
    }

    // Prepare customizations
    List<String> customizations = [];

    String recipeType = _mode.name;
    String? recipeContent;
    if (_mode == RecipeInputType.write) {
      recipeContent = recipeStepsController.text.trim();
    } else if (_mode == RecipeInputType.link) {
      recipeContent = recipeLinkController.text.trim();
    }

    customizations.add('BYOD_NAME:$name');
    customizations.add('BYOD_TYPE:$recipeType');
    if (recipeContent != null && recipeContent.isNotEmpty) {
      customizations.add('BYOD_CONTENT:$recipeContent');
      if (_mode == RecipeInputType.write) {
        customizations.add('Instructions: $recipeContent');
      }
    }
    customizations.add('Ingredients: ${ingredientDetails.join(', ')}');

    final byodItem = CartItem(
      name: name,
      price: totalPrice, // Use the calculated total price from state
      quantity: 1,
      restaurantName: widget.restaurant.name,
      restaurantId: widget.restaurant.id,
      imageUrl: '',
      isHealthy: false,
      customizations: customizations,
    );

    // Check if cart has items from another restaurant
    if (cart.items.isNotEmpty &&
        cart.items.first.restaurantId != widget.restaurant.id) {
      _showReplaceCartDialog(cart, [byodItem]);
    } else {
      // Add items to cart and navigate
      cart.addToCart(byodItem);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dish added to cart!')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    }
  }

  void _showReplaceCartDialog(CartNotifier cart, List<CartItem> newItems) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Replace cart items?"),
        content: const Text(
          "Your cart contains items from another restaurant. Do you want to clear it and add these new items?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              cart.clearCart();
              for (var item in newItems) {
                cart.addToCart(item);
              }
              Navigator.pop(context); // pop dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            child: const Text("Replace"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BYOD - Build Your Own Dish',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),

      // Sticky totals bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _miniStat(Icons.local_fire_department, '$totalCalories kcal'),
                  _miniStat(Icons.fitness_center, '$totalProtein g P'),
                  _miniStat(Icons.grain, '$totalCarbs g C'),
                  _miniStat(Icons.opacity, '$totalFat g F'),
                  _miniStat(Icons.currency_rupee, '$totalPrice'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Send to Kitchen'),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe input
            Text(
              'Add your recipe',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _modeChip('Write', Icons.edit, RecipeInputType.write),
                _modeChip('Upload', Icons.photo, RecipeInputType.upload),
                _modeChip('Link', Icons.link, RecipeInputType.link),
              ],
            ),
            const SizedBox(height: 12),
            _inputWidget(),

            const SizedBox(height: 24),
            const Divider(),

            // Ingredients
            Row(
              children: [
                Icon(Icons.shopping_basket_outlined, color: primary),
                const SizedBox(width: 8),
                Text(
                  'Select Ingredients',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(
                      () =>
                          quantities = List<int>.filled(ingredients.length, 0),
                    );
                    _recalculate();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search (e.g., chicken, rice)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingIngredients)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              ..._categoryBlocks(primary),

            const SizedBox(height: 16),

            // Nutrition summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepOrange.shade100),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _statTile(
                    'Calories',
                    '$totalCalories',
                    'kcal',
                    Icons.local_fire_department,
                  ),
                  _statTile(
                    'Protein',
                    '$totalProtein',
                    'g',
                    Icons.fitness_center,
                  ),
                  _statTile('Carbs', '$totalCarbs', 'g', Icons.grain),
                  _statTile('Fat', '$totalFat', 'g', Icons.opacity),
                  _statTile('Price', '₹$totalPrice', '', Icons.payments),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ---------- UI helpers ----------
  Widget _modeChip(String label, IconData icon, RecipeInputType type) {
    final isSelected = _mode == type;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, color: isSelected ? Colors.white : Colors.deepOrange),
      selected: isSelected,
      onSelected: (_) => setState(() => _mode = type),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.deepOrange,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  Widget _inputWidget() {
    switch (_mode) {
      case RecipeInputType.write:
        return Column(
          children: [
            TextField(
              controller: recipeNameController,
              decoration: const InputDecoration(
                labelText: 'Dish Name',
                hintText: "Dish name (e.g., Spicy Chicken Bowl)",
                prefixIcon: Icon(Icons.ramen_dining),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: recipeStepsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Steps',
                hintText: 'Cooking instructions (optional)',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.list_alt),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case RecipeInputType.upload:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: DottedBorder(
                // borderType: BorderType.RRect,
                // radius: const Radius.circular(12),
                // dashPattern: const [6, 6],
                // color: Colors.grey,
                // strokeWidth: 2,
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 42,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text('Tap to upload a photo'),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Camera'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: recipeNameController,
              decoration: const InputDecoration(
                labelText: 'Dish Name',
                hintText: 'Give your recipe a name',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case RecipeInputType.link:
        return Column(
          children: [
            TextField(
              controller: recipeNameController,
              decoration: const InputDecoration(
                labelText: 'Dish Name',
                hintText: 'Dish name',
                prefixIcon: Icon(Icons.restaurant_menu),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: recipeLinkController,
              decoration: const InputDecoration(
                labelText: 'Recipe URL',
                hintText: 'Paste a recipe link',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
    }
  }

  List<Widget> _categoryBlocks(Color primary) {
    final q = searchCtrl.text.toLowerCase();
    final cats = categorized.keys.toList()..sort();
    final out = <Widget>[];

    for (final cat in cats) {
      final idxs = categorized[cat]!;
      final filtered = idxs.where((i) {
        if (q.isEmpty) return true;
        return (ingredients[i]['name'] as String? ?? '').toLowerCase().contains(
          q,
        );
      }).toList();

      final selectedCount = idxs.where((i) => quantities[i] > 0).length;

      out.add(
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: expand[cat] ?? true,
            onExpansionChanged: (v) => setState(() => expand[cat] = v),
            tilePadding: EdgeInsets.zero,
            title: Row(
              children: [
                Text(
                  cat,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                if (selectedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$selectedCount selected',
                      style: TextStyle(color: primary),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    final allSel = idxs.every((i) => quantities[i] > 0);
                    setState(() {
                      for (final i in idxs) {
                        quantities[i] = allSel ? 0 : 1;
                      }
                    });
                    _recalculate();
                  },
                  child: Text(
                    idxs.every((i) => quantities[i] > 0)
                        ? 'Unselect All'
                        : 'Select All',
                  ),
                ),
              ],
            ),
            childrenPadding: EdgeInsets.zero,
            children: filtered.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        'No items match "$q"',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ]
                : filtered.map(_ingredientTile).toList(),
          ),
        ),
      );
      out.add(const Divider(height: 16));
    }
    if (out.isNotEmpty) out.removeLast();
    return out;
  }

  Widget _ingredientTile(int index) {
    final ing = ingredients[index];
    final qty = quantities[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // checkbox behaviour driven by qty
          Checkbox(
            value: qty > 0,
            onChanged: (v) {
              setState(() => quantities[index] = v == true ? 1 : 0);
              _recalculate();
            },
          ),
          // name + chips
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ing['name'] as String? ?? 'Unnamed',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    _chip(ing['unit'] as String? ?? '-'),
                    _chip('${ing['calories'] ?? 0} kcal'),
                    _chip('${ing['protein'] ?? 0}g protein'),
                  ],
                ),
              ],
            ),
          ),
          // qty selector
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (qty > 0) {
                    setState(() => quantities[index]--);
                    _recalculate();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: qty > 0 ? Colors.deepOrange : Colors.grey[300],
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: qty > 0 ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$qty',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() => quantities[index]++);
                  _recalculate();
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepOrange,
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(t, style: TextStyle(color: Colors.grey[800])),
  );

  Widget _miniStat(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );

  Widget _statTile(String label, String value, String unit, IconData icon) =>
      Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange.withOpacity(.25)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            if (unit.isNotEmpty)
              Text(unit, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      );
}
