import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/restaurent/dashboard/add_item_page.dart';
import 'package:project/restaurent/dashboard/restaurent_category.dart';
import 'package:project/services/upload_image.dart';
import 'package:project/models/menu_item_model.dart';

// IMPORTANT: your updated AddItemPage

class CategoryItemsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryItemsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryItemsPage> createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NumberFormatHelper currency = NumberFormatHelper();
  String _searchQuery = "";

  // 🔥 STREAM FOR ITEMS INSIDE CATEGORY
  Stream<List<MenuItem>> getItems() {
    return _firestore
        .collection("categories")
        .doc(widget.categoryId)
        .collection("items")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => MenuItem.fromMap(doc.data()))
              .toList();
        });
  }

  // 🔥 DELETE ITEM
  Future<void> deleteItem(String itemId) async {
    await _firestore
        .collection("categories")
        .doc(widget.categoryId)
        .collection("items")
        .doc(itemId)
        .delete();
  }

  // 🔥 GRID ITEM CARD
  Widget buildGridItem(MenuItem item) {
    return GestureDetector(
      onTap: () {
        // EDIT ITEM
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddItemPage(
              categoryId: widget.categoryId,
              categoryName: widget.categoryName,
              initialItem: MenuItem.fromMap(item.toMap()),
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),

            // NAME & PRICE
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency.format(item.price),
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // DELETE BUTTON
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteItem(item.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.deepPurple,
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          // ADD NEW ITEM
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemPage(
                categoryId: widget.categoryId,
                categoryName: widget.categoryName,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Food"),
      ),

      body: Column(
        children: [
          // SEARCH BAR
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

          // ITEMS GRID
          Expanded(
            child: StreamBuilder<List<MenuItem>>(
              stream: getItems(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  );
                }

                final items = snapshot.data!;
                final filtered = items.where((item) {
                  return item.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "No food items yet.\nClick 'Add Food' to start!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return buildGridItem(filtered[index]);
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

// ------------------------------
// Helper: Currency Formatter
// ------------------------------
class NumberFormatHelper {
  String format(double value) {
    return "₹${value.toStringAsFixed(2)}";
  }
}

// ------------------------------
// Item Model (for this file)
// ------------------------------
class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? nutrition;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.nutrition,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      id: map["id"],
      name: map["name"],
      description: map["description"],
      price: (map["price"] ?? 0.0).toDouble(),
      imageUrl: map["imageUrl"],
      nutrition: map["nutrition"],
    );
  }
}
