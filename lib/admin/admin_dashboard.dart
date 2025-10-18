import 'package:flutter/material.dart';
import 'package:project/admin/widget/restaurentcontent.dart';
import 'package:project/admin/widget/usermanagement.dart';
import 'widget/dashboardcontent.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    DashboardContent(),
    
    RestaurentContent(),
    UserManagement(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FoodFlex', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[700],
      ),
      body: Row(
        // Use a Row to place the side panel next to the main content
        children: [
          // This will be your side panel
          Container(
            width: 250.0, // Let's try a more reasonable width
            color: Colors.grey[800], // Your dark background color
            // For height, if it's directly inside a Row within Scaffold's body,
            // it will naturally expand to fill the available height.
            // No explicit height property is usually needed here.
            // Inside the Container for your side panel:
            child: Column(
              children: [
                // Branding / Header (optional, but good practice)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'FoodFlex Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // 1. Dashboard Item
                _SideMenuItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                  selectedIndex: _selectedIndex,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                const SizedBox(height: 5), // Small space between items
                // 2. Restaurant Management Item
                _SideMenuItem(
                  icon: Icons.restaurant,
                  title: 'Restaurent Management',
                  index: 1,
                  selectedIndex: _selectedIndex,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                const SizedBox(height: 5),

                // 3. User Management Item
                _SideMenuItem(
                  icon: Icons.person_3_outlined,
                  title: 'User Management',
                  index: 2,
                  selectedIndex: _selectedIndex,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          // This will be the main content area of your dashboard
          Expanded(
            child: Container(
              color: Colors
                  .white, // Or a light grey for the main content background
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  const _SideMenuItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // THIS IS THE CONTENT YOU NEED TO ADD/CORRECT
    return Container(
      color:
          selectedIndex ==
              index // Use 'selectedIndex' and 'index' properties
          ? Colors.blue[700] // Highlight color
          : Colors.transparent, // Default transparent
      child: InkWell(
        onTap: onTap, // Use the 'onTap' callback property
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70), // Use the 'icon' property
              const SizedBox(width: 10),
              Text(
                title, // Use the 'title' property
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
