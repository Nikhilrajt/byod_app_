import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:project/models/menu_item_model.dart';
import 'package:project/restaurent/dashboard/add_item_page.dart';

class ManageMenuPage extends StatefulWidget {
  const ManageMenuPage({super.key});

  @override
  State<ManageMenuPage> createState() => _ManageMenuPageState();
}

class _ManageMenuPageState extends State<ManageMenuPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= FIRESTORE =================

  Stream<QuerySnapshot> getCategories() {
    return _firestore.collection("categories").snapshots();
  }

  Stream<List<MenuItem>> getItems(String categoryId, String categoryName) {
    return _firestore
        .collection("categories")
        .doc(categoryId)
        .collection("items")
        .where("restaurantId", isEqualTo: _auth.currentUser!.uid)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = Map<String, dynamic>.from(d.data());
            data['categoryId'] = categoryId;
            data['categoryName'] = categoryName;
            return MenuItem.fromMap(data);
          }).toList(),
        );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5F5AE0), Color(0xFF8E88FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Manage Menu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: getCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final category = categories[i];
              return _categoryGlass(category.id, category["name"]);
            },
          );
        },
      ),
    );
  }

  // ================= CATEGORY CARD =================

  Widget _categoryGlass(String categoryId, String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(16),
      decoration: _glass(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Category items",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const Spacer(),
              _pill(
                "Add Item",
                Icons.add,
                () => _addFood(categoryId, name),
                const Color(0xFF5F5AE0),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<MenuItem>>(
            stream: getItems(categoryId, name),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final items = snapshot.data!;
              if (items.isEmpty) {
                return Text(
                  "No items added yet",
                  style: TextStyle(color: Colors.grey.shade500),
                );
              }
              return Column(
                children: items
                    .map((item) => _foodGlass(item, categoryId))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= FOOD CARD =================

  Widget _foodGlass(MenuItem item, String categoryId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: _glass(light: true),
      child: Row(
        children: [
          // IMAGE
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade200, Colors.grey.shade100],
              ),
              borderRadius: BorderRadius.circular(12),
              image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.imageUrl == null || item.imageUrl!.isEmpty
                ? const Icon(Icons.fastfood, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${item.price}",
                  style: const TextStyle(
                    color: Color(0xFF5F5AE0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    if (item.byod) _tag("BYOD", Colors.teal),
                    if (item.health) _tag("HEALTH", Colors.orange),
                  ],
                ),
              ],
            ),
          ),

          // ACTIONS
          Column(
            children: [
              _availabilityChip(item.isAvailable),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 20,
                  color: Color(0xFF5F5AE0),
                ),
                onPressed: () => _editFood(item, categoryId),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: () => _deleteFood(item, categoryId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ACTIONS =================

  void _addFood(String categoryId, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddItemPage(categoryId: categoryId, categoryName: categoryName),
      ),
    );
  }

  void _editFood(MenuItem item, String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemPage(
          categoryId: categoryId,
          categoryName: item.categoryName,
          initialItem: item,
        ),
      ),
    );
  }

  Future<void> _deleteFood(MenuItem item, String categoryId) async {
    await _firestore
        .collection("categories")
        .doc(categoryId)
        .collection("items")
        .doc(item.id)
        .delete();
  }

  // ================= UI HELPERS =================

  BoxDecoration _glass({bool light = false, double radius = 22}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: light
            ? [Colors.white, Colors.white.withOpacity(0.92)]
            : [Colors.white, Colors.white.withOpacity(0.88)],
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          blurRadius: 35,
          offset: Offset(0, 14),
          color: Color(0x16000000),
        ),
      ],
    );
  }

  Widget _pill(String text, IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color)),
    );
  }

  Widget _availabilityChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? Colors.green : Colors.red),
      ),
      child: Text(
        active ? "Available" : "Unavailable",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: active ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
