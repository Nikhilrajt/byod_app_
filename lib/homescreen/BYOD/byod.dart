import 'package:flutter/material.dart';

// --- BYOD Page Code ---
class ByodPage extends StatefulWidget {
  const ByodPage({super.key});

  @override
  _ByodPageState createState() => _ByodPageState();
}

class _ByodPageState extends State<ByodPage> {
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController recipeStepsController = TextEditingController();

  final List<Map<String, dynamic>> ingredients = [
    {
      "name": "Chicken",
      "cal": 165,
      "protein": 31,
      "carbs": 0,
      "fat": 3.6,
      "price": 60,
    },
    {
      "name": "Paneer",
      "cal": 265,
      "protein": 18,
      "carbs": 6,
      "fat": 20,
      "price": 50,
    },
    {
      "name": "Rice",
      "cal": 130,
      "protein": 2,
      "carbs": 28,
      "fat": 0.3,
      "price": 20,
    },
    {
      "name": "Spinach",
      "cal": 23,
      "protein": 3,
      "carbs": 4,
      "fat": 0.4,
      "price": 15,
    },
    {
      "name": "Tomato",
      "cal": 18,
      "protein": 1,
      "carbs": 4,
      "fat": 0.2,
      "price": 10,
    },
    {
      "name": "Cheese",
      "cal": 403,
      "protein": 25,
      "carbs": 1,
      "fat": 33,
      "price": 40,
    },
    {"name": "Egg", "cal": 68, "protein": 6, "carbs": 1, "fat": 5, "price": 12},
  ];

  List<bool> selected = [];
  int totalCalories = 0;
  int totalProtein = 0;
  int totalCarbs = 0;
  int totalFat = 0;
  int totalPrice = 0;

  @override
  void initState() {
    super.initState();
    selected = List.generate(ingredients.length, (index) => false);
  }

  void calculateNutrition() {
    int cal = 0, protein = 0, carbs = 0, fat = 0, price = 0;
    for (int i = 0; i < ingredients.length; i++) {
      if (selected[i]) {
        cal += (ingredients[i]["cal"] as num).toInt();
        protein += (ingredients[i]["protein"] as num).toInt();
        carbs += (ingredients[i]["carbs"] as num).toInt();
        fat += (ingredients[i]["fat"] as num).toInt();
        price += (ingredients[i]["price"] as num).toInt();
      }
    }
    setState(() {
      totalCalories = cal;
      totalProtein = protein;
      totalCarbs = carbs;
      totalFat = fat;
      totalPrice = price;
    });
  }

  void submitRecipe() {
    String recipeName = recipeNameController.text.trim();
    String recipeSteps = recipeStepsController.text.trim();
    List<String> selectedIngredients = [];
    ingredients.asMap().forEach((index, ing) {
      if (selected[index]) selectedIngredients.add(ing["name"]);
    });

    if (recipeName.isEmpty && selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a recipe name or select at least one ingredient.",
          ),
        ),
      );
      return;
    }

    print("Recipe Name: $recipeName");
    print("Custom Steps: $recipeSteps");
    print("Selected Ingredients: $selectedIngredients");
    print(
      "Nutrition: $totalCalories kcal, P:$totalProtein g, C:$totalCarbs g, F:$totalFat g",
    );
    print("Price: ₹$totalPrice");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recipe sent to the kitchen! 👨‍🍳")),
    );

    recipeNameController.clear();
    recipeStepsController.clear();
    selected = List.generate(ingredients.length, (index) => false);
    calculateNutrition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BYOD - Build Your Own Dish"),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "✍ Write Your Recipe",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: recipeNameController,
              decoration: const InputDecoration(
                hintText: "Enter your recipe name",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: recipeStepsController,
              decoration: const InputDecoration(
                hintText: "Enter steps/instructions (optional)",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "🥗 Select Ingredients",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(
                    "${ingredients[index]["name"]} (₹${ingredients[index]["price"]})",
                  ),
                  subtitle: Text(
                    "Cal: ${ingredients[index]["cal"]}, P: ${ingredients[index]["protein"]}g, "
                    "C: ${ingredients[index]["carbs"]}g, F: ${ingredients[index]["fat"]}g",
                  ),
                  value: selected[index],
                  onChanged: (bool? value) {
                    setState(() {
                      selected[index] = value ?? false;
                      calculateNutrition();
                    });
                  },
                );
              },
            ),
            const Divider(),
            const Text(
              "📊 Dish Summary",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text("Calories: $totalCalories kcal"),
            Text("Protein: $totalProtein g"),
            Text("Carbs: $totalCarbs g"),
            Text("Fat: $totalFat g"),
            const SizedBox(height: 10),
            Text(
              "💰 Total Price: ₹$totalPrice",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text("Send Recipe"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Restaurant App Code ---
class Restaurant {
  final String name;
  final String imagePath;
  final double rating;
  final String time;
  final String category;
  final String location;
  final String offer;
  Restaurant({
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.time,
    required this.category,
    required this.location,
    required this.offer,
  });
}

final List<Restaurant> restaurants = [
  Restaurant(
    name: 'Nigs Hut',
    imagePath: 'assets/images/res1.jpg',
    rating: 4.3,
    time: '65-90 mins',
    category: 'Restaurent',
    location: 'Mannarkkad',
    offer: 'ITEMS AT ₹99',
  ),
  Restaurant(
    name: 'FoodFlex',
    imagePath: 'assets/images/res2.jpeg',
    rating: 4.5,
    time: '40-55 mins',
    category: 'Healthy',
    location: 'Palakkad',
    offer: 'UPTO 50% OFF',
  ),
  Restaurant(
    name: 'Pizza Hut',
    imagePath: 'assets/images/res3.png',
    rating: 4.2,
    time: '55-65 mins',
    category: 'Pizzas',
    location: 'Kavumpuram',
    offer: 'ITEMS AT ₹99',
  ),
  Restaurant(
    name: 'Burger King',
    imagePath: 'assets/images/res4.jpeg',
    rating: 4.1,
    time: '30-45 mins',
    category: 'Burgers',
    location: 'Ottapalam',
    offer: 'FREE DELIVERY',
  ),
  Restaurant(
    name: 'Subway',
    imagePath: 'assets/images/res5.jpeg',
    rating: 4.0,
    time: '25-35 mins',
    category: 'Sandwiches',
    location: 'Shornur',
    offer: 'BUY 1 GET 1',
  ),
  Restaurant(
    name: 'The Plate',
    imagePath: 'assets/images/res6.jpeg',
    rating: 4.6,
    time: '35-50 mins',
    category: 'Multi-cuisine',
    location: 'Cherpulassery',
    offer: 'NEW ARRIVAL',
  ),
];

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantDetailScreen({required this.restaurant, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to ${restaurant.name}!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ByodPage()),
                );
              },
              child: const Text('Build Your Own Dish'),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurentListScreen extends StatelessWidget {
  const RestaurentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final r = restaurants[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantDetailScreen(restaurant: r),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.asset(
                            r.imagePath,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              r.offer,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${r.rating} • ${r.time}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.category,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            r.location,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
