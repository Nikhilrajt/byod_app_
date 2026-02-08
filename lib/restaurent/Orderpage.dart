import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

// ================= COLORS =================
const Color kPrimary = Color(0xFF3F2B96);
const Color kPrimaryLight = Color(0xFF5F5AA2);
const Color kBackground = Color(0xFFF6F7FB);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kPrimary,
            side: const BorderSide(color: kPrimary),
          ),
        ),
      ),
      home: const Orderpage(),
    );
  }
}

// --- Data Models ---

enum OrderStatus {
  AwaitingApproval,
  PendingPayment,
  Pending,
  Accepted,
  Preparing,
  Ready,
  OutForDelivery,
  Completed,
  Rejected,
  Cancelled,
}

enum OrderType { Normal, BYOD }

class OrderItem {
  final String name;
  final int qty;
  final double price;
  final String imageUrl;
  final List<String> customizations;
  final bool isHealthy;

  OrderItem({
    required this.name,
    required this.qty,
    required this.price,
    this.imageUrl = '',
    this.customizations = const [],
    this.isHealthy = false,
  });
}

class Order {
  final String id;
  final String customerName;
  final String? userId;
  final DateTime createdAt;
  final List<OrderItem> items;
  final OrderType type;

  double get total => items.fold(0, (p, e) => p + e.price * e.qty);
  OrderStatus status;

  final String? byodRecipeName;
  final String? byodRecipeType;
  final String? byodRecipeContent;

  Order({
    required this.id,
    required this.customerName,
    this.userId,
    required this.createdAt,
    required this.items,
    required this.type,
    this.status = OrderStatus.Pending,
    this.byodRecipeName,
    this.byodRecipeType,
    this.byodRecipeContent,
  });

  factory Order.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      customerName: data['customerName'] ?? 'Customer',
      userId: data['userId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: (data['items'] as List<dynamic>? ?? [])
          .map(
            (i) => OrderItem(
              name: i['name'] ?? 'Unknown',
              qty: i['quantity'] ?? 1,
              price: (i['price'] ?? 0).toDouble(),
              imageUrl: i['imageUrl'] ?? '',
              customizations:
                  (i['customizations'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
              isHealthy: i['isHealthy'] == true,
            ),
          )
          .toList(),
      type: _parseType(data['orderType']),
      status: _parseStatus(data['orderStatus'] ?? data['status']),
      byodRecipeName: data['byodRecipeName'],
      byodRecipeType: data['byodRecipeType'],
      byodRecipeContent: data['byodRecipeContent'],
    );
  }

  static OrderStatus _parseStatus(String? status) {
    final statusLower = status?.toLowerCase().replaceAll('_', '') ?? 'pending';
    switch (statusLower) {
      case 'awaitingapproval':
        return OrderStatus.AwaitingApproval;
      case 'pendingpayment':
        return OrderStatus.PendingPayment;
      case 'pending':
        return OrderStatus.Pending;
      case 'placed':
        return OrderStatus.Pending;
      case 'accepted':
        return OrderStatus.Accepted;
      case 'preparing':
        return OrderStatus.Preparing;
      case 'ready':
        return OrderStatus.Ready;
      case 'outfordelivery':
        return OrderStatus.OutForDelivery;
      case 'completed':
        return OrderStatus.Completed;
      case 'rejected':
        return OrderStatus.Rejected;
      case 'cancelled':
        return OrderStatus.Cancelled;
      default:
        return OrderStatus.Pending;
    }
  }

  static OrderType _parseType(String? type) {
    if (type != null && type.toLowerCase() == 'byod') return OrderType.BYOD;
    return OrderType.Normal;
  }
}

// --- Order Page Widget ---

class Orderpage extends StatefulWidget {
  const Orderpage({super.key});

  @override
  State<Orderpage> createState() => _OrderpageState();
}

class _OrderpageState extends State<Orderpage>
    with SingleTickerProviderStateMixin {
  final DateFormat _timeFormat = DateFormat('hh:mm a, MMM d');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _deleteOldOrders(); // Cleanup old orders on page load
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Delete orders older than 30 days from Firestore
  Future<void> _deleteOldOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('restaurantId', isEqualTo: user.uid)
          .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      // Batch delete old orders
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      if (querySnapshot.docs.isNotEmpty) {
        await batch.commit();
        debugPrint(
          'Deleted ${querySnapshot.docs.length} orders older than 30 days',
        );
      }
    } catch (e) {
      debugPrint('Error deleting old orders: $e');
    }
  }

  String _formatCurrency(double amount) => _currencyFormat.format(amount);

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #${order.id.substring(0, 5).toUpperCase()}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _timeFormat.format(order.createdAt),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        _buildStatusBadge(order.status),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Customer"),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: kPrimary.withOpacity(0.1),
                        child: const Icon(Icons.person, color: kPrimary),
                      ),
                      title: Text(order.customerName),
                      subtitle: const Text("Tap to contact"),
                    ),
                    const Divider(height: 32),
                    if (order.type == OrderType.BYOD) ...[
                      _buildSectionTitle("BYOD Details"),
                      const SizedBox(height: 8),
                      _buildByodContent(order),
                      const Divider(height: 32),
                    ],
                    _buildSectionTitle("Order Items"),
                    ...order.items.map((item) => _buildDetailItem(item)),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatCurrency(order.total),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (order.status != OrderStatus.Completed &&
                        order.status != OrderStatus.Cancelled &&
                        order.status != OrderStatus.Rejected)
                      _buildActionButtons(order),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[200],
                child: const Icon(Icons.fastfood, color: Colors.grey),
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (item.customizations.isNotEmpty)
                  Text(
                    item.customizations.join(", "),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Text(
            "${item.qty} x ${_formatCurrency(item.price)}",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(Order order, OrderStatus next) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newStatus = next.name.toLowerCase();
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .update({'orderStatus': newStatus, 'status': newStatus});

      // Also update any related approval_requests so user UI reflects the change
      try {
        final query = await FirebaseFirestore.instance
            .collection('approval_requests')
            .where('orderId', isEqualTo: order.id)
            .get();
        for (final doc in query.docs) {
          final updateData = <String, dynamic>{'status': newStatus};
          if (next == OrderStatus.Completed) {
            // stamp completion time so the client can show a short-lived "Reached successfully" badge
            updateData['completedAt'] = FieldValue.serverTimestamp();
          }
          await doc.reference.update(updateData);
        }
      } catch (e) {
        // ignore errors here - approval_requests may not exist for this order
      }
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.AwaitingApproval:
        return 'Awaiting Approval';
      case OrderStatus.PendingPayment:
        return 'Pending Payment';
      case OrderStatus.Pending:
        return 'Pending';
      case OrderStatus.Accepted:
        return 'Accepted';
      case OrderStatus.Preparing:
        return 'Preparing';
      case OrderStatus.Ready:
        return 'Ready for Pickup';
      case OrderStatus.OutForDelivery:
        return 'Out for Delivery';
      case OrderStatus.Completed:
        return 'Completed';
      case OrderStatus.Rejected:
        return 'Rejected';
      case OrderStatus.Cancelled:
        return 'Cancelled';
    }
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.AwaitingApproval:
        return Colors.blueGrey;
      case OrderStatus.PendingPayment:
        return Colors.purple;
      case OrderStatus.Pending:
        return Colors.orange;
      case OrderStatus.Accepted:
        return Colors.lightBlue;
      case OrderStatus.Preparing:
        return Colors.blue;
      case OrderStatus.Ready:
        return Colors.green;
      case OrderStatus.OutForDelivery:
        return Colors.teal;
      case OrderStatus.Completed:
        return Colors.grey;
      case OrderStatus.Rejected:
        return Colors.red;
      case OrderStatus.Cancelled:
        return Colors.red;
    }
  }

  Widget _buildOrderItem(OrderItem item) {
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
                  item.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.orange.shade50,
                    child: Icon(Icons.kitchen, color: Colors.orange.shade300),
                  ),
                ),
              ),
              if (item.isHealthy)
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
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (item.customizations.isNotEmpty)
                  Text(
                    item.customizations.join(', '),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "x${item.qty}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _formatCurrency(item.price),
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
          // Total for item
          Text(
            _formatCurrency(item.price * item.qty),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Order order) {
    switch (order.status) {
      case OrderStatus.AwaitingApproval:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    _updateOrderStatus(order, OrderStatus.Rejected),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Reject"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    _updateOrderStatus(order, OrderStatus.PendingPayment),
                child: const Text("Accept"),
              ),
            ),
          ],
        );
      case OrderStatus.Pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    _updateOrderStatus(order, OrderStatus.Rejected),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Reject"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    _updateOrderStatus(order, OrderStatus.Accepted),
                child: const Text("Accept"),
              ),
            ),
          ],
        );
      case OrderStatus.Accepted:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _updateOrderStatus(order, OrderStatus.Preparing),
            child: const Text("Start Preparing"),
          ),
        );
      case OrderStatus.Preparing:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _updateOrderStatus(order, OrderStatus.Ready),
            child: const Text("Mark Ready"),
          ),
        );
      case OrderStatus.Ready:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                _updateOrderStatus(order, OrderStatus.OutForDelivery),
            child: const Text("Out for Delivery"),
          ),
        );
      case OrderStatus.OutForDelivery:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _updateOrderStatus(order, OrderStatus.Completed),
            child: const Text("Complete Order"),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildByodContent(Order order) {
    // Used in the details modal
    if (order.type != OrderType.BYOD) return const SizedBox.shrink();

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
        contentWidget = content != null
            ? GestureDetector(
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
        contentWidget = content != null
            ? GestureDetector(
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.byodRecipeName ?? "Custom Recipe",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 12),
          contentWidget,
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _statusColor(order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            order.type == OrderType.BYOD
                                ? Icons.build_circle_outlined
                                : Icons.restaurant_menu,
                            color: _statusColor(order.status),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.customerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "#${order.id.substring(0, 5).toUpperCase()} • ${_timeFormat.format(order.createdAt)}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: _buildStatusBadge(order.status)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              if (order.type == OrderType.BYOD && order.byodRecipeName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Recipe: ${order.byodRecipeName}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ...order.items
                  .take(2)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            "${item.qty}x",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (order.items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "+ ${order.items.length - 2} more items",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatCurrency(order.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (order.status == OrderStatus.Pending)
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () =>
                              _updateOrderStatus(order, OrderStatus.Rejected),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text("Reject"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              _updateOrderStatus(order, OrderStatus.Accepted),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text("Accept"),
                        ),
                      ],
                    )
                  else
                    _buildCardAction(order),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardAction(Order order) {
    switch (order.status) {
      case OrderStatus.Accepted:
        return ElevatedButton(
          onPressed: () => _updateOrderStatus(order, OrderStatus.Preparing),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(0, 36),
          ),
          child: const Text("Start Preparing"),
        );
      case OrderStatus.Preparing:
        return ElevatedButton(
          onPressed: () => _updateOrderStatus(order, OrderStatus.Ready),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(0, 36),
          ),
          child: const Text("Mark Ready"),
        );
      case OrderStatus.Ready:
        return ElevatedButton(
          onPressed: () =>
              _updateOrderStatus(order, OrderStatus.OutForDelivery),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(0, 36),
          ),
          child: const Text("Out for Delivery"),
        );
      case OrderStatus.OutForDelivery:
        return ElevatedButton(
          onPressed: () => _updateOrderStatus(order, OrderStatus.Completed),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(0, 36),
          ),
          child: const Text("Complete"),
        );
      default:
        return TextButton(
          onPressed: () => _showOrderDetails(order),
          child: const Text("View Details"),
        );
    }
  }

  Widget _buildStatusBadge(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor(status).withOpacity(0.2)),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: _statusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimary, kPrimaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Orders Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Normal Orders'),
            Tab(text: 'BYOD Orders'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderList(OrderType.Normal),
            _buildOrderList(OrderType.BYOD),
            _buildOrderList(null, isCompleted: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(OrderType? type, {bool isCompleted = false}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Not logged in"));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('restaurantId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // 1. Parse all orders
        final allOrders = snapshot.data!.docs
            .map((d) => Order.fromSnapshot(d))
            .toList();

        // 2. Filter by tab type (Normal vs BYOD) and exclude old orders (older than 30 days)
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final orders = allOrders.where((o) {
          // Exclude orders older than 30 days
          if (o.createdAt.isBefore(thirtyDaysAgo)) return false;

          if (isCompleted) return o.status == OrderStatus.Completed;
          return o.type == type && o.status != OrderStatus.Completed;
        }).toList();

        // 3. Sort by date descending (Client-side to avoid index errors)
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders found',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            return _buildOrderCard(orders[i]);
          },
        );
      },
    );
  }
}
