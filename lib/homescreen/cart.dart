import 'package:flutter/material.dart';
import 'package:project/homescreen/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../state/cart_notifier.dart';
import '../models/category_models.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/order_service.dart';
import 'dart:async';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Razorpay _razorpay;
  String? _payingForOrderId;

  final Map<String, Timer> _completionTimers = {};
  void _startRazorpay(BuildContext context, List<CartItem> items, int total) {
    final options = {
      'key': 'rzp_test_RQX7adT0U42yu4',
      'amount': total * 100,
      'name': 'Food Order',
      'description': 'Restaurant Order',
    };
    _razorpay.open(options);
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_payingForOrderId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('approval_requests')
          .doc(_payingForOrderId)
          .get();
      if (doc.exists) {
        await _finalizeApprovedOrder(
          _payingForOrderId!,
          doc.data() as Map<String, dynamic>,
          'Online',
          'paid',
        );
      }
      if (_payingForOrderId == 'CART_CHECKOUT') {
        await _placeNormalOrder('Online', 'paid');
      }

      if (mounted) setState(() => _payingForOrderId = null);
    }
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
    _completionTimers.forEach((_, t) => t.cancel());
    _completionTimers.clear();
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _finalizeApprovedOrder(
    String requestId,
    Map<String, dynamic> data,
    String paymentMethod,
    String paymentStatus,
  ) async {
    try {
      final itemsList = (data['items'] as List)
          .map((i) => CartItem.fromJson(i))
          .toList();
      final total = data['totalAmount'];
      final restaurantId = data['restaurantId'];
      final orderType = data['orderType'] ?? 'Normal';

      final existingOrderId = data['orderId'] as String?;

      if (existingOrderId != null && existingOrderId.isNotEmpty) {
        // Order was already created when the user submitted the BYOD request.
        // Just update payment details on the existing order.
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(existingOrderId)
            .update({
              'paymentMethod': paymentMethod,
              'paymentStatus': paymentStatus,
            });
      } else {
        // No existing order, create one now
        final placedOrderId = await OrderService().placeOrder(
          restaurantId: restaurantId,
          items: itemsList,
          totalAmount: total,
          paymentMethod: paymentMethod,
          paymentStatus: paymentStatus,
          orderType: orderType,
        );
        // placedOrderId is available if needed for debugging or follow-up actions.
      }

      await FirebaseFirestore.instance
          .collection('approval_requests')
          .doc(requestId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
    }
  }

  Future<void> _cancelApproval(QueryDocumentSnapshot doc) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final approvalRef = FirebaseFirestore.instance
        .collection('approval_requests')
        .doc(doc.id);
    final data = doc.data() as Map<String, dynamic>;
    final orderId = (data['orderId'] as String?) ?? '';

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        // Read approval request first
        final approvalSnap = await tx.get(approvalRef);
        if (!approvalSnap.exists) {
          throw Exception('Request not found');
        }

        final currentStatus = (approvalSnap.get('status') ?? 'pending')
            .toString()
            .toLowerCase();
        if (currentStatus != 'pending') {
          throw Exception('Cannot cancel; current status: $currentStatus');
        }

        // Pre-read restaurant order doc (if any) BEFORE doing any writes
        final restaurantId =
            (approvalSnap.data() as Map<String, dynamic>?)?['restaurantId']
                as String? ??
            '';
        DocumentSnapshot? restSnap;
        var restOrderRef;
        if (restaurantId.isNotEmpty && orderId.isNotEmpty) {
          restOrderRef = FirebaseFirestore.instance
              .collection('restaurants')
              .doc(restaurantId)
              .collection('orders')
              .doc(orderId);
          restSnap = await tx.get(restOrderRef);
        }

        // All reads complete - now perform updates
        tx.update(approvalRef, {
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });

        if (orderId.isNotEmpty) {
          final orderRef = FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId);
          // Update both 'orderStatus' and 'status' for compatibility across UI pages
          tx.update(orderRef, {
            'orderStatus': 'cancelled',
            'status': 'cancelled',
            'cancelledBy': user.uid,
            'cancelledAt': FieldValue.serverTimestamp(),
          });

          // Ensure the restaurant's copy exists and reflects cancellation.
          // Use set(merge: true) to create or update safely.
          final restaurantId =
              (approvalSnap.data() as Map<String, dynamic>?)?['restaurantId']
                  as String? ??
              '';
          if (restaurantId.isNotEmpty) {
            final restOrderRef = FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurantId)
                .collection('orders')
                .doc(orderId);
            tx.set(restOrderRef, {
              'orderStatus': 'cancelled',
              'status': 'cancelled',
              'cancelledBy': user.uid,
              'cancelledAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request cancelled')));
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to cancel: $e')));
      }
    }
  }

  Future<void> _deleteApproval(QueryDocumentSnapshot doc) async {
    try {
      await FirebaseFirestore.instance
          .collection('approval_requests')
          .doc(doc.id)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Approval removed')));
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Future<void> _placeNormalOrder(
    String paymentMethod,
    String paymentStatus,
  ) async {
    final cart = context.read<CartNotifier>();
    final items = cart.items;
    if (items.isEmpty) return;

    final total = items.fold(0, (sum, item) => sum + item.totalPrice);
    final restaurantId = items.first.restaurantId;

    if (restaurantId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Restaurant ID is missing')),
      );
      return;
    }

    try {
      final placedOrderId = await OrderService().placeOrder(
        restaurantId: restaurantId,
        items: items,
        totalAmount: total,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        orderType: 'Normal',
      );
      // placedOrderId available if needed for follow-up actions.

      cart.clearCart();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
    }
  }

  Future<void> _submitForApproval(
    BuildContext context,
    List<CartItem> items,
    int total,
  ) async {
    if (items.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Place BYOD order directly into `orders` so it appears immediately
      // in the restaurant's BYOD orders list (skip approval requests).
      // First, create the order so restaurants see it immediately
      final placedOrderId = await OrderService().placeOrder(
        restaurantId: items.first.restaurantId,
        items: items,
        totalAmount: total,
        paymentMethod: 'COD',
        paymentStatus: 'pending',
        orderType: 'byod',
      );

      try {
        // Create an approval request for the user UI (Pending Approval box)
        final ref = FirebaseFirestore.instance
            .collection('approval_requests')
            .doc();
        await ref.set({
          'requestId': ref.id,
          'orderId': placedOrderId,
          'userId': user.uid,
          'restaurantName': items.first.restaurantName,
          'restaurantId': items.first.restaurantId,
          'orderType': 'byod',
          'items': items.map((e) => e.toJson()).toList(),
          'totalAmount': total,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context); // close progress dialog
        context.read<CartNotifier>().clearCart();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent for approval')),
        );

        // Return to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        // If approval doc creation fails, roll back the previously created order
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(placedOrderId)
            .delete();
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending request: $e')));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              context.read<CartNotifier>().clearCart();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPendingApprovalSection(),
            Expanded(
              child: Consumer<CartNotifier>(
                builder: (_, cart, __) {
                  final items = cart.items;
                  if (items.isEmpty) {
                    return SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 20),
                          const Text('Your cart is empty'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CategoryPage(
                                  categoryId: '',
                                  categoryName: '',
                                ),
                              ),
                            ),
                            child: const Text('Browse Menu'),
                          ),
                        ],
                      ),
                    );
                  }

                  final total = items.fold(
                    0,
                    (sum, item) => sum + item.totalPrice,
                  );

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            MediaQuery.of(context).padding.bottom + 88,
                          ),
                          itemCount: items.length,
                          itemBuilder: (_, i) =>
                              _buildCartItem(context, items[i], i, cart),
                        ),
                      ),
                      _buildBottomSection(context, items, total),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    int index,
    CartNotifier cart,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.restaurantName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                if (item.quantity > 1) {
                                  cart.updateQuantity(index, item.quantity - 1);
                                } else {
                                  cart.removeFromCart(index);
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Icon(Icons.remove, size: 16),
                              ),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                cart.updateQuantity(index, item.quantity + 1);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Icon(Icons.add, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    List<CartItem> items,
    int total,
  ) {
    final isByod = items.any((item) => item.isByod);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '₹$total',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => isByod
                    ? _submitForApproval(context, items, total)
                    : _showPaymentOptionsForNormalOrder(context, total),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  isByod ? 'Submit for Approval' : 'Checkout',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentOptionsForNormalOrder(BuildContext context, int total) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.blue),
                title: const Text('Pay Online'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _payingForOrderId = 'CART_CHECKOUT');
                  _startRazorpay(context, [], total);
                },
              ),
              ListTile(
                leading: const Icon(Icons.money, color: Colors.green),
                title: const Text('Cash on Delivery'),
                onTap: () => _placeNormalOrder('COD', 'pending'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingApprovalSection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('approval_requests')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (_, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        // Filter client-side so transient case/value mismatches don't remove the doc
        // Also ignore any dummy/placeholder documents (missing required data)
        final now = DateTime.now();
        final docs = snapshot.data!.docs.where((d) {
          final data = d.data() as Map<String, dynamic>;

          // Basic validity checks - reject dummy documents
          final orderId = (data['orderId'] as String?) ?? '';
          final restaurantId = (data['restaurantId'] as String?) ?? '';
          final itemsList = data['items'] as List?;
          final isDummy = data['isDummy'] as bool? ?? false;

          if (isDummy) return false;
          if (orderId.isEmpty || restaurantId.isEmpty) return false;
          if (itemsList == null || itemsList.isEmpty) return false;

          final status = (data['status'] ?? 'pending').toString().toLowerCase();

          if (status == 'completed') {
            // only show completed if it happened recently (within 5 seconds)
            final completedTs = data['completedAt'] as Timestamp?;
            if (completedTs == null) return false;
            final completedAt = completedTs.toDate();
            final elapsed = now.difference(completedAt);
            return elapsed.inMilliseconds <= 5000;
          }

          if (status == 'cancelled') {
            // only show cancelled if it happened recently (within 5 seconds)
            final cancelledTs = data['cancelledAt'] as Timestamp?;
            if (cancelledTs == null) return false;
            final cancelledAt = cancelledTs.toDate();
            final elapsed = now.difference(cancelledAt);
            return elapsed.inMilliseconds <= 5000;
          }

          return [
            'pending',
            'accepted',
            'preparing',
            'ready',
            'outfordelivery',
          ].contains(status);
        }).toList();

        if (docs.isEmpty) return const SizedBox.shrink();

        // Schedule timers to refresh the UI when a completed item expires
        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>;
          final status = (data['status'] ?? 'pending').toString().toLowerCase();
          if (status == 'completed') {
            final completedTs = data['completedAt'] as Timestamp?;
            if (completedTs != null) {
              final completedAt = completedTs.toDate();
              final elapsed = now.difference(completedAt);
              final remaining = Duration(milliseconds: 5000) - elapsed;
              if (remaining.inMilliseconds > 0) {
                final id = d.id;
                // avoid scheduling duplicate timers
                if (!_completionTimers.containsKey(id)) {
                  _completionTimers[id] = Timer(
                    remaining + const Duration(milliseconds: 100),
                    () {
                      _completionTimers.remove(id)?.cancel();
                      if (mounted) setState(() {});
                    },
                  );
                }
              }
            }
          }

          if (status == 'cancelled') {
            final cancelledTs = data['cancelledAt'] as Timestamp?;
            if (cancelledTs != null) {
              final cancelledAt = cancelledTs.toDate();
              final elapsed = now.difference(cancelledAt);
              final remaining = Duration(milliseconds: 5000) - elapsed;
              if (remaining.inMilliseconds > 0) {
                final id = d.id;
                if (!_completionTimers.containsKey(id)) {
                  _completionTimers[id] = Timer(
                    remaining + const Duration(milliseconds: 100),
                    () {
                      _completionTimers.remove(id)?.cancel();
                      if (mounted) setState(() {});
                    },
                  );
                }
              }
            }
          }
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          constraints: const BoxConstraints(maxHeight: 260),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Approval',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final orderId = (data['orderId'] as String?) ?? '';

                  // Only render approvals that have a real linked order document
                  return FutureBuilder<DocumentSnapshot>(
                    future: orderId.isNotEmpty
                        ? FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .get()
                        : Future.value(null),
                    builder: (context, orderSnap) {
                      if (!orderSnap.hasData ||
                          orderSnap.data == null ||
                          !orderSnap.data!.exists) {
                        // linked order missing - don't show this (dummy) approval
                        return const SizedBox.shrink();
                      }

                      final status = (data['status'] ?? 'pending')
                          .toString()
                          .toLowerCase();
                      String badgeLabel;
                      Color badgeColor = Colors.orange;

                      if (status == 'outfordelivery') {
                        badgeLabel = 'Reaching';
                        badgeColor = Colors.orange;
                      } else if (status == 'ready') {
                        badgeLabel = 'Ready';
                        badgeColor = Colors.green;
                      } else if (status == 'completed') {
                        badgeLabel = 'Reached successfully';
                        badgeColor = Colors.green;
                      } else if (status == 'cancelled') {
                        badgeLabel = 'Cancelled';
                        badgeColor = Colors.red;
                      } else {
                        badgeLabel = status.isNotEmpty
                            ? status[0].toUpperCase() + status.substring(1)
                            : 'Pending';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Request to ${data['restaurantName']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text('Total: ₹${data['totalAmount']}'),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    badgeLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Action buttons: Cancel (when pending) and Delete (manual cleanup)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (status == 'pending')
                                  TextButton.icon(
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Cancel request'),
                                          content: const Text(
                                            'Are you sure you want to cancel this request?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        _cancelApproval(doc);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),

                                // Manual delete button (for removing default/dummy approvals)
                                if ([
                                  'pending',
                                  'ready',
                                  'cancelled',
                                  'rejected',
                                  'awaitingapproval',
                                  'pendingpayment',
                                ].contains(status))
                                  TextButton.icon(
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete approval'),
                                          content: const Text(
                                            'This will permanently remove this approval request from your cart. Proceed?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        _deleteApproval(doc);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildCompletedApprovalsSection() {
  // Completed approvals are not shown in cart per product requirement.
  return const SizedBox.shrink();
}
