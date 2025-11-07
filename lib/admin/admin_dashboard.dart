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
  bool _compactView = false;
  bool _sideMenuVisible = true;
  // Pages will be rebuilt in build() so we can pass current settings
  List<Widget> _pages(BuildContext context) => [
    DashboardContent(compactView: _compactView),
    RestaurentContent(),
    UserManagement(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodFlex', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              setState(() {
                _sideMenuVisible = !_sideMenuVisible;
              });
            },
            tooltip: _sideMenuVisible ? 'Hide side menu' : 'Show side menu',
          ),
        ],
      ),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _sideMenuVisible ? 250.0 : 0.0,
            child: _sideMenuVisible
                ? Container(
                    color: Colors.grey[800],
                    child: Column(
                      children: [
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
                        const SizedBox(height: 5),
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
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: _pages(context)[_selectedIndex],
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
    Key? key,
    required this.icon,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selectedIndex == index ? Colors.blue[700] : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
