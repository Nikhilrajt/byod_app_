import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/homescreen/BYOD/byod.dart' as byod;

class ByodRestaurantsPage extends StatelessWidget {
  const ByodRestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BYOD Restaurants"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'restaurant')
            .where('isByodEnabled', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_food, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "No BYOD restaurants found",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // Extract data safely
              final name = data['fullName'] ?? data['name'] ?? 'Unknown';
              final imageUrl = data['imageUrl'] ?? '';
              final rating =
                  double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0;
              final description = data['description'] ?? 'BYOD Enabled';
              final location = data['address'] ?? 'Unknown Location';

              return _ByodRestaurantCard(
                id: doc.id,
                name: name,
                imageUrl: imageUrl,
                rating: rating,
                description: description,
                location: location,
              );
            },
          );
        },
      ),
    );
  }
}

class _ByodRestaurantCard extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final String description;
  final String location;

  const _ByodRestaurantCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.description,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => byod.RestaurantDetailScreen(
              restaurant: byod.Restaurant(
                id: id,
                name: name,
                imagePath: imageUrl,
                rating: rating,
                time: '30-45 mins',
                category: 'Restaurant',
                location: location,
                offer: 'BYOD Available',
              ),
            ),
          ),
        );
      },
      child: Container(
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image, size: 40),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: const Text(
                        "BYOD Available",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '$rating • 30-45 mins',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Restaurant",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(location, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
