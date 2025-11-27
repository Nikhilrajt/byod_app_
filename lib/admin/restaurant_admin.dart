import 'package:flutter/material.dart';

class AdminRestaurantPage extends StatefulWidget {
  const AdminRestaurantPage({super.key});

  @override
  State<AdminRestaurantPage> createState() => _AdminRestaurantPageState();
}

class _AdminRestaurantPageState extends State<AdminRestaurantPage> {
  final List<Map<String, dynamic>> _restaurants = [
    {
      "name": "The Gourmet Kitchen",
      "location": "123 Main St, Anytown",
      "isActive": true,
    },
    {
      "name": "Pizza Palace",
      "location": "456 Oak Ave, Somecity",
      "isActive": false,
    },
    {
      "name": "Burger Barn",
      "location": "789 Pine Ln, Otherville",
      "isActive": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Restaurants'),
      ),
      body: ListView.builder(
        itemCount: _restaurants.length,
        itemBuilder: (context, index) {
          return _buildRestaurantTile(_restaurants[index], index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your logic here to add a new restaurant
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRestaurantTile(Map<String, dynamic> restaurant, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant['name'],
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(restaurant['location']),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _restaurants[index]['isActive'] =
                          !_restaurants[index]['isActive'];
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        restaurant['isActive'] ? Colors.green : Colors.grey,
                  ),
                  child: Text(restaurant['isActive'] ? 'Active' : 'Deactivated'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _restaurants.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
