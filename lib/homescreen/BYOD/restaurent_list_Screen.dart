// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

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
  final String name;
  final String imagePath; // asset image path
  final double rating;
  final String time;
  final String category;
  final String location;
  final String offer;
  const Restaurant({
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.time,
    required this.category,
    required this.location,
    required this.offer,
  });
}

final List<Restaurant> restaurants = [
  const Restaurant(
    name: 'Nigs Hut',
    imagePath: 'assets/images/res1.jpg',
    rating: 4.3,
    time: '65–90 mins',
    category: 'Restaurant',
    location: 'Mannarkkad',
    offer: 'ITEMS AT ₹99',
  ),
  const Restaurant(
    name: 'FoodFlex',
    imagePath: 'assets/images/res2.jpeg',
    rating: 4.5,
    time: '40–55 mins',
    category: 'Healthy',
    location: 'Palakkad',
    offer: 'UPTO 50% OFF',
  ),
  const Restaurant(
    name: 'Pizza Hut',
    imagePath: 'assets/images/res3.png',
    rating: 4.2,
    time: '55–65 mins',
    category: 'Pizzas',
    location: 'Kavumpuram',
    offer: 'ITEMS AT ₹99',
  ),
  const Restaurant(
    name: 'Burger King',
    imagePath: 'assets/images/res4.jpeg',
    rating: 4.1,
    time: '30–45 mins',
    category: 'Burgers',
    location: 'Ottapalam',
    offer: 'FREE DELIVERY',
  ),
  const Restaurant(
    name: 'Subway',
    imagePath: 'assets/images/res5.jpeg',
    rating: 4.0,
    time: '25–35 mins',
    category: 'Sandwiches',
    location: 'Shornur',
    offer: 'BUY 1 GET 1',
  ),
  const Restaurant(
    name: 'The Plate',
    imagePath: 'assets/images/res6.jpeg',
    rating: 4.6,
    time: '35–50 mins',
    category: 'Multi-cuisine',
    location: 'Cherpulassery',
    offer: 'NEW ARRIVAL',
  ),
];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, i) {
          final r = restaurants[i];
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
                          child: Image.asset(
                            r.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image, size: 40),
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
                                BoxShadow(color: Colors.black26, blurRadius: 4),
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
            child: Image.asset(
              restaurant.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image, size: 48)),
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
                      MaterialPageRoute(builder: (_) => const ByodPage()),
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
  const ByodPage({super.key});
  @override
  State<ByodPage> createState() => _ByodPageState();
}

class _ByodPageState extends State<ByodPage> {
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController recipeStepsController = TextEditingController();
  final TextEditingController recipeLinkController = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();

  RecipeInputType _mode = RecipeInputType.write;
  File? _selectedImage;

  /// Ingredient schema (low price-per-unit)
  /// name, category, unit (per serving), cal, protein, carbs, fat, price (₹ per unit)
  final List<Map<String, dynamic>> ingredients = const [
    // Bases (per 100g or 1 pc)
    {
      "name": "Steamed Rice",
      "category": "Bases",
      "unit": "100 g",
      "cal": 130,
      "protein": 2,
      "carbs": 28,
      "fat": 0,
      "price": 5,
    },
    {
      "name": "Quinoa",
      "category": "Bases",
      "unit": "100 g",
      "cal": 120,
      "protein": 4,
      "carbs": 21,
      "fat": 2,
      "price": 8,
    },
    {
      "name": "Whole Wheat Roti",
      "category": "Bases",
      "unit": "1 pc",
      "cal": 100,
      "protein": 3,
      "carbs": 22,
      "fat": 1,
      "price": 5,
    },
    {
      "name": "Hakka Noodles",
      "category": "Bases",
      "unit": "100 g",
      "cal": 138,
      "protein": 4,
      "carbs": 27,
      "fat": 2,
      "price": 6,
    },

    // Proteins (per 50g or 1 pc)
    {
      "name": "Grilled Chicken",
      "category": "Proteins",
      "unit": "50 g",
      "cal": 82,
      "protein": 15,
      "carbs": 0,
      "fat": 2,
      "price": 10,
    },
    {
      "name": "Paneer Cubes",
      "category": "Proteins",
      "unit": "50 g",
      "cal": 132,
      "protein": 9,
      "carbs": 3,
      "fat": 10,
      "price": 8,
    },
    {
      "name": "Boiled Egg",
      "category": "Proteins",
      "unit": "1 pc",
      "cal": 78,
      "protein": 6,
      "carbs": 1,
      "fat": 5,
      "price": 4,
    },
    {
      "name": "Tofu",
      "category": "Proteins",
      "unit": "50 g",
      "cal": 70,
      "protein": 7,
      "carbs": 2,
      "fat": 4,
      "price": 6,
    },
    {
      "name": "Fish Tikka",
      "category": "Proteins",
      "unit": "50 g",
      "cal": 100,
      "protein": 13,
      "carbs": 1,
      "fat": 5,
      "price": 12,
    },

    // Veggies (per 50g or 30g)
    {
      "name": "Bell Peppers",
      "category": "Veggies",
      "unit": "50 g",
      "cal": 16,
      "protein": 0,
      "carbs": 3,
      "fat": 0,
      "price": 4,
    },
    {
      "name": "Broccoli",
      "category": "Veggies",
      "unit": "50 g",
      "cal": 17,
      "protein": 2,
      "carbs": 3,
      "fat": 0,
      "price": 5,
    },
    {
      "name": "Onion",
      "category": "Veggies",
      "unit": "30 g",
      "cal": 12,
      "protein": 0,
      "carbs": 3,
      "fat": 0,
      "price": 2,
    },
    {
      "name": "Tomato",
      "category": "Veggies",
      "unit": "50 g",
      "cal": 9,
      "protein": 0,
      "carbs": 2,
      "fat": 0,
      "price": 2,
    },
    {
      "name": "Mushroom",
      "category": "Veggies",
      "unit": "50 g",
      "cal": 11,
      "protein": 1,
      "carbs": 1,
      "fat": 0,
      "price": 4,
    },
    {
      "name": "Spinach",
      "category": "Veggies",
      "unit": "50 g",
      "cal": 5,
      "protein": 1,
      "carbs": 1,
      "fat": 0,
      "price": 3,
    },
    {
      "name": "Sweet Corn",
      "category": "Veggies",
      "unit": "40 g",
      "cal": 26,
      "protein": 1,
      "carbs": 6,
      "fat": 1,
      "price": 3,
    },

    // Sauces (per tbsp)
    {
      "name": "Tomato Basil",
      "category": "Sauces",
      "unit": "1 tbsp",
      "cal": 15,
      "protein": 0,
      "carbs": 3,
      "fat": 0,
      "price": 2,
    },
    {
      "name": "Butter Masala",
      "category": "Sauces",
      "unit": "1 tbsp",
      "cal": 55,
      "protein": 1,
      "carbs": 2,
      "fat": 6,
      "price": 3,
    },
    {
      "name": "Mint Chutney",
      "category": "Sauces",
      "unit": "1 tbsp",
      "cal": 12,
      "protein": 1,
      "carbs": 2,
      "fat": 0,
      "price": 2,
    },
    {
      "name": "Teriyaki",
      "category": "Sauces",
      "unit": "1 tbsp",
      "cal": 20,
      "protein": 1,
      "carbs": 5,
      "fat": 0,
      "price": 3,
    },

    // Toppings (per 10–15g / tbsp)
    {
      "name": "Cheddar Cheese",
      "category": "Toppings",
      "unit": "15 g",
      "cal": 60,
      "protein": 3,
      "carbs": 1,
      "fat": 5,
      "price": 6,
    },
    {
      "name": "Olives",
      "category": "Toppings",
      "unit": "10 g",
      "cal": 15,
      "protein": 0,
      "carbs": 0,
      "fat": 2,
      "price": 4,
    },
    {
      "name": "Crushed Peanuts",
      "category": "Toppings",
      "unit": "1 tbsp",
      "cal": 26,
      "protein": 1,
      "carbs": 1,
      "fat": 2,
      "price": 2,
    },
    {
      "name": "Fried Onions",
      "category": "Toppings",
      "unit": "1 tbsp",
      "cal": 22,
      "protein": 0,
      "carbs": 1,
      "fat": 1,
      "price": 2,
    },

    // Extras (per piece / 50g)
    {
      "name": "Papad",
      "category": "Extras",
      "unit": "1 pc",
      "cal": 38,
      "protein": 2,
      "carbs": 5,
      "fat": 1,
      "price": 3,
    },
    {
      "name": "Raita",
      "category": "Extras",
      "unit": "50 g",
      "cal": 30,
      "protein": 2,
      "carbs": 2,
      "fat": 1,
      "price": 6,
    },
    {
      "name": "Gulab Jamun",
      "category": "Extras",
      "unit": "1 pc",
      "cal": 150,
      "protein": 2,
      "carbs": 25,
      "fat": 5,
      "price": 8,
    },
  ];

  late final Map<String, List<int>> categorized;
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
    categorized = {};
    for (int i = 0; i < ingredients.length; i++) {
      final c = ingredients[i]['category'] as String;
      categorized.putIfAbsent(c, () => []).add(i);
      expand[c] = true;
    }
    quantities = List<int>.filled(ingredients.length, 0);
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
        cal += ((ingredients[i]['cal'] as num) * q).round();
        pro += ((ingredients[i]['protein'] as num) * q).round();
        carb += ((ingredients[i]['carbs'] as num) * q).round();
        fat += ((ingredients[i]['fat'] as num) * q).round();
        price += ((ingredients[i]['price'] as num) * q).round();
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
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  void _submit() {
    final name = recipeNameController.text.trim();
    final link = recipeLinkController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe name.')),
      );
      return;
    }
    final chosen = <String>[];
    for (int i = 0; i < ingredients.length; i++) {
      final q = quantities[i];
      if (q > 0) chosen.add('${ingredients[i]['name']} × $q');
    }
    if (chosen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one ingredient.')),
      );
      return;
    }
    if (_mode == RecipeInputType.link) {
      final ok = Uri.tryParse(link)?.hasAbsolutePath ?? false;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please paste a valid link.')),
        );
        return;
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Send to kitchen?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipe: $name'),
            const SizedBox(height: 8),
            Text('Items (${chosen.length}):\n• ${chosen.join('\n• ')}'),
            const SizedBox(height: 12),
            Text(
              'Totals: $totalCalories kcal • $totalProtein g P • '
              '$totalCarbs g C • $totalFat g F • ₹$totalPrice',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recipe sent 👩‍🍳')),
              );
              setState(() {
                recipeNameController.clear();
                recipeStepsController.clear();
                recipeLinkController.clear();
                _selectedImage = null;
                quantities = List<int>.filled(ingredients.length, 0);
                _recalculate();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
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
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
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
        return (ingredients[i]['name'] as String).toLowerCase().contains(q);
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
                  ing['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    _chip(ing['unit'] as String),
                    _chip('${ing['cal']} kcal'),
                    _chip('₹${ing['price']}'),
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
