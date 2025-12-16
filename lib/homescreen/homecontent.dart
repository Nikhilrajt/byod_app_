// lib/homescreen/homecontent.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:project/homescreen/HomeBannerCarousel.dart';
import 'package:project/homescreen/cart_itme.dart';
import 'package:project/models/cart_item.dart';
import 'package:provider/provider.dart';
import '../state/health_mode_notifier.dart';
import 'category.dart';
import 'restaurant_detail.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int _currentOffer = 0;

  // ---------- SEARCH STATE ----------
  final TextEditingController _searchCtl = TextEditingController();
  String _query = '';
  bool _matches(String text) =>
      text.toLowerCase().contains(_query.toLowerCase());

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  /// Normal offer banners
  final List<String> normalBanners = const [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
    'assets/images/4.png',
  ];

  /// Health mode banners
  final List<String> healthBanners = const [
    'assets/images/health1.png',
    'assets/images/health2.png',
  ];

  /// Normal Categories (original)
  final List<_Category> normalCategories = const [
    _Category('Pizza', 'assets/images/Classic Cheese Pizza.png'),
    _Category('Burgers', 'assets/images/burger.png'),
    _Category('Pasta', 'assets/images/newpasta.png'),
    _Category('Desserts', 'assets/images/newlava.jpg'),
    _Category('Drinks', 'assets/images/drinks.jpg'),
    _Category('Salads', 'assets/images/salad.jpg'),
    _Category('Wraps', 'assets/images/wraps.jpg'),
    _Category('Fries', 'assets/images/fries.jpg'),
  ];

  /// Health Mode Categories
  final List<_Category> healthCategories = const [
    _Category('Fruits', 'assets/images/fruits.png'),
    _Category('Dry Fruits', 'assets/images/dry fruits.png'),
    _Category('Mushroom', 'assets/images/mushrrom.png'),
    _Category('Paneer', 'assets/images/paneer.png'),
    _Category('Corn', 'assets/images/corn.png'),
    _Category('Salads', 'assets/images/salad.jpg'),
  ];

  /// Normal New Food Arrivals
  final List<_Food> normalNewArrivals = const [
    _Food(
      name: 'Cheese Burst Pizza',
      img: 'assets/images/newpizza.jpg',
      price: 199,
      rating: 4.5,
    ),
    _Food(
      name: 'Sadya',
      img: 'assets/images/Kerala-Sadya.jpg',
      price: 149,
      rating: 4.5,
    ),
    _Food(
      name: 'Chocolate Lava Cake',
      img: 'assets/images/newlava.jpg',
      price: 89,
      rating: 4.8,
    ),
    _Food(
      name: 'Pasta Alfredo',
      img: 'assets/images/newpasta.png',
      price: 169,
      rating: 4.4,
    ),
  ];

  /// Health-mode top dishes
  final List<_Food> healthNewArrivals = const [
    _Food(
      name: 'Mixed Fruit Bowl',
      img: 'assets/images/mixed_fruit_bowl.png',
      price: 99,
      rating: 4.6,
    ),
    _Food(
      name: 'Dry Fruit Mix',
      img: 'assets/images/dry_fruit_mix.png',
      price: 149,
      rating: 4.5,
    ),
    _Food(
      name: 'Grilled Mushroom Skewers',
      img: 'assets/images/mushroom_skewers.png',
      price: 129,
      rating: 4.4,
    ),
    _Food(
      name: 'Paneer & Veg Bowl',
      img: 'assets/images/paneer_bowl.png',
      price: 159,
      rating: 4.7,
    ),
  ];

  List<_Category> getActiveCategories(bool healthMode) =>
      healthMode ? healthCategories : normalCategories;
  List<_Food> getActiveNewArrivals(bool healthMode) =>
      healthMode ? healthNewArrivals : normalNewArrivals;
  List<String> getActiveBanners(bool healthMode) =>
      healthMode ? healthBanners : normalBanners;

  // Get food items for a specific restaurant
  List<CategoryItem> _getFoodItemsForRestaurant(String restaurantName) {
    final List<CategoryItem> allItems = [];

    if (restaurantName == 'Planet Cafe') {
      allItems.addAll([
        CategoryItem(
          id: 'planet_1',
          name: 'Margherita Pizza',
          image: 'assets/images/Classic Cheese Pizza.png',
          price: 199,
          rating: 4.5,
          restaurantName: 'Planet Cafe',
        ),
        CategoryItem(
          id: 'planet_2',
          name: 'Pepperoni Pizza',
          image: 'assets/images/Classic Cheese Pizza.png',
          price: 249,
          rating: 4.6,
          restaurantName: 'Planet Cafe',
        ),
        CategoryItem(
          id: 'planet_3',
          name: 'Veggie Burger',
          image: 'assets/images/burger.png',
          price: 139,
          rating: 4.3,
          restaurantName: 'Planet Cafe',
        ),
        CategoryItem(
          id: 'planet_4',
          name: 'Chicken Burger',
          image: 'assets/images/burger.png',
          price: 189,
          rating: 4.6,
          restaurantName: 'Planet Cafe',
        ),
        CategoryItem(
          id: 'planet_5',
          name: 'Penne Arrabbiata',
          image: 'assets/images/newpasta.png',
          price: 159,
          rating: 4.3,
          restaurantName: 'Planet Cafe',
        ),
        CategoryItem(
          id: 'planet_6',
          name: 'Mac & Cheese',
          image: 'assets/images/newpasta.png',
          price: 149,
          rating: 4.6,
          restaurantName: 'Planet Cafe',
        ),
        CategoryItem(
          id: 'planet_7',
          name: 'Chocolate Lava Cake',
          image: 'assets/images/newlava.jpg',
          price: 89,
          rating: 4.8,
          restaurantName: 'Planet Cafe',
        ),
        CategoryItem(
          id: 'planet_8',
          name: 'Ice Cream Sundae',
          image: 'assets/images/newlava.jpg',
          price: 99,
          rating: 4.6,
          restaurantName: 'Planet Cafe',
        ),
      ]);
    } else if (restaurantName == 'Big Flooda') {
      allItems.addAll([
        CategoryItem(
          id: 'big_1',
          name: 'Veggie Supreme',
          image: 'assets/images/Classic Cheese Pizza.png',
          price: 229,
          rating: 4.4,
          restaurantName: 'Big Flooda',
        ),
        CategoryItem(
          id: 'big_2',
          name: 'BBQ Chicken Pizza',
          image: 'assets/images/Classic Cheese Pizza.png',
          price: 279,
          rating: 4.7,
          restaurantName: 'Big Flooda',
        ),
        CategoryItem(
          id: 'big_3',
          name: 'Classic Burger',
          image: 'assets/images/burger.png',
          price: 149,
          rating: 4.4,
          restaurantName: 'Big Flooda',
        ),
        CategoryItem(
          id: 'big_4',
          name: 'Cheese Burger',
          image: 'assets/images/burger.png',
          price: 169,
          rating: 4.5,
          restaurantName: 'Big Flooda',
        ),
        CategoryItem(
          id: 'big_5',
          name: 'Pasta Primavera',
          image: 'assets/images/newpasta.png',
          price: 189,
          rating: 4.4,
          restaurantName: 'Big Flooda',
        ),
        CategoryItem(
          id: 'big_6',
          name: 'Lasagna',
          image: 'assets/images/newpasta.png',
          price: 199,
          rating: 4.7,
          restaurantName: 'Big Flooda',
        ),
        CategoryItem(
          id: 'big_7',
          name: 'Brownie',
          image: 'assets/images/newlava.jpg',
          price: 79,
          rating: 4.5,
          restaurantName: 'Big Flooda',
        ),
        CategoryItem(
          id: 'big_8',
          name: 'Cheesecake',
          image: 'assets/images/newlava.jpg',
          price: 129,
          rating: 4.7,
          restaurantName: 'Big Flooda',
        ),
      ]);
    } else if (restaurantName == 'Eato') {
      allItems.addAll([
        CategoryItem(
          id: 'eato_1',
          name: 'Farmhouse Pizza',
          image: 'assets/images/Classic Cheese Pizza.png',
          price: 259,
          rating: 4.5,
          restaurantName: 'Eato',
        ),
        CategoryItem(
          id: 'eato_2',
          name: 'Cheese Burst Pizza',
          image: 'assets/images/newpizza.jpg',
          price: 299,
          rating: 4.8,
          restaurantName: 'Eato',
        ),
        CategoryItem(
          id: 'eato_3',
          name: 'Double Cheese Burger',
          image: 'assets/images/burger.png',
          price: 219,
          rating: 4.7,
          restaurantName: 'Eato',
        ),
        CategoryItem(
          id: 'eato_4',
          name: 'BBQ Burger',
          image: 'assets/images/burger.png',
          price: 199,
          rating: 4.5,
          restaurantName: 'Eato',
        ),
        CategoryItem(
          id: 'eato_5',
          name: 'Spaghetti Carbonara',
          image: 'assets/images/newpasta.png',
          price: 179,
          rating: 4.5,
          restaurantName: 'Eato',
        ),
        CategoryItem(
          id: 'eato_6',
          name: 'Fettuccine Pasta',
          image: 'assets/images/newpasta.png',
          price: 169,
          rating: 4.4,
          restaurantName: 'Eato',
        ),
        CategoryItem(
          id: 'eato_7',
          name: 'Tiramisu',
          image: 'assets/images/newlava.jpg',
          price: 139,
          rating: 4.6,
          restaurantName: 'Eato',
        ),
        CategoryItem(
          id: 'eato_8',
          name: 'Chocolate Mousse',
          image: 'assets/images/newlava.jpg',
          price: 109,
          rating: 4.4,
          restaurantName: 'Eato',
        ),
      ]);
    } else if (restaurantName == 'Juicy') {
      allItems.addAll([
        CategoryItem(
          id: 'juicy_1',
          name: 'Fresh Orange Juice',
          image: 'assets/images/drinks.jpg',
          price: 59,
          rating: 4.3,
          restaurantName: 'Juicy',
        ),
        CategoryItem(
          id: 'juicy_2',
          name: 'Mango Smoothie',
          image: 'assets/images/drinks.jpg',
          price: 69,
          rating: 4.5,
          restaurantName: 'Juicy',
        ),
        CategoryItem(
          id: 'juicy_3',
          name: 'Banana Smoothie',
          image: 'assets/images/fruits.png',
          price: 89,
          rating: 4.5,
          restaurantName: 'Juicy',
        ),
        CategoryItem(
          id: 'juicy_4',
          name: 'Orange Platter',
          image: 'assets/images/fruits.png',
          price: 109,
          rating: 4.3,
          restaurantName: 'Juicy',
        ),
        CategoryItem(
          id: 'juicy_5',
          name: 'Strawberry Shake',
          image: 'assets/images/drinks.jpg',
          price: 79,
          rating: 4.4,
          restaurantName: 'Juicy',
        ),
        CategoryItem(
          id: 'juicy_6',
          name: 'Grape Juice',
          image: 'assets/images/drinks.jpg',
          price: 55,
          rating: 4.2,
          restaurantName: 'Juicy',
        ),
      ]);
    } else if (restaurantName == 'Pisharodys Pure Veg') {
      allItems.addAll([
        CategoryItem(
          id: 'pish_1',
          name: 'Paneer & Veg Bowl',
          image: 'assets/images/paneer.png',
          price: 159,
          rating: 4.7,
          restaurantName: 'Pisharodys Pure Veg',
        ),
        CategoryItem(
          id: 'pish_2',
          name: 'Paneer Tikka',
          image: 'assets/images/paneer.png',
          price: 149,
          rating: 4.6,
          restaurantName: 'Pisharodys Pure Veg',
        ),
        CategoryItem(
          id: 'pish_3',
          name: 'Paneer Curry',
          image: 'assets/images/paneer.png',
          price: 139,
          rating: 4.5,
          restaurantName: 'Pisharodys Pure Veg',
        ),
        CategoryItem(
          id: 'pish_4',
          name: 'Paneer Wrap',
          image: 'assets/images/paneer.png',
          price: 129,
          rating: 4.4,
          restaurantName: 'Pisharodys Pure Veg',
        ),
        CategoryItem(
          id: 'pish_5',
          name: 'Paneer Salad',
          image: 'assets/images/paneer.png',
          price: 119,
          rating: 4.5,
          restaurantName: 'Pisharodys Pure Veg',
        ),
        CategoryItem(
          id: 'pish_6',
          name: 'Dosa Special',
          image: 'assets/images/paneer.png',
          price: 139,
          rating: 4.6,
          restaurantName: 'Pisharodys Pure Veg',
        ),
      ]);
    } else if (restaurantName == 'Shawarma Fusion') {
      allItems.addAll([
        CategoryItem(
          id: 'shaw_1',
          name: 'Chicken Shawarma',
          image: 'assets/images/burger.png',
          price: 189,
          rating: 4.6,
          restaurantName: 'Shawarma Fusion',
        ),
        CategoryItem(
          id: 'shaw_2',
          name: 'Beef Shawarma',
          image: 'assets/images/burger.png',
          price: 229,
          rating: 4.7,
          restaurantName: 'Shawarma Fusion',
        ),
        CategoryItem(
          id: 'shaw_3',
          name: 'Veggie Shawarma',
          image: 'assets/images/burger.png',
          price: 159,
          rating: 4.5,
          restaurantName: 'Shawarma Fusion',
        ),
        CategoryItem(
          id: 'shaw_4',
          name: 'Mixed Shawarma Platter',
          image: 'assets/images/burger.png',
          price: 279,
          rating: 4.8,
          restaurantName: 'Shawarma Fusion',
        ),
      ]);
    }

    return allItems;
  }

  // ---------------- FIRESTORE DYNAMIC CATEGORIES ----------------
  Widget _buildDynamicCategories(bool healthMode) {
    return SizedBox(
      height: 95,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("categories")
            .orderBy("createdAt", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No categories found"));
          }

          final docs = snapshot.data!.docs;

          // 🔥 FILTER CATEGORIES BASED ON HEALTH MODE
          final filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final isHealthy = data['isHealthy'] ?? false;

            // If health mode is ON, show only healthy categories
            // If health mode is OFF, show only non-healthy categories
            if (healthMode) {
              return isHealthy == true;
            } else {
              return isHealthy == false || isHealthy == null;
            }
          }).toList();

          // Show message if no categories match the current mode
          if (filteredDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    healthMode ? Icons.spa : Icons.restaurant_menu,
                    color: Colors.grey.shade400,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    healthMode
                        ? "No healthy categories available"
                        : "No regular categories available",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filteredDocs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) {
              final data = filteredDocs[i].data() as Map<String, dynamic>;
              final categoryId = filteredDocs[i].id;
              final name = data["name"] ?? "";
              final imageUrl = data["imageUrl"];

              return CategoryCircle(
                title: name,
                image: imageUrl ?? "",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryPage(
                        categoryName: name,
                        categoryId: categoryId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthMode = context.watch<HealthModeNotifier>().isOn;
    final cats = getActiveCategories(healthMode);
    final items = getActiveNewArrivals(healthMode);

    // Filtered lists used only when _query is not empty
    final filteredCats = cats.where((c) => _matches(c.title)).toList();
    final filteredItems = items.where((f) => _matches(f.name)).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              /// HEADER + SEARCH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(
                      healthMode: healthMode,
                      onToggleHealthMode: () {
                        context.read<HealthModeNotifier>().toggle();
                        final enabled = context.read<HealthModeNotifier>().isOn;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              enabled
                                  ? 'Health mode enabled'
                                  : 'Health mode disabled',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _searchCtl,
                      hint: 'Search your food or restaurant',
                      onChanged: (v) => setState(() => _query = v.trim()),
                      onSubmitted: (v) => setState(() => _query = v.trim()),
                      onClear: () => setState(() {
                        _searchCtl.clear();
                        _query = '';
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // If searching, show results instead of carousel + normal sections
              if (_query.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search results for: "$_query"',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (filteredCats.isNotEmpty) ...[
                        _buildSection(context, 'Categories'),
                        const SizedBox(height: 10),
                        _buildCategories(filteredCats),
                        const SizedBox(height: 20),
                      ],

                      if (filteredItems.isNotEmpty) ...[
                        _buildSection(
                          context,
                          healthMode ? 'Nutrition Picks' : 'Food Items',
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 260,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, index) => SizedBox(
                              width: 150,
                              child: FoodItemWidget(item: filteredItems[index]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (filteredCats.isEmpty && filteredItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text('No results found.'),
                        ),
                    ],
                  ),
                ),
              ] else ...[
                // ORIGINAL home when there's no query
                // _buildCarousel(context, healthMode),
                // 🔥 REPLACING _buildCarousel with the new isolated widget
                HomeBannerCarousel(
                  banners: getActiveBanners(healthMode),
                  healthMode: healthMode,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22),
                      _buildSection(context, 'craving for something?'),
                      const SizedBox(height: 12),

                      // 🔥 PASS healthMode PARAMETER HERE
                      _buildDynamicCategories(healthMode),

                      const SizedBox(height: 24),
                      _buildSection(
                        context,
                        healthMode ? 'Nutrition Picks' : 'Most Preferred',
                      ),
                      const SizedBox(height: 12),

                      const SizedBox(height: 24),
                      _buildSection(context, 'Restaurants'),
                      const SizedBox(height: 12),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- CAROUSEL ----------------
  Widget _buildCarousel(BuildContext context, bool healthMode) {
    final banners = getActiveBanners(healthMode);
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 900;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: banners.length,
          options: CarouselOptions(
            height: isWide ? 320 : 240,
            autoPlay: true,
            enlargeCenterPage: true,
            onPageChanged: (i, _) => setState(() => _currentOffer = i),
          ),
          itemBuilder: (_, i, __) {
            return GestureDetector(
              onTap: () {
                if (banners[i] == 'assets/images/4.png') {
                  context.read<HealthModeNotifier>().toggle();
                  final enabled = context.read<HealthModeNotifier>().isOn;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        enabled
                            ? 'Health mode activated via banner! 🥗'
                            : 'Health mode deactivated.',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isWide ? 18 : 14),
                child: Image.asset(banners[i], fit: BoxFit.cover),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _currentOffer == i ? 18 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _currentOffer == i
                    ? (healthMode ? Colors.green : Colors.deepOrange)
                    : Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Row _buildSection(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ---------------- CATEGORIES ----------------
  Widget _buildCategories(List<_Category> cats) {
    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) => CategoryCircle(
          title: cats[i].title,
          image: cats[i].image,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryPage(
                  categoryName: cats[i].title,
                  categoryId: "all",
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------- NEW ARRIVALS ----------------
  Widget _buildNewArrivals(List<_Food> items) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (_, index) => FoodItemWidget(item: items[index]),
      ),
    );
  }
}

// ---------------- SMALL COMPONENTS ----------------

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.healthMode,
    required this.onToggleHealthMode,
  });

  final bool healthMode;
  final VoidCallback onToggleHealthMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on, size: 18),
                SizedBox(width: 4),
                Text(
                  'Perinthalmanna',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: onToggleHealthMode,
          icon: Icon(
            Icons.health_and_safety,
            size: 28,
            color: healthMode ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class FoodItemWidget extends StatefulWidget {
  const FoodItemWidget({super.key, required this.item});

  final _Food item;

  @override
  State<FoodItemWidget> createState() => _FoodItemWidgetState();
}

class _FoodItemWidgetState extends State<FoodItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.asset(
              widget.item.img,
              height: 120,
              width: 160,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${widget.item.price}",
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------- VERTICAL RESTAURANT CARD (for Most Preferred) --------

class _RestaurantCardVertical extends StatelessWidget {
  final _Restaurant item;

  const _RestaurantCardVertical({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailPage(
              name: item.name,
              description: item.data,
              image: item.img,
              rating: item.rating,
              foodItems: item.foodItems,
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image at top
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                item.img,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant name
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${item.rating}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------- HORIZONTAL RESTAURANT CARD (default) --------

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.item});

  final _Restaurant item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailPage(
              name: item.name,
              description: item.data,
              image: item.img,
              rating: item.rating,
              foodItems: item.foodItems,
            ),
          ),
        );
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.asset(
                item.img,
                width: 130,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text("${item.rating}"),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.data,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class CategoryCircle extends StatelessWidget {
  const CategoryCircle({
    super.key,
    required this.title,
    required this.image,
    this.onTap,
  });

  final String title;
  final String image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            padding: const EdgeInsets.all(2), // space between border & image
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE5E7EB), // light grey border
                width: 5, // you can reduce to 1.2 for a subtler border
              ),
            ),
            child: ClipOval(
              child: image.startsWith("http")
                  ? Image.network(image, fit: BoxFit.cover)
                  : Image.asset(image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasText = controller?.text.isNotEmpty == true;
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: hasText
              ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _Food {
  final String name;
  final String img;
  final int price;
  final double rating;

  const _Food({
    required this.name,
    required this.img,
    required this.price,
    required this.rating,
  });
}

class _Category {
  final String title;
  final String image;

  const _Category(this.title, this.image);
}

class _Restaurant {
  final String name;
  final String data;
  final String img;
  final double rating;
  final String restaurantId;
  final List<CategoryItem> foodItems;

  const _Restaurant({
    required this.name,
    required this.data,
    required this.img,
    required this.rating,
    required this.restaurantId,
    required this.foodItems,
  });
}
