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
      status: _parseStatus(data['orderStatus']),
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
  }

  String _formatCurrency(double amount) => _currencyFormat.format(amount);

  void _updateOrderStatus(Order order, OrderStatus next) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('orders').doc(order.id).update({
        'orderStatus': next.name.toLowerCase(),
      });
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

  Widget _buildByodDetails(Order order) {
    if (order.type != OrderType.BYOD || order.byodRecipeName == null) {
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
        contentWidget = content != null
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
        contentWidget = content != null
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
          Row(
            children: [
              const Icon(Icons.menu_book, color: Colors.deepOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Recipe: ${order.byodRecipeName}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Instructions / Content:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          contentWidget,
        ],
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

        // 2. Filter by tab type (Normal vs BYOD)
        final orders = allOrders.where((o) {
          if (isCompleted) return o.status == OrderStatus.Completed;
          return o.type == type && o.status != OrderStatus.Completed;
        }).toList();

        // 3. Sort by date descending (Client-side to avoid index errors)
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (orders.isEmpty) {
          return const Center(
            child: Text(
              'No orders found',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final order = orders[i];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order #${order.id.substring(0, 5).toUpperCase()}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kPrimary,
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
                    const SizedBox(height: 6),
                    Text(
                      '${order.customerName} • ${_timeFormat.format(order.createdAt)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Divider(height: 24),
                    _buildByodDetails(order),
                    ...order.items.map((item) => _buildOrderItem(item)),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatCurrency(order.total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: kPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildActionButtons(order),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
