import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Manager',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.deepPurple,
            side: const BorderSide(color: Colors.deepPurple),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const Orderpage(),
    );
  }
}

// --- Data Models ---

enum OrderStatus {
  Pending,
  Accepted,
  Preparing,
  Ready,
  OutForDelivery,
  Completed,
  Rejected,
}

enum OrderType { Normal, BYOD }

class OrderItem {
  final String name;
  final int qty;
  final double price;

  OrderItem({required this.name, required this.qty, required this.price});
}

class Order {
  final String id;
  final String customerName;
  final DateTime createdAt;
  final List<OrderItem> items;
  final OrderType type;

  double get total => items.fold(0, (p, e) => p + e.price * e.qty);
  OrderStatus status;

  Order({
    required this.id,
    required this.customerName,
    required this.createdAt,
    required this.items,
    required this.type,
    this.status = OrderStatus.Pending,
  });
}

// --- Order Page Widget ---

class Orderpage extends StatefulWidget {
  const Orderpage({super.key});

  @override
  State<Orderpage> createState() => _OrderpageState();
}

class _OrderpageState extends State<Orderpage>
    with SingleTickerProviderStateMixin {
  List<Order> orders = [];
  bool loading = false;

  // Currency and Date Formatters
  final DateFormat _timeFormat = DateFormat('hh:mm a, MMM d');

  // ⭐ CHANGE 1: Use NumberFormat for Indian Rupee (₹) formatting.
  // 'en_IN' locale provides the correct comma grouping (lakhs, crores).
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹', // Indian Rupee Symbol
    decimalDigits: 2,
  );

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadMockOrders();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper to format currency
  String _formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  void _loadMockOrders() {
    // Note: The prices are kept as doubles, assuming they now represent Rupees.
    orders = [
      Order(
        id: 'ORD-1001',
        customerName: 'Alice Johnson',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        status: OrderStatus.Pending,
        type: OrderType.Normal,
        items: [
          OrderItem(
            name: 'Classic Cheese Pizza',
            qty: 2,
            price: 550.00,
          ), // Example: ₹550
          OrderItem(name: 'Soda', qty: 2, price: 65.00), // Example: ₹65
        ],
      ),
      Order(
        id: 'ORD-1002',
        customerName: 'Mohammed Ali',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        status: OrderStatus.Preparing,
        type: OrderType.BYOD,
        items: [
          OrderItem(
            name: 'MSG Smash Burgers (BYOD)',
            qty: 1,
            price: 380.50,
          ), // Example: ₹380.50
          OrderItem(name: 'Fries', qty: 1, price: 150.00),
        ],
      ),
      Order(
        id: 'ORD-1003',
        customerName: 'Sofia R',
        createdAt: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 5),
        ),
        status: OrderStatus.OutForDelivery,
        type: OrderType.Normal,
        items: [OrderItem(name: 'Veggie Plate', qty: 1, price: 420.75)],
      ),
      Order(
        id: 'ORD-1004',
        customerName: 'Guest',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: OrderStatus.Completed,
        type: OrderType.Normal,
        items: [
          OrderItem(name: 'Family Pack', qty: 1, price: 1250.00),
        ], // Example: ₹1,250
      ),
      Order(
        id: 'ORD-1005',
        customerName: 'John Doe',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: OrderStatus.Rejected,
        type: OrderType.BYOD,
        items: [OrderItem(name: 'Container 1 (BYOD)', qty: 3, price: 200.00)],
      ),
    ];
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loadMockOrders();
      loading = false;
    });
  }

  // ... (Other status and action methods remain the same)
  void _updateOrderStatus(Order order, OrderStatus next) {
    setState(() {
      order.status = next;
    });
    // In production, send update to backend here.
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
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
    }
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
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
    }
  }

  void _showOrderDetails(Order order) {
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '${it.name} x${it.qty}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          // ⭐ CHANGE 2: Used _formatCurrency helper for item total
                          Text(
                            _formatCurrency(it.price * it.qty),
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
                      // ⭐ CHANGE 3: Used _formatCurrency helper for grand total
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
                    children: _actionButtonsFor(order),
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

  List<Widget> _actionButtonsFor(Order order) {
    // ... (This method remains the same as it handles logic, not display)
    List<Widget> actions = [];
    switch (order.status) {
      case OrderStatus.Pending:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            onPressed: () {
              _updateOrderStatus(order, OrderStatus.Accepted);
              Navigator.pop(context);
            },
            label: const Text('Accept Order'),
          ),
        );
        actions.add(
          OutlinedButton.icon(
            icon: const Icon(Icons.close),
            onPressed: () {
              _updateOrderStatus(order, OrderStatus.Rejected);
              Navigator.pop(context);
            },
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        );
        break;
      case OrderStatus.Accepted:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.kitchen),
            onPressed: () => _updateOrderStatus(order, OrderStatus.Preparing),
            label: const Text('Start Preparing'),
          ),
        );
        break;
      case OrderStatus.Preparing:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.local_dining),
            onPressed: () => _updateOrderStatus(order, OrderStatus.Ready),
            label: const Text('Mark Ready'),
          ),
        );
        break;
      case OrderStatus.Ready:
        actions.add(
          order.type == OrderType.Normal
              ? ElevatedButton.icon(
                  icon: const Icon(Icons.delivery_dining),
                  onPressed: () =>
                      _updateOrderStatus(order, OrderStatus.OutForDelivery),
                  label: const Text('Out for Delivery'),
                )
              : ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_bag),
                  onPressed: () =>
                      _updateOrderStatus(order, OrderStatus.Completed),
                  label: const Text('Mark Picked Up'),
                ),
        );
        break;
      case OrderStatus.OutForDelivery:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.done_all),
            onPressed: () => _updateOrderStatus(order, OrderStatus.Completed),
            label: const Text('Complete Delivery'),
          ),
        );
        break;
      case OrderStatus.Completed:
      case OrderStatus.Rejected:
        actions.add(
          const Text(
            'No further actions available for this status.',
            style: TextStyle(color: Colors.grey),
          ),
        );
        break;
    }
    return actions;
  }

  Widget _buildOrderList(OrderType type) {
    final filteredOrders = orders.where((order) => order.type == type).toList();

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredOrders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              'No ${type.name} orders yet! Pull down to refresh.',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: filteredOrders.length,
      separatorBuilder: (context, i) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final order = filteredOrders[i];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
                  const SizedBox(height: 6),
                  // ⭐ CHANGE 4: Used _formatCurrency for total display in the list item
                  Text(
                    '${order.items.length} item(s) • Total: ${_formatCurrency(order.total)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _actionButtonsFor(order)
                        .take(1)
                        .map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: FittedBox(child: w),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Normal Orders'),
            Tab(text: 'BYOD Orders'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderList(OrderType.Normal),
            _buildOrderList(OrderType.BYOD),
          ],
        ),
      ),
    );
  }
}
