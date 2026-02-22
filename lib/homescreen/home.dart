import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/homescreen/BYOD/restaurent_list_Screen.dart';
import 'package:project/homescreen/cart.dart';
import 'package:project/homescreen/homecontent.dart';
import 'package:project/profile/profile.dart';
import 'package:project/homescreen/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // Index 0: Category (starts empty)
    HomeContent(),
    const CategoryPage(
      categoryName: "All Restaurants",
      categoryId: "",
      // restaurantId: '',
    ), // Index 1: Categories
    RestaurentListScreen(), // Index 2: BYOD tab
    CartScreen(), // Index 3: Cart
    Center(child: ProfileScreen()), // Index 4: Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Soft warm orange abstract background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFF3E0), // Very light orange
                    Colors.white,
                    const Color(0xFFFFF8E1), // Light amber/orange hint
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Subtle organic shapes
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.05),
              ),
            ),
          ),
          // Main Content
          Theme(
            data: Theme.of(context).copyWith(
              scaffoldBackgroundColor: Colors.transparent,
              appBarTheme: Theme.of(context).appBarTheme.copyWith(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.category),
                label: 'category',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/images/BYOD plate.svg',
                  width: 35,
                ),
                label: 'byod',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
