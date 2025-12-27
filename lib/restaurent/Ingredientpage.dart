import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/ingredient_model.dart';
import 'package:project/services/ingredient_service.dart';

// ================= COLORS =================
const Color kPrimary = Color(0xFF3F2B96);
const Color kPrimaryLight = Color(0xFF5F5AA2);
const Color kBackground = Color(0xFFF6F7FB);
const Color kCard = Colors.white;

class IngredientPage extends StatefulWidget {
  final bool isRestaurantSide;
  final Function(List<IngredientModel>)? onIngredientsSelected;
  final List<IngredientModel>? initiallySelectedIngredients;

  const IngredientPage({
    super.key,
    this.isRestaurantSide = true,
    this.onIngredientsSelected,
    this.initiallySelectedIngredients,
  });

  @override
  State<IngredientPage> createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  final IngredientService _ingredientService = IngredientService();
  final TextEditingController _searchController = TextEditingController();

  final Map<String, bool> _expandedCategories = {};
  final Map<String, bool> _selectedIngredients = {};

  String _searchQuery = "";

  final Map<String, IconData> _iconMap = const {
    'seedling': FontAwesomeIcons.seedling,
    'carrot': FontAwesomeIcons.carrot,
    'apple_whole': FontAwesomeIcons.appleWhole,
    'drumstick_bite': FontAwesomeIcons.drumstickBite,
    'fish': FontAwesomeIcons.fish,
    'egg': FontAwesomeIcons.egg,
    'cheese': FontAwesomeIcons.cheese,
    'wheat_awn': FontAwesomeIcons.wheatAwn,
    'pepper_hot': FontAwesomeIcons.pepperHot,
    'bowl_rice': FontAwesomeIcons.bowlRice,
    'mug_hot': FontAwesomeIcons.mugHot,
  };

  final List<String> _unitOptions = [
    'kg',
    '100 g',
    '50 g',
    'liter',
    'ml',
    '100 ml',
    '50 ml',
    'piece',
    'pack',
    'bottle',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });

    if (!widget.isRestaurantSide &&
        widget.initiallySelectedIngredients != null) {
      for (final ing in widget.initiallySelectedIngredients!) {
        _selectedIngredients[ing.id] = true;
      }
    }
  }

  // ================= ICON MAP =================

  IconData _getIconData(String iconName) {
    final map = <String, IconData>{
      // This is now redundant but kept for safety
      'carrot': FontAwesomeIcons.carrot,
      'apple_whole': FontAwesomeIcons.appleWhole,
      'drumstick_bite': FontAwesomeIcons.drumstickBite,
      'fish': FontAwesomeIcons.fish,
      'egg': FontAwesomeIcons.egg,
      'cheese': FontAwesomeIcons.cheese,
      'wheat_awn': FontAwesomeIcons.wheatAwn,
      'pepper_hot': FontAwesomeIcons.pepperHot,
      'bowl_rice': FontAwesomeIcons.bowlRice,
      'mug_hot': FontAwesomeIcons.mugHot,
    };
    return _iconMap[iconName] ?? FontAwesomeIcons.seedling;
  }

  // ================= DATA HELPERS =================

  void _toggleIngredientSelection(IngredientModel ingredient) {
    setState(() {
      _selectedIngredients.containsKey(ingredient.id)
          ? _selectedIngredients.remove(ingredient.id)
          : _selectedIngredients[ingredient.id] = true;
    });
  }

  // ================= INVENTORY CONTROLS =================

  Future<void> _updateQuantity(IngredientModel ingredient, double delta) async {
    final newQty = (ingredient.quantityAvailable + delta).clamp(
      0.0,
      double.infinity,
    );
    await _ingredientService.updateIngredientQuantity(ingredient.id, newQty);
  }

  Future<void> _deleteIngredient(IngredientModel ingredient) async {
    await _ingredientService.deleteIngredient(ingredient.id);
  }

  Widget _inventoryControls(IngredientModel ingredient) {
    Color statusColor;
    String statusText;

    if (ingredient.quantityAvailable <= 0) {
      statusColor = Colors.red;
      statusText = 'OUT OF STOCK';
    } else if (ingredient.quantityAvailable <= 5) {
      statusColor = Colors.orange;
      statusText = 'LOW STOCK';
    } else {
      statusColor = Colors.green;
      statusText = 'IN STOCK';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.lato(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
            Text(
              '${ingredient.quantityAvailable.toStringAsFixed(1)} ${ingredient.unit}',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => _updateQuantity(ingredient, -1),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: () => _updateQuantity(ingredient, 1),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
              onPressed: () => _showAddIngredientDialog(
                ingredient.category,
                ingredient: ingredient,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => _deleteIngredient(ingredient),
            ),
          ],
        ),
      ],
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimary, kPrimaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          widget.isRestaurantSide
              ? 'Inventory Management'
              : 'Customize Ingredients',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _searchBar(),
          Expanded(child: _ingredientList()),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Ingredients...',
          prefixIcon: const Icon(Icons.search, color: kPrimary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: kPrimary),
          ),
        ),
      ),
    );
  }

  Widget _ingredientList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ingredient_collections')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, collectionSnapshot) {
        if (!collectionSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final collections = collectionSnapshot.data!.docs;

        return StreamBuilder<List<IngredientModel>>(
          stream: _ingredientService.getRestaurantIngredients(),
          builder: (context, ingredientSnapshot) {
            if (!ingredientSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allIngredients = ingredientSnapshot.data!;
            final filteredIngredients = allIngredients
                .where((i) => i.name.toLowerCase().contains(_searchQuery))
                .toList();

            if (collections.isEmpty) {
              return const Center(child: Text("No collections found."));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collectionData =
                    collections[index].data() as Map<String, dynamic>;
                final collectionName =
                    collectionData['name'] ?? 'Uncategorized';
                final collectionImage = collectionData['imageUrl'] ?? '';

                final items = filteredIngredients
                    .where((i) => i.category == collectionName)
                    .toList();

                return _buildCollectionSection(
                  collectionName,
                  collectionImage,
                  items,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCollectionSection(
    String title,
    String imageUrl,
    List<IngredientModel> items,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(
          backgroundColor: kPrimary.withOpacity(0.1),
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          child: imageUrl.isEmpty
              ? const Icon(Icons.category, color: kPrimary)
              : null,
        ),
        title: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kPrimary,
          ),
        ),
        children: [
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "No items yet.",
                style: GoogleFonts.lato(color: Colors.grey),
              ),
            )
          else
            Column(children: items.map(_ingredientCard).toList()),
          if (widget.isRestaurantSide)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddIngredientDialog(title),
                  icon: const Icon(Icons.add),
                  label: Text("Add Item to $title"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimary,
                    side: const BorderSide(color: kPrimary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddIngredientDialog(
    String category, {
    IngredientModel? ingredient,
  }) {
    final isEdit = ingredient != null;

    final nameCtrl = TextEditingController(text: ingredient?.name ?? '');
    final priceCtrl = TextEditingController(
      text: ingredient?.price.toString() ?? '',
    );
    String selectedUnit = ingredient?.unit ?? 'kg';
    final calCtrl = TextEditingController(
      text: ingredient?.calories.toString() ?? '',
    );
    final protCtrl = TextEditingController(
      text: ingredient?.protein.toString() ?? '',
    );
    final initialQtyCtrl = TextEditingController(
      text: ingredient?.quantityAvailable.toString() ?? '',
    );
    String selectedIcon = ingredient?.iconName ?? 'seedling';

    if (!_unitOptions.contains(selectedUnit)) {
      selectedUnit = 'kg';
    }
    if (!_iconMap.containsKey(selectedIcon)) {
      selectedIcon = 'seedling';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEdit ? 'Edit ${ingredient!.name}' : 'Add to $category',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(nameCtrl, 'Name'),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            priceCtrl,
                            'Price',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            items: _unitOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() => selectedUnit = newValue);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      initialQtyCtrl,
                      isEdit ? 'Available Quantity' : 'Initial Quantity',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            calCtrl,
                            'Calories',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            protCtrl,
                            'Protein',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedIcon,
                      decoration: const InputDecoration(
                        labelText: 'Icon',
                        border: OutlineInputBorder(),
                      ),
                      items: _iconMap.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Row(
                            children: [
                              FaIcon(_iconMap[key]!, size: 18),
                              const SizedBox(width: 10),
                              Text(key),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() => selectedIcon = newValue);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty) return;

                    final model = IngredientModel(
                      id:
                          ingredient?.id ??
                          '', // Use existing id or empty for new
                      name: nameCtrl.text,
                      category: category,
                      price: double.tryParse(priceCtrl.text) ?? 0,
                      calories: double.tryParse(calCtrl.text) ?? 0,
                      protein: double.tryParse(protCtrl.text) ?? 0,
                      unit: selectedUnit,
                      quantityAvailable:
                          double.tryParse(initialQtyCtrl.text) ?? 0,
                      iconName: selectedIcon,
                      restaurantId: FirebaseAuth.instance.currentUser!.uid,
                      createdAt: ingredient?.createdAt ?? DateTime.now(),
                    );

                    if (isEdit) {
                      await _ingredientService.updateIngredient(model);
                    } else {
                      await _ingredientService.addIngredient(model);
                    }
                    if (mounted) Navigator.pop(context);
                  },
                  child: Text(isEdit ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _ingredientCard(IngredientModel ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              blurRadius: 16,
              offset: Offset(0, 6),
              color: Color(0x14000000),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: FaIcon(
                  _getIconData(ingredient.iconName),
                  color: Colors.green, // stays green
                ),
                title: Text(
                  ingredient.name,
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${ingredient.calories} kcal • ${ingredient.protein}g protein',
                  style: GoogleFonts.lato(fontSize: 12),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '₹${ingredient.price.toStringAsFixed(2)}',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        color: kPrimary,
                      ),
                    ),
                    Text(
                      'per ${ingredient.unit}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                onTap: widget.isRestaurantSide
                    ? null
                    : () => _toggleIngredientSelection(ingredient),
              ),
              const Divider(),
              widget.isRestaurantSide
                  ? _inventoryControls(ingredient)
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
