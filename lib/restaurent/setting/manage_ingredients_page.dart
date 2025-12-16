import 'package:flutter/material.dart';

class IngredientStock {
  String name;
  double quantity; // stored in unit
  String unit;
  double threshold; // below this considered deficient
  bool byod;

  IngredientStock({
    required this.name,
    required this.quantity,
    this.unit = 'g',
    this.threshold = 50,
    this.byod = false,
  });

  bool get isLow => quantity <= threshold;
}

class ManageIngredientsPage extends StatefulWidget {
  const ManageIngredientsPage({super.key});

  @override
  State<ManageIngredientsPage> createState() => _ManageIngredientsPageState();
}

class _ManageIngredientsPageState extends State<ManageIngredientsPage> {
  final List<IngredientStock> _items = [];

  @override
  void initState() {
    super.initState();
    _loadMock();
  }

  void _loadMock() {
    _items.addAll([
      IngredientStock(
        name: 'Tomato',
        quantity: 120,
        unit: 'g',
        threshold: 30,
        byod: true,
      ),
      IngredientStock(
        name: 'Cheese',
        quantity: 40,
        unit: 'g',
        threshold: 50,
        byod: true,
      ),
      IngredientStock(
        name: 'Flour',
        quantity: 5000,
        unit: 'g',
        threshold: 1000,
        byod: false,
      ),
      IngredientStock(
        name: 'Salt',
        quantity: 200,
        unit: 'g',
        threshold: 20,
        byod: false,
      ),
    ]);
  }

  Future<void> _showEditDialog({IngredientStock? item, int? index}) async {
    final isEdit = item != null && index != null;
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final qtyCtrl = TextEditingController(
      text: item != null ? item.quantity.toString() : '',
    );
    final unitCtrl = TextEditingController(text: item?.unit ?? 'g');
    final threshCtrl = TextEditingController(
      text: item != null ? item.threshold.toString() : '',
    );
    bool byodValue = item?.byod ?? false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Ingredient' : 'Add Ingredient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                TextFormField(
                  controller: unitCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Unit (g, kg, ml, etc)',
                  ),
                ),
                TextFormField(
                  controller: threshCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Low stock threshold',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Available for BYOD'),
                  value: byodValue,
                  onChanged: (v) => setState(() => byodValue = v ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
                final unit = unitCtrl.text.trim();
                final thresh = double.tryParse(threshCtrl.text.trim()) ?? 0.0;
                if (name.isEmpty) return; // could show validation
                setState(() {
                  final newItem = IngredientStock(
                    name: name,
                    quantity: qty,
                    unit: unit.isEmpty ? 'g' : unit,
                    threshold: thresh,
                    byod: byodValue,
                  );
                  if (isEdit) {
                    _items[index] = newItem;
                  } else {
                    _items.add(newItem);
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete ingredient'),
        content: const Text('Are you sure you want to delete this ingredient?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _items.removeAt(index));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _changeQuantity(int index, double delta) {
    setState(() {
      final it = _items[index];
      it.quantity = (it.quantity + delta).clamp(0, double.infinity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Ingredients')),
      body: _items.isEmpty
          ? const Center(child: Text('No ingredients'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final it = _items[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    it.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (it.isLow)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Low',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 6),
                                  if (it.byod)
                                    Chip(
                                      backgroundColor:
                                          Colors.deepOrange.shade50,
                                      label: Text(
                                        'BYOD',
                                        style: TextStyle(
                                          color: Colors.deepOrange.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (it.quantity <= 0)
                                    const SizedBox(width: 6),
                                  if (it.quantity <= 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Out',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Quantity: ${it.quantity.toStringAsFixed(it.quantity % 1 == 0 ? 0 : 2)} ${it.unit}',
                              ),
                              Text(
                                'Threshold: ${it.threshold.toStringAsFixed(it.threshold % 1 == 0 ? 0 : 2)} ${it.unit}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _changeQuantity(i, -1),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                IconButton(
                                  onPressed: () => _changeQuantity(i, 1),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'edit') {
                                  _showEditDialog(item: it, index: i);
                                }
                                if (v == 'delete') _deleteItem(i);
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        tooltip: 'Add ingredient',
        child: const Icon(Icons.add),
      ),
    );
  }
}
