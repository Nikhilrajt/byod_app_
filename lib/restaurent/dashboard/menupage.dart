import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// You need to ensure the 'intl' package is added to your pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   intl: ^0.18.1  // Or the latest version

// ---------------------------------------------------------------- //
// ⭐ Data Models
// ---------------------------------------------------------------- //

// Represents an option like "Extra Cheese" or "Medium"
class Modifier {
  final String id;
  final String name;
  final double price;
  Modifier({required this.id, required this.name, required this.price});
}

// Represents a single menu item
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  bool isAvailable;
  bool isPopular;
  final List<Modifier> modifiers;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    this.isAvailable = true,
    this.isPopular = false,
    this.modifiers = const [],
  });
}

// Represents a category of items
class MenuCategory {
  final String id;
  final String name;
  final List<MenuItem> items;

  MenuCategory({required this.id, required this.name, required this.items});
}

// ---------------------------------------------------------------- //
// ⭐ Menu Page Widget
// ---------------------------------------------------------------- //

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Mock Data (Made mutable for deletion feature)
  List<MenuCategory> _categories = [
    MenuCategory(
      id: 'C1',
      name: 'Pizzas',
      items: [
        MenuItem(
          id: 'I1',
          name: 'Margherita',
          description: 'Classic tomato and mozzarella.',
          basePrice: 550.00,
          isPopular: true,
        ),
        MenuItem(
          id: 'I2',
          name: 'Pepperoni Feast',
          description: 'Pepperoni, peppers, and spicy sauce.',
          basePrice: 780.00,
          isAvailable: false,
        ),
      ],
    ),
    MenuCategory(
      id: 'C2',
      name: 'Burgers & Wraps',
      items: [
        MenuItem(
          id: 'I3',
          name: 'Smash Burger',
          description: 'Double patty, special sauce, cheese.',
          basePrice: 420.00,
          modifiers: [
            Modifier(id: 'M1', name: 'Add Bacon', price: 80.0),
            Modifier(id: 'M2', name: 'Add Fries', price: 150.0),
          ],
        ),
        MenuItem(
          id: 'I5',
          name: 'Paneer Wrap',
          description: 'Spicy paneer tikka wrapped in paratha.',
          basePrice: 350.00,
        ),
      ],
    ),
    MenuCategory(
      id: 'C3',
      name: 'Beverages',
      items: [
        MenuItem(
          id: 'I4',
          name: 'Coke (300ml)',
          description: 'Chilled carbonated drink.',
          basePrice: 60.00,
        ),
      ],
    ),
    MenuCategory(id: 'C4', name: 'Desserts', items: []),
  ];

  late MenuCategory _selectedCategory;
  String _searchQuery = ''; // State variable for search input

  // Rupee formatter
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
  }

  // --- Utility Functions ---

  void _editCategory(MenuCategory category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing Category: ${category.name}')),
    );
  }

  void _addCategory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening form to add new category...')),
    );
  }

  void _deleteCategory(MenuCategory category) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete the "${category.name}" category? This will delete ${category.items.length} items.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _categories.removeWhere((c) => c.id == category.id);
        if (_selectedCategory.id == category.id) {
          // Select the first category if the current one was deleted
          _selectedCategory = _categories.isNotEmpty
              ? _categories.first
              : MenuCategory(id: '0', name: 'All', items: []);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "${category.name}" deleted.')),
      );
    }
  }

  void _addItem(MenuCategory category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening form to add item to ${category.name}')),
    );
  }

  void _editItem(MenuItem item) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Editing Item: ${item.name}')));
  }

  void _toggleItemAvailability(MenuItem item) {
    setState(() {
      item.isAvailable = !item.isAvailable;
    });
  }

  String _formatCurrency(double amount) => _currencyFormat.format(amount);

  // --- Widgets ---

  // 1. Category Navigation Panel (Desktop/Tablet)
  Widget _buildCategoryPanel() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.deepPurple,
                  ),
                  onPressed: _addCategory,
                  tooltip: 'Add New Category',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category.id == _selectedCategory.id;

                return ListTile(
                  title: Text(category.name),
                  subtitle: Text('${category.items.length} items'),
                  selected: isSelected,
                  selectedTileColor: Colors.deepPurple.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _searchQuery = ''; // Reset search on category switch
                    });
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () => _editCategory(category),
                        tooltip: 'Edit Category',
                      ),
                      // Delete Button
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red.shade400,
                        ),
                        onPressed: () => _deleteCategory(category),
                        tooltip: 'Delete Category',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 2. Individual Menu Item Card (Used in both grid and list)
  Widget _buildMenuItemCard(MenuItem item) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.isAvailable ? Colors.transparent : Colors.red.shade100,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Item Name & Description
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: item.isAvailable
                ? TextDecoration.none
                : TextDecoration.lineThrough,
            color: item.isAvailable ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              _formatCurrency(item.basePrice),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.deepPurple,
                fontSize: 18,
              ),
            ),
            if (item.modifiers.isNotEmpty)
              Text(
                '+ ${item.modifiers.length} Modifiers',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
          ],
        ),
        isThreeLine: true,

        // Management Options (Trailing)
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Edit Button
            SizedBox(
              height: 30,
              child: IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                onPressed: () => _editItem(item),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Edit Item Details/Modifiers',
              ),
            ),
            const SizedBox(height: 8),
            // Availability Switch
            SizedBox(
              height: 30,
              child: Switch(
                value: item.isAvailable,
                onChanged: (_) => _toggleItemAvailability(item),
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                inactiveTrackColor: Colors.red.shade200,
              ),
            ),
            Text(
              item.isAvailable ? 'Available' : 'Sold Out',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: item.isAvailable ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Main Content (Search Bar, Header, and Item List/Grid)
  Widget _buildMainContent(double maxWidth) {
    // Item Filtering Logic
    final filteredItems = _selectedCategory.items.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Use Expanded to ensure the content takes available space in the Row (desktop)
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Category Name & Add Button)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _addItem(_selectedCategory),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search items in ${_selectedCategory.name}...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 10,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Item List/Grid Area
            filteredItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No items found matching "$_searchQuery".'
                            : 'No items in the ${_selectedCategory.name} category. Add one!',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    // ⭐ Crucial for wide-screen GridView to fill remaining space
                    child: (maxWidth < 700)
                        ?
                          // Mobile View: Use a simple ListView (scrollable inside the Expanded)
                          ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: _buildMenuItemCard(filteredItems[index]),
                              );
                            },
                          )
                        :
                          // Tablet/Desktop View: Use GridView
                          GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 400,
                                  childAspectRatio: 3.5,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              return _buildMenuItemCard(filteredItems[index]);
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  // --- Main Build Method (Responsive Layout) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check screen width for responsiveness
            if (constraints.maxWidth < 700) {
              // Mobile View: Use SingleChildScrollView for vertical scrolling
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Categories as a horizontal, scrollable list (for mobile)
                    SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected =
                              category.id == _selectedCategory.id;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 8.0,
                            ),
                            child: ActionChip(
                              label: Text(category.name),
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = category;
                                  _searchQuery = '';
                                });
                              },
                              backgroundColor: isSelected
                                  ? Colors.deepPurple
                                  : Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    // Main content (search bar and item list/grid)
                    Expanded(
                      // ⭐ Use Expanded with the SingleChildScrollView to let it scroll
                      child: SingleChildScrollView(
                        child: _buildMainContent(constraints.maxWidth),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Default wide-screen side-by-side view
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryPanel(), // Left Panel
                _buildMainContent(constraints.maxWidth), // Right Panel
              ],
            );
          },
        ),
      ),
    );
  }
}
