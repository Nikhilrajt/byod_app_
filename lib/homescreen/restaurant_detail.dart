import 'package:flutter/material.dart';
import 'package:project/models/cart_item.dart';
import 'package:project/models/category_models.dart' hide CategoryItem;
// import 'package:project/models/cart_item.dart' show CategoryItem, CartItem;

import 'package:provider/provider.dart';
import '../state/cart_notifier.dart';
import 'category.dart';

class RestaurantDetailPage extends StatelessWidget {
  final String name;
  final String description;
  final String image;
  final double rating;
  final List<CategoryItem> foodItems;

  const RestaurantDetailPage({
    super.key,
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
    required this.foodItems,
  });

  @override
  Widget build(BuildContext context) {
    // Group food items by category
    final groupedByCategory = _groupFoodItemsByCategory(foodItems);

    return Scaffold(
      appBar: AppBar(title: Text(name), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Hero Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: Image.asset(
                image,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Name and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Restaurant Description
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  // Menu Title with Restaurant Name
                  Text(
                    "$name's Menu",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Food Items grouped by Category
            ...groupedByCategory.entries.map((entry) {
              final category = entry.key;
              final items = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Food Items for this category in Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildFoodTile(context: context, item: item);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Group food items by category name
  Map<String, List<CategoryItem>> _groupFoodItemsByCategory(
    List<CategoryItem> items,
  ) {
    final grouped = <String, List<CategoryItem>>{};

    for (final item in items) {
      final category = _getCategoryFromItemName(item.name);
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(item);
    }

    return grouped;
  }

  // Determine category based on food item name
  String _getCategoryFromItemName(String itemName) {
    itemName = itemName.toLowerCase();

    if (itemName.contains('pizza')) return 'Pizza';
    if (itemName.contains('burger')) return 'Burgers';
    if (itemName.contains('pasta') ||
        itemName.contains('spaghetti') ||
        itemName.contains('fettuccine') ||
        itemName.contains('mac & cheese') ||
        itemName.contains('lasagna')) {
      return 'Pasta';
    }
    if (itemName.contains('dessert') ||
        itemName.contains('cake') ||
        itemName.contains('brownie') ||
        itemName.contains('cheesecake') ||
        itemName.contains('tiramisu') ||
        itemName.contains('mousse')) {
      return 'Desserts';
    }
    if (itemName.contains('juice') ||
        itemName.contains('smoothie') ||
        itemName.contains('shake') ||
        itemName.contains('platter')) {
      return 'Drinks';
    }
    if (itemName.contains('paneer') ||
        itemName.contains('dosa') ||
        itemName.contains('tikka') ||
        itemName.contains('curry') ||
        itemName.contains('wrap') ||
        itemName.contains('veg')) {
      return 'Vegetarian';
    }
    if (itemName.contains('shawarma')) return 'Shawarma';

    return 'Other';
  }

  Widget _buildFoodTile({
    required BuildContext context,
    required CategoryItem item,
  }) {
    return _FoodTileWidget(item: item);
  }
}

class _FoodTileWidget extends StatelessWidget {
  final CategoryItem item;

  const _FoodTileWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartNotifier>(
      builder: (context, cartNotifier, _) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image - Larger and takes more space
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: Image.asset(
                  item.image,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item name
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // Price and Add button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '₹${item.price}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 94, 64, 134),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            width: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                final cartItem = CartItem(
                                  name: item.name,
                                  // image: item.image,
                                  price: item.price.toInt(),
                                  // rating: item.rating,
                                  restaurantName: item.restaurantName,
                                  imageUrl: item.image,
                                );
                                cartNotifier.addToCart(cartItem);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item.name} added to cart'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
// // project/models/cart_item.dart (Corrected version)
// class CartItem {
//   final String name;
//   final String image;
//   final double price;
//   final double rating;
//   // ✨ Add this new property
//   final String restaurantName; 

//   CartItem({
//     required this.name,
//     required this.image,
//     required this.price,
//     required this.rating,
//     // ✨ Add this to the constructor
//     required this.restaurantName,
//   });

//   // You may also want to override toString or add a copyWith method
//   // but this basic structure should fix your immediate error.
// }