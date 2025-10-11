import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:project/homescreen/BYOD/byod.dart';
import 'package:project/homescreen/BYOD/restaurent_list_Screen.dart';
import 'package:project/homescreen/cart.dart';
import 'package:project/homescreen/delivery.dart';
import 'package:project/homescreen/homecontent.dart';
import 'package:project/profile/profile.dart';
// import 'package:project/homescreen/location.dart'; // Make sure this path matches the actual file where LocationScreen is defined
// TODO: Update the import below to the correct path if profile.dart exists elsewhere
// import 'package:project/your_actual_profile_path/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(), // Home
    LocationScreen(),
      RestaurentListScreen(),
    CartScreen(),
    Center(child: ProfileScreen()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(100)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(100)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.delivery_dining_outlined, weight: 70),
                label: 'Location',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/images/BYOD plate.svg',
                  width: 70,
                ),
                label: 'byod',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_sharp),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  


// Scaffold(
//       backgroundColor: Colors.white,
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         selectedItemColor: Colors.amber,
//         unselectedItemColor: Colors.white,
//         backgroundColor: Colors.black,
//         type: BottomNavigationBarType.fixed,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.delivery_dining_outlined, weight: 70),
//             label: 'Location',
//           ),
//           BottomNavigationBarItem(
//             icon: SvgPicture.asset('assets/images/BYOD plate.svg', width: 70),
//             label: 'byod',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart_sharp),
//             label: 'Cart',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Profile',
//           ),
//         ],
//       ),
      
//     );