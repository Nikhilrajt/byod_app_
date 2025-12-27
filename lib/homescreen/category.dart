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
  String _currentCategoryName = "";
  String _lastHealthModeState = ""; // Track health mode changes
  bool _shouldAutoSelect = false; // Only auto-select if coming from bottom nav
  bool _userManuallySelectedCategory = false;

  // Search State
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    // Check if category was provided (coming from specific category selection)
    // or if empty/default (coming from bottom navigation)
    if (widget.categoryId.isEmpty || widget.categoryId == "") {
      // Coming from bottom nav - should auto-select first category
      _shouldAutoSelect = true;
      _currentCategoryId = "";
      _currentCategoryName = "";
    } else {
      // Coming with specific category - use it
      _shouldAutoSelect = false;
      _currentCategoryId = widget.categoryId;
      _currentCategoryName = widget.categoryName;
      _lastHealthModeState = "initialized"; // Mark as already initialized
      _userManuallySelectedCategory = true;
    }
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
  // 2. AUTO-SELECT FIRST CATEGORY
  // ---------------------------------------------------
  void _autoSelectFirstCategory(
    List<DocumentSnapshot> docs,
    String healthModeKey,
  ) {
    // Only auto-select if:
    // 1. Should auto-select flag is true (coming from bottom nav) OR
    // 2. Health mode has changed (different state key)
    if (docs.isNotEmpty &&
        _currentCategoryId.isEmpty &&
        (_shouldAutoSelect || healthModeKey != _lastHealthModeState)) {
      final firstDoc = docs.first;
      final firstData = firstDoc.data() as Map<String, dynamic>;

      // Use WidgetsBinding to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentCategoryId = firstDoc.id;
            _currentCategoryName = firstData['name'];
            _lastHealthModeState = healthModeKey;
            _shouldAutoSelect = false; // Reset after first auto-select
            _userManuallySelectedCategory = false; // Reset manual selection
          });
        }
      });
    }
  }

  // ---------------------------------------------------
  // 3. FETCH ITEMS WITH HEALTH MODE FILTERING
  // ---------------------------------------------------
  Stream<List<CategoryItem>> fetchCategoryItems(
    String categoryId,
    bool healthMode,
  ) {
    Query query = FirebaseFirestore.instance
        .collection("categories")
        .doc(categoryId)
        .collection("items");

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
            double.tryParse(data["rating"]?.toString() ?? "0") ?? 0.0,
            data["restaurantId"] ?? "",
            restaurantName,
            categoryKey: categoryId,
            description: data["description"] ?? "",
            isAvailable: data["isAvailable"] ?? true,
            isCustomizable: data["isCustomizable"] ?? false,
            isHealthy: data["isHealthy"] ?? false,
            customizationSteps: parsedSteps,
            calories: data["calories"]?.toString(),
          ),
        );
      }
      return items;
    });
  }

  // ---------------------------------------------------
  // 4. ADD TO CART LOGIC
  // ---------------------------------------------------
  bool _isDifferentRestaurant(CategoryItem item, CartNotifier cart) {
    if (cart.items.isEmpty) return false;

    // Get restaurantId of first cart item
    final existingRestaurantId = cart.items.first.restaurantId;

    return existingRestaurantId != item.restaurantId;
  }

  void _showReplaceCartDialog(CategoryItem item, CartNotifier cart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Do You Want To Replace The Items\nFrom The Previous Restaurant?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),

            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Close"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                cart.clearCart(); // 🔥 IMPORTANT
                Navigator.pop(context);
                _addItemDirectly(item, cart);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _addItemDirectly(CategoryItem item, CartNotifier cart) {
    if (item.isCustomizable) {
      _showAddOptionsDialog(item, cart);
    } else {
      cart.addItem(item.toCartItem());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${item.name} added to cart"),
          duration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _addToCart(CategoryItem item, CartNotifier cart) {
    // 🔐 CHECK RESTAURANT RULE
    if (_isDifferentRestaurant(item, cart)) {
      _showReplaceCartDialog(item, cart);
      return;
    }

    // Normal flow
    _addItemDirectly(item, cart);
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
              Navigator.pop(context);
              _addToCart(item, cart); // 🔥 USE SAME RULE
            },
            child: const Text("Quick Add (Base)"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              if (_isDifferentRestaurant(item, cart)) {
                _showReplaceCartDialog(item, cart);
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomizationPage(
                    customizableItem: item,
                    template: item.customizationSteps!,
                  ),
                ),
              );
            },

            child: const Text(
              "Customize",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // 5. RESTAURANT HEADER
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
  // 6. ITEM CARD
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
          // Image
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
          // Details
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
                          "Custom",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (item.isHealthy)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        margin: EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          "Healthy",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  item.restaurantName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                if (item.description?.isNotEmpty == true) ...[
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                if (item.calories != null) ...[
                  Text(
                    "${item.calories} kcal",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
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

  // ---------------------------------------------------
  // 7. BUILD CATEGORY CHIPS
  // ---------------------------------------------------
  Widget _buildCategoryChips(List<DocumentSnapshot> docs, bool healthMode) {
    // Create a unique key for the current state
    String stateKey = "health_${healthMode}_categories_${docs.length}";

    // Auto-select first category only when state changes
    _autoSelectFirstCategory(docs, stateKey);

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
              setState(() {
                _userManuallySelectedCategory = true; // 🔥 IMPORTANT
                _currentCategoryId = id;
                _currentCategoryName = name;
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthMode = context.watch<HealthModeNotifier>().isOn;
    final cart = context.watch<CartNotifier>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search items...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black),
              )
            : Text(
                _currentCategoryName,
                style: const TextStyle(color: Colors.black),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _searchQuery = "";
                  });
                },
              )
            : null,
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                if (_searchController.text.isEmpty) {
                  setState(() {
                    _isSearching = false;
                  });
                } else {
                  _searchController.clear();
                }
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (!_isSearching) ...[
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    healthMode
                        ? Icons.health_and_safety
                        : Icons.health_and_safety_outlined,
                    color: healthMode ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Health",
                    style: TextStyle(
                      fontSize: 12,
                      color: healthMode ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cart.itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // HORIZONTAL CATEGORY CHIPS
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

                final items = snapshot.data!;
                final filteredItems = _searchQuery.isEmpty
                    ? items
                    : items
                          .where(
                            (item) =>
                                item.name.toLowerCase().contains(_searchQuery),
                          )
                          .toList();

                if (filteredItems.isEmpty) {
                  final noItemsText = _searchQuery.isNotEmpty
                      ? "No items found matching '$_searchQuery'"
                      : (healthMode
                            ? "No healthy items found in $_currentCategoryName."
                            : "No items found in $_currentCategoryName.");
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
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                Map<String, List<CategoryItem>> groupedItems = {};

                for (var item in filteredItems) {
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
                        ...restaurantItems.map(
                          (item) => _buildItemCard(item, cart),
                        ),
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
}
