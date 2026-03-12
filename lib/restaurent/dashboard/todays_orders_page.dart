import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import '../../homescreen/BYOD/full_screen_image.dart';
import 'package:url_launcher/url_launcher.dart';

class TodaysOrdersPage extends StatelessWidget {
  const TodaysOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    // Get start of today
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Orders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(userId)
            .collection('orders')
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .orderBy('createdAt', descending: true)
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
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "No orders received today",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final items = (order['items'] as List<dynamic>?) ?? [];
              final total = order['totalAmount'] ?? 0;
              final status = order['orderStatus'] ?? 'pending';
              final timestamp = (order['createdAt'] as Timestamp?)?.toDate();
              final timeStr = timestamp != null
                  ? DateFormat('hh:mm a').format(timestamp)
                  : '';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    "Order #${orders[index].id.substring(0, 5).toUpperCase()}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "$timeStr • ₹$total • ${status.toUpperCase()}",
                    style: TextStyle(
                      color: status == 'pending' ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    ...items.map<Widget>((item) {
                      return ListTile(
                        title: Text(item['name'] ?? 'Unknown Item'),
                        subtitle: item['customizations'] != null
                            ? Text(
                                (item['customizations'] as List)
                                    .map((e) => e.toString())
                                    .join(', '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              )
                            : null,
                        trailing: Text(
                          "${item['quantity']} x ₹${item['price']}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    _ByodDetails(order: order),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ByodDetails extends StatelessWidget {
  final Map<String, dynamic> order;

  const _ByodDetails({required this.order});

  @override
  Widget build(BuildContext context) {
    final type = order['byodRecipeType'] as String?;
    final content = order['byodRecipeContent'] as String?;

    if (type == null || content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget contentWidget;
    switch (type) {
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
            content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        );
        break;
      case 'upload':
        contentWidget = InkWell(
          onTap: () {
            print('Tapped image: $content');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImageScreen(imageUrl: content),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              content,
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
            final url = Uri.tryParse(content);
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
                    content,
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "BYOD Recipe: ${order['byodRecipeName'] ?? 'Custom'}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          contentWidget,
        ],
      ),
    );
  }
}
