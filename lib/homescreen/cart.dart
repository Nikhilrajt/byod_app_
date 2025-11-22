import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cart_notifier.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              context.read<CartNotifier>().clearCart();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Cart cleared')));
            },
          ),
        ],
      ),
      body: Consumer<CartNotifier>(
        builder: (context, cartNotifier, _) {
          if (cartNotifier.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: cartNotifier.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartNotifier.cartItems[index];
                    return Dismissible(
                      key: Key(item.name),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        cartNotifier.removeFromCart(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} removed from cart'),
                          ),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                item.image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '₹${item.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    cartNotifier.removeFromCart(index);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${item.name} removed from cart',
                                        ),
                                      ),
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        if (item.qty > 1) {
                                          cartNotifier.updateQuantity(
                                            index,
                                            item.qty - 1,
                                          );
                                        }
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                    Text(
                                      item.qty.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.deepOrange,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        cartNotifier.updateQuantity(
                                          index,
                                          item.qty + 1,
                                        );
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
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
              ),
              _buildOrderSummary(cartNotifier),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(CartNotifier cartNotifier) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter promo code',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: TextButton(
                onPressed: () {},
                child: Text(
                  'Apply',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildSummaryRow(
            'Subtotal',
            '₹${cartNotifier.subtotal.toStringAsFixed(2)}',
          ),
          SizedBox(height: 8),
          _buildSummaryRow(
            'Delivery Fee',
            '₹${cartNotifier.deliveryFee.toStringAsFixed(2)}',
          ),
          SizedBox(height: 8),
          _buildSummaryRow(
            'Discount',
            '-₹${cartNotifier.discount.toStringAsFixed(2)}',
            isDiscount: true,
          ),
          Divider(height: 30, thickness: 1),
          _buildSummaryRow(
            'Total',
            '₹${cartNotifier.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Checkout logic
              },
              child: Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    String amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 20 : 15,
            color: isDiscount ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }
}
