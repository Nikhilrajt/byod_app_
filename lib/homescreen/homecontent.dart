// lib/homescreen/homecontent.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
    'assets/images/4.png', // ✅ Tap on this to toggle Health Mode
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

  /// Restaurants List with Food Items
  List<_Restaurant> get restaurants {
    return [
      _Restaurant(
        name: 'Planet Cafe',
        data: "Club sandwich, Burger, Smoothies",
        img: 'assets/images/res1.jpg',
        rating: 4.4,
        foodItems: _getFoodItemsForRestaurant('Planet Cafe'),
      ),
      _Restaurant(
        name: 'Big Flooda',
        data: "Make a way for the burger craze",
        img: 'assets/images/res2.jpeg',
        rating: 4.3,
        foodItems: _getFoodItemsForRestaurant('Big Flooda'),
      ),
      _Restaurant(
        name: 'Eato',
        data: "Indian | Chinese | Italian cuisines",
        img: 'assets/images/res3.png',
        rating: 4.8,
        foodItems: _getFoodItemsForRestaurant('Eato'),
      ),
      _Restaurant(
        name: 'Shawarma Fusion',
        data: "Full meat customizable shawarma",
        img: 'assets/images/res4.jpeg',
        rating: 4.2,
        foodItems: _getFoodItemsForRestaurant('Shawarma Fusion'),
      ),
      _Restaurant(
        name: "Juicy",
        data: "Juices with real cream",
        img: 'assets/images/res5.jpeg',
        rating: 4.5,
        foodItems: _getFoodItemsForRestaurant('Juicy'),
      ),
      _Restaurant(
        name: "Pisharodys Pure Veg",
        data: "Special Dosa | Roast | Meals",
        img: 'assets/images/res6.jpeg',
        rating: 4.5,
        foodItems: _getFoodItemsForRestaurant('Pisharodys Pure Veg'),
      ),
    ];
  }

  List<_Category> getActiveCategories(bool healthMode) =>
      healthMode ? healthCategories : normalCategories;
  List<_Food> getActiveNewArrivals(bool healthMode) =>
      healthMode ? healthNewArrivals : normalNewArrivals;
  List<String> getActiveBanners(bool healthMode) =>
      healthMode ? healthBanners : normalBanners;

  // Get food items for a specific restaurant
  List<CategoryItem> _getFoodItemsForRestaurant(String restaurantName) {
    final List<CategoryItem> allItems = [];

    // Add items from each category that match this restaurant
    if (restaurantName == 'Planet Cafe') {
      allItems.addAll([
        CategoryItem(
          'Margherita Pizza',
          'assets/images/Classic Cheese Pizza.png',
          199,
          4.5,
          'Planet Cafe',
        ),
        CategoryItem(
          'Pepperoni Pizza',
          'assets/images/Classic Cheese Pizza.png',
          249,
          4.6,
          'Planet Cafe',
        ),
        CategoryItem(
          'Veggie Burger',
          'assets/images/burger.png',
          139,
          4.3,
          'Planet Cafe',
        ),
        CategoryItem(
          'Chicken Burger',
          'assets/images/burger.png',
          189,
          4.6,
          'Planet Cafe',
        ),
        CategoryItem(
          'Penne Arrabbiata',
          'assets/images/newpasta.png',
          159,
          4.3,
          'Planet Cafe',
        ),
        CategoryItem(
          'Mac & Cheese',
          'assets/images/newpasta.png',
          149,
          4.6,
          'Planet Cafe',
        ),
        CategoryItem(
          'Chocolate Lava Cake',
          'assets/images/newlava.jpg',
          89,
          4.8,
          'Planet Cafe',
        ),
        CategoryItem(
          'Ice Cream Sundae',
          'assets/images/newlava.jpg',
          99,
          4.6,
          'Planet Cafe',
        ),
      ]);
    } else if (restaurantName == 'Big Flooda') {
      allItems.addAll([
        CategoryItem(
          'Veggie Supreme',
          'assets/images/Classic Cheese Pizza.png',
          229,
          4.4,
          'Big Flooda',
        ),
        CategoryItem(
          'BBQ Chicken Pizza',
          'assets/images/Classic Cheese Pizza.png',
          279,
          4.7,
          'Big Flooda',
        ),
        CategoryItem(
          'Classic Burger',
          'assets/images/burger.png',
          149,
          4.4,
          'Big Flooda',
        ),
        CategoryItem(
          'Cheese Burger',
          'assets/images/burger.png',
          169,
          4.5,
          'Big Flooda',
        ),
        CategoryItem(
          'Pasta Primavera',
          'assets/images/newpasta.png',
          189,
          4.4,
          'Big Flooda',
        ),
        CategoryItem(
          'Lasagna',
          'assets/images/newpasta.png',
          199,
          4.7,
          'Big Flooda',
        ),
        CategoryItem(
          'Brownie',
          'assets/images/newlava.jpg',
          79,
          4.5,
          'Big Flooda',
        ),
        CategoryItem(
          'Cheesecake',
          'assets/images/newlava.jpg',
          129,
          4.7,
          'Big Flooda',
        ),
      ]);
    } else if (restaurantName == 'Eato') {
      allItems.addAll([
        CategoryItem(
          'Farmhouse Pizza',
          'assets/images/Classic Cheese Pizza.png',
          259,
          4.5,
          'Eato',
        ),
        CategoryItem(
          'Cheese Burst Pizza',
          'assets/images/newpizza.jpg',
          299,
          4.8,
          'Eato',
        ),
        CategoryItem(
          'Double Cheese Burger',
          'assets/images/burger.png',
          219,
          4.7,
          'Eato',
        ),
        CategoryItem(
          'BBQ Burger',
          'assets/images/burger.png',
          199,
          4.5,
          'Eato',
        ),
        CategoryItem(
          'Spaghetti Carbonara',
          'assets/images/newpasta.png',
          179,
          4.5,
          'Eato',
        ),
        CategoryItem(
          'Fettuccine Pasta',
          'assets/images/newpasta.png',
          169,
          4.4,
          'Eato',
        ),
        CategoryItem('Tiramisu', 'assets/images/newlava.jpg', 139, 4.6, 'Eato'),
        CategoryItem(
          'Chocolate Mousse',
          'assets/images/newlava.jpg',
          109,
          4.4,
          'Eato',
        ),
      ]);
    } else if (restaurantName == 'Juicy') {
      allItems.addAll([
        CategoryItem(
          'Fresh Orange Juice',
          'assets/images/drinks.jpg',
          59,
          4.3,
          'Juicy',
        ),
        CategoryItem(
          'Mango Smoothie',
          'assets/images/drinks.jpg',
          69,
          4.5,
          'Juicy',
        ),
        CategoryItem(
          'Banana Smoothie',
          'assets/images/fruits.png',
          89,
          4.5,
          'Juicy',
        ),
        CategoryItem(
          'Orange Platter',
          'assets/images/fruits.png',
          109,
          4.3,
          'Juicy',
        ),
        CategoryItem(
          'Strawberry Shake',
          'assets/images/drinks.jpg',
          79,
          4.4,
          'Juicy',
        ),
        CategoryItem(
          'Grape Juice',
          'assets/images/drinks.jpg',
          55,
          4.2,
          'Juicy',
        ),
      ]);
    } else if (restaurantName == 'Pisharodys Pure Veg') {
      allItems.addAll([
        CategoryItem(
          'Paneer & Veg Bowl',
          'assets/images/paneer.png',
          159,
          4.7,
          'Pisharodys Pure Veg',
        ),
        CategoryItem(
          'Paneer Tikka',
          'assets/images/paneer.png',
          149,
          4.6,
          'Pisharodys Pure Veg',
        ),
        CategoryItem(
          'Paneer Curry',
          'assets/images/paneer.png',
          139,
          4.5,
          'Pisharodys Pure Veg',
        ),
        CategoryItem(
          'Paneer Wrap',
          'assets/images/paneer.png',
          129,
          4.4,
          'Pisharodys Pure Veg',
        ),
        CategoryItem(
          'Paneer Salad',
          'assets/images/paneer.png',
          119,
          4.5,
          'Pisharodys Pure Veg',
        ),
        CategoryItem(
          'Dosa Special',
          'assets/images/paneer.png',
          139,
          4.6,
          'Pisharodys Pure Veg',
        ),
      ]);
    } else if (restaurantName == 'Shawarma Fusion') {
      allItems.addAll([
        CategoryItem(
          'Chicken Shawarma',
          'assets/images/burger.png',
          189,
          4.6,
          'Shawarma Fusion',
        ),
        CategoryItem(
          'Beef Shawarma',
          'assets/images/burger.png',
          229,
          4.7,
          'Shawarma Fusion',
        ),
        CategoryItem(
          'Veggie Shawarma',
          'assets/images/burger.png',
          159,
          4.5,
          'Shawarma Fusion',
        ),
        CategoryItem(
          'Mixed Shawarma Platter',
          'assets/images/burger.png',
          279,
          4.8,
          'Shawarma Fusion',
        ),
      ]);
    }

    return allItems;
  }

  @override
  Widget build(BuildContext context) {
    final healthMode = context.watch<HealthModeNotifier>().isOn;
    final cats = getActiveCategories(healthMode);
    final items = getActiveNewArrivals(healthMode);

    // Filtered lists used only when _query is not empty
    final filteredCats = cats.where((c) => _matches(c.title)).toList();
    final filteredItems = items.where((f) => _matches(f.name)).toList();
    final filteredRestaurants = restaurants
        .where((r) => _matches(r.name) || _matches(r.data))
        .toList();

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

                      if (filteredRestaurants.isNotEmpty) ...[
                        _buildSection(context, 'Restaurants'),
                        const SizedBox(height: 10),
                        Column(
                          children: List.generate(
                            filteredRestaurants.length,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: RestaurantCard(
                                item: filteredRestaurants[i],
                              ),
                            ),
                          ),
                        ),
                      ],

                      if (filteredCats.isEmpty &&
                          filteredItems.isEmpty &&
                          filteredRestaurants.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text('No results found.'),
                        ),
                    ],
                  ),
                ),
              ] else ...[
                // ORIGINAL home when there's no query
                _buildCarousel(context, healthMode),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22),
                      _buildSection(context, 'craving for something?'),
                      const SizedBox(height: 12),
                      _buildCategories(cats),

                      const SizedBox(height: 24),
                      _buildSection(
                        context,
                        healthMode ? 'Nutrition Picks' : 'Most Preferred',
                      ),
                      const SizedBox(height: 12),
                      _buildMostPreferredRestaurants(),

                      const SizedBox(height: 24),
                      _buildSection(context, 'Restaurants'),
                      const SizedBox(height: 12),
                      _buildRestaurantList(),

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
                // ✅ Toggle health mode when tapping 'assets/images/4.png'
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
        // const Text(
        //   '  ',
        //   style: TextStyle(
        //     color: Colors.blue,
        //     decoration: TextDecoration.underline,
        //   ),
        // ),
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
                builder: (context) => CategoryPage(categoryName: cats[i].title),
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

  // ---------------- MOST PREFERRED RESTAURANTS ----------------

  Widget _buildMostPreferredRestaurants() {
    // Filter restaurants with rating >= 4.5
    final preferredRestaurants = restaurants
        .where((restaurant) => restaurant.rating >= 4.5)
        .toList();

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: preferredRestaurants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) => SizedBox(
          width: 160,
          child: _RestaurantCardVertical(item: preferredRestaurants[index]),
        ),
      ),
    );
  }

  // ---------------- RESTAURANTS ----------------

  Widget _buildRestaurantList() {
    return Column(
      children: List.generate(
        restaurants.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RestaurantCard(item: restaurants[index]),
        ),
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
            child: ClipOval(child: Image.asset(image, fit: BoxFit.cover)),
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
  final List<CategoryItem> foodItems;

  const _Restaurant({
    required this.name,
    required this.data,
    required this.img,
    required this.rating,
    required this.foodItems,
  });
}
