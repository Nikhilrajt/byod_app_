import 'package:flutter/material.dart';

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
    Center(child: Text('Restaurent Management Page')),
    Center(child: Text('User Management Page')),
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
            child: Column(
              // Your Column for vertical arrangement of menu items
              children: [
                // Add some initial padding at the top for the app title/logo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  // child: Text(
                  //   ' // Placeholder for your branding
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ),
                // This is where your menu items will go
                // For now, just a placeholder
                Container(
                  color: _selectedIndex == 0
                      ? Colors.blue[900]
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.dashboard, color: Colors.white70),
                          SizedBox(width: 10),
                          Text(
                            'Dashboard',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  color: _selectedIndex == 1
                      ? Colors.blue[900]
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.white70),
                          SizedBox(width: 10),
                          Text(
                            'Restaurent Management',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  color: _selectedIndex == 2
                      ? Colors.blue[900]
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.person_3_outlined, color: Colors.white70),
                          SizedBox(width: 10),
                          Text(
                            'User Management',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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



class _SidemenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;
  const _SidemenuItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    this.selectedIndex == this.index;

    return Container();
  }
}
