import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/restaurent/dashboard/add_item_page.dart';
import 'package:project/models/menu_item_model.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = "";
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  final NumberFormatHelper currency = NumberFormatHelper();

  @override
  void initState() {
    super.initState();
    _loadFirstCategory();
  }

  Future<void> _loadFirstCategory() async {
    try {
      final snapshot = await _firestore.collection("categories").limit(1).get();
      if (snapshot.docs.isNotEmpty && mounted) {
        final firstCategory = snapshot.docs.first;
        setState(() {
          _selectedCategoryId = firstCategory.id;
          _selectedCategoryName = firstCategory.data()["name"] ?? "Category";
        });
      }
    } catch (e) {
      print('Error loading first category: $e');
    }
  }

  // 🔥 GET ITEMS FOR SELECTED CATEGORY
  Stream<List<MenuItem>> getItemsForCategory(String categoryId) {
    return _firestore
        .collection("categories")
        .doc(categoryId)
        .collection("items")
        .where("restaurantId", isEqualTo: _auth.currentUser!.uid)
        .snapshots()
        .map((snap) {
          final items = snap.docs
              .map((doc) => MenuItem.fromMap(doc.data()))
              .toList();
          items.sort((a, b) => a.name.compareTo(b.name));
          return items;
        });
  }

  // 🔥 ENHANCED SEARCH FILTER
  bool _matchesSearch(MenuItem item) {
    if (_searchQuery.isEmpty) return true;
    return item.name.toLowerCase().contains(_searchQuery) ||
        item.description.toLowerCase().contains(_searchQuery);
  }

  // 🔥 DELETE ITEM
  Future<void> deleteItem(String itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true && _selectedCategoryId != null) {
      await _firestore
          .collection("categories")
          .doc(_selectedCategoryId)
          .collection("items")
          .doc(itemId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item deleted successfully")),
        );
      }
    }
  }

  // 🔥 BUILD ITEM CARD
  Widget _buildItemCard(MenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemPage(
                categoryId: _selectedCategoryId ?? "",
                categoryName: _selectedCategoryName ?? "",
                initialItem: MenuItem.fromMap(item.toMap()),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE WITH VEG/NON-VEG BADGE
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: item.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.fastfood,
                                  size: 30,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.fastfood,
                            size: 30,
                            color: Colors.grey,
                          ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.circle,
                        color: item.isVeg ? Colors.green : Colors.red,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // ITEM DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (item.description.isNotEmpty)
                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currency.format(item.price),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // RIGHT SIDE ACTIONS
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: item.isAvailable
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: item.isAvailable
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Text(
                      item.isAvailable ? "Available" : "Unavailable",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: item.isAvailable
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => deleteItem(item.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Menu"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          if (_selectedCategoryId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddItemPage(
                  categoryId: _selectedCategoryId ?? "",
                  categoryName: _selectedCategoryName ?? "",
                ),
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Food"),
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search food items...",
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          // 🧂 CATEGORIES LIST (HORIZONTAL)
          SizedBox(
            height: 100,
            child: StreamBuilder(
              stream: _firestore.collection("categories").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  );
                }

                final categories = snapshot.data!.docs;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final data = categories[index].data();
                    final categoryId = categories[index].id;
                    final isSelected = _selectedCategoryId == categoryId;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = categoryId;
                          _selectedCategoryName = data["name"];
                          _searchQuery = "";
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.deepPurple,
                                        width: 3,
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: CircleAvatar(
                                radius: 34,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: data["imageUrl"] != null
                                    ? NetworkImage(data["imageUrl"])
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data["name"],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 🧂 ITEMS LIST
          Expanded(
            child: _selectedCategoryId == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  )
                : StreamBuilder<List<MenuItem>>(
                    stream: getItemsForCategory(_selectedCategoryId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepPurple,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Error loading items",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No food items yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Click 'Add Food' to start adding items!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final items = snapshot.data!;
                      final filtered = items.where(_matchesSearch).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No items found for '$_searchQuery'",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _buildItemCard(filtered[index]);
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

// Helper: Currency Formatter
class NumberFormatHelper {
  String format(double value) {
    return "₹${value.toStringAsFixed(2)}";
  }
}
