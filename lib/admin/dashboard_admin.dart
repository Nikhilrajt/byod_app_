import 'package:flutter/material.dart';
import 'package:project/admin/admin_category.dart';
import 'package:project/admin/restaurant_admin.dart';
import 'package:project/admin/settings_admin.dart';
import 'package:project/admin/user_admin.dart';
import 'package:project/admin/review_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: <Widget>[
            _buildDashboardCard('Categories', Icons.category, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCategoryPage()));
            }),
            _buildDashboardCard('Restaurants', Icons.restaurant, () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminRestaurantPage()));
            }),
            _buildDashboardCard('Users', Icons.people, () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminUserPage()));
            }),
            _buildDashboardCard('Settings', Icons.settings, () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSettingsPage()));
            }),
            _buildDashboardCard('Reviews', Icons.reviews, () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminReviewPage()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48.0),
            const SizedBox(height: 8.0),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
