import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Dashboard Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: DashboardPage(),
//     );
//   }
// }

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Dashboard")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Card 1: Today's Orders
            DashboardCard(
              title: "Today's Orders",
              value: "18",
              icon: Icons.receipt_long,
              color: Colors.deepOrange,
            ),

            // Card 2: Pending BYOD Requests
            DashboardCard(
              title: "Pending BYOD Requests",
              value: "4",
              icon: Icons.fastfood,
              color: Colors.green,
            ),

            // Card 3: Completed Orders
            DashboardCard(
              title: "Completed Orders",
              value: "12",
              icon: Icons.check_circle,
              color: Colors.blue,
            ),

            // Card 4: Earnings Summary
            DashboardCard(
              title: "Today's Earnings",
              value: "₹4,250",
              icon: Icons.attach_money,
              color: Colors.purple,
            ),

            // Card 5: Low Stock Alerts
            DashboardCard(
              title: "Low Stock Ingredients",
              value: "3 Items",
              icon: Icons.warning,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Navigate to detailed page or show more info
        },
      ),
    );
  }
}
