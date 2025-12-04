import 'package:project/restaurent/Ingredientpage.dart';
import 'package:flutter/material.dart';
import 'package:project/restaurent/Orderpage.dart';
import 'package:project/restaurent/dashboard/restaurent_category.dart';
import 'package:project/restaurent/dashboard/todays_orders_page.dart';
import 'package:project/restaurent/dashboard/pending_byod_requests_page.dart';
import 'package:project/restaurent/dashboard/completed_orders_page.dart';
import 'package:project/restaurent/dashboard/todays_earnings_page.dart';
import 'package:project/restaurent/dashboard/low_stock_ingredients_page.dart';
import 'package:project/restaurent/setting/restaurant_profile_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/services/low_stock_service.dart';

// Placeholder `items` list — do not populate here. This list is expected to
// be filled from the app's existing menu/data sources (DB, provider, etc.).
final List<dynamic> items = [];

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LowStockService _lowStockService = LowStockService();

  String _restaurantName = "Restaurant";
  String? _restaurantImageUrl;
  int _lowStockCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // ✅ Fetch from 'users' collection
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _restaurantName = data['fullName']?.isNotEmpty == true
              ? data['fullName']
              : "Restaurant";
          _restaurantImageUrl = data['imageUrl'];
        });
      }
    } catch (e) {
      print('Error loading restaurant data: $e');
    }
  }

  // Widget for notification badge
  Widget _buildNotificationBadge(int count) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: Text(
        count > 9 ? '9+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _restaurantName,
          style: GoogleFonts.pacifico(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          // Profile image with navigation to profile page
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RestaurantProfilePage(),
                ),
              ).then((_) {
                // Reload data when returning from profile page
                _loadRestaurantData();
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 28, // Increased size
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 25, // Slightly smaller inner circle
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      _restaurantImageUrl != null &&
                          _restaurantImageUrl!.isNotEmpty
                      ? NetworkImage(_restaurantImageUrl!)
                      : null,
                  child:
                      _restaurantImageUrl == null ||
                          _restaurantImageUrl!.isEmpty
                      ? const Icon(
                          Icons.restaurant,
                          size: 30,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard",
              style: GoogleFonts.aboreto(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.deepPurple,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),

            // Card 1: Today's Orders
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Orderpage()),
                );
              },
              child: const DashboardCard(
                title: "Today's Orders",
                value: "18",
                icon: Icons.receipt_long,
                color: Colors.deepOrange,
              ),
            ),

            // Card 2: Pending BYOD Requests
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PendingByodRequestsPage(),
                  ),
                );
              },
              child: const DashboardCard(
                title: "Pending BYOD Requests",
                value: "4",
                icon: Icons.fastfood,
                color: Colors.green,
              ),
            ),

            // Card 3: Completed Orders
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompletedOrdersPage(),
                  ),
                );
              },
              child: const DashboardCard(
                title: "Completed Orders",
                value: "12",
                icon: Icons.check_circle,
                color: Colors.blue,
              ),
            ),

            // Card 4: Earnings Summary
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TodaysEarningsPage(),
                  ),
                );
              },
              child: const DashboardCard(
                title: "Today's Earnings",
                value: "₹4,250",
                icon: Icons.attach_money,
                color: Colors.purple,
              ),
            ),

            // ⭐ NEW TILE: Menu Management (in the old model)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuPage()),
                );
              },
              child: const DashboardCard(
                title: "Menu Management",
                value: "Setup & Edit Items",
                icon: Icons.restaurant_menu,
                color: Colors.teal, // Using the new color
              ),
            ),

            // Card 5: Low Stock Alerts with Notification Badge
            StreamBuilder<int>(
              stream: _lowStockService.getLowStockCount(),
              builder: (context, snapshot) {
                final lowStockCount = snapshot.data ?? 0;

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LowStockIngredientsPage(),
                          ),
                        );
                      },
                      child: DashboardCard(
                        title: "Low Stock Ingredients",
                        value: lowStockCount > 0
                            ? "$lowStockCount Items Need Attention"
                            : "All Stock Good",
                        icon: Icons.warning,
                        color: lowStockCount > 0 ? Colors.red : Colors.orange,
                      ),
                    ),
                    if (lowStockCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildNotificationBadge(lowStockCount),
                      ),
                  ],
                );
              },
            ),

            // Card 6: Ingredients
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IngredientPage(),
                  ),
                );
              },
              child: const DashboardCard(
                title: "Ingredients",
                value: "View & Manage",
                icon: Icons.kitchen,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reverted DashboardCard widget (single ListTile model)
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.blue,
        ),
      ),
    );
  }
}
