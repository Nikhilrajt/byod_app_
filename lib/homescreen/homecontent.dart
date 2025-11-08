// lib/homescreen/homecontent.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _healthMode = false;
  int _currentOffer = 0;

  /// Banners
  final List<String> offerBanners = const [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
    // 'assets/images/4.png',
  ];

  /// Categories
  final List<_Category> categories = const [
    _Category('Pizza', 'assets/images/Classic Cheese Pizza.png'),
    _Category('Burgers', 'assets/images/burger.png'),
    _Category('Pasta', 'assets/images/newpasta.png'),
    _Category('Desserts', 'assets/images/newlava.jpg'),
    _Category('Drinks', 'assets/images/drinks.jpg'),
    _Category('Salads', 'assets/images/salad.jpg'),
    _Category('Wraps', 'assets/images/wraps.jpg'),
    _Category('Fries', 'assets/images/fries.jpg'),
  ];

  /// New Food Arrivals
  final List<_Food> newArrivals = const [
    _Food(
      name: 'Cheese Burst Pizza',
      img: 'assets/images/newpizza.jpg',
      price: 199,
      rating: 4.5,
    ),
    _Food(
      name: 'Sadhya',
      img: 'assets/images/Kerala-Sadya.jpg',
      price: 149,
      rating: 4.3,
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

  /// Restaurants List
  final List<_Restaurant> restaurants = const [
    _Restaurant(
      name: 'Planet Cafe',
      data: "Club sandwich, Burger, Smoothies",
      img: 'assets/images/res1.jpg',
      rating: 4.4,
    ),
    _Restaurant(
      name: 'Big Flooda',
      data: "Make a way for the burger craze",
      img: 'assets/images/res2.jpeg',
      rating: 4.3,
    ),
    _Restaurant(
      name: 'Eato',
      data: "Indian | Chinese | Italian cuisines",
      img: 'assets/images/res3.png',
      rating: 4.8,
    ),
    _Restaurant(
      name: 'Shawarma Fusion',
      data: "Full meat customizable shawarma",
      img: 'assets/images/res4.jpeg',
      rating: 4.2,
    ),
    _Restaurant(
      name: "Juicy",
      data: "Juices with real cream",
      img: 'assets/images/res5.jpeg',
      rating: 4.5,
    ),
    _Restaurant(
      name: "Pisharodys Pure Veg",
      data: "Special Dosa | Roast | Meals",
      img: 'assets/images/res6.jpeg',
      rating: 4.5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                      healthMode: _healthMode,
                      onToggleHealthMode: () {
                        setState(() => _healthMode = !_healthMode);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _healthMode
                                  ? 'Health mode enabled'
                                  : 'Health mode disabled',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const CustomTextField(
                      hint: 'Search your food or restaurant',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              _buildCarousel(context),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),

                    _buildSection(context, 'Categories'),
                    const SizedBox(height: 12),
                    _buildCategories(),

                    const SizedBox(height: 24),

                    _buildSection(context, 'Top Dishes'),
                    const SizedBox(height: 12),
                    _buildNewArrivals(),

                    const SizedBox(height: 24),

                    _buildSection(context, 'Restaurants'),
                    const SizedBox(height: 12),
                    _buildRestaurantList(),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- CAROUSEL ----------------

  Widget _buildCarousel(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 900;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: offerBanners.length,
          options: CarouselOptions(
            height: isWide ? 320 : 240,
            autoPlay: true,
            enlargeCenterPage: true,
            onPageChanged: (i, _) => setState(() => _currentOffer = i),
          ),
          itemBuilder: (_, i, __) => ClipRRect(
            borderRadius: BorderRadius.circular(isWide ? 18 : 14),
            child: Image.asset(offerBanners[i], fit: BoxFit.cover),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            offerBanners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _currentOffer == i ? 18 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _currentOffer == i ? Colors.deepOrange : Colors.grey,
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
        const Text(
          'Show all',
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  // ---------------- CATEGORIES ----------------

  Widget _buildCategories() {
    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) => CategoryCircle(
          title: categories[i].title,
          image: categories[i].image,
        ),
      ),
    );
  }

  // ---------------- NEW ARRIVALS ----------------

  Widget _buildNewArrivals() {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: newArrivals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (_, index) => FoodItemWidget(item: newArrivals[index]),
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

class FoodItemWidget extends StatelessWidget {
  const FoodItemWidget({super.key, required this.item});

  final _Food item;

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
              item.img,
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
                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text("${item.rating}"),
                    const Spacer(),
                    Text(
                      "₹${item.price}",
                      style: const TextStyle(color: Colors.deepOrange),
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

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.item});

  final _Restaurant item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
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

          /// TEXT SECTION
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

                /// ✅ DATA LINE (description)
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
    );
  }
}

class CategoryCircle extends StatelessWidget {
  const CategoryCircle({super.key, required this.title, required this.image});

  final String title;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 6),
        Text(title),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, this.hint});

  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, size: 28),
    );
  }
}

// ---------------- MODELS ----------------

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

  const _Restaurant({
    required this.name,
    required this.data,
    required this.img,
    required this.rating,
  });
}
