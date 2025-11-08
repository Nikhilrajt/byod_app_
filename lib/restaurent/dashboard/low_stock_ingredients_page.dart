
import 'package:flutter/material.dart';

class LowStockIngredientsPage extends StatefulWidget {
  const LowStockIngredientsPage({super.key});

  @override
  State<LowStockIngredientsPage> createState() =>
      _LowStockIngredientsPageState();
}

class _LowStockIngredientsPageState extends State<LowStockIngredientsPage> {
  final List<String> _lowStockIngredients = [
    'Tomatoes',
    'Onions',
    'Lettuce',
  ];

  void _addIngredient() {
    showDialog(
      context: context,
      builder: (context) {
        String newIngredient = '';
        return AlertDialog(
          title: const Text('Add Low Stock Ingredient'),
          content: TextField(
            onChanged: (value) {
              newIngredient = value;
            },
            decoration: const InputDecoration(hintText: "Ingredient Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newIngredient.isNotEmpty) {
                  setState(() {
                    _lowStockIngredients.add(newIngredient);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Ingredients'),
      ),
      body: ListView.builder(
        itemCount: _lowStockIngredients.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_lowStockIngredients[index]),
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

