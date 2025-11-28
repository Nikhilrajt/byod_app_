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

            // 🧂 CATEGORIES HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🧂 CATEGORIES LIST (HORIZONTAL)
            SizedBox(
              height: 120,
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

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryItemsPage(
                                categoryId: categoryId,
                                categoryName: data["name"],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 34,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: data["imageUrl"] != null
                                    ? NetworkImage(data["imageUrl"])
                                    : null,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                data["name"],
                                style: const TextStyle(fontSize: 14),
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

            const SizedBox(height: 30),

            Center(
              child: Text(
                "Select a category to manage items",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
