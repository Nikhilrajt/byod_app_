import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    CategoryPage(categoryName: ''), // Index 1: Home
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
              BottomNavigationBarItem(
                icon: Icon(Icons.home, weight: 70),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category),
                label: 'category',
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

// Categories Page for bottom navigation
// class _CategoriesPage extends StatelessWidget {
//   final List<Map<String, String>> categories = const [
//     {'name': 'Pizza', 'image': 'assets/images/Classic Cheese Pizza.png'},
//     {'name': 'Burgers', 'image': 'assets/images/burger.png'},
//     {'name': 'Pasta', 'image': 'assets/images/newpasta.png'},
//     {'name': 'Desserts', 'image': 'assets/images/newlava.jpg'},
//     {'name': 'Drinks', 'image': 'assets/images/drinks.jpg'},
//     {'name': 'Salads', 'image': 'assets/images/salad.jpg'},
//     {'name': 'Wraps', 'image': 'assets/images/wraps.jpg'},
//     {'name': 'Fries', 'image': 'assets/images/fries.jpg'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           final category = categories[index];
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => CategoryPage(
//                     categoryName: category['name']!,
//                   ),
//                 ),
//               );
//             },
//             child: Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 5,
//                     offset: Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     margin: const EdgeInsets.all(12),
//                     height: 80,
//                     width: 80,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: const Color(0xFFE5E7EB),
//                         width: 3,
//                       ),
//                     ),
//                     child: ClipOval(
//                       child: Image.asset(
//                         category['image']!,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return const Icon(
//                             Icons.image_not_supported,
//                             color: Colors.grey,
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Text(
//                       category['name']!,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                   const Padding(
//                     padding: EdgeInsets.only(right: 16),
//                     child: Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
