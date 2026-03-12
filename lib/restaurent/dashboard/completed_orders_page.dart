import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:project/restaurent/Orderpage.dart' as OP;
import '../../homescreen/BYOD/full_screen_image.dart';
import 'package:url_launcher/url_launcher.dart';

class CompletedOrdersPage extends StatelessWidget {
  const CompletedOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Completed Orders"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('restaurantId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allOrders = snapshot.data!.docs
                    .map((d) => OP.Order.fromSnapshot(d))
                    .toList();

                final completedOrders = allOrders
                    .where((o) => o.status == OP.OrderStatus.Completed)
                    .toList();

                completedOrders.sort(
                  (a, b) => b.createdAt.compareTo(a.createdAt),
                );

                if (completedOrders.isEmpty) {
                  return const Center(child: Text("No completed orders yet"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: completedOrders.length,
                  itemBuilder: (context, index) {
                    return _DetailedCompletedOrderCard(
                      order: completedOrders[index],
                    );
                  },
                );
              },
            ),
    );
  }
}

class _DetailedCompletedOrderCard extends StatelessWidget {
  final OP.Order order;
  const _DetailedCompletedOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('MMM d, yyyy • hh:mm a');
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${order.id.substring(0, 5).toUpperCase()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(order.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Completed",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Customer Info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Customer",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // Items List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${item.qty}x",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          if (item.customizations.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                item.customizations.join(", "),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      currencyFormat.format(item.price * item.qty),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
          ),
          if (order.type == OP.OrderType.BYOD) _ByodDetailsWidget(order: order),

          // Footer / Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Amount",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  currencyFormat.format(order.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ByodDetailsWidget extends StatelessWidget {
  final OP.Order order;

  const _ByodDetailsWidget({required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.type != OP.OrderType.BYOD ||
        order.byodRecipeContent == null ||
        order.byodRecipeContent!.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget contentWidget;
    switch (order.byodRecipeType) {
      case 'write':
        contentWidget = Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            order.byodRecipeContent!,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        );
        break;
      case 'upload':
        contentWidget = InkWell(
          onTap: () {
            print('Tapped image: ${order.byodRecipeContent!}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    FullScreenImageScreen(imageUrl: order.byodRecipeContent!),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              order.byodRecipeContent!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Text('Could not load image.')),
            ),
          ),
        );
        break;
      case 'link':
        contentWidget = InkWell(
          onTap: () async {
            final url = Uri.tryParse(order.byodRecipeContent!);
            if (url != null && await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.byodRecipeContent!,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      default:
        contentWidget = const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "BYOD Recipe: ${order.byodRecipeName ?? 'Custom'}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          contentWidget,
        ],
      ),
    );
  }
}
