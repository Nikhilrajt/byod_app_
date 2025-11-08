import 'package:flutter/material.dart';
import '../../services/inventory_service.dart';

class LowStockIngredientsPage extends StatefulWidget {
  const LowStockIngredientsPage({super.key});

  @override
  State<LowStockIngredientsPage> createState() =>
      _LowStockIngredientsPageState();
}

class _LowStockIngredientsPageState extends State<LowStockIngredientsPage> {
  // Keep the same threshold as before; can be parameterized later.
  static const double _lowStockThreshold = 5.0;

  final InventoryService _service = InventoryService();

  @override
  void initState() {
    super.initState();
    _service.addListener(_onInventoryChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onInventoryChanged);
    super.dispose();
  }

  void _onInventoryChanged() => setState(() {});

  void _addIngredient() {
    String name = '';
    String qtyStr = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Ingredient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Ingredient name'),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Quantity (e.g. 3.5)',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => qtyStr = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final q = double.tryParse(qtyStr) ?? 0.0;
                if (name.trim().isNotEmpty) {
                  _service.addIngredient(name.trim(), q);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _restockItem(String name) {
    String qtyStr = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Restock $name'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Add quantity (e.g. 5)',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => qtyStr = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final add = double.tryParse(qtyStr) ?? 0.0;
                _service.restock(name, add);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lowItems = _service.lowStock(threshold: _lowStockThreshold);

    return Scaffold(
      appBar: AppBar(title: const Text('Low Stock Ingredients')),
      body: lowItems.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No low stock ingredients. All items are above the threshold.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              itemCount: lowItems.length,
              itemBuilder: (context, index) {
                final item = lowItems[index];
                final qty = item.qty;
                return ListTile(
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                  title: Text(item.name),
                  subtitle: Text('Qty: ${qty.toStringAsFixed(1)}'),
                  trailing: TextButton(
                    onPressed: () {
                      _restockItem(item.name);
                    },
                    child: const Text('Restock'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addIngredient,
        tooltip: 'Add Ingredient',
        child: const Icon(Icons.add),
      ),
    );
  }
}
