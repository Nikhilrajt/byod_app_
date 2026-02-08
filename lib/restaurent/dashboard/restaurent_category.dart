import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/restaurent/dashboard/add_item_page.dart';
import 'package:project/models/menu_item_model.dart';
import 'package:project/restaurent/dashboard/category_items_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _searchQuery = "";

  final NumberFormatHelper currency = NumberFormatHelper();

  // 🎨 Colors (UPDATED VALUES ONLY)
  static const Color kPrimary = Color(0xFF3F2B96);
  static const Color kPrimaryLight = Color(0xFF5F5AA2);
  static const Color kBg = Color(0xFFF6F7FB);

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,

      // 🔝 APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimary, kPrimaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Restaurant Menu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // 📄 BODY
      body: Column(
        children: [
          _searchBar(),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(child: _buildCategorySections()),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH BAR =================

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search categories...",
          prefixIcon: const Icon(Icons.search, color: kPrimary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: kPrimary),
          ),
        ),
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
      ),
    );
  }

  // ================= CATEGORY SECTIONS =================

  Widget _buildCategorySections() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("categories").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final allDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? "").toString().toLowerCase();
          return name.contains(_searchQuery);
        }).toList();

        final normalDocs = allDocs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          return data['isHealthy'] != true;
        }).toList();

        final healthyDocs = allDocs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          return data['isHealthy'] == true;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. STANDARD MENU
            if (normalDocs.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  "Standard Menu",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 120, child: _buildHorizontalList(normalDocs)),
            ],

            // 2. HEALTHY CORNER (Lower)
            if (healthyDocs.isNotEmpty) ...[
              if (normalDocs.isNotEmpty)
                const Divider(
                  height: 24,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),

              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.spa, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Healthy Corner",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 120, child: _buildHorizontalList(healthyDocs)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHorizontalList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: docs.length,
      itemBuilder: (_, i) {
        final doc = docs[i];
        final data = doc.data() as Map<String, dynamic>;
        final id = doc.id;
        final isHealthy = data['isHealthy'] == true;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryItemsPage(
                  categoryId: id,
                  categoryName: data["name"],
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isHealthy
                              ? Colors.green.withOpacity(0.5)
                              : Colors.black,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: data["imageUrl"] != null
                            ? NetworkImage(data["imageUrl"])
                            : null,
                      ),
                    ),
                    if (isHealthy)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.spa,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 72,
                  child: Text(
                    data["name"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: isHealthy ? Colors.green : Colors.black,
                    ),
                  ),
                ),
                if (isHealthy)
                  const Text(
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
        );
      },
    );
  }
}

// ================= CURRENCY =================

class NumberFormatHelper {
  String format(double value) => "₹${value.toStringAsFixed(2)}";
}
