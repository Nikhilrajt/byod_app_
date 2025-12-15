import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../state/health_mode_notifier.dart';
import '../state/cart_notifier.dart';
import '../customization_page.dart';
import '../models/category_models.dart';
import '../homescreen/cart.dart';

// ---------------------------------------------------
// CART EXTENSIONS (Keep same behavior)
// ---------------------------------------------------

extension CartNotifierItemCountExtension on CartNotifier {
  int get itemCount {
    try {
      final dynamic items = this.items;
      if (items is Iterable) return items.length;
    } catch (_) {}
    return 0;
  }
}

// ---------------------------------------------------
// CATEGORY PAGE
// ---------------------------------------------------

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
  String? _selectedRestaurantId;
  String? _selectedRestaurantName;

  @override
  void initState() {
    super.initState();
    _currentCategoryId = widget.categoryId;
  }

  // ---------------------------------------------------
  // FETCH RESTAURANTS FROM USERS COLLECTION (role: "restaurant")
  // ---------------------------------------------------
  Stream<List<Map<String, dynamic>>> fetchRestaurantsForCategory(
    String categoryId,
  ) {
    // First, get all restaurants with role: "restaurant"
    final restaurantsQuery = FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "restaurant")
        .where("isActive", isEqualTo: true);

    return restaurantsQuery.snapshots().asyncMap((snap) async {
      final validRestaurants = <Map<String, dynamic>>[];

      for (final doc in snap.docs) {
        final restaurantData = doc.data() as Map<String, dynamic>;
        final restaurantId = doc.id;
        final restaurantName = restaurantData["fullName"] ?? "Restaurant";

        // Check if this restaurant has items in the selected category
        bool hasItemsInCategory = false;

        if (categoryId == "all") {
          // Check if restaurant has any items in any category
          final itemsQuery = await FirebaseFirestore.instance
              .collectionGroup("items")
              .where("restaurantId", isEqualTo: restaurantId)
              .limit(1)
              .get();

          hasItemsInCategory = itemsQuery.docs.isNotEmpty;
        } else {
          // Check if restaurant has items in specific category
          final itemsQuery = await FirebaseFirestore.instance
              .collection("categories")
              .doc(categoryId)
              .collection("items")
              .where("restaurantId", isEqualTo: restaurantId)
              .limit(1)
              .get();

          hasItemsInCategory = itemsQuery.docs.isNotEmpty;
        }

        if (hasItemsInCategory) {
          validRestaurants.add({
            "id": restaurantId,
            "name": restaurantName,
            "image":
                restaurantData["imageUrl"] ?? restaurantData["langedit1"] ?? "",
            "address": restaurantData["address"] ?? "",
            "email": restaurantData["email"] ?? "",
            "phoneNumber": restaurantData["phoneNumber"] ?? "",
          });
        }
      }

      return validRestaurants;
    });
  }

  // ---------------------------------------------------
  // FETCH ITEMS FOR SELECTED RESTAURANT AND CATEGORY
  // ---------------------------------------------------
  Stream<List<CategoryItem>> fetchItemsByRestaurant(
    String categoryId,
    String restaurantId,
    bool healthMode,
  ) {
    Query query;

    if (categoryId == "all") {
      // Get all items from this specific restaurant
      query = FirebaseFirestore.instance
          .collectionGroup("items")
          .where("restaurantId", isEqualTo: restaurantId);
    } else {
      // Get items from specific category and restaurant
      query = FirebaseFirestore.instance
          .collection("categories")
          .doc(categoryId)
          .collection("items")
          .where("restaurantId", isEqualTo: restaurantId);
    }

    if (healthMode) {
      query = query.where("isHealthy", isEqualTo: true);
    }

    return query.snapshots().asyncMap((snap) async {
      // Get restaurant name for the items
      final restaurantDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(restaurantId)
          .get();

      final restaurantName = restaurantDoc.exists
          ? restaurantDoc["fullName"] ?? "Restaurant"
          : "Restaurant";

      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CategoryItem(
          data["name"] ?? "",
          data["imageUrl"] ?? "",
          data["price"] ?? 0,
          double.tryParse(data["rating"]?.toString() ?? "4.5") ?? 4.5,
          restaurantId,
          restaurantName, // Use actual restaurant name
          data["categoryKey"],
          data["description"] ?? "",
          data["isAvailable"] ?? true,
          data["isCustomizable"] ?? false,
          data["isHealthy"] ?? false,
        );
      }).toList();
    });
  }

  // ---------------------------------------------------
  // CUSTOMIZATION TEMPLATE HANDLER
  // ---------------------------------------------------

  final Map<String, List<CustomizationStep>> templates = {
    // (Your template data remains unchanged)
  };

  List<CustomizationStep>? _lookupTemplate(CategoryItem item) {
    return templates[item.categoryKey];
  }

  void _openCustomization(CategoryItem item) {
    final t = _lookupTemplate(item);
    if (t == null || t.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomizationPage(customizableItem: item, template: t),
      ),
    );
  }

  // ---------------------------------------------------
  // ADD TO CART
  // ---------------------------------------------------

  void _addToCart(CategoryItem item, CartNotifier cart) {
    if (_lookupTemplate(item) != null) {
      _showAddOptionsDialog(item, cart);
    } else {
      cart.addItem(item.toCartItem());
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
            },
            child: Text("Quick Add"),
          ),
          if (item.isCustomizable)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _openCustomization(item);
              },
              child: Text("Customize"),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // RESTAURANT CARD UI
  // ---------------------------------------------------

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRestaurantId = restaurant["id"];
            _selectedRestaurantName = restaurant["name"];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Restaurant Image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child:
                    restaurant["image"] != null &&
                        restaurant["image"].isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          restaurant["image"],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.restaurant,
                              size: 30,
                              color: Colors.grey[400],
                            );
                          },
                        ),
                      )
                    : Icon(Icons.restaurant, size: 30, color: Colors.grey[400]),
              ),

              SizedBox(width: 12),

              // Restaurant Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant["name"],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4),

                    if (restaurant["address"] != null &&
                        restaurant["address"].isNotEmpty)
                      Text(
                        restaurant["address"],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(Icons.phone, size: 12, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant["phoneNumber"] ?? "No phone",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // ITEM CARD UI
  // ---------------------------------------------------

  Widget _buildItemCard(CategoryItem item, CartNotifier cart) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.fastfood,
                          size: 30,
                          color: Colors.grey[400],
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4),

                      if (item.description != null &&
                          item.description!.isNotEmpty)
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          // Rating
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              Text(
                                item.rating.toStringAsFixed(1),
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),

                          SizedBox(width: 12),

                          // Price
                          Text(
                            "₹${item.price}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Spacer(),

                          // Health Indicator
                          if (item.isHealthy)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Healthy",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addToCart(item, cart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text("ADD TO CART"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // BUILD UI
  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final healthMode = context.watch<HealthModeNotifier>().isOn;
    final cart = context.watch<CartNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: _selectedRestaurantId != null
            ? Text(_selectedRestaurantName ?? "Menu")
            : Text(widget.categoryName),
        leading: _selectedRestaurantId != null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedRestaurantId = null;
                    _selectedRestaurantName = null;
                  });
                },
              )
            : null,
        actions: [
          // Cart Icon with Badge
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 18, minHeight: 18),
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
          // CATEGORY CHIP SELECTOR (only show when not in restaurant view)
          if (_selectedRestaurantId == null)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200] ?? Colors.grey),
                ),
              ),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("categories")
                    .snapshots()
                    .map(
                      (snap) => snap.docs
                          .map(
                            (doc) => {
                              "id": doc.id,
                              "name": doc["name"],
                              "image": doc["imageUrl"] ?? "",
                            },
                          )
                          .toList(),
                    ),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) return SizedBox();

                  final cats = snapshot.data!;
                  // Add "All" option
                  final allCats = [
                    {"id": "all", "name": "All"},
                    ...cats,
                  ];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: allCats.map((cat) {
                        final isSelected = cat["id"] == _currentCategoryId;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(cat["name"]),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _currentCategoryId = cat["id"];
                                _selectedRestaurantId = null;
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.deepOrange,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.deepOrange
                                    : Colors.grey[300]!,
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

          // BODY CONTENT
          Expanded(
            child: _selectedRestaurantId == null
                ? StreamBuilder<List<Map<String, dynamic>>>(
                    stream: fetchRestaurantsForCategory(_currentCategoryId),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error loading restaurants",
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                "No restaurants available",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "for this category",
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        );
                      }

                      final restaurants = snapshot.data!;

                      return RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});
                        },
                        child: ListView(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "Available Restaurants",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...restaurants.map(_buildRestaurantCard).toList(),
                            SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  )
                : StreamBuilder<List<CategoryItem>>(
                    stream: fetchItemsByRestaurant(
                      _currentCategoryId,
                      _selectedRestaurantId!,
                      healthMode,
                    ),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error loading menu",
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final items = snapshot.data ?? [];

                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fastfood,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                "No items available",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (healthMode)
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    "Try turning off Health Mode for more options",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});
                        },
                        child: ListView(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                "Menu Items",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "${items.length} items found",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            SizedBox(height: 8),
                            ...items
                                .map((item) => _buildItemCard(item, cart))
                                .toList(),
                            SizedBox(height: 20),
                          ],
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

// ---------------------------------------------------
// UPDATED CATEGORY ITEM MODEL (Add these fields)
// ---------------------------------------------------

// In your category_models.dart file, update the CategoryItem class:

/*
class CategoryItem {
  final String name;
  final String imageUrl;
  final int price;
  final double rating;
  final String restaurantId;
  final String restaurantName;
  final String? categoryKey;
  final String? description;
  final bool isAvailable;
  final bool isCustomizable;
  final bool isHealthy;

  CategoryItem(
    this.name,
    this.imageUrl,
    this.price,
    this.rating,
    this.restaurantId,
    this.restaurantName, {
    this.categoryKey,
    this.description,
    this.isAvailable = true,
    this.isCustomizable = false,
    this.isHealthy = false,
  });

  // ... rest of your model methods
}
*/
