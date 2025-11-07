import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/restaurent/Orderpage.dart' as OP;

class PendingByodRequestsPage extends StatefulWidget {
  const PendingByodRequestsPage({super.key});

  @override
  State<PendingByodRequestsPage> createState() =>
      _PendingByodRequestsPageState();
}

class _PendingByodRequestsPageState extends State<PendingByodRequestsPage> {
  List<OP.Order> orders = [];
  List<OP.Order> completedOrders = [];
  bool loading = false;

  final DateFormat _timeFormat = DateFormat('hh:mm a, MMM d');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadMockOrders();
  }

  void _loadMockOrders() {
    // Recreate the same mock orders used elsewhere but keep local to admin
    orders = [
      // Pending order — admin should see Accept/Reject
      OP.Order(
        id: 'ORD-1010',
        customerName: 'Asha Patel',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        status: OP.OrderStatus.Pending,
        type: OP.OrderType.BYOD,
        items: [
          OP.OrderItem(name: 'Glass Bottle (BYOD)', qty: 1, price: 0.00),
          OP.OrderItem(name: 'Caesar Salad', qty: 1, price: 220.00),
        ],
      ),
      // Recently accepted — next action should be Start Preparing
      OP.Order(
        id: 'ORD-1006',
        customerName: 'Rahul K',
        createdAt: DateTime.now().subtract(const Duration(minutes: 22)),
        status: OP.OrderStatus.Accepted,
        type: OP.OrderType.BYOD,
        items: [
          OP.OrderItem(name: 'Paneer Wrap (BYOD)', qty: 2, price: 140.00),
        ],
      ),
      // Preparing — next action Mark Ready
      OP.Order(
        id: 'ORD-1002',
        customerName: 'Mohammed Ali',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        status: OP.OrderStatus.Preparing,
        type: OP.OrderType.BYOD,
        items: [
          OP.OrderItem(name: 'MSG Smash Burgers (BYOD)', qty: 1, price: 380.50),
          OP.OrderItem(name: 'Fries', qty: 1, price: 150.00),
        ],
      ),
      // Ready (Packing) — next action Picked Up / Complete
      OP.Order(
        id: 'ORD-1008',
        customerName: 'Sana M',
        createdAt: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 12),
        ),
        status: OP.OrderStatus.Ready,
        type: OP.OrderType.BYOD,
        items: [
          OP.OrderItem(name: 'Grilled Sandwich (BYOD)', qty: 1, price: 180.00),
          OP.OrderItem(name: 'Orange Juice', qty: 1, price: 85.00),
        ],
      ),
      // Out for delivery — next step Complete Delivery
      OP.Order(
        id: 'ORD-1009',
        customerName: 'Vikram S',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        status: OP.OrderStatus.OutForDelivery,
        type: OP.OrderType.BYOD,
        items: [
          OP.OrderItem(name: 'Family Pack (BYOD)', qty: 1, price: 1250.00),
        ],
      ),
      // (completed orders are kept separately)
      // Rejected example
      OP.Order(
        id: 'ORD-1005',
        customerName: 'John Doe',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: OP.OrderStatus.Rejected,
        type: OP.OrderType.BYOD,
        items: [
          OP.OrderItem(name: 'Container 1 (BYOD)', qty: 3, price: 200.00),
        ],
      ),
    ];

    // Completed / historical (kept separate so pending list doesn't show them)
    completedOrders = [
      OP.Order(
        id: 'ORD-1011',
        customerName: 'Guest',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: OP.OrderStatus.Completed,
        type: OP.OrderType.BYOD,
        items: [
          OP.OrderItem(name: 'Container 1 (BYOD)', qty: 2, price: 200.00),
          OP.OrderItem(name: 'Salad', qty: 1, price: 120.00),
        ],
      ),
    ];

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {});
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    _loadMockOrders();
    setState(() => loading = false);
  }

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
    }
  }

  void _updateOrderStatus(OP.Order order, OP.OrderStatus next) {
    setState(() {
      order.status = next;
      if (next == OP.OrderStatus.Completed) {
        // move to completed list and remove from pending list
        orders.removeWhere((o) => o.id == order.id);
        completedOrders.insert(0, order);
      }
    });
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
                      child: Row(
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
                    children: _actionButtonsFor(order).take(1).toList(),
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

  List<Widget> _actionButtonsFor(OP.Order order, {bool closeOnAction = false}) {
    List<Widget> actions = [];
    switch (order.status) {
      case OP.OrderStatus.Pending:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            onPressed: () {
              _updateOrderStatus(order, OP.OrderStatus.Accepted);
              if (closeOnAction) Navigator.pop(context);
            },
            label: const Text('Accept Order'),
          ),
        );
        actions.add(
          OutlinedButton.icon(
            icon: const Icon(Icons.close),
            onPressed: () {
              _updateOrderStatus(order, OP.OrderStatus.Rejected);
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
            onPressed: () {
              _updateOrderStatus(order, OP.OrderStatus.Preparing);
              if (closeOnAction) Navigator.pop(context);
            },
            label: const Text('Start Preparing'),
          ),
        );
        break;
      case OP.OrderStatus.Preparing:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.local_dining),
            onPressed: () {
              _updateOrderStatus(order, OP.OrderStatus.Ready);
              if (closeOnAction) Navigator.pop(context);
            },
            label: const Text('Mark Ready'),
          ),
        );
        break;
      case OP.OrderStatus.Ready:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () {
              _updateOrderStatus(order, OP.OrderStatus.Completed);
              if (closeOnAction) Navigator.pop(context);
            },
            label: const Text('Mark Picked Up'),
          ),
        );
        break;
      case OP.OrderStatus.OutForDelivery:
        actions.add(
          ElevatedButton.icon(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              _updateOrderStatus(order, OP.OrderStatus.Completed);
              if (closeOnAction) Navigator.pop(context);
            },
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
    final byodOrders = orders
        .where(
          (o) =>
              o.type == OP.OrderType.BYOD &&
              o.status != OP.OrderStatus.Completed,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pending BYOD Requests')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : byodOrders.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No BYOD orders yet.')),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: byodOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final order = byodOrders[i];
                  return _buildOrderCard(order);
                },
              ),
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
              const Divider(height: 20),
              // Action buttons: show primary action only
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
  }
}
