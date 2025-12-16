import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/restaurent/dashboard/category_items_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Menu"),
        backgroundColor: Colors.deepPurple,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search items...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.deepPurple,
                  ),
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

            // ====================================================
            // 1. STANDARD CATEGORIES SECTION
            // ====================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // Standard List (Shows Mixed or Non-Healthy)
            _buildCategoryList(isHealthySection: false),

            const SizedBox(height: 20),
            Divider(thickness: 6, color: Colors.grey.shade100), // Separator
            // ====================================================
            // 2. HEALTHY CORNER SECTION (NEW)
            // ====================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: const [
                  Icon(Icons.spa, color: Colors.green), // Healthy Icon
                  SizedBox(width: 8),
                  Text(
                    "Healthy Corner",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // Healthy List (Shows ONLY Healthy)
            _buildCategoryList(isHealthySection: true),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // REUSABLE WIDGET TO BUILD THE LISTS
  // ---------------------------------------------------
  Widget _buildCategoryList({required bool isHealthySection}) {
    // Define the Query
    Query query = _firestore.collection("categories");

    // If this is the Healthy Section, filter strictly for true
    if (isHealthySection) {
      query = query.where('isHealthy', isEqualTo: true);
    }
    // If you want the top list to HIDE healthy items, uncomment the line below:
    // else { query = query.where('isHealthy', isEqualTo: false); }

    return SizedBox(
      height: 130, // Fixed height for the list
      child: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // Optional: Client-side search filtering
          final filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'].toString().toLowerCase();
            return _searchQuery.isEmpty || name.contains(_searchQuery);
          }).toList();

          if (filteredDocs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                isHealthySection
                    ? "No healthy items yet."
                    : "No categories found.",
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryItemsPage(
                        categoryId: doc.id,
                        categoryName: data["name"],
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2), // Border width
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Green border for healthy items
                          border: isHealthySection
                              ? Border.all(color: Colors.green, width: 2)
                              : null,
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
                      Text(data["name"], style: const TextStyle(fontSize: 14)),
                    ],
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
