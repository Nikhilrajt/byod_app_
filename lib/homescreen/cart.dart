import 'package:flutter/material.dart';
import 'package:project/homescreen/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../state/cart_notifier.dart';
import '../models/category_models.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/order_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Razorpay _razorpay;
  String? _payingForOrderId;

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
      final orderType = data['orderType'] ?? 'normal';

      await OrderService().placeOrder(
        restaurantId: restaurantId,
        items: itemsList,
        totalAmount: total,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        orderType: orderType,
      );

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

  Future<void> _placeNormalOrder(
      String paymentMethod, String paymentStatus) async {
    final cart = context.read<CartNotifier>();
    final items = cart.items;
    if (items.isEmpty) return;

    final total = items.fold(0, (sum, item) => sum + item.totalPrice);
    final restaurantId = items.first.restaurantId;

    try {
      await OrderService().placeOrder(
        restaurantId: restaurantId,
        items: items,
        totalAmount: total,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        orderType: 'normal',
      );

      cart.clearCart();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error placing order: $e')));
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
      final ref = FirebaseFirestore.instance
          .collection('approval_requests')
          .doc();

      await ref.set({
        'requestId': ref.id,
        'userId': user.uid,
        'restaurantName': items.first.restaurantName,
        'restaurantId': items.first.restaurantId,
        'orderType': 'byod',
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': total,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      context.read<CartNotifier>().clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent for approval')),
      );

      /// 🔥 REQUIRED: GO BACK TO HOME
      Navigator.of(context).popUntil((route) => route.isFirst);
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
      body: Column(
        children: [
          _buildApprovedOrdersSection(),
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
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (_, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
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
                ...snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Pending',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Delete/Cancel Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('approval_requests')
                                    .doc(doc.id)
                                    .delete();
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
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApprovedOrdersSection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('approval_requests')
          .where('userId', isEqualTo: user.uid)
          .where(
            'status',
            whereIn: ['approved', 'accepted', 'Approved', 'Accepted'],
          )
          .snapshots(),
      builder: (_, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Approved Orders - Ready to Pay',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
            ),
            ...snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _buildApprovedOrderCard(doc.id, data);
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildApprovedOrderCard(String requestId, Map<String, dynamic> data) {
    final total = data['totalAmount'];
    final isByod = data['orderType'] == 'byod';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${data['orderType'] == 'byod' ? 'BYOD ' : ''}Order from ${data['restaurantName']}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text('Total Amount: ₹$total'),
          const SizedBox(height: 16),
          const Text(
            'Select Payment Method:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (!isByod) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _payingForOrderId = requestId);
                      _startRazorpay(context, [], total);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pay Online'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _finalizeApprovedOrder(requestId, data, 'COD', 'pending');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cash on Delivery'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
