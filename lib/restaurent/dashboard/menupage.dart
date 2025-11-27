import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

// ---------------- AddItemPage ----------------
class AddItemPage extends StatefulWidget {
  final String categoryName;
  final MenuItem? initialItem; // if provided, the page will be in edit mode
  const AddItemPage({super.key, required this.categoryName, this.initialItem});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _nutritionController = TextEditingController();
  String? _imagePath;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file != null) {
        setState(() => _imagePath = file.path);
      }
    } catch (e) {
      // ignore for now
    }
  }

  @override
  void initState() {
    super.initState();
    // Prefill controllers if editing an existing item
    final existing = widget.initialItem;
    if (existing != null) {
      _nameController.text = existing.name;
      _descController.text = existing.description;
      _priceController.text = existing.basePrice.toString();
      _nutritionController.text = existing.nutrition ?? '';
      _imagePath = existing.imagePath;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final id =
        widget.initialItem?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final item = MenuItem(
      id: id,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      basePrice: double.tryParse(_priceController.text.trim()) ?? 0.0,
      imagePath: _imagePath,
      nutrition: _nutritionController.text.trim(),
    );
    Navigator.of(context).pop(item);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _nutritionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Item to ${widget.categoryName}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                      image: _imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _imagePath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_a_photo, size: 40),
                              SizedBox(height: 8),
                              Text('Tap to pick image'),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Dish name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => (v == null || double.tryParse(v) == null)
                      ? 'Enter a valid price'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nutritionController,
                  decoration: const InputDecoration(
                    labelText: 'Nutrition (calories / details)',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text('Save Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Represents a single menu item
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String? imagePath;
  final String? nutrition;
  bool isAvailable;
  bool isPopular;
  bool isHidden; // New flag to hide item from menu view
  final List<Modifier> modifiers;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    this.imagePath,
    this.nutrition,
    this.isAvailable = true,
    this.isPopular = false,
    this.isHidden = false,
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
      name: 'Pizza',
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
      name: 'Burgers',
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
      ],
    ),
    MenuCategory(id: 'C3', name: 'Pasta', items: []),
    MenuCategory(id: 'C4', name: 'Desserts', items: []),
    MenuCategory(
      id: 'C5',
      name: 'Drinks',
      items: [
        MenuItem(
          id: 'I4',
          name: 'Coke (300ml)',
          description: 'Chilled carbonated drink.',
          basePrice: 60.00,
        ),
      ],
    ),
    MenuCategory(id: 'C6', name: 'Salads', items: []),
    MenuCategory(
      id: 'C7',
      name: 'Wraps',
      items: [
        MenuItem(
          id: 'I5',
          name: 'Paneer Wrap',
          description: 'Spicy paneer tikka wrapped in paratha.',
          basePrice: 350.00,
        ),
      ],
    ),
    MenuCategory(id: 'C8', name: 'Fries', items: []),
  ];

  late MenuCategory _selectedCategory;
  String _searchQuery = ''; // State variable for search input
  // Selection mode state for bulk delete
  bool _selectionMode = false;
  final Set<String> _selectedItemIds = {};
  // Show hidden items toggle
  bool _showHidden = false;
  // Temporary hides (in-memory, not persisted) — toggled by the eye icon
  final Set<String> _tempHiddenItemIds = {};

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
    final _categoryNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: _categoryNameController,
            decoration: const InputDecoration(hintText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _categoryNameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _categories.add(
                      MenuCategory(
                        id: 'C${_categories.length + 1}',
                        name: name,
                        items: [],
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
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
    // Open a full-screen form to add a new MenuItem. The form returns
    // a MenuItem via Navigator.pop when saved.
    Navigator.push<MenuItem?>(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemPage(categoryName: category.name),
      ),
    ).then((created) {
      if (created != null) {
        setState(() {
          category.items.add(created);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${created.name}" to ${category.name}'),
          ),
        );
      }
    });
  }

  void _editItem(MenuItem item) {
    // Debug/log so we can confirm the tap was received
    debugPrint('editItem invoked for id=${item.id}');

    // Open AddItemPage in edit mode; replace item on return
    Navigator.push<MenuItem?>(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemPage(
          categoryName: _selectedCategory.name,
          initialItem: item,
        ),
      ),
    ).then((updated) {
      if (updated != null) {
        setState(() {
          for (var i = 0; i < _selectedCategory.items.length; i++) {
            if (_selectedCategory.items[i].id == updated.id) {
              _selectedCategory.items[i] = updated;
              break;
            }
          }
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Updated ${updated.name}')));
      }
    });
  }

  // Availability toggling handled inline in the item card now.

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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Leading: Checkbox or Image
            if (_selectionMode)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Checkbox(
                  value: _selectedItemIds.contains(item.id),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedItemIds.add(item.id);
                      } else {
                        _selectedItemIds.remove(item.id);
                      }
                    });
                  },
                ),
              )
            else if (item.imagePath != null &&
                File(item.imagePath!).existsSync())
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(item.imagePath!),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              const SizedBox(width: 12),

            // Main content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: item.isAvailable
                            ? TextDecoration.none
                            : TextDecoration.lineThrough,
                        color: item.isAvailable ? Colors.black : Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Price and modifiers row
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _formatCurrency(item.basePrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.deepPurple,
                            fontSize: 16,
                          ),
                        ),
                        if (item.modifiers.isNotEmpty) ...[
                          const Icon(
                            Icons.extension,
                            color: Colors.orange,
                            size: 14,
                          ),
                          Text(
                            '${item.modifiers.length} mods',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Trailing: Switch and Edit button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Availability Switch (compact)
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: item.isAvailable,
                      onChanged: (v) => setState(() => item.isAvailable = v),
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                  // Edit button (compact)
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => _editItem(item),
                      tooltip: 'Edit Item',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) _selectedItemIds.clear();
    });
  }

  void _deleteSelectedItems() async {
    if (_selectedItemIds.isEmpty) return;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Delete ${_selectedItemIds.length} selected item(s)?'),
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
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );

    if (confirm == true) {
      setState(() {
        for (final cat in _categories) {
          cat.items.removeWhere((i) => _selectedItemIds.contains(i.id));
        }
        _selectedItemIds.clear();
        _selectionMode = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: const Text('Selected items deleted')));
    }
  }

  // 3. Main Content (Search Bar, Header, and Item List/Grid)
  Widget _buildMainContent(double maxWidth) {
    // Item Filtering Logic
    final filteredItems = _selectedCategory.items.where((item) {
      // Respect permanent hidden flag and temporary hides unless 'Show Hidden' is enabled
      if (!_showHidden &&
          (item.isHidden || _tempHiddenItemIds.contains(item.id)))
        return false;
      if (_searchQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Action buttons that adapt to screen size
    Widget actionButtons = LayoutBuilder(
      builder: (context, constraints) {
        // Use compact buttons on smaller widths
        if (constraints.maxWidth < 450) {
          return Wrap(
            spacing: 4,
            alignment: WrapAlignment.end,
            children: [
              IconButton(
                onPressed: () => _addItem(_selectedCategory),
                icon: const Icon(Icons.add),
                tooltip: 'Add New Item',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: _toggleSelectionMode,
                icon: const Icon(Icons.check_box_outline_blank),
                tooltip: 'Select Items',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => setState(() => _showHidden = !_showHidden),
                icon: Icon(
                  _showHidden ? Icons.visibility : Icons.visibility_off,
                ),
                tooltip: _showHidden ? 'Hide Hidden' : 'Show Hidden',
                visualDensity: VisualDensity.compact,
              ),
              if (_selectionMode)
                IconButton(
                  onPressed: _deleteSelectedItems,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  tooltip: 'Delete Selected',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          );
        }
        // Use full-size buttons on wider screens
        return Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () => _addItem(_selectedCategory),
              icon: const Icon(Icons.add),
              label: const Text('Add New Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _toggleSelectionMode,
              icon: const Icon(Icons.check_box_outline_blank),
              label: const Text('Select'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _showHidden = !_showHidden),
              icon: Icon(_showHidden ? Icons.visibility : Icons.visibility_off),
              label: Text(_showHidden ? 'Hide Hidden' : 'Show Hidden'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
            if (_selectionMode)
              ElevatedButton.icon(
                onPressed: _deleteSelectedItems,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete Selected'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
          ],
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title + Actions
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedCategory.name} items',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actionButtons,
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
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 16),

          // Item List/Grid Area
          if (filteredItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  _searchQuery.isNotEmpty
                      ? 'No items found matching "$_searchQuery".'
                      : 'No items in the ${_selectedCategory.name} category. Add one!',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            // Tablet/Desktop View: regular GridView (caller should provide Expanded)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 450,
                mainAxisExtent: 160, // Increased height to accommodate content
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) =>
                  _buildMenuItemCard(filteredItems[index]),
            ),
        ],
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
                        itemCount:
                            _categories.length +
                            1, // Add one for the add button
                        itemBuilder: (context, index) {
                          if (index == _categories.length) {
                            // This is the add button
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 8.0,
                              ),
                              child: ActionChip(
                                avatar: const Icon(
                                  Icons.add,
                                  color: Colors.black54,
                                ),
                                label: const Text('Add'),
                                onPressed: _addCategory,
                                backgroundColor: Colors.grey.shade300,
                              ),
                            );
                          }
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
                    _buildMainContent(constraints.maxWidth),
                  ],
                ),
              );
            }

            // Default wide-screen side-by-side view
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryPanel(), // Left Panel
                Flexible(
                  flex: 3, // Give more space to the main content
                  child: SingleChildScrollView(
                    child: _buildMainContent(constraints.maxWidth),
                  ),
                ), // Right Panel
              ],
            );
          },
        ),
      ),
      // Floating action button to quickly add an item to the currently selected category
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(_selectedCategory),
        label: const Text(
          'Add Item',
          style: TextStyle(color: Color.fromARGB(255, 238, 231, 231)),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
