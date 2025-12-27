// lib/screens/customization_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_models.dart';
import '../state/cart_notifier.dart';

class CustomizationPage extends StatefulWidget {
  final CategoryItem customizableItem;
  final List<CustomizationStep> template;

  const CustomizationPage({
    super.key,
    required this.customizableItem,
    required this.template,
  });

  @override
  State<CustomizationPage> createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  late Map<int, dynamic> _selections;
  late int _totalPrice;

  @override
  void initState() {
    super.initState();
    _selections = {};
    _totalPrice = widget.customizableItem.price.toInt();
  }

  void _updateSelection(int stepIndex, dynamic selection, int additionalPrice) {
    setState(() {
      final oldSelection = _selections[stepIndex];

      // Remove old price if exists
      if (oldSelection != null) {
        if (oldSelection is CustomizationOption) {
          _totalPrice -= oldSelection.additionalPrice;
        } else if (oldSelection is List) {
          for (var opt in oldSelection) {
            if (opt is CustomizationOption) {
              _totalPrice -= opt.additionalPrice;
            }
          }
        }
      }

      _selections[stepIndex] = selection;
      _totalPrice += additionalPrice;
    });
  }

  void _addToCart() {
    final cart = context.read<CartNotifier>();

    // Build customization summary
    final customizations = <String>[];
    for (int i = 0; i < widget.template.length; i++) {
      final step = widget.template[i];
      final selection = _selections[i];

      if (selection != null) {
        if (selection is CustomizationOption) {
          customizations.add('${step.title}: ${selection.name}');
        } else if (selection is String) {
          customizations.add('${step.title}: $selection');
        } else if (selection is List) {
          final names = selection
              .map((s) {
                if (s is CustomizationOption) return s.name;
                if (s is String) return s;
                return s.toString();
              })
              .join(', ');
          customizations.add('${step.title}: $names');
        }
      }
    }

    // Create cart item with customizations
    final cartItem = CartItem(
      name: widget.customizableItem.name,
      price: _totalPrice,
      imageUrl: widget.customizableItem.imageUrl,
      restaurantName: widget.customizableItem.restaurantName,
      customizations: customizations,
      restaurantId: widget.customizableItem.restaurantId,
    );

    cart.addItem(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.customizableItem.name} added to cart!'),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Customize ${widget.customizableItem.name}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Item Header Card
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.customizableItem.imageUrl,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.fastfood, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customizableItem.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.customizableItem.restaurantName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.customizableItem.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Customization Steps
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.template.length,
              itemBuilder: (context, index) {
                return _buildCustomizationStep(index, widget.template[index]);
              },
            ),
          ),

          // Bottom Bar with Price and Add Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '₹$_totalPrice',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ADD TO CART',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationStep(int stepIndex, CustomizationStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (step.isRequired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'Required',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildOptions(stepIndex, step),
        ],
      ),
    );
  }

  Widget _buildOptions(int stepIndex, CustomizationStep step) {
    if (step.isSingleChoice) {
      return Column(
        children: step.options.map((option) {
          final isString = option is String;
          final name = isString ? option : (option as CustomizationOption).name;
          final price = isString
              ? 0
              : (option as CustomizationOption).additionalPrice;
          final isSelected = _selections[stepIndex] == option;

          return InkWell(
            onTap: () => _updateSelection(stepIndex, option, price),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange.shade50 : Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? Colors.deepOrange : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (price > 0)
                    Text(
                      '+₹$price',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    } else {
      // Multiple choice
      return Column(
        children: step.options.map((option) {
          final isString = option is String;
          final name = isString ? option : (option as CustomizationOption).name;
          final price = isString
              ? 0
              : (option as CustomizationOption).additionalPrice;

          final currentSelections = _selections[stepIndex] as List? ?? [];
          final isSelected = currentSelections.contains(option);

          return InkWell(
            onTap: () {
              setState(() {
                List newSelections = List.from(currentSelections);
                int priceChange = 0;

                if (isSelected) {
                  newSelections.remove(option);
                  priceChange = -price;
                } else {
                  newSelections.add(option);
                  priceChange = price;
                }

                _selections[stepIndex] = newSelections;
                _totalPrice += priceChange;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange.shade50 : Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isSelected ? Colors.deepOrange : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (price > 0)
                    Text(
                      '+₹$price',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }
  }
}
