import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/health_mode_notifier.dart';
import '../state/cart_notifier.dart';
// Import the stub for the customization page
import '../customization_page.dart';
// Import the newly defined models
import '../models/category_models.dart';
import './cart.dart'; // Should already be imported

// Backwards-compatible itemCount accessor for CartNotifier.
// Uses dynamic access to avoid requiring changes in the existing CartNotifier API.
extension CartNotifierItemCountExtension on CartNotifier {
  int get itemCount {
    try {
      final dynamic self = this;
      // Prefer an items iterable if present
      final dynamic items = self.items;
      if (items is Iterable) return items.length;
      // Fallback to common numeric fields if present
      final dynamic maybeCount = self.count ?? self.length;
      if (maybeCount is int) return maybeCount;
    } catch (_) {
      // swallow errors and return 0 as a safe default
    }
    return 0;
  }
}

// Compatibility extension to provide a resilient addItem API for various CartNotifier implementations.
// This will try several common method/property names and fall back to mutating an `items` list if available.
extension CartNotifierAddItemExtension on CartNotifier {
  void addItem(dynamic cartItem) {
    try {
      final dynamic self = this;

      // If the implementation already exposes a method named addItem/add/addToCart, call it.
      if (self.addItem is Function) {
        self.addItem(cartItem);
        return;
      }
      if (self.add is Function) {
        self.add(cartItem);
        return;
      }
      if (self.addToCart is Function) {
        self.addToCart(cartItem);
        return;
      }

      // If there's an `items` list, append and notify listeners if possible.
      final dynamic items = self.items;
      if (items is List) {
        items.add(cartItem);
        if (self.notifyListeners is Function) {
          self.notifyListeners();
        }
        return;
      }
    } catch (_) {
      // swallow any errors to keep this compatibility shim safe
    }
    // If none of the above worked, do nothing (silently fail to preserve runtime stability).
  }
}

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

  // --- Data Initialization (as provided by you) ---
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

  // (Your getCategoryItems function goes here, using the CategoryItem model)
  // ... (omitted for brevity, assume it's here and correct) ...
  List<CategoryItem> getCategoryItems(String category, bool healthMode) {
    final normalizedCategory = category.trim().toLowerCase();

    if (healthMode) {
      switch (normalizedCategory) {
        case 'fruits':
          return [
            CategoryItem(
              'Mixed Fruit Bowl',
              'assets/images/fruits.png',
              99,
              4.6,
              'Fresh Harvest',
            ),
            CategoryItem(
              'Apple Slices',
              'assets/images/fruits.png',
              79,
              4.4,
              'Fresh Harvest',
            ),
            CategoryItem(
              'Banana Smoothie',
              'assets/images/drinks.jpg', // Changed image for better realism
              89,
              4.5,
              'Juicy',
              categoryKey: 'drink', // Added categoryKey for customization
            ),
          ];
        case 'salads':
          return [
            CategoryItem(
              'Caesar Salad',
              'assets/images/salad.jpg',
              129,
              4.4,
              'Pisharodys Pure Veg',
              categoryKey: 'salad', // Added categoryKey for customization
            ),
            CategoryItem(
              'Greek Salad',
              'assets/images/salad.jpg',
              139,
              4.5,
              'Eato',
              categoryKey: 'salad',
            ),
            CategoryItem(
              'Garden Salad',
              'assets/images/salad.jpg',
              119,
              4.3,
              'Fresh Harvest',
              categoryKey: 'salad',
            ),
          ];
        case 'dry fruits':
        case 'dryfruit':
        case 'dry-fruits':
          return [
            CategoryItem(
              'Dry Fruit Mix',
              'assets/images/dry fruits.png',
              149,
              4.5,
              'Healthy Bites',
            ),
            CategoryItem(
              'Almonds Pack',
              'assets/images/dry fruits.png',
              199,
              4.6,
              'Healthy Bites',
            ),
            CategoryItem(
              'Trail Mix',
              'assets/images/dry fruits.png',
              159,
              4.7,
              'Healthy Bites',
            ),
          ];
        case 'mushroom':
          return [
            CategoryItem(
              'Grilled Mushroom Skewers',
              'assets/images/mushrrom.png',
              129,
              4.4,
              'Eato',
            ),
            CategoryItem(
              'Mushroom Soup',
              'assets/images/mushrrom.png',
              99,
              4.3,
              'Eato',
            ),
            CategoryItem(
              'Stuffed Mushrooms',
              'assets/images/mushrrom.png',
              139,
              4.5,
              'Eato',
            ),
          ];
        case 'paneer':
          return [
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
              'Paneer Wrap',
              'assets/images/paneer.png',
              129,
              4.4,
              'Pisharodys Pure Veg',
              categoryKey: 'sandwich', // Added categoryKey for customization
            ),
          ];
        case 'corn':
          return [
            CategoryItem(
              'Grilled Corn',
              'assets/images/corn.png',
              79,
              4.3,
              'Fresh Harvest',
            ),
            CategoryItem(
              'Corn Salad',
              'assets/images/corn.png',
              99,
              4.4,
              'Fresh Harvest',
            ),
            CategoryItem(
              'Corn Sandwich',
              'assets/images/corn.png',
              99,
              4.5,
              'Fresh Harvest',
              categoryKey: 'sandwich', // Added categoryKey for customization
            ),
          ];
        default:
          return [];
      }
    }

    switch (normalizedCategory) {
      case 'pizza':
        return [
          CategoryItem(
            'Margherita Pizza',
            'assets/images/Classic Cheese Pizza.png',
            199,
            4.5,
            'Planet Cafe',
            categoryKey: 'pizza', // Added categoryKey for customization
          ),
          CategoryItem(
            'Pepperoni Pizza',
            'assets/images/Classic Cheese Pizza.png',
            249,
            4.6,
            'Planet Cafe',
            categoryKey: 'pizza',
          ),
          CategoryItem(
            'Veggie Supreme',
            'assets/images/Classic Cheese Pizza.png',
            229,
            4.4,
            'Big Flooda',
            categoryKey: 'pizza',
          ),
        ];
      case 'burgers':
        return [
          CategoryItem(
            'Classic Burger',
            'assets/images/burger.png',
            149,
            4.4,
            'Big Flooda',
            categoryKey: 'burger',
          ),
          CategoryItem(
            'Cheese Burger',
            'assets/images/burger.png',
            169,
            4.5,
            'Big Flooda',
            categoryKey: 'burger',
          ),
          CategoryItem(
            'Veggie Burger',
            'assets/images/burger.png',
            139,
            4.3,
            'Planet Cafe',
            categoryKey: 'burger',
          ),
        ];
      case 'pasta':
        return [
          CategoryItem(
            'Pasta Alfredo',
            'assets/images/newpasta.png',
            169,
            4.4,
            'Eato',
            categoryKey: 'pasta',
          ),
          CategoryItem(
            'Spaghetti Carbonara',
            'assets/images/newpasta.png',
            179,
            4.5,
            'Eato',
            categoryKey: 'pasta',
          ),
          CategoryItem(
            'Penne Arrabbiata',
            'assets/images/newpasta.png',
            159,
            4.3,
            'Planet Cafe',
            categoryKey: 'pasta',
          ),
        ];
      case 'desserts':
        return [
          CategoryItem(
            'Chocolate Lava Cake',
            'assets/images/newlava.jpg',
            89,
            4.8,
            'Planet Cafe',
            categoryKey: 'dessert',
          ),
          CategoryItem(
            'Ice Cream Sundae',
            'assets/images/newlava.jpg',
            99,
            4.6,
            'Planet Cafe',
            categoryKey: 'dessert',
          ),
          CategoryItem(
            'Brownie',
            'assets/images/newlava.jpg',
            79,
            4.5,
            'Big Flooda',
          ),
        ];
      case 'drinks':
        return [
          CategoryItem(
            'Fresh Orange Juice',
            'assets/images/drinks.jpg',
            59,
            4.3,
            'Juicy',
            categoryKey: 'drink',
          ),
          CategoryItem(
            'Mango Smoothie',
            'assets/images/drinks.jpg',
            69,
            4.5,
            'Juicy',
            categoryKey: 'drink',
          ),
          CategoryItem(
            'Cold Coffee',
            'assets/images/drinks.jpg',
            89,
            4.6,
            'Planet Cafe',
            categoryKey: 'drink',
          ),
        ];
      case 'salads':
        return [
          CategoryItem(
            'Caesar Salad',
            'assets/images/salad.jpg',
            129,
            4.4,
            'Planet Cafe',
            categoryKey: 'salad',
          ),
          CategoryItem(
            'Greek Salad',
            'assets/images/salad.jpg',
            139,
            4.5,
            'Eato',
            categoryKey: 'salad',
          ),
        ];
      case 'wraps':
        return [
          CategoryItem(
            'Chicken Wrap',
            'assets/images/wraps.jpg',
            149,
            4.5,
            'Big Flooda',
            categoryKey: 'sandwich',
          ),
          CategoryItem(
            'Veggie Wrap',
            'assets/images/wraps.jpg',
            129,
            4.4,
            'Planet Cafe',
            categoryKey: 'sandwich',
          ),
        ];
      case 'fries':
        return [
          CategoryItem(
            'Classic Fries',
            'assets/images/fries.jpg',
            79,
            4.3,
            'Eato',
          ),
          CategoryItem(
            'Loaded Fries',
            'assets/images/fries.jpg',
            119,
            4.6,
            'Big Flooda',
            categoryKey: 'loaded',
          ),
        ];
      default:
        return [];
    }
  }

  // --- Customization Templates (as provided by you) ---
  // Add this to your category.dart file - replace the templates map

  final Map<String, List<CustomizationStep>> templates = {
    'burger': [
      CustomizationStep.singleChoice('Choose Your Bun', [
        CustomizationOption('Sesame Seed Bun', 0),
        CustomizationOption('Brioche Bun', 10),
        CustomizationOption('Whole Wheat Bun', 15),
        CustomizationOption('Gluten-Free Bun', 25),
      ], isRequired: true),
      CustomizationStep.singleChoice('Patty Choice', [
        CustomizationOption('Regular Patty', 0),
        CustomizationOption('Cheese-Stuffed Patty', 30),
        CustomizationOption('Veggie Patty', 0),
        CustomizationOption('Paneer Patty', 20),
      ], isRequired: true),
      CustomizationStep.multipleChoice('Toppings', [
        CustomizationOption('Lettuce', 0),
        CustomizationOption('Tomato', 0),
        CustomizationOption('Onion', 0),
        CustomizationOption('Pickles', 5),
        CustomizationOption('Jalapeños', 10),
        CustomizationOption('Extra Cheese', 20),
        CustomizationOption('Bacon', 30),
        CustomizationOption('Avocado', 25),
      ]),
      CustomizationStep.multipleChoice('Sauces', [
        CustomizationOption('Ketchup', 0),
        CustomizationOption('Mustard', 0),
        CustomizationOption('Mayo', 5),
        CustomizationOption('BBQ Sauce', 10),
        CustomizationOption('Hot Sauce', 10),
        CustomizationOption('Garlic Aioli', 15),
      ]),
      CustomizationStep.singleChoice('Cooking Level', [
        'Well Done',
        'Medium Well',
        'Medium',
      ]),
    ],

    'pizza': [
      CustomizationStep.singleChoice('Choose Your Crust', [
        CustomizationOption('Classic Hand-Tossed', 0),
        CustomizationOption('Thin & Crispy', 0),
        CustomizationOption('Thick Crust', 20),
        CustomizationOption('Stuffed Crust', 40),
        CustomizationOption('Whole Wheat', 25),
      ], isRequired: true),
      CustomizationStep.singleChoice('Size', [
        CustomizationOption('Small (8")', -50),
        CustomizationOption('Medium (10")', 0),
        CustomizationOption('Large (12")', 50),
        CustomizationOption('Extra Large (14")', 100),
      ], isRequired: true),
      CustomizationStep.singleChoice('Sauce', [
        CustomizationOption('Tomato Sauce', 0),
        CustomizationOption('White Sauce', 10),
        CustomizationOption('Pesto', 20),
        CustomizationOption('BBQ Sauce', 15),
        CustomizationOption('No Sauce', 0),
      ], isRequired: true),
      CustomizationStep.singleChoice('Cheese', [
        CustomizationOption('Regular Cheese', 0),
        CustomizationOption('Extra Cheese', 30),
        CustomizationOption('Light Cheese', -10),
        CustomizationOption('Vegan Cheese', 40),
        CustomizationOption('No Cheese', -20),
      ]),
      CustomizationStep.multipleChoice('Vegetable Toppings', [
        CustomizationOption('Mushrooms', 15),
        CustomizationOption('Onions', 10),
        CustomizationOption('Bell Peppers', 15),
        CustomizationOption('Olives', 15),
        CustomizationOption('Tomatoes', 10),
        CustomizationOption('Jalapeños', 15),
        CustomizationOption('Corn', 10),
        CustomizationOption('Pineapple', 15),
        CustomizationOption('Spinach', 15),
      ]),
      CustomizationStep.multipleChoice('Non-Veg Toppings', [
        CustomizationOption('Pepperoni', 40),
        CustomizationOption('Chicken', 40),
        CustomizationOption('Sausage', 40),
        CustomizationOption('Bacon', 45),
        CustomizationOption('Ham', 40),
      ]),
      CustomizationStep.multipleChoice('Seasonings', [
        'Italian Herbs',
        'Chili Flakes',
        'Oregano',
        'Garlic',
        'Black Pepper',
      ]),
    ],

    'pasta': [
      CustomizationStep.singleChoice('Choose Your Pasta Shape', [
        CustomizationOption('Spaghetti', 0),
        CustomizationOption('Penne', 0),
        CustomizationOption('Fusilli', 5),
        CustomizationOption('Fettuccine', 5),
        CustomizationOption('Macaroni', 0),
        CustomizationOption('Whole Wheat Pasta', 15),
      ], isRequired: true),
      CustomizationStep.singleChoice('Sauce Choice', [
        CustomizationOption('Tomato Marinara', 0),
        CustomizationOption('Alfredo', 20),
        CustomizationOption('Pesto', 25),
        CustomizationOption('Arrabbiata (Spicy)', 15),
        CustomizationOption('Carbonara', 30),
        CustomizationOption('Aglio e Olio', 20),
      ], isRequired: true),
      CustomizationStep.multipleChoice('Add Vegetables', [
        CustomizationOption('Mushrooms', 15),
        CustomizationOption('Bell Peppers', 15),
        CustomizationOption('Olives', 15),
        CustomizationOption('Broccoli', 20),
        CustomizationOption('Zucchini', 20),
        CustomizationOption('Cherry Tomatoes', 15),
        CustomizationOption('Spinach', 15),
      ]),
      CustomizationStep.multipleChoice('Add Protein', [
        CustomizationOption('Grilled Chicken', 50),
        CustomizationOption('Prawns', 70),
        CustomizationOption('Paneer', 40),
        CustomizationOption('Tofu', 35),
      ]),
      CustomizationStep.singleChoice('Cheese Topping', [
        CustomizationOption('Regular Parmesan', 10),
        CustomizationOption('Extra Parmesan', 20),
        CustomizationOption('Mozzarella', 25),
        CustomizationOption('No Cheese', 0),
      ]),
      CustomizationStep.multipleChoice('Extras', [
        CustomizationOption('Garlic Bread', 30),
        'Extra Spicy',
        'Fresh Basil',
        'Chili Flakes',
      ]),
    ],

    'salad': [
      CustomizationStep.singleChoice('Base', [
        CustomizationOption('Romaine Lettuce', 0),
        CustomizationOption('Mixed Greens', 0),
        CustomizationOption('Spinach', 5),
        CustomizationOption('Iceberg Lettuce', 0),
        CustomizationOption('Arugula', 10),
      ], isRequired: true),
      CustomizationStep.multipleChoice('Vegetables', [
        CustomizationOption('Tomatoes', 0),
        CustomizationOption('Cucumbers', 0),
        CustomizationOption('Bell Peppers', 10),
        CustomizationOption('Onions', 0),
        CustomizationOption('Carrots', 10),
        CustomizationOption('Corn', 10),
        CustomizationOption('Olives', 15),
        CustomizationOption('Mushrooms', 15),
        CustomizationOption('Avocado', 30),
      ]),
      CustomizationStep.singleChoice('Protein', [
        CustomizationOption('No Protein', 0),
        CustomizationOption('Grilled Chicken', 50),
        CustomizationOption('Boiled Egg', 20),
        CustomizationOption('Paneer', 40),
        CustomizationOption('Tofu', 35),
        CustomizationOption('Chickpeas', 25),
        CustomizationOption('Feta Cheese', 40),
      ]),
      CustomizationStep.multipleChoice('Toppings', [
        CustomizationOption('Croutons', 10),
        CustomizationOption('Seeds Mix', 15),
        CustomizationOption('Nuts', 20),
        CustomizationOption('Parmesan Cheese', 15),
      ]),
      CustomizationStep.singleChoice('Dressing', [
        CustomizationOption('Caesar', 0),
        CustomizationOption('Ranch', 5),
        CustomizationOption('Italian', 5),
        CustomizationOption('Balsamic Vinaigrette', 10),
        CustomizationOption('Honey Mustard', 10),
        CustomizationOption('Olive Oil & Lemon', 0),
        CustomizationOption('No Dressing', 0),
      ], isRequired: true),
    ],

    'sandwich': [
      CustomizationStep.singleChoice('Bread', [
        CustomizationOption('White Bread', 0),
        CustomizationOption('Whole Wheat', 5),
        CustomizationOption('Multigrain', 10),
        CustomizationOption('Sourdough', 15),
        CustomizationOption('Ciabatta', 20),
        CustomizationOption('Baguette', 15),
      ], isRequired: true),
      CustomizationStep.singleChoice('Toasted?', [
        'Not Toasted',
        'Lightly Toasted',
        'Well Toasted',
      ]),
      CustomizationStep.multipleChoice('Fillings', [
        CustomizationOption('Lettuce', 0),
        CustomizationOption('Tomato', 0),
        CustomizationOption('Onion', 0),
        CustomizationOption('Cucumber', 5),
        CustomizationOption('Cheese Slice', 15),
        CustomizationOption('Paneer', 30),
        CustomizationOption('Grilled Chicken', 50),
        CustomizationOption('Egg', 20),
        CustomizationOption('Avocado', 30),
      ]),
      CustomizationStep.multipleChoice('Spreads', [
        CustomizationOption('Mayo', 5),
        CustomizationOption('Mustard', 5),
        CustomizationOption('Butter', 5),
        CustomizationOption('Pesto', 15),
        CustomizationOption('Hummus', 20),
        CustomizationOption('Cream Cheese', 20),
      ]),
      CustomizationStep.multipleChoice('Extras', [
        'Pickles',
        'Jalapeños',
        'Olives',
        'Salt & Pepper',
      ]),
    ],

    'drink': [
      CustomizationStep.singleChoice('Size', [
        CustomizationOption('Small (200ml)', -20),
        CustomizationOption('Medium (300ml)', 0),
        CustomizationOption('Large (500ml)', 30),
      ], isRequired: true),
      CustomizationStep.singleChoice('Ice Level', [
        'No Ice',
        'Less Ice',
        'Regular Ice',
        'Extra Ice',
      ]),
      CustomizationStep.singleChoice('Sweetness Level', [
        'No Sugar',
        'Less Sweet',
        'Regular',
        'Extra Sweet',
      ]),
      CustomizationStep.multipleChoice('Add-ons', [
        CustomizationOption('Whipped Cream', 20),
        CustomizationOption('Extra Shot (Coffee)', 30),
        CustomizationOption('Chocolate Syrup', 15),
        CustomizationOption('Caramel Drizzle', 15),
        CustomizationOption('Fresh Mint', 10),
        CustomizationOption('Chia Seeds', 20),
      ]),
    ],

    'dessert': [
      CustomizationStep.singleChoice('Portion Size', [
        CustomizationOption('Mini', -30),
        CustomizationOption('Regular', 0),
        CustomizationOption('Large', 40),
      ], isRequired: true),
      CustomizationStep.singleChoice('Temperature', [
        'Room Temperature',
        'Chilled',
        'Warm',
      ]),
      CustomizationStep.multipleChoice('Toppings', [
        CustomizationOption('Chocolate Sauce', 15),
        CustomizationOption('Caramel Sauce', 15),
        CustomizationOption('Whipped Cream', 20),
        CustomizationOption('Ice Cream Scoop', 40),
        CustomizationOption('Fresh Fruits', 30),
        CustomizationOption('Nuts', 20),
        CustomizationOption('Sprinkles', 10),
        CustomizationOption('Oreo Crumbles', 25),
      ]),
      CustomizationStep.singleChoice('Extra Flavor', [
        CustomizationOption('None', 0),
        CustomizationOption('Vanilla Extract', 10),
        CustomizationOption('Coffee Shot', 15),
        CustomizationOption('Mint', 10),
      ]),
    ],

    'loaded': [
      CustomizationStep.singleChoice('Base', [
        CustomizationOption('Classic Fries', 0),
        CustomizationOption('Waffle Fries', 10),
        CustomizationOption('Curly Fries', 15),
        CustomizationOption('Sweet Potato Fries', 20),
      ], isRequired: true),
      CustomizationStep.singleChoice('Size', [
        CustomizationOption('Regular', 0),
        CustomizationOption('Large', 30),
        CustomizationOption('Extra Large', 60),
      ]),
      CustomizationStep.multipleChoice('Toppings', [
        CustomizationOption('Cheese Sauce', 25),
        CustomizationOption('Sour Cream', 20),
        CustomizationOption('Jalapeños', 15),
        CustomizationOption('Bacon Bits', 40),
        CustomizationOption('Chili', 30),
        CustomizationOption('Onions', 10),
        CustomizationOption('Paneer Cubes', 35),
      ]),
      CustomizationStep.multipleChoice('Seasonings', [
        'Peri-Peri',
        'BBQ',
        'Cheese & Herbs',
        'Plain Salt',
        'Cajun Spice',
      ]),
    ],
  };

  List<CustomizationStep>? _lookupTemplateForItem(CategoryItem item) {
    final name = item.categoryKey; // Use the provided category key
    return templates[name];
  }

  // --- Navigation & Logic Handlers ---

  void _navigateToCustomization(CategoryItem item) {
    final template = _lookupTemplateForItem(item);
    if (template != null && template.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CustomizationPage(customizableItem: item, template: template),
        ),
      );
    }
  }

  // Add-to-cart helper: open customization when required, otherwise add directly to the cart.
  void _addToCart(CategoryItem item, CartNotifier cart) {
    final template = _lookupTemplateForItem(item);

    if (template != null && template.isNotEmpty) {
      // Customizable item - show dialog with options
      _showAddOptionsDialog(item, cart);
    } else {
      // Non-customizable item - add directly and go to cart
      cart.addItem(item.toCartItem());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} added to cart!'),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ),
      );

      // Navigate to cart page after brief delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartScreen()),
          );
        }
      });
    }
  }

  // New method to show dialog for customizable items
  void _showAddOptionsDialog(CategoryItem item, CartNotifier cart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.fastfood, color: Colors.deepOrange),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This item can be customized. How would you like to proceed?',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              SizedBox(height: 20),

              // Quick Add Option
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _quickAddToCart(item, cart);
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Add',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green.shade800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Add with standard options',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12),

              // Customize Option
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _navigateToCustomization(item);
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.tune, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customize',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Choose your preferences',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  // New method for quick add without customization
  void _quickAddToCart(CategoryItem item, CartNotifier cart) {
    // Add item with default/no customizations
    final cartItem = CartItem(
      name: item.name,
      price: item.price,
      imageUrl: item.imageUrl,
      restaurantName: item.restaurantName,
      customizations: ['Standard Options'], // Indicate it's a quick add
    );

    cart.addItem(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('${item.name} added with standard options!')),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartScreen()),
            );
          },
        ),
      ),
    );

    // Navigate to cart page after brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartScreen()),
        );
      }
    });
  }

  // Duplicate _navigateToCustomization removed; original implementation above is used.

  // Updated _buildItemCard - changed button text to "ADD/CUSTOMIZE"
  Widget _buildItemCard(CategoryItem item, CartNotifier cart) {
    final isCustomizable =
        _lookupTemplateForItem(item) != null &&
        (_lookupTemplateForItem(item)?.isNotEmpty ?? false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'From: ${item.restaurantName}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        item.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${item.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Info/Add Button Column
            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Customization Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCustomizable
                          ? Colors.green.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCustomizable
                            ? Colors.green.shade200
                            : Colors.blue.shade200,
                      ),
                    ),
                    child: Text(
                      isCustomizable ? 'Customizable' : 'Quick Order',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isCustomizable
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),

                  // Add Button with Icon
                  ElevatedButton.icon(
                    onPressed: () => _addToCart(item, cart),
                    icon: Icon(
                      isCustomizable
                          ? Icons.add_shopping_cart
                          : Icons.shopping_cart,
                      size: 16,
                    ),
                    label: Text(
                      'ADD',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCustomizable
                          ? Colors.deepOrange
                          : Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(95, 35),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthMode = context.watch<HealthModeNotifier>().isOn;
    final cart = context.watch<CartNotifier>();
    final allCategories = healthMode ? healthCategories : normalCategories;

    if (_currentCategory.isEmpty && allCategories.isNotEmpty) {
      _currentCategory = allCategories[0]['name']!;
    }

    final items = getCategoryItems(_currentCategory, healthMode);

    final Map<String, List<CategoryItem>> groupedItems = {};
    for (var item in items) {
      final restaurant = item.restaurantName.isNotEmpty
          ? item.restaurantName
          : 'Other';
      if (!groupedItems.containsKey(restaurant)) groupedItems[restaurant] = [];
      groupedItems[restaurant]!.add(item);
    }

    final bool canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      cart.itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              children: allCategories.map((cat) {
                final name = cat['name']!;
                final selected = name == _currentCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: Text(name),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        _currentCategory = name;
                      });
                    },
                    selectedColor: Colors.deepOrange,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    avatar: healthMode
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              (allCategories.firstWhere(
                                (c) => c['name'] == name,
                              )['image'])!,
                              height: 24,
                              width: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.image, size: 20),
                            ),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: groupedItems.entries.map((entry) {
                final restaurantName = entry.key;
                final restaurantItems = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                      child: Text(
                        '🍽️ $restaurantName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                    ...restaurantItems
                        .map((item) => _buildItemCard(item, cart))
                        .toList(),
                    const SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: cart.itemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
              backgroundColor: Colors.deepOrange,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                '${cart.itemCount} items',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}
