import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import your existing state and models
import '../state/health_mode_notifier.dart';
import '../state/cart_notifier.dart';
import '../customization_page.dart';
import '../models/category_models.dart';
import '../homescreen/cart.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const CategoryPage({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String _currentCategoryId = "";

  @override
  void initState() {
    super.initState();
    _currentCategoryId = widget.categoryId;
  }

  // --- 1. FUNCTION TO CHECK IF A CATEGORY CONTAINS HEALTHY ITEMS ---
  Future<bool> _categoryHasHealthyItems(String categoryId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("categories")
        .doc(categoryId)
        .collection("items")
        .where("isHealthy", isEqualTo: true)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // ---------------------------------------------------
  // 2. FETCH ITEMS WITH HEALTH MODE FILTERING
  // ---------------------------------------------------
  Stream<List<CategoryItem>> fetchCategoryItems(
    String categoryId,
    bool healthMode,
  ) {
    Query query = FirebaseFirestore.instance
        .collection("categories")
        .doc(categoryId)
        .collection("items");

    // ⭐ FIX: Apply health mode filter at the database level
    if (healthMode) {
      query = query.where("isHealthy", isEqualTo: true);
    }

    return query.snapshots().asyncMap((snap) async {
      List<CategoryItem> items = [];

      for (var doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String restaurantName = data["restaurantName"] ?? "Unknown Restaurant";
        num price = data["price"] ?? 0;

        // PARSE CUSTOMIZATIONS
        List<CustomizationStep> parsedSteps = [];

        if (data['variantGroups'] != null) {
          var rawGroups = data['variantGroups'] as List;

          for (var group in rawGroups) {
            var rawOptions = group['options'] as List;
            List<CustomizationOption> parsedOptions = rawOptions.map((opt) {
              return CustomizationOption(
                opt['name'] ?? '',
                (opt['priceModifier'] ?? 0).toInt(),
              );
            }).toList();

            bool isMultiple = group['allowMultiple'] ?? false;
            bool isRequired = group['isRequired'] ?? false;

            if (isMultiple) {
              parsedSteps.add(
                CustomizationStep.multipleChoice(
                  group['name'] ?? 'Options',
                  parsedOptions,
                  isRequired: isRequired,
                ),
              );
            } else {
              parsedSteps.add(
                CustomizationStep.singleChoice(
                  group['name'] ?? 'Options',
                  parsedOptions,
                  isRequired: isRequired,
                ),
              );
            }
          }
        }

        items.add(
          CategoryItem(
            data["name"] ?? "Unknown",
            data["imageUrl"] ?? "",
            price,
            double.tryParse(data["rating"]?.toString() ?? "4.5") ?? 4.5,
            data["restaurantId"] ?? "",
            restaurantName,
            categoryKey: categoryId,
            description: data["description"] ?? "",
            isAvailable: data["isAvailable"] ?? true,
            isCustomizable: data["isCustomizable"] ?? false,
            isHealthy: data["isHealthy"] ?? false,
            customizationSteps: parsedSteps,
          ),
        );
      }
      return items;
    });
  }

  // ---------------------------------------------------
  // 3. ADD TO CART LOGIC
  // ---------------------------------------------------
  void _addToCart(CategoryItem item, CartNotifier cart) {
    if (item.isCustomizable) {
      _showAddOptionsDialog(item, cart);
    } else {
      cart.addItem(item.toCartItem());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${item.name} added to cart"),
          duration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _showAddOptionsDialog(CategoryItem item, CartNotifier cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.name),
        content: Text("From: ${item.restaurantName}"),
        actions: [
          TextButton(
            onPressed: () {
              cart.addItem(item.toCartItem());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${item.name} added to cart")),
              );
            },
            child: const Text("Quick Add (Base)"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () {
              Navigator.pop(context);
              if (item.customizationSteps != null &&
                  item.customizationSteps!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomizationPage(
                      customizableItem: item,
                      template: item.customizationSteps!,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No customization options available"),
                  ),
                );
              }
            },
            child: const Text(
              "Customize",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // 4. RESTAURANT HEADER
  // ---------------------------------------------------
  Widget _buildRestaurantHeader(String restaurantName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Icon(Icons.restaurant_menu, color: Colors.deepOrange, size: 20),
          SizedBox(width: 8),
          Text(
            restaurantName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // 5. ITEM CARD
  // ---------------------------------------------------
  Widget _buildItemCard(CategoryItem item, CartNotifier cart) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: Icon(Icons.fastfood),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isCustomizable)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          "Customizable",
                          style: TextStyle(fontSize: 10, color: Colors.green),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  "From: ${item.restaurantName}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      item.rating.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${item.price}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: item.isAvailable
                            ? () => _addToCart(item, cart)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.shopping_cart, size: 14),
                            SizedBox(width: 4),
                            Text("ADD", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthMode = context.watch<HealthModeNotifier>().isOn;
    final cart = context.watch<CartNotifier>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.categoryName, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CartScreen()),
                ),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      cart.itemCount.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // HORIZONTAL CATEGORY CHIPS - FIXED NAVIGATION
          Container(
            height: 60,
            color: Colors.white,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("categories")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                var docs = snapshot.data!.docs;

                if (healthMode) {
                  return FutureBuilder<List<DocumentSnapshot?>>(
                    future: Future.wait(
                      docs.map((doc) async {
                        if (await _categoryHasHealthyItems(doc.id)) {
                          return doc;
                        }
                        return null;
                      }),
                    ),
                    builder: (context, filteredSnapshot) {
                      if (filteredSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      final healthyDocs = filteredSnapshot.data!
                          .where((d) => d != null)
                          .cast<DocumentSnapshot>()
                          .toList();

                      if (healthyDocs.isEmpty) {
                        return const Center(
                          child: Text("No healthy categories available"),
                        );
                      }

                      return _buildCategoryChips(healthyDocs, healthMode);
                    },
                  );
                } else {
                  return _buildCategoryChips(docs, healthMode);
                }
              },
            ),
          ),

          // MAIN ITEMS LIST
          Expanded(
            child: StreamBuilder<List<CategoryItem>>(
              stream: fetchCategoryItems(_currentCategoryId, healthMode),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  final noItemsText = healthMode
                      ? "No healthy items found in ${widget.categoryName}."
                      : "No items found in this category.";

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fastfood_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            noItemsText,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final items = snapshot.data!;
                Map<String, List<CategoryItem>> groupedItems = {};

                for (var item in items) {
                  if (!groupedItems.containsKey(item.restaurantName)) {
                    groupedItems[item.restaurantName] = [];
                  }
                  groupedItems[item.restaurantName]!.add(item);
                }

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 20),
                  itemCount: groupedItems.length,
                  itemBuilder: (context, index) {
                    String restaurantName = groupedItems.keys.elementAt(index);
                    List<CategoryItem> restaurantItems =
                        groupedItems[restaurantName]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRestaurantHeader(restaurantName),
                        ...restaurantItems
                            .map((item) => _buildItemCard(item, cart))
                            .toList(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Category chips now update state instead of navigating
  Widget _buildCategoryChips(List<DocumentSnapshot> docs, bool healthMode) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var doc = docs[index];
        var catData = doc.data() as Map<String, dynamic>;
        String id = doc.id;
        String name = catData['name'];
        bool isSelected = id == _currentCategoryId;

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ActionChip(
            label: Text(name),
            backgroundColor: isSelected ? Colors.deepOrange : Colors.grey[100],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide.none,
            onPressed: () {
              // FIX: Update state instead of navigating to new page
              setState(() {
                _currentCategoryId = id;
              });
            },
          ),
        );
      },
    );
  }
}
