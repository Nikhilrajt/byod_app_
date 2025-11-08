import 'package:flutter/foundation.dart';

/// Simple inventory item used by the dashboard low-stock UI.
class InventoryItem {
  String name;
  double qty;

  InventoryItem({required this.name, required this.qty});
}

/// In-memory singleton InventoryService. Exposes a small API to read
/// inventory, query low-stock items and modify quantities. It's a
/// ChangeNotifier so UI can listen and rebuild on changes.
class InventoryService extends ChangeNotifier {
  InventoryService._internal() {
    // Seed with the full ingredient dataset (names + quantities)
    // mirrored from the main IngredientPage so the low-stock
    // dashboard reflects the same data (includes out-of-stock items).
    _inventory = [
      // Vegetables
      InventoryItem(name: 'Carrot', qty: 15.5),
      InventoryItem(name: 'Broccoli', qty: 2.0),
      InventoryItem(name: 'Spinach', qty: 0.0),
      InventoryItem(name: 'Tomato', qty: 40.8),
      InventoryItem(name: 'Cucumber', qty: 12.3),
      InventoryItem(name: 'Onion', qty: 55.0),
      InventoryItem(name: 'Garlic', qty: 5.5),
      InventoryItem(name: 'Potato', qty: 80.0),
      InventoryItem(name: 'Bell Pepper', qty: 10.0),
      InventoryItem(name: 'Lettuce', qty: 3.2),
      InventoryItem(name: 'Zucchini', qty: 1.5),
      InventoryItem(name: 'Eggplant', qty: 4.0),
      InventoryItem(name: 'Cabbage', qty: 20.0),
      InventoryItem(name: 'Cauliflower', qty: 1.0),
      InventoryItem(name: 'Mushroom', qty: 0.5),
      InventoryItem(name: 'Radish', qty: 5.0),
      InventoryItem(name: 'Sweet Potato', qty: 10.0),
      InventoryItem(name: 'Artichoke', qty: 0.0),
      InventoryItem(name: 'Asparagus', qty: 0.8),
      InventoryItem(name: 'Beetroot', qty: 6.0),

      // Fruits
      InventoryItem(name: 'Apple', qty: 30.0),
      InventoryItem(name: 'Banana', qty: 50.0),
      InventoryItem(name: 'Orange', qty: 22.0),
      InventoryItem(name: 'Grapes', qty: 18.0),
      InventoryItem(name: 'Strawberry', qty: 0.2),
      InventoryItem(name: 'Mango', qty: 5.0),
      InventoryItem(name: 'Pineapple', qty: 8.0),
      InventoryItem(name: 'Watermelon', qty: 15.0),
      InventoryItem(name: 'Kiwi', qty: 2.0),
      InventoryItem(name: 'Blueberry', qty: 0.1),
      InventoryItem(name: 'Peach', qty: 3.5),
      InventoryItem(name: 'Plum', qty: 4.0),
      InventoryItem(name: 'Cherry', qty: 0.0),
      InventoryItem(name: 'Pomegranate', qty: 6.0),
      InventoryItem(name: 'Fig', qty: 1.0),
      InventoryItem(name: 'Guava', qty: 10.0),
      InventoryItem(name: 'Lychee', qty: 0.5),
      InventoryItem(name: 'Papaya', qty: 7.0),
      InventoryItem(name: 'Raspberry', qty: 0.0),
      InventoryItem(name: 'Blackberry', qty: 0.1),

      // Grains
      InventoryItem(name: 'Rice', qty: 500.0),
      InventoryItem(name: 'Wheat', qty: 300.0),
      InventoryItem(name: 'Oats', qty: 15.0),
      InventoryItem(name: 'Quinoa', qty: 5.0),
      InventoryItem(name: 'Barley', qty: 10.0),
      InventoryItem(name: 'Corn', qty: 20.0),
      InventoryItem(name: 'Millet', qty: 8.0),
      InventoryItem(name: 'Rye', qty: 12.0),
      InventoryItem(name: 'Buckwheat', qty: 4.0),
      InventoryItem(name: 'Sorghum', qty: 9.0),

      // Proteins
      InventoryItem(name: 'Chicken Breast', qty: 30.0),
      InventoryItem(name: 'Salmon', qty: 8.0),
      InventoryItem(name: 'Eggs (Dozen)', qty: 50.0),
      InventoryItem(name: 'Tofu', qty: 10.0),
      InventoryItem(name: 'Lentils', qty: 40.0),
      InventoryItem(name: 'Chickpeas', qty: 35.0),
      InventoryItem(name: 'Beef', qty: 15.0),
      InventoryItem(name: 'Pork', qty: 12.0),
      InventoryItem(name: 'Shrimp', qty: 5.0),
      InventoryItem(name: 'Almonds', qty: 2.0),

      // Dairy
      InventoryItem(name: 'Milk', qty: 100.0),
      InventoryItem(name: 'Cheese', qty: 5.0),
      InventoryItem(name: 'Yogurt', qty: 20.0),
      InventoryItem(name: 'Butter', qty: 3.0),
      InventoryItem(name: 'Cream', qty: 5.0),
      InventoryItem(name: 'Paneer', qty: 15.0),
      InventoryItem(name: 'Ghee', qty: 2.0),
      InventoryItem(name: 'Buttermilk', qty: 10.0),
      InventoryItem(name: 'Sour Cream', qty: 1.0),
      InventoryItem(name: 'Cottage Cheese', qty: 8.0),

      // Spices
      InventoryItem(name: 'Turmeric', qty: 1.0),
      InventoryItem(name: 'Cumin', qty: 0.8),
      InventoryItem(name: 'Coriander', qty: 1.2),
      InventoryItem(name: 'Chili Powder', qty: 0.5),
      InventoryItem(name: 'Ginger', qty: 2.5),
      InventoryItem(name: 'Cinnamon', qty: 0.3),
      InventoryItem(name: 'Cloves', qty: 0.1),
      InventoryItem(name: 'Cardamom', qty: 0.2),
      InventoryItem(name: 'Black Pepper', qty: 0.4),
      InventoryItem(name: 'Mustard Seeds', qty: 1.5),
    ];
  }

  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;

  late List<InventoryItem> _inventory;

  List<InventoryItem> get inventory => List.unmodifiable(_inventory);

  /// Return low-stock items at or below [threshold].
  List<InventoryItem> lowStock({double threshold = 5.0}) {
    return _inventory.where((i) => i.qty <= threshold).toList();
  }

  void addIngredient(String name, double qty) {
    _inventory.add(InventoryItem(name: name, qty: qty));
    notifyListeners();
  }

  /// Add quantity to an existing item (matched by name). If the item
  /// does not exist an item is created.
  void restock(String name, double addQty) {
    final idx = _inventory.indexWhere((i) => i.name == name);
    if (idx != -1) {
      _inventory[idx].qty = (_inventory[idx].qty + addQty).clamp(
        0.0,
        double.infinity,
      );
    } else {
      _inventory.add(InventoryItem(name: name, qty: addQty));
    }
    notifyListeners();
  }

  /// Update absolute quantity by name (if found).
  void updateQuantity(String name, double qty) {
    final idx = _inventory.indexWhere((i) => i.name == name);
    if (idx != -1) {
      _inventory[idx].qty = qty.clamp(0.0, double.infinity);
      notifyListeners();
    }
  }

  /// Find inventory index by name.
  int indexOf(String name) => _inventory.indexWhere((i) => i.name == name);
}
