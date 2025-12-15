import 'package:flutter/material.dart';
import 'package:project/services/ingredient_service.dart';
import 'package:project/services/low_stock_service.dart';
import 'package:project/models/ingredient_model.dart';

class LowStockIngredientsPage extends StatefulWidget {
  const LowStockIngredientsPage({super.key});

  @override
  State<LowStockIngredientsPage> createState() =>
      _LowStockIngredientsPageState();
}

class _LowStockIngredientsPageState extends State<LowStockIngredientsPage> {
  final LowStockService _lowStockService = LowStockService();
  final IngredientService _ingredientService = IngredientService();

  Future<void> _restockIngredient(
    IngredientModel ingredient,
    double additionalQuantity,
  ) async {
    try {
      final newQuantity = ingredient.quantityAvailable + additionalQuantity;
      await _ingredientService.updateIngredientQuantity(
        ingredient.id,
        newQuantity,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${ingredient.name} restocked to ${newQuantity.toStringAsFixed(1)} ${ingredient.unit}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restocking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRestockDialog(IngredientModel ingredient) {
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restock ${ingredient.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current: ${ingredient.quantityAvailable} ${ingredient.unit}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity to add',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              final quantity = double.tryParse(quantityController.text) ?? 0.0;
              if (quantity > 0) {
                _restockIngredient(ingredient, quantity);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Restock'),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatus(double quantity) {
    if (quantity <= 0.1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red),
        ),
        child: const Text(
          'OUT OF STOCK',
          style: TextStyle(
            color: Colors.red,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.orange),
        ),
        child: const Text(
          'LOW STOCK',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Ingredients'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<IngredientModel>>(
        stream: _lowStockService.getLowStockIngredients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final lowStockIngredients = snapshot.data ?? [];

          if (lowStockIngredients.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'All ingredients are well stocked!',
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: lowStockIngredients.length,
            itemBuilder: (context, index) {
              final ingredient = lowStockIngredients[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                  title: Text(ingredient.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity: ${ingredient.quantityAvailable} ${ingredient.unit}',
                      ),
                      const SizedBox(height: 4),
                      _buildStockStatus(ingredient.quantityAvailable),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _showRestockDialog(ingredient),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Restock'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
