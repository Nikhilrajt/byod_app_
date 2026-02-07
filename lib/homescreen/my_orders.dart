import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../profile/setting.dart';
import 'package:provider/provider.dart';
import '../state/cart_notifier.dart';
import '../models/category_models.dart';
import 'cart.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Orders")),
        body: const Center(child: Text("Please login to view orders")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // --- Profile Header ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.deepOrange.shade100,
                  child: Text(
                    (user.displayName ?? user.email ?? "U")[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? "User",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email ?? "",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- Orders List ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Query all orders across all restaurants where userId matches the current user
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user.uid)
                  .where(
                    'orderStatus',
                    whereIn: [
                      'pending',
                      'accepted',
                      'preparing',
                      'ready',
                      'outfordelivery',
                      'completed',
                      'rejected',
                      'cancelled',
                    ],
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text("Error: ${snapshot.error}"),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No past orders found",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Create a modifiable list and sort client-side
                final orders = List<QueryDocumentSnapshot>.from(
                  snapshot.data!.docs,
                );
                orders.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = aData['createdAt'] as Timestamp?;
                  final bTime = bData['createdAt'] as Timestamp?;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  return bTime.compareTo(aTime); // Descending
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index].data() as Map<String, dynamic>;
                    final items = (order['items'] as List<dynamic>?) ?? [];
                    final total = order['totalAmount'] ?? 0;

                    return _buildOrderCard(context, order, items, total);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderCard(
    BuildContext context,
    Map<String, dynamic> order,
    List<dynamic> items,
    dynamic total,
  ) {
    final status = order['orderStatus'] ?? order['paymentStatus'] ?? 'pending';
    final timestamp = (order['createdAt'] as Timestamp?)?.toDate();
    final dateStr = timestamp != null
        ? DateFormat('MMM d, yyyy • hh:mm a').format(timestamp)
        : 'Unknown Date';

    final restaurantName =
        order['restaurantName']?.toString() ??
        (items.isNotEmpty
            ? (items[0]['restaurantName']?.toString() ?? 'Restaurant')
            : 'Restaurant');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Header: Restaurant & Status ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    restaurantName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // --- Body: Items List ---
            ...items.map((item) => _buildOrderItem(item)),

            const SizedBox(height: 12),
            const Divider(height: 1),

            // --- Footer: Actions ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    Text(
                      "Total: ₹$total",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (status.toLowerCase() == 'pending')
                      TextButton(
                        onPressed: () =>
                            _cancelOrder(context, order['orderId']),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => _handleReorder(
                        context,
                        items,
                        order['restaurantId']?.toString() ?? '',
                      ),
                      icon: const Icon(
                        Icons.refresh,
                        size: 18,
                        color: Colors.deepOrange,
                      ),
                      label: const Text(
                        "Reorder",
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
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
  }

  Widget _buildOrderItem(dynamic item) {
    final itemMap = item as Map<String, dynamic>;
    final isHealthy = itemMap['isHealthy'] == true;
    final imageUrl = itemMap['imageUrl'] ?? '';
    final name = itemMap['name'] ?? 'Unknown';
    final quantity = itemMap['quantity'] ?? 1;
    final price = itemMap['price'] ?? 0;
    final customizations = itemMap['customizations'] as List<dynamic>?;
    final categoryName = itemMap['categoryName'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                ),
              ),
              if (isHealthy)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.spa, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (categoryName != null)
                  Text(
                    categoryName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                if (customizations != null && customizations.isNotEmpty)
                  Text(
                    customizations.join(', '),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "x$quantity",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "₹$price",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(BuildContext context, String? orderId) async {
    if (orderId == null || orderId.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'orderStatus': 'cancelled'},
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order cancelled successfully")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to cancel order: $e")));
      }
    }
  }

  void _handleReorder(
    BuildContext context,
    List<dynamic> items,
    String orderRestaurantId,
  ) {
    final cart = Provider.of<CartNotifier>(context, listen: false);

    // Clear existing cart to avoid restaurant conflict
    cart.clearCart();

    print("Reordering from Restaurant ID: $orderRestaurantId"); // Debug log

    for (var i in items) {
      // Safely parse price
      int price = 0;
      if (i['price'] is int) {
        price = i['price'];
      } else if (i['price'] is double) {
        price = (i['price'] as double).toInt();
      }

      // Determine correct restaurant ID for this item
      final itemRestaurantId =
          (i['restaurantId'] != null && i['restaurantId'].toString().isNotEmpty)
          ? i['restaurantId']
          : orderRestaurantId;

      final cartItem = CartItem(
        name: i['name'] ?? 'Unknown',
        price: price,
        imageUrl: i['imageUrl'] ?? '',
        restaurantName: i['restaurantName'] ?? '',
        customizations: (i['customizations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        restaurantId: itemRestaurantId,
      );

      // Set quantity
      cartItem.quantity = i['quantity'] ?? 1;

      cart.addItem(cartItem);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Items added to cart!")));

    // Navigate to Cart
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }
}
