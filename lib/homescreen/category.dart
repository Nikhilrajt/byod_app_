import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/health_mode_notifier.dart';
import '../state/cart_notifier.dart';
import './cart.dart';

// CategoryPage with customization flow and the info button kept as full
// labels ("Customisable" / "Non-customisable") moved slightly downwards.
// Layout uses Expanded for the info button so it never overflows the card.

class CategoryPage extends StatefulWidget {
  final String categoryName;

  const CategoryPage({super.key, required this.categoryName});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String _currentCategory = '';

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.categoryName;
  }

  @override
  void didUpdateWidget(CategoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryName != oldWidget.categoryName) {
      setState(() {
        _currentCategory = widget.categoryName;
      });
    }
  }

  final List<Map<String, String>> normalCategories = const [
    {'name': 'Pizza', 'image': 'assets/images/Classic Cheese Pizza.png'},
    {'name': 'Burgers', 'image': 'assets/images/burger.png'},
    {'name': 'Pasta', 'image': 'assets/images/newpasta.png'},
    {'name': 'Desserts', 'image': 'assets/images/newlava.jpg'},
    {'name': 'Drinks', 'image': 'assets/images/drinks.jpg'},
    {'name': 'Salads', 'image': 'assets/images/salad.jpg'},
    {'name': 'Wraps', 'image': 'assets/images/wraps.jpg'},
    {'name': 'Fries', 'image': 'assets/images/fries.jpg'},
  ];

  final List<Map<String, String>> healthCategories = const [
    {'name': 'Fruits', 'image': 'assets/images/fruits.png'},
    {'name': 'Dry Fruits', 'image': 'assets/images/dry fruits.png'},
    {'name': 'Mushroom', 'image': 'assets/images/mushrrom.png'},
    {'name': 'Paneer', 'image': 'assets/images/paneer.png'},
    {'name': 'Corn', 'image': 'assets/images/corn.png'},
    {'name': 'Salads', 'image': 'assets/images/salad.jpg'},
  ];

  List<CategoryItem> getCategoryItems(String category, bool healthMode) {
    final normalizedCategory = category.trim().toLowerCase();

    if (healthMode) {
      switch (normalizedCategory) {
        case 'fruits':
          return [
            CategoryItem('Mixed Fruit Bowl', 'assets/images/fruits.png', 99, 4.6, 'Fresh Harvest'),
            CategoryItem('Apple Slices', 'assets/images/fruits.png', 79, 4.4, 'Fresh Harvest'),
            CategoryItem('Banana Smoothie', 'assets/images/fruits.png', 89, 4.5, 'Juicy'),
            CategoryItem('Orange Platter', 'assets/images/fruits.png', 109, 4.3, 'Juicy'),
            CategoryItem('Grapes Bowl', 'assets/images/fruits.png', 119, 4.6, 'Fresh Harvest'),
            CategoryItem('Watermelon Bowl', 'assets/images/fruits.png', 99, 4.5, 'Fresh Harvest'),
          ];
        case 'dry fruits':
        case 'dryfruit':
        case 'dry-fruits':
          return [
            CategoryItem('Dry Fruit Mix', 'assets/images/dry fruits.png', 149, 4.5, 'Healthy Bites'),
            CategoryItem('Almonds Pack', 'assets/images/dry fruits.png', 199, 4.6, 'Healthy Bites'),
            CategoryItem('Cashew Mix', 'assets/images/dry fruits.png', 179, 4.4, 'Healthy Bites'),
            CategoryItem('Raisins & Dates', 'assets/images/dry fruits.png', 129, 4.5, 'Healthy Bites'),
            CategoryItem('Trail Mix', 'assets/images/dry fruits.png', 159, 4.7, 'Healthy Bites'),
            CategoryItem('Walnut Mix', 'assets/images/dry fruits.png', 189, 4.5, 'Healthy Bites'),
          ];
        case 'mushroom':
          return [
            CategoryItem('Grilled Mushroom Skewers', 'assets/images/mushrrom.png', 129, 4.4, 'Eato'),
            CategoryItem('Mushroom Soup', 'assets/images/mushrrom.png', 99, 4.3, 'Eato'),
            CategoryItem('Stuffed Mushrooms', 'assets/images/mushrrom.png', 139, 4.5, 'Eato'),
            CategoryItem('Mushroom Pasta', 'assets/images/mushrrom.png', 149, 4.6, 'Eato'),
            CategoryItem('Mushroom Curry', 'assets/images/mushrrom.png', 119, 4.4, 'Eato'),
            CategoryItem('Mushroom Pizza', 'assets/images/mushrrom.png', 159, 4.5, 'Eato'),
          ];
        case 'paneer':
          return [
            CategoryItem('Paneer & Veg Bowl', 'assets/images/paneer.png', 159, 4.7, 'Pisharodys Pure Veg'),
            CategoryItem('Paneer Tikka', 'assets/images/paneer.png', 149, 4.6, 'Pisharodys Pure Veg'),
            CategoryItem('Paneer Curry', 'assets/images/paneer.png', 139, 4.5, 'Pisharodys Pure Veg'),
            CategoryItem('Paneer Wrap', 'assets/images/paneer.png', 129, 4.4, 'Pisharodys Pure Veg'),
            CategoryItem('Paneer Salad', 'assets/images/paneer.png', 119, 4.5, 'Pisharodys Pure Veg'),
            CategoryItem('Paneer Biryani', 'assets/images/paneer.png', 169, 4.6, 'Pisharodys Pure Veg'),
          ];
        case 'corn':
          return [
            CategoryItem('Grilled Corn', 'assets/images/corn.png', 79, 4.3, 'Fresh Harvest'),
            CategoryItem('Corn Salad', 'assets/images/corn.png', 99, 4.4, 'Fresh Harvest'),
            CategoryItem('Corn Soup', 'assets/images/corn.png', 89, 4.5, 'Eato'),
            CategoryItem('Corn Chaat', 'assets/images/corn.png', 109, 4.6, 'Eato'),
            CategoryItem('Corn Fritters', 'assets/images/corn.png', 119, 4.4, 'Fresh Harvest'),
            CategoryItem('Corn Sandwich', 'assets/images/corn.png', 99, 4.5, 'Fresh Harvest'),
          ];
        case 'salads':
          return [
            CategoryItem('Caesar Salad', 'assets/images/salad.jpg', 129, 4.4, 'Pisharodys Pure Veg'),
            CategoryItem('Greek Salad', 'assets/images/salad.jpg', 139, 4.5, 'Eato'),
            CategoryItem('Garden Salad', 'assets/images/salad.jpg', 119, 4.3, 'Fresh Harvest'),
            CategoryItem('Chicken Salad', 'assets/images/salad.jpg', 149, 4.6, 'Planet Cafe'),
            CategoryItem('Fruit Salad', 'assets/images/salad.jpg', 99, 4.4, 'Fresh Harvest'),
            CategoryItem('Quinoa Salad', 'assets/images/salad.jpg', 159, 4.5, 'Pisharodys Pure Veg'),
          ];
        default:
          return [];
      }
    }

    switch (normalizedCategory) {
      case 'pizza':
        return [
          CategoryItem('Margherita Pizza', 'assets/images/Classic Cheese Pizza.png', 199, 4.5, 'Planet Cafe'),
          CategoryItem('Pepperoni Pizza', 'assets/images/Classic Cheese Pizza.png', 249, 4.6, 'Planet Cafe'),
          CategoryItem('Veggie Supreme', 'assets/images/Classic Cheese Pizza.png', 229, 4.4, 'Big Flooda'),
          CategoryItem('BBQ Chicken Pizza', 'assets/images/Classic Cheese Pizza.png', 279, 4.7, 'Big Flooda'),
          CategoryItem('Farmhouse Pizza', 'assets/images/Classic Cheese Pizza.png', 259, 4.5, 'Eato'),
          CategoryItem('Cheese Burst Pizza', 'assets/images/newpizza.jpg', 299, 4.8, 'Eato'),
        ];
      case 'burgers':
        return [
          CategoryItem('Classic Burger', 'assets/images/burger.png', 149, 4.4, 'Big Flooda'),
          CategoryItem('Cheese Burger', 'assets/images/burger.png', 169, 4.5, 'Big Flooda'),
          CategoryItem('Veggie Burger', 'assets/images/burger.png', 139, 4.3, 'Planet Cafe'),
          CategoryItem('Chicken Burger', 'assets/images/burger.png', 189, 4.6, 'Planet Cafe'),
          CategoryItem('Double Cheese Burger', 'assets/images/burger.png', 219, 4.7, 'Eato'),
          CategoryItem('BBQ Burger', 'assets/images/burger.png', 199, 4.5, 'Eato'),
        ];
      case 'pasta':
        return [
          CategoryItem('Pasta Alfredo', 'assets/images/newpasta.png', 169, 4.4, 'Eato'),
          CategoryItem('Spaghetti Carbonara', 'assets/images/newpasta.png', 179, 4.5, 'Eato'),
          CategoryItem('Penne Arrabbiata', 'assets/images/newpasta.png', 159, 4.3, 'Planet Cafe'),
          CategoryItem('Mac & Cheese', 'assets/images/newpasta.png', 149, 4.6, 'Planet Cafe'),
          CategoryItem('Pasta Primavera', 'assets/images/newpasta.png', 189, 4.4, 'Big Flooda'),
          CategoryItem('Lasagna', 'assets/images/newpasta.png', 199, 4.7, 'Big Flooda'),
        ];
      case 'desserts':
        return [
          CategoryItem('Chocolate Lava Cake', 'assets/images/newlava.jpg', 89, 4.8, 'Planet Cafe'),
          CategoryItem('Ice Cream Sundae', 'assets/images/newlava.jpg', 99, 4.6, 'Planet Cafe'),
          CategoryItem('Brownie', 'assets/images/newlava.jpg', 79, 4.5, 'Big Flooda'),
          CategoryItem('Cheesecake', 'assets/images/newlava.jpg', 129, 4.7, 'Big Flooda'),
          CategoryItem('Tiramisu', 'assets/images/newlava.jpg', 139, 4.6, 'Eato'),
          CategoryItem('Chocolate Mousse', 'assets/images/newlava.jpg', 109, 4.4, 'Eato'),
        ];
      case 'drinks':
        return [
          CategoryItem('Fresh Orange Juice', 'assets/images/drinks.jpg', 59, 4.3, 'Juicy'),
          CategoryItem('Mango Smoothie', 'assets/images/drinks.jpg', 69, 4.5, 'Juicy'),
          CategoryItem('Orange Smoothie', 'assets/images/drinks.jpg', 89, 4.5, 'Juicy'),
          CategoryItem('Strawberry Shake', 'assets/images/drinks.jpg', 79, 4.4, 'Planet Cafe'),
          CategoryItem('Cold Coffee', 'assets/images/drinks.jpg', 89, 4.6, 'Planet Cafe'),
          CategoryItem('Lemonade', 'assets/images/drinks.jpg', 49, 4.2, 'Eato'),
          CategoryItem('Iced Tea', 'assets/images/drinks.jpg', 59, 4.3, 'Eato'),
        ];
      case 'salads':
        return [
          CategoryItem('Caesar Salad', 'assets/images/salad.jpg', 129, 4.4),
          CategoryItem('Greek Salad', 'assets/images/salad.jpg', 139, 4.5),
          CategoryItem('Garden Salad', 'assets/images/salad.jpg', 119, 4.3),
          CategoryItem('Chicken Salad', 'assets/images/salad.jpg', 149, 4.6),
          CategoryItem('Fruit Salad', 'assets/images/salad.jpg', 99, 4.4),
          CategoryItem('Quinoa Salad', 'assets/images/salad.jpg', 159, 4.5),
        ];
      case 'wraps':
        return [
          CategoryItem('Chicken Wrap', 'assets/images/wraps.jpg', 149, 4.5),
          CategoryItem('Veggie Wrap', 'assets/images/wraps.jpg', 129, 4.4),
          CategoryItem('Grilled Wrap', 'assets/images/wraps.jpg', 159, 4.6),
          CategoryItem('Paneer Wrap', 'assets/images/wraps.jpg', 139, 4.5),
          CategoryItem('BBQ Wrap', 'assets/images/wraps.jpg', 169, 4.7),
          CategoryItem('Mexican Wrap', 'assets/images/wraps.jpg', 149, 4.4),
        ];
      case 'fries':
        return [
          CategoryItem('Classic Fries', 'assets/images/fries.jpg', 79, 4.3),
          CategoryItem('Cheese Fries', 'assets/images/fries.jpg', 99, 4.5),
          CategoryItem('Peri Peri Fries', 'assets/images/fries.jpg', 89, 4.4),
          CategoryItem('Loaded Fries', 'assets/images/fries.jpg', 119, 4.6),
          CategoryItem('Curly Fries', 'assets/images/fries.jpg', 89, 4.4),
          CategoryItem('Sweet Potato Fries', 'assets/images/fries.jpg', 99, 4.5),
        ];
      default:
        return [];
    }
  }

  // Templates (unchanged)
  final Map<String, List<CustomizationStep>> templates = {
    'burger': [
      CustomizationStep.singleChoice('Bun', ['Sesame Seed Bun', 'Brioche Bun', 'Pretzel Bun', 'Lettuce Wrap', 'Gluten-Free Bun']),
      CustomizationStep.singleChoice('Patty', ['Beef', 'Grilled Chicken', 'Crispy Fried Chicken', 'Spicy Bean Burger', 'Paneer Tikka Patty', 'Plant-Based Patty']),
      CustomizationStep.singleChoice('Cheese', ['Classic American Cheddar', 'Sharp Swiss', 'Pepper Jack', 'Blue Cheese', 'Vegan Cheese']),
      CustomizationStep.multiChoice('Fresh Toppings', ['Lettuce', 'Sliced Tomato', 'Raw Onion', 'Pickles', 'Jalapeños']),
      CustomizationStep.multiChoice('Premium Toppings', ['Caramelized Onions', 'Sautéed Mushrooms', 'Crispy Bacon', 'Fried Egg', 'Avocado Slices']),
      CustomizationStep.multiChoice('Sauces', ['Ketchup', 'Mayonnaise', 'Mustard', 'BBQ Sauce', 'Sriracha']),
    ],
    'pasta': [
      CustomizationStep.singleChoice('Pasta Shape', ['Spaghetti', 'Penne', 'Fusilli', 'Farfalle', 'Ravioli']),
      CustomizationStep.singleChoice('Sauce', ['Marinara', 'Alfredo', 'Pesto', 'Arrabbiata', 'Pink Sauce', 'Aglio e Olio']),
      CustomizationStep.singleChoice('Protein', ['Grilled Chicken', 'Spicy Italian Sausage', 'Beef Meatballs', 'Prawns', 'Tofu']),
      CustomizationStep.multiChoice('Veggie Add-ins', ['Mushrooms', 'Bell Peppers', 'Spinach', 'Broccoli', 'Sun-dried Tomatoes', 'Black Olives']),
      CustomizationStep.multiChoice('Finishers', ['Grated Parmesan', 'Melted Mozzarella', 'Chili Flakes', 'Fresh Basil']),
    ],
    'burrito': [
      CustomizationStep.singleChoice('Format', ['Flour Tortilla', 'Rice Bowl', 'Salad Bowl']),
      CustomizationStep.singleChoice('Rice', ['Cilantro-Lime White Rice', 'Brown Rice', 'No Rice']),
      CustomizationStep.singleChoice('Beans', ['Black Beans', 'Pinto Beans']),
      CustomizationStep.singleChoice('Protein', ['Grilled Chicken', 'Steak', 'Spicy Chorizo', 'Pulled Pork', 'Grilled Vegetables', 'Spiced Tofu']),
      CustomizationStep.multiChoice('Salsas & Toppings', ['Pico de Gallo', 'Corn Salsa', 'Green Salsa', 'Red Salsa', 'Sour Cream', 'Shredded Cheese', 'Guacamole', 'Shredded Lettuce']),
    ],
    'pizza': [
      CustomizationStep.singleChoice('Crust', ['Classic Hand-Tossed', 'Thin & Crispy', 'Deep Dish', 'Gluten-Free Crust']),
      CustomizationStep.singleChoice('Sauce', ['Classic Tomato', 'Spicy Tomato', 'White Garlic Sauce', 'Pesto Base', 'BBQ Base']),
      CustomizationStep.singleChoice('Cheese', ['Shredded Mozzarella', 'Fresh Mozzarella', 'Feta Cheese', 'Vegan Cheese']),
      CustomizationStep.multiChoice('Veg Toppings', ['Onions', 'Bell Peppers', 'Mushrooms', 'Black Olives', 'Jalapeños', 'Pineapple', 'Spinach', 'Corn']),
      CustomizationStep.multiChoice('Meat Toppings', ['Pepperoni', 'Sausage', 'Grilled Chicken', 'Ham', 'Bacon', 'Paneer Tikka']),
    ],
    'stir': [
      CustomizationStep.singleChoice('Base', ['Steamed White Rice', 'Egg Fried Rice', 'Hakka Noodles', 'Udon Noodles']),
      CustomizationStep.singleChoice('Protein', ['Chicken', 'Beef', 'Prawns', 'Tofu', 'Paneer', 'Egg']),
      CustomizationStep.multiChoice('Veg Mix', ['Carrot', 'Cabbage', 'Broccoli', 'Bell Peppers', 'Baby Corn', 'Onions', 'Bean Sprouts']),
      CustomizationStep.singleChoice('Sauce Flavor', ['Teriyaki', 'Schezwan', 'Manchurian', 'Black Bean', 'Sweet & Sour']),
      CustomizationStep.multiChoice('Garnish', ['Spring Onions', 'Toasted Sesame Seeds', 'Fried Garlic', 'Crushed Peanuts']),
    ],
    'salad': [
      CustomizationStep.singleChoice('Base', ['Romaine Lettuce', 'Mixed Greens', 'Quinoa', 'Brown Rice', 'Half-and-Half']),
      CustomizationStep.singleChoice('Main Protein', ['Grilled Chicken', 'Roasted Paneer', 'Hard-Boiled Egg', 'Spiced Chickpeas', 'Tuna Salad', 'Avocado']),
      CustomizationStep.multiChoice('Standard Toppings', ['Cucumber', 'Cherry Tomatoes', 'Shredded Carrots', 'Corn', 'Onions', 'Bell Peppers', 'Broccoli', 'Black Olives']),
      CustomizationStep.multiChoice('Premium Toppings', ['Feta Cheese', 'Goat Cheese', 'Sun-Dried Tomatoes', 'Toasted Almonds', 'Roasted Beets', 'Pomegranate Seeds']),
      CustomizationStep.singleChoice('Dressing', ['Balsamic Vinaigrette', 'Creamy Caesar', 'Lemon & Herb', 'Spicy Chipotle Ranch', 'Yogurt & Mint']),
    ],
    'sandwich': [
      CustomizationStep.singleChoice('Bread', ['Sourdough', 'Multigrain', 'Ciabatta Roll', 'Sub Roll', 'Flour Tortilla', 'Spinach Wrap']),
      CustomizationStep.singleChoice('Filling', ['Roasted Turkey', 'Smoked Ham', 'Roast Beef', 'Spicy Paneer', 'Vegetable & Hummus', 'Tuna Salad', 'Chicken Salad']),
      CustomizationStep.singleChoice('Cheese', ['Provolone', 'Swiss', 'Cheddar', 'Pepper Jack']),
      CustomizationStep.multiChoice('Veggies', ['Lettuce', 'Tomato', 'Onions', 'Pickles', 'Jalapeños', 'Cucumbers', 'Olives']),
      CustomizationStep.multiChoice('Spreads', ['Mayonnaise', 'Mustard', 'Hummus', 'Pesto', 'Mint Chutney', 'Chipotle Aioli']),
    ],
    'poke': [
      CustomizationStep.singleChoice('Base', ['Sushi Rice', 'Brown Rice', 'Quinoa', 'Zucchini Noodles']),
      CustomizationStep.singleChoice('Protein', ['Raw Tuna', 'Raw Salmon', 'Cooked Prawns', 'Cooked Chicken', 'Marinated Tofu']),
      CustomizationStep.singleChoice('Sauce', ['Shoyu', 'Spicy Aioli', 'Ponzu', 'Wasabi Aioli']),
      CustomizationStep.multiChoice('Mix-ins', ['Edamame', 'Avocado', 'Cucumber', 'Seaweed Salad', 'Pickled Ginger', 'Corn', 'Mango']),
      CustomizationStep.multiChoice('Crunch', ['Crispy Fried Onions', 'Toasted Sesame Seeds', 'Nori Strips', 'Crushed Peanuts']),
    ],
    'omelette': [
      CustomizationStep.singleChoice('Base', ['3-Egg Omelette', 'Scrambled Egg Bowl', 'Tofu Scramble', 'Breakfast Potato Bowl']),
      CustomizationStep.singleChoice('Cheese', ['Cheddar', 'Mozzarella', 'Feta']),
      CustomizationStep.multiChoice('Veggies', ['Onions', 'Bell Peppers', 'Mushrooms', 'Spinach', 'Tomatoes', 'Jalapeños']),
      CustomizationStep.multiChoice('Protein', ['Chicken Sausage', 'Bacon Bits', 'Smoked Salmon', 'Spiced Paneer']),
      CustomizationStep.singleChoice('Side', ['Toast', 'Hash Brown', 'Side of Fruit']),
    ],
    'loaded': [
      CustomizationStep.singleChoice('Base', ['Classic Fries', 'Waffle Fries', 'Corn Tortilla Chips']),
      CustomizationStep.multiChoice('Drizzle', ['Warm Cheese Sauce', 'Queso', 'Spicy Mayo', 'BBQ Sauce']),
      CustomizationStep.multiChoice('Protein', ['Spicy Ground Beef', 'Shredded Chicken', 'Black Beans', 'Chopped Bacon']),
      CustomizationStep.multiChoice('Toppings', ['Diced Tomatoes', 'Jalapeños', 'Sour Cream', 'Guacamole', 'Spring Onions', 'Black Olives']),
    ],
    'drink': [
      CustomizationStep.singleChoice('Drink Type', ['Milkshake', 'Smoothie', 'Bubble Tea', 'Lemonade/Iced Tea', 'Lassi', 'Coffee', 'Hot Chocolate', 'Italian Soda', 'Fresh Juice', 'Mocktail']),
    ],
    'dessert': [
      CustomizationStep.singleChoice('Dessert Type', ['Sundae', 'Frozen Yogurt', 'Crepe', 'Waffle/Pancake', 'Donut/Cupcake', 'Ice Cream Sandwich', 'Falooda', 'Cheesecake', 'Brownie A-La-Mode', 'Fruit Parfait']),
    ],
  };

  List<CustomizationStep>? _lookupTemplateForItem(CategoryItem item) {
    final name = item.name.toLowerCase();
    if (name.contains('burger')) return templates['burger'];
    if (name.contains('pasta')) return templates['pasta'];
    if (name.contains('burrito') || name.contains('bowl')) return templates['burrito'];
    if (name.contains('pizza')) return templates['pizza'];
    if (name.contains('stir') || name.contains('noodle') || name.contains('rice')) return templates['stir'];
    if (name.contains('salad') || name.contains('grain')) return templates['salad'];
    if (name.contains('sandwich') || name.contains('wrap')) return templates['sandwich'];
    if (name.contains('poke')) return templates['poke'];
    if (name.contains('omelette') || name.contains('breakfast')) return templates['omelette'];
    if (name.contains('loaded') || name.contains('fries') || name.contains('nachos')) return templates['loaded'];
    if (name.contains('juice') || name.contains('shake') || name.contains('smoothie') || name.contains('tea') || name.contains('coffee')) return templates['drink'];
    if (name.contains('cake') || name.contains('sundae') || name.contains('brownie') || name.contains('cheesecake') || name.contains('crepe')) return templates['dessert'];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final healthMode = context.watch<HealthModeNotifier>().isOn;
    final allCategories = healthMode ? healthCategories : normalCategories;

    if (_currentCategory.isEmpty && allCategories.isNotEmpty) {
      _currentCategory = allCategories[0]['name']!;
    }

    final items = getCategoryItems(_currentCategory, healthMode);

    final Map<String, List<CategoryItem>> groupedItems = {};
    for (var item in items) {
      final restaurant = item.restaurantName.isNotEmpty ? item.restaurantName : 'Other';
      if (!groupedItems.containsKey(restaurant)) groupedItems[restaurant] = [];
      groupedItems[restaurant]!.add(item);
    }

    final bool canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: canPop ? IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)) : null,
        automaticallyImplyLeading: canPop,
        title: Text(canPop && _currentCategory.isNotEmpty ? _currentCategory : 'Categories'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final category = allCategories[index];
                  final isSelected = category['name'] == _currentCategory;
                  return GestureDetector(
                    onTap: () {
                      if (!isSelected) {
                        setState(() {
                          _currentCategory = category['name']!;
                        });
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 64,
                          width: 64,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? Colors.deepOrange : const Color(0xFFE5E7EB), width: isSelected ? 4 : 3),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              category['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported, color: Colors.grey);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category['name']!,
                          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.deepOrange : Colors.black),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedItems.length,
              itemBuilder: (context, index) {
                final restaurantName = groupedItems.keys.elementAt(index);
                final restaurantItems = groupedItems[restaurantName]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        restaurantName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: TileConfig.cardHeight,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 16),
                        itemCount: restaurantItems.length,
                        itemBuilder: (context, itemIndex) {
                          final item = restaurantItems[itemIndex];
                          final isCustomizable = _lookupTemplateForItem(item) != null;
                          return Padding(
                            padding: EdgeInsets.only(right: TileConfig.horizontalSpacing),
                            child: Consumer<CartNotifier>(
                              builder: (context, cartNotifier, _) {
                                return SizedBox(
                                  width: TileConfig.cardWidth,
                                  child: _RestaurantItemCard(
                                    item: item,
                                    isCustomizable: isCustomizable,
                                    onAddPressed: () async {
                                      final template = _lookupTemplateForItem(item);
                                      if (template != null) {
                                        final result = await Navigator.of(context).push<Map<String, dynamic>>(
                                          MaterialPageRoute(
                                            builder: (_) => CustomizationScreen(item: item, template: template),
                                          ),
                                        );
                                        if (result != null && result['confirmed'] == true) {
                                          final selectedSummary = result['summary'] as String? ?? '';
                                          final cartItem = CartItem(
                                            name: '${item.name}${selectedSummary.isNotEmpty ? ' — $selectedSummary' : ''}',
                                            image: item.image,
                                            price: item.price,
                                            rating: item.rating,
                                            restaurantName: item.restaurantName,
                                            qty: result['qty'] ?? 1,
                                          );
                                          cartNotifier.addToCart(cartItem);
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added to cart')));
                                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => CartScreen()));
                                        }
                                      } else {
                                        final cartItem = CartItem(
                                          name: item.name,
                                          image: item.image,
                                          price: item.price,
                                          rating: item.rating,
                                          restaurantName: item.restaurantName,
                                          qty: 1,
                                        );
                                        cartNotifier.addToCart(cartItem);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added to cart')));
                                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => CartScreen()));
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- CUSTOMIZATION MODELS & UI --------------------
class CustomizationStep {
  final String title;
  final List<String> options;
  final bool multiSelect; // true -> multi choice, false -> single choice

  CustomizationStep(this.title, this.options, {this.multiSelect = false});

  factory CustomizationStep.singleChoice(String title, List<String> options) => CustomizationStep(title, options, multiSelect: false);
  factory CustomizationStep.multiChoice(String title, List<String> options) => CustomizationStep(title, options, multiSelect: true);
}

class CustomizationScreen extends StatefulWidget {
  final CategoryItem item;
  final List<CustomizationStep> template;

  const CustomizationScreen({super.key, required this.item, required this.template});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  final Map<int, dynamic> selections = {};
  int qty = 1;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.template.length; i++) {
      final step = widget.template[i];
      if (step.multiSelect) selections[i] = <String>{};
      else selections[i] = step.options.isNotEmpty ? step.options[0] : '';
    }
  }

  String _buildSummary() {
    final parts = <String>[];
    for (var i = 0; i < widget.template.length; i++) {
      final step = widget.template[i];
      final sel = selections[i];
      if (step.multiSelect) {
        final set = (sel as Set<String>);
        if (set.isNotEmpty) parts.add('${step.title}: ${set.join(', ')}');
      } else {
        final s = (sel as String);
        if (s.isNotEmpty) parts.add('${step.title}: $s');
      }
    }
    return parts.join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customize ${widget.item.name}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.template.length,
              itemBuilder: (context, index) {
                final step = widget.template[index];
                final sel = selections[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: step.options.map((opt) {
                          final selected = step.multiSelect ? (sel as Set<String>).contains(opt) : (sel as String) == opt;
                          return ChoiceChip(
                            label: Text(opt, overflow: TextOverflow.ellipsis),
                            selected: selected,
                            onSelected: (on) {
                              setState(() {
                                if (step.multiSelect) {
                                  final set = selections[index] as Set<String>;
                                  if (on)
                                    set.add(opt);
                                  else
                                    set.remove(opt);
                                } else {
                                  selections[index] = opt;
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(onPressed: () => setState(() => qty = (qty > 1) ? qty - 1 : 1), icon: const Icon(Icons.remove_circle_outline)),
                        Text('Qty: $qty'),
                        IconButton(onPressed: () => setState(() => qty++), icon: const Icon(Icons.add_circle_outline)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (var i = 0; i < widget.template.length; i++) {
                            final step = widget.template[i];
                            if (step.multiSelect) selections[i] = <String>{};
                            else selections[i] = step.options.isNotEmpty ? step.options[0] : '';
                          }
                          qty = 1;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    final summary = _buildSummary();
                    Navigator.of(context).pop({'confirmed': true, 'summary': summary, 'qty': qty});
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Add to cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem {
  final String name;
  final String image;
  final int price;
  final double rating;
  final String restaurantName;

  CategoryItem(this.name, this.image, this.price, this.rating, [this.restaurantName = '']);
}

// Tile configuration
class TileConfig {
  static const double cardWidth = 160;
  static const double cardHeight = 200;
  static const double cardBorderRadius = 12;
  static const double cardPadding = 8;

  static const double imageHeight = 100;

  static const double itemNameFontSize = 12;
  static const double ratingFontSize = 10;
  static const double priceFontSize = 14;
  static const double ratingIconSize = 12;

  static const double addButtonHeight = 30;
  static const double addButtonBorderRadius = 8;
  static const double addButtonFontSize = 14;

  static const double horizontalSpacing = 12;
  static const double verticalSpacing = 2;
  static const double spacing4 = 4;
  static const double spacing6 = 6;

  static const Color cardColor = Colors.white;
  static const Color shadowColor = Colors.black12;
  static const Color addButtonColor = Colors.deepOrange;
  static const Color textColor = Colors.black;
  static const Color priceColor = Colors.deepOrange;
  static const Color ratingColor = Colors.amber;
}

class _RestaurantItemCard extends StatelessWidget {
  final CategoryItem item;
  final VoidCallback? onAddPressed;
  final bool isCustomizable; // info-only button flag

  const _RestaurantItemCard({required this.item, this.onAddPressed, this.isCustomizable = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TileConfig.cardColor,
        borderRadius: BorderRadius.circular(TileConfig.cardBorderRadius),
        boxShadow: const [
          BoxShadow(color: TileConfig.shadowColor, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(TileConfig.cardBorderRadius)),
            child: Image.asset(
              item.image,
              width: double.infinity,
              height: TileConfig.imageHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: TileConfig.imageHeight,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(TileConfig.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: TileConfig.itemNameFontSize),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: TileConfig.spacing4),
                // Price on first line, buttons moved a little down to second line
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price row (flexible to avoid overflow)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '₹${item.price}',
                            style: const TextStyle(color: TileConfig.priceColor, fontWeight: FontWeight.bold, fontSize: TileConfig.priceFontSize),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Buttons row: info button expands to remaining width; Add button fixed width
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {}, // intentionally inert (info only)
                            child: Container(
                              height: TileConfig.addButtonHeight,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCustomizable ? Colors.green.shade600 : Colors.grey.shade500,
                                borderRadius: BorderRadius.circular(TileConfig.addButtonBorderRadius),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                isCustomizable ? 'Customisable' : 'Non-customisable',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 56,
                          height: TileConfig.addButtonHeight,
                          child: GestureDetector(
                            onTap: onAddPressed,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: TileConfig.addButtonColor,
                                borderRadius: BorderRadius.circular(TileConfig.addButtonBorderRadius),
                              ),
                              child: const Text(
                                'Add',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: TileConfig.addButtonFontSize),
                              ),
                            ),
                          ),
                        ),
                      ],
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



