import 'package:project/restaurent/Ingredientpage.dart';
import 'package:flutter/material.dart';
import 'package:project/restaurent/Orderpage.dart';
import 'package:project/restaurent/dashboard/menupage.dart';
import 'package:project/restaurent/dashboard/todays_orders_page.dart';
import 'package:project/restaurent/dashboard/pending_byod_requests_page.dart';
import 'package:project/restaurent/dashboard/completed_orders_page.dart';
import 'package:project/restaurent/dashboard/todays_earnings_page.dart';
import 'package:project/restaurent/dashboard/low_stock_ingredients_page.dart';

// ---------------------------------------------------------------- //
// Placeholder for MenuPage (You should move this to a separate file)
// class MenuPage extends StatelessWidget {
// const MenuPage({super.key});
//
// @override
// Widget build(BuildContext context) {
// return Scaffold(
// appBar: AppBar(
// title: const Text('Menu Management'),
// backgroundColor: Colors.teal, // New color for Menu
// foregroundColor: Colors.white,
// ),
// body: const Center(
// child: Text(
// 'Manage your Menu items here.',
// style: TextStyle(fontSize: 20, color: Colors.teal),
// ),
// ),
// );
// }
// }
// ---------------------------------------------------------------- //

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    // We are reverting to the simple, single-column layout
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Dashboard"),
      //   elevation: 0, // Resetting AppBar for simpler look
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              child: DashboardCard(
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
              child: DashboardCard(
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
              child: DashboardCard(
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
              child: DashboardCard(
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
              child: DashboardCard(
                title: "Menu Management",
                value: "Setup & Edit Items",
                icon: Icons.restaurant_menu,
                color: Colors.teal, // Using the new color
              ),
            ),

            // Card 5: Low Stock Alerts
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LowStockIngredientsPage(),
                  ),
                );
              },
              child: DashboardCard(
                title: "Low Stock Ingredients",
                value: "3 Items",
                icon: Icons.warning,
                color: Colors.red,
              ),
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
              child: DashboardCard(
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
          color: Colors.grey,
        ),
      ),
    );
  }
}
