import 'package:flutter/material.dart';
import 'package:project/homescreen/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../state/cart_notifier.dart';
import '../models/category_models.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/order_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Razorpay _razorpay;
  String? _payingForOrderId;
  void _startRazorpay(BuildContext context, List<CartItem> items, int total) {
    final options = {
      'key': 'rzp_test_RQX7adT0U42yu4', // replace with real key
      'amount': total * 100,
      'name': 'Food Order',
      'description': 'Restaurant Order',
    };

    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_payingForOrderId != null) {
      // This was a payment for an approved BYOD order
      await _completeApprovedOrder(_payingForOrderId!, 'Razorpay', 'paid');
      if (mounted) {
        setState(() {
          _payingForOrderId = null;
        });
      }
    } else {
      // This is a payment for a regular cart
      final cartNotifier = context.read<CartNotifier>();
      final items = _getCartItems(cartNotifier);

      if (items.isEmpty) return;
      final restaurantId = items.first.restaurantId;

      if (restaurantId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: Restaurant ID missing. Please clear cart and re-add items.',
            ),
          ),
        );
        return;
      }

      try {
        await OrderService().placeOrder(
          restaurantId: restaurantId,
          items: items,
          totalAmount: cartNotifier.total,
          paymentMethod: 'Razorpay',
          paymentStatus: 'paid',
        );

        if (!mounted) return;
        cartNotifier.clearCart();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment successful')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placement failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_payingForOrderId != null) {
      setState(() => _payingForOrderId = null);
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Payment failed')));
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _showPaymentOptions(
    BuildContext context,
    List<CartItem> items,
    int total,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.money, color: Colors.green),
              title: const Text('Cash on Delivery'),
              onTap: () {
                Navigator.pop(context);
                _placeCODOrder(context, items, total);
              },
            ),

            ListTile(
              leading: const Icon(Icons.payment, color: Colors.blue),
              title: const Text('Pay Online (Razorpay)'),
              onTap: () {
                Navigator.pop(context);
                _startRazorpay(context, items, total);
              },
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showPaymentOptionsForApprovedOrder(
    BuildContext context,
    String orderId,
    int total,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Complete Payment',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.money, color: Colors.green),
              title: const Text('Cash on Delivery'),
              onTap: () {
                Navigator.pop(context);
                _placeCODOrderForApproved(orderId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.blue),
              title: const Text('Pay Online (Razorpay)'),
              onTap: () {
                Navigator.pop(context);
                _startRazorpayForApproved(context, orderId, total);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _placeCODOrder(
    BuildContext context,
    List<CartItem> items,
    int total,
  ) async {
    final orderService = OrderService();

    if (items.isEmpty) return;
    final restaurantId = items.first.restaurantId;

    if (restaurantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: Restaurant ID missing. Please clear cart and re-add items.',
          ),
        ),
      );
      return;
    }

    print("Placing COD Order. Restaurant ID: $restaurantId"); // Debug log

    try {
      await orderService.placeOrder(
        restaurantId: restaurantId,
        items: items,
        totalAmount: total,
        paymentMethod: 'COD',
        paymentStatus: 'pending',
      );

      if (!context.mounted) return;

      context.read<CartNotifier>().clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully (COD)')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _placeCODOrderForApproved(String orderId) async {
    await _completeApprovedOrder(orderId, 'COD', 'pending');
  }

  void _startRazorpayForApproved(
    BuildContext context,
    String orderId,
    int total,
  ) {
    setState(() {
      _payingForOrderId = orderId;
    });
    _startRazorpay(context, [], total);
  }

  Future<void> _completeApprovedOrder(
    String orderId,
    String paymentMethod,
    String paymentStatus,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {
          'paymentMethod': paymentMethod,
          'paymentStatus': paymentStatus,
          'orderStatus': 'pending', // Move to restaurant's normal queue
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _submitForApproval(
    BuildContext context,
    List<CartItem> items,
    int total,
  ) async {
    final orderService = OrderService();

    if (items.isEmpty) return;
    final restaurantId = items.first.restaurantId;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to submit a request.')),
      );
      return;
    }

    if (restaurantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: Restaurant ID missing. Please clear cart and re-add items.',
          ),
        ),
      );
      return;
    }

    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final requestRef = FirebaseFirestore.instance
          .collection('approval_requests')
          .doc();
      final itemsAsMaps = items
          .map(
            (item) => {
              'name': item.name,
              'price': item.price,
              'quantity': item.quantity,
              'restaurantName': item.restaurantName,
              'restaurantId': item.restaurantId,
              'imageUrl': item.imageUrl,
              'isHealthy': item.isHealthy,
              'customizations': item.customizations,
            },
          )
          .toList();

      // --- BYOD Data Extraction ---
      final byodData = <String, dynamic>{};
      if (items.isNotEmpty &&
          items.first.customizations != null &&
          items.first.customizations!.any((c) => c.startsWith('BYOD_NAME:'))) {
        final customizations = items.first.customizations!;
        final byodNameLine = customizations.firstWhere(
          (c) => c.startsWith('BYOD_NAME:'),
          orElse: () => '',
        );
        final byodTypeLine = customizations.firstWhere(
          (c) => c.startsWith('BYOD_TYPE:'),
          orElse: () => '',
        );
        final byodContentLine = customizations.firstWhere(
          (c) => c.startsWith('BYOD_CONTENT:'),
          orElse: () => '',
        );

        if (byodNameLine.isNotEmpty) {
          byodData['byodRecipeName'] = byodNameLine.substring(
            'BYOD_NAME:'.length,
          );
          byodData['byodRecipeType'] = byodTypeLine.substring(
            'BYOD_TYPE:'.length,
          );
          byodData['byodRecipeContent'] = byodContentLine.substring(
            'BYOD_CONTENT:'.length,
          );

          // Clean the special tags from the item's customizations list
          (itemsAsMaps.first['customizations'] as List?)?.removeWhere(
            (c) => c.toString().startsWith('BYOD_'),
          );
        }
      }

      await requestRef.set({
        'requestId': requestRef.id,
        'restaurantId': restaurantId,
        'userId': user.uid,
        'customerName': user.displayName ?? user.email ?? 'Guest',
        'items': itemsAsMaps,
        'totalAmount': total,
        'status': 'pending', // status for the request itself
        'createdAt': FieldValue.serverTimestamp(),
        ...byodData, // Add extracted BYOD data
      });

      if (!context.mounted) return;
      Navigator.pop(context); // pop loading dialog
      context.read<CartNotifier>().clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request sent to restaurant for approval!'),
        ),
      );
      Navigator.pop(context); // Go back from cart
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // pop loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: const Text(
          'My Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Clear Cart",
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              _showClearCartDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildApprovedOrdersSection(),
          Expanded(
            child: Consumer<CartNotifier>(
              builder: (context, cartNotifier, _) {
                final items = _getCartItems(cartNotifier);

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Add items to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryPage(
                                categoryName: '',
                                categoryId: '',
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.restaurant_menu),
                          label: const Text('Browse Menu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildCartItem(
                            context,
                            item,
                            index,
                            cartNotifier,
                          );
                        },
                      ),
                    ),
                    _buildOrderSummary(context, cartNotifier, items),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedOrdersSection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('orderStatus', isEqualTo: 'pending_payment')
          // .orderBy('createdAt', descending: true) // Removed to avoid index requirement
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final approvedOrders = List<QueryDocumentSnapshot>.from(
          snapshot.data!.docs,
        );
        // Client-side sorting
        approvedOrders.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['createdAt'] as Timestamp?;
          final bTime = bData['createdAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.blue.shade50,
          constraints: const BoxConstraints(maxHeight: 250),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Awaiting Payment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                ...approvedOrders.map((orderDoc) {
                  final orderData = orderDoc.data() as Map<String, dynamic>;
                  return _buildApprovedOrderCard(orderDoc.id, orderData);
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApprovedOrderCard(
    String orderId,
    Map<String, dynamic> orderData,
  ) {
    final items = (orderData['items'] as List<dynamic>? ?? [])
        .map((i) {
          // Ensure the item is a Map<String, dynamic> before parsing
          if (i is Map) {
            return CartItem.fromJson(Map<String, dynamic>.from(i));
          }
          return null;
        })
        .whereType<CartItem>()
        .toList();
    final isByod = (orderData['orderType'] ?? '') == 'byod';
    final total = (orderData['totalAmount'] as num?)?.toInt() ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order from ${orderData['restaurantName'] ?? 'Awaiting Details...'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...items.map((item) => Text("- ${item.name} x${item.quantity}")),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: ₹$total",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: isByod
                      ? () => _placeCODOrderForApproved(orderId)
                      : () => _showPaymentOptionsForApprovedOrder(
                          context,
                          orderId,
                          total,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isByod ? Colors.green : Colors.blue,
                  ),
                  child: Row(
                    children: [
                      if (isByod)
                        const Icon(Icons.money, size: 16)
                      else
                        const Icon(Icons.payment, size: 16),
                      const SizedBox(width: 8),
                      Text(isByod ? "Place COD Order" : "Pay Now"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to get cart items safely
  List<CartItem> _getCartItems(CartNotifier cartNotifier) {
    try {
      final dynamic self = cartNotifier;
      final dynamic items = self.items;
      if (items is List<CartItem>) return items;
      if (items is Iterable) return items.cast<CartItem>().toList();
    } catch (_) {}
    return [];
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text('Clear Cart?'),
            ],
          ),
          content: const Text(
            'Are you sure you want to remove all items from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _clearCart(context.read<CartNotifier>());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart cleared'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _clearCart(CartNotifier cartNotifier) {
    try {
      final dynamic self = cartNotifier;
      if (self.clearCart is Function) {
        self.clearCart();
      } else if (self.clear is Function) {
        self.clear();
      } else {
        final dynamic items = self.items;
        if (items is List) {
          items.clear();
          if (self.notifyListeners is Function) {
            self.notifyListeners();
          }
        }
      }
    } catch (_) {}
  }

  void _removeItem(CartNotifier cartNotifier, int index) {
    try {
      final dynamic self = cartNotifier;
      if (self.removeFromCart is Function) {
        self.removeFromCart(index);
      } else if (self.removeAt is Function) {
        self.removeAt(index);
      } else {
        final dynamic items = self.items;
        if (items is List && index >= 0 && index < items.length) {
          items.removeAt(index);
          if (self.notifyListeners is Function) {
            self.notifyListeners();
          }
        }
      }
    } catch (_) {}
  }

  void _updateQuantity(CartNotifier cartNotifier, int index, int newQty) {
    try {
      final dynamic self = cartNotifier;
      if (self.updateQuantity is Function) {
        self.updateQuantity(index, newQty);
      } else {
        final dynamic items = self.items;
        if (items is List<CartItem> && index >= 0 && index < items.length) {
          items[index].quantity = newQty;
          if (self.notifyListeners is Function) {
            self.notifyListeners();
          }
        }
      }
    } catch (_) {}
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    int index,
    CartNotifier cartNotifier,
  ) {
    final hasCustomizations =
        item.customizations != null && item.customizations!.isNotEmpty;

    return Dismissible(
      key: Key('${item.name}_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _removeItem(cartNotifier, index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} removed from cart'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                // Could implement undo functionality here
              },
            ),
          ),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 30),
            SizedBox(height: 5),
            Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.imageUrl.isEmpty
                      ? Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.fastfood, size: 40),
                        )
                      : (item.imageUrl.startsWith('http')
                            ? Image.network(
                                item.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.fastfood, size: 40),
                                ),
                              )
                            : Image.asset(
                                item.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.fastfood, size: 40),
                                ),
                              )),
                ),
                const SizedBox(width: 16),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.restaurantName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${item.price}',
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quantity Controls
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Remove Button
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () {
                        _removeItem(cartNotifier, index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} removed from cart'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 10),

                    // Quantity Counter
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: item.quantity > 1
                                  ? Colors.deepOrange
                                  : Colors.grey,
                              size: 22,
                            ),
                            onPressed: () {
                              if (item.quantity > 1) {
                                _updateQuantity(
                                  cartNotifier,
                                  index,
                                  item.quantity - 1,
                                );
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.deepOrange,
                              size: 22,
                            ),
                            onPressed: () {
                              _updateQuantity(
                                cartNotifier,
                                index,
                                item.quantity + 1,
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Customizations Section
            if (hasCustomizations) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune,
                          size: 16,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Customizations:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...item.customizations!.map(
                      (customization) => Padding(
                        padding: const EdgeInsets.only(top: 4, left: 22),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                customization,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Item Total
            if (item.quantity > 1) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Item Total:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '₹${item.totalPrice}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    CartNotifier cartNotifier,
    List<CartItem> items,
  ) {
    final subtotal = items.fold<int>(0, (sum, item) => sum + item.totalPrice);
    const deliveryFee = 0;
    const discount = 0;
    final total = subtotal + deliveryFee - discount;
    final isByodOrder = items.any(
      (item) => item.customizations?.any((c) => c.startsWith('BYOD_')) ?? false,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Promo Code
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter promo code',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.local_offer_outlined),
                suffixIcon: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Promo code feature coming soon!'),
                      ),
                    );
                  },
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Summary Rows
            _buildSummaryRow('Subtotal', '₹$subtotal'),
            const SizedBox(height: 8),
            _buildSummaryRow('Delivery Fee', '₹$deliveryFee'),
            const SizedBox(height: 8),
            if (discount > 0)
              _buildSummaryRow('Discount', '-₹$discount', isDiscount: true),
            const Divider(height: 30, thickness: 1),
            _buildSummaryRow('Total', '₹$total', isTotal: true),
            const SizedBox(height: 20),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  if (isByodOrder) {
                    _submitForApproval(context, items, total);
                  } else {
                    _showPaymentOptions(context, items, total);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isByodOrder
                          ? 'Submit for Approval'
                          : 'Proceed to Checkout',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '(${items.length} ${items.length == 1 ? 'item' : 'items'})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
