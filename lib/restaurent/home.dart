import 'package:flutter/material.dart';
import 'package:project/restaurent/dashboard/Dashboard.dart';
import 'package:project/restaurent/Ingredientpage.dart';
import 'package:project/restaurent/Orderpage.dart';
import 'package:project/restaurent/feedbackpage.dart';
import 'package:project/restaurent/setting/settingspage.dart';

class restaurent_home_page extends StatefulWidget {
  const restaurent_home_page({super.key});

  @override
  State<restaurent_home_page> createState() => _restaurent_home_pageState();
}

class _restaurent_home_pageState extends State<restaurent_home_page> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    DashboardPage(),
    Orderpage(),
    IngredientPage(),
    Feedbackpage(),
    Settingspage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("foodflex restaurent")),
      appBar: AppBar(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Ingredients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
