import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/restaurent/Orderpage.dart' as OP;
import 'package:url_launcher/url_launcher.dart';


class PendingByodRequestsPage extends StatefulWidget {
  const PendingByodRequestsPage({super.key});

  @override
  State<PendingByodRequestsPage> createState() =>
      _PendingByodRequestsPageState();
}

class _PendingByodRequestsPageState extends State<PendingByodRequestsPage> {
  final DateFormat _timeFormat = DateFormat('hh:mm a, MMM d');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  String _formatCurrency(double amount) => _currencyFormat.format(amount);

  String _statusLabel(OP.OrderStatus s) {
    switch (s) {
      case OP.OrderStatus.Pending:
        return 'Pending';
      case OP.OrderStatus.Accepted:
        return 'Accepted';
      case OP.OrderStatus.Preparing:
        return 'Preparing';
      case OP.OrderStatus.Ready:
        return 'Ready for Pickup';
      case OP.OrderStatus.OutForDelivery:
        return 'Out for Delivery';
      case OP.OrderStatus.Completed:
        return 'Completed';
      case OP.OrderStatus.Rejected:
        return 'Rejected';
      case OP.OrderStatus.Cancelled:
        return 'Cancelled';
      case OP.OrderStatus.AwaitingApproval:
        return 'Awaiting Approval';
      case OP.OrderStatus.PendingPayment:
        return 'Pending Payment';
    }
  }

  Color _statusColor(OP.OrderStatus s) {
    switch (s) {
      case OP.OrderStatus.Pending:
        return Colors.orange;
      case OP.OrderStatus.Accepted:
        return Colors.lightBlue;
      case OP.OrderStatus.Preparing:
        return Colors.blue;
      case OP.OrderStatus.Ready:
        return Colors.green;
      case OP.OrderStatus.OutForDelivery:
        return Colors.teal;
      case OP.OrderStatus.Completed:
        return Colors.grey;
      case OP.OrderStatus.Rejected:
        return Colors.red;
      case OP.OrderStatus.Cancelled:
        return Colors.red;
      case OP.OrderStatus.AwaitingApproval:
        return Colors.blueGrey;
      case OP.OrderStatus.PendingPayment:
        return Colors.purple;
    }
  }

  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('approval_requests')
        .doc(requestId)
        .update({'status': newStatus});
  }

  Future<void> _acceptRequest(OP.Order request) async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Fetch the restaurant's name to include in the order details.
    final restaurantDoc = await firestore.collection('users').doc(user.uid).get();
    final restaurantData = restaurantDoc.data();
    final restaurantName = restaurantData?['fullName'] ?? 'A Restaurant';

    final orderRef = firestore.collection('orders').doc();

    // Create a new order from the request data
    await orderRef.set({
      'orderId': orderRef.id,
      'restaurantId': user.uid,
      'restaurantName': restaurantName,
      'customerName': request.customerName,
      'userId': request.userId, // Assuming Order model has userId
      'items': request.items.map((item) => {
        'name': item.name,
        'quantity': item.qty,
        'price': item.price,
        'customizations': item.customizations,
        'isHealthy': item.isHealthy,
        'imageUrl': item.imageUrl,
      }).toList(),
      'totalAmount': request.total,
      'paymentMethod': 'pending',
      'paymentStatus': 'unpaid',
      'orderStatus': 'pending_payment', // New status for user to pay
      'orderType': 'byod',
      'byodRecipeName': request.byodRecipeName,
      'byodRecipeType': request.byodRecipeType,
      'byodRecipeContent': request.byodRecipeContent,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Delete the original request
    await firestore.collection('approval_requests').doc(request.id).delete();
  }

  void _showOrderDetails(OP.Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.only(top: 16),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order ${order.id}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        backgroundColor: _statusColor(
                          order.status,
                        ).withOpacity(0.15),
                        label: Text(
                          _statusLabel(order.status),
                          style: TextStyle(
                            color: _statusColor(order.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Type: ${order.type.name}'),
                  Text('Customer: ${order.customerName}'),
                  Text('Placed: ${_timeFormat.format(order.createdAt)}'),
                  const Divider(height: 24),
                  const Text(
                    'Items Ordered',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map(
                    (it) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  '${it.name} x${it.qty}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Text(
                                _formatCurrency(it.price * it.qty),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          if (it.customizations.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                              child: Text(
                                it.customizations.join('\n'),
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatCurrency(order.total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _actionButtonsFor(order, closeOnAction: true),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildByodDetails(OP.Order order) {
    if (order.type != OP.OrderType.BYOD || order.byodRecipeName == null) {
      return const SizedBox.shrink();
    }

    Widget contentWidget;
    final content = order.byodRecipeContent;

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
            content != null && content.isNotEmpty
                ? content
                : 'No instructions provided.',
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        );
        break;
      case 'upload':
        contentWidget = content != null && content.isNotEmpty
            ? InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(child: Image.network(content)),
                ),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(content),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            : const Text('No image uploaded.');
        break;
      case 'link':
        contentWidget = content != null && content.isNotEmpty
            ? InkWell(
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
              )
            : const Text('No link provided.');
        break;
      default:
        contentWidget = const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0), // Light Orange
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("BYOD Recipe Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          contentWidget,
        ],
      ),
    );
  }

  List<Widget> _actionButtonsFor(OP.Order order, {bool closeOnAction = false}) {
    List<Widget> actions = [];
    switch (order.status) {
      case OP.OrderStatus.Pending:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            onPressed: () async {
              await _acceptRequest(order);
              if (closeOnAction) Navigator.pop(context);
            }, 
            label: const Text('Accept Order'),
          ),
        );
        actions.add(
          OutlinedButton.icon(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await _updateRequestStatus(order.id, 'rejected');
              if (closeOnAction) Navigator.pop(context);
            }, 
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        );
        break;
      case OP.OrderStatus.Accepted:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.kitchen),
            onPressed: null, // No action from here in this flow
            label: const Text('Start Preparing'),
          ),
        );
        break;
      case OP.OrderStatus.Preparing:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.local_dining),
            onPressed: null,
            label: const Text('Mark Ready'),
          ),
        );
        break;
      case OP.OrderStatus.Ready:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.shopping_bag),
            onPressed: null,
            label: const Text('Mark Picked Up'),
          ),
        );
        break;
      case OP.OrderStatus.OutForDelivery:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.done_all),
            onPressed: null,
            label: const Text('Complete Delivery'),
          ),
        );
        break;
      case OP.OrderStatus.Completed:
      case OP.OrderStatus.Rejected:
        actions.add(
          const Text(
            'No further actions available for this status.',
            style: TextStyle(color: Colors.grey),
          ),
        );
        break;
      case OP.OrderStatus.Cancelled:
      case OP.OrderStatus.AwaitingApproval:
      case OP.OrderStatus.PendingPayment:
        actions.add(const SizedBox.shrink());
        break;
    }
    return actions;
  }

  /// Small horizontal progress indicator showing common order steps.
  Widget _buildStatusProgress(OP.Order order) {
    final steps = [
      OP.OrderStatus.Pending,
      OP.OrderStatus.Accepted,
      OP.OrderStatus.Preparing,
      OP.OrderStatus.Ready, // we'll label this as "Packing/Ready"
      OP.OrderStatus.OutForDelivery,
      OP.OrderStatus.Completed,
    ];

    final currentIndex = steps.indexOf(order.status);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(steps.length, (i) {
          final s = steps[i];
          final done = i <= currentIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Chip(
              backgroundColor: (done ? _statusColor(s) : Colors.grey.shade200)
                  .withOpacity(done ? 0.18 : 1.0),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (done)
                    Icon(Icons.check_circle, size: 14, color: _statusColor(s))
                  else
                    Icon(
                      Icons.radio_button_unchecked,
                      size: 14,
                      color: Colors.grey,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    // show friendly labels for some steps
                    s == OP.OrderStatus.Ready ? 'Packing' : _statusLabel(s),
                    style: TextStyle(
                      color: done ? _statusColor(s) : Colors.grey.shade700,
                      fontWeight: done ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Pending BYOD Requests')),
      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('approval_requests')
                  .where('restaurantId', isEqualTo: user.uid)
                  .where('status', isEqualTo: 'pending')
                  // .orderBy('createdAt', descending: true) // This requires a composite index
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No pending requests."));
                }

                // Create a modifiable list from the snapshot docs
                final requestDocs =
                    List<QueryDocumentSnapshot>.from(snapshot.data!.docs);

                // Sort client-side to avoid needing a composite index
                requestDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = aData['createdAt'] as Timestamp?;
                  final bTime = bData['createdAt'] as Timestamp?;
                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1; // push nulls to the end
                  if (bTime == null) return -1;
                  return bTime.compareTo(aTime); // descending
                });

                final requests = requestDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return OP.Order(
                    id: doc.id,
                    customerName: data['customerName'] ?? 'Guest',
                    createdAt: (data['createdAt'] as Timestamp).toDate(),
                    status: OP.OrderStatus.Pending, // Treat as pending for UI
                    type: OP.OrderType.BYOD,
                    items: (data['items'] as List<dynamic>).map((item) {
                      return OP.OrderItem(
                        name: item['name'] ?? '',
                        qty: item['quantity'] ?? 1,
                        price: (item['price'] ?? 0).toDouble(),
                        customizations: (item['customizations'] as List<dynamic>?)
                                ?.map((e) => e.toString())
                                .toList() ?? [],
                      );
                    }).toList(),
                    // Pass user ID for creating the final order
                    userId: data['userId'], 
                    byodRecipeName: data['byodRecipeName'],
                    byodRecipeType: data['byodRecipeType'],
                    byodRecipeContent: data['byodRecipeContent'],
                  );
                }).toList();

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    return _buildOrderCard(requests[i]);
                  },
                );
              },
            ),
    );
  }

  Widget _buildOrderCard(OP.Order order) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: _statusColor(
                      order.status,
                    ).withOpacity(0.12),
                    label: Text(
                      _statusLabel(order.status),
                      style: TextStyle(
                        color: _statusColor(order.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${order.customerName} - ${_timeFormat.format(order.createdAt)}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 8),
              // Show a short list of items ordered
              Text(
                'Items: ${order.items.map((it) => '${it.name} x${it.qty}').join(', ')}',
                style: const TextStyle(color: Colors.black87, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${order.items.length} item(s) • Total: ${_formatCurrency(order.total)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildStatusProgress(order),
              _buildByodDetails(order),
              const Divider(height: 20),
              // Action buttons: show primary action only
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _actionButtonsFor(order).map((w) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: w,
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
