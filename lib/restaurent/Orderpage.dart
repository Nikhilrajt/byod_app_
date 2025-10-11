import 'package:flutter/material.dart';

class Orderpage extends StatefulWidget {
  const Orderpage({super.key});

  @override
  State<Orderpage> createState() => _OrderpageState();
}

enum OrderStatus {
  Pending,
  Accepted,
  Preparing,
  Ready,
  OutForDelivery,
  Completed,
  Rejected,
}

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
  double get total => items.fold(0, (p, e) => p + e.price * e.qty);
  OrderStatus status;

  Order({
    required this.id,
    required this.customerName,
    required this.createdAt,
    required this.items,
    this.status = OrderStatus.Pending,
  });
}

class _OrderpageState extends State<Orderpage> {
  List<Order> orders = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadMockOrders();
  }

  void _loadMockOrders() {
    // In a real app you'd fetch from network / database.
    orders = [
      Order(
        id: 'ORD-1001',
        customerName: 'Alice Johnson',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        status: OrderStatus.Pending,
        items: [
          OrderItem(name: 'Classic Cheese Pizza', qty: 2, price: 8.5),
          OrderItem(name: 'Soda', qty: 2, price: 1.5),
        ],
      ),
      Order(
        id: 'ORD-1002',
        customerName: 'Mohammed Ali',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        status: OrderStatus.Preparing,
        items: [
          OrderItem(name: 'MSG Smash Burgers', qty: 1, price: 6.99),
          OrderItem(name: 'Fries', qty: 1, price: 2.5),
        ],
      ),
      Order(
        id: 'ORD-1003',
        customerName: 'Sofia R',
        createdAt: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 5),
        ),
        status: OrderStatus.OutForDelivery,
        items: [OrderItem(name: 'Veggie Plate', qty: 1, price: 7.0)],
      ),
      Order(
        id: 'ORD-1004',
        customerName: 'Guest',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: OrderStatus.Completed,
        items: [OrderItem(name: 'Family Pack', qty: 1, price: 20.0)],
      ),
    ];
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1));
    // In production re-fetch from API. Here we just keep mock data.
    setState(() => loading = false);
  }

  void _updateOrderStatus(Order order, OrderStatus next) {
    setState(() {
      order.status = next;
    });
    // In production, send update to backend here and handle failures.
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
        return 'Ready';
      case OrderStatus.OutForDelivery:
        return 'Out for delivery';
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
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          backgroundColor: _statusColor(
                            order.status,
                          ).withOpacity(0.15),
                          label: Text(
                            _statusLabel(order.status),
                            style: TextStyle(color: _statusColor(order.status)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Customer: ${order.customerName}'),
                    Text('Placed: ${order.createdAt}'),
                    const Divider(),
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...order.items.map(
                      (it) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('${it.name} x${it.qty}'),
                        trailing: Text(
                          '\$${(it.price * it.qty).toStringAsFixed(2)}',
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(spacing: 8, children: _actionButtonsFor(order)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _actionButtonsFor(Order order) {
    List<Widget> actions = [];
    switch (order.status) {
      case OrderStatus.Pending:
        actions.add(
          ElevatedButton(
            onPressed: () => _updateOrderStatus(order, OrderStatus.Accepted),
            child: const Text('Accept'),
          ),
        );
        actions.add(
          OutlinedButton(
            onPressed: () => _updateOrderStatus(order, OrderStatus.Rejected),
            child: const Text('Reject'),
          ),
        );
        break;
      case OrderStatus.Accepted:
        actions.add(
          ElevatedButton(
            onPressed: () => _updateOrderStatus(order, OrderStatus.Preparing),
            child: const Text('Mark Preparing'),
          ),
        );
        break;
      case OrderStatus.Preparing:
        actions.add(
          ElevatedButton(
            onPressed: () => _updateOrderStatus(order, OrderStatus.Ready),
            child: const Text('Mark Ready'),
          ),
        );
        break;
      case OrderStatus.Ready:
        actions.add(
          ElevatedButton(
            onPressed: () =>
                _updateOrderStatus(order, OrderStatus.OutForDelivery),
            child: const Text('Out for Delivery'),
          ),
        );
        break;
      case OrderStatus.OutForDelivery:
        actions.add(
          ElevatedButton(
            onPressed: () => _updateOrderStatus(order, OrderStatus.Completed),
            child: const Text('Complete'),
          ),
        );
        break;
      case OrderStatus.Completed:
      case OrderStatus.Rejected:
        actions.add(
          const Text('No actions', style: TextStyle(color: Colors.grey)),
        );
        break;
    }
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : orders.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No orders yet')),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                separatorBuilder: (context, i) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final order = orders[i];
                  return Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _showOrderDetails(order),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Chip(
                                  backgroundColor: _statusColor(
                                    order.status,
                                  ).withOpacity(0.12),
                                  label: Text(
                                    _statusLabel(order.status),
                                    style: TextStyle(
                                      color: _statusColor(order.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(order.customerName),
                            const SizedBox(height: 6),
                            Text(
                              '${order.items.length} item(s) • \$${order.total.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: _actionButtonsFor(order)
                                  .map(
                                    (w) => Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: w,
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
              ),
      ),
    );
  }
}
