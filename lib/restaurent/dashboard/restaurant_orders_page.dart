// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// import 'package:project/restaurent/setting/restaurant_profile_page.dart';

// class RestaurantOrdersPage extends StatelessWidget {
//   const RestaurantOrdersPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     final restaurantId = user?.uid;

//     if (restaurantId == null) {
//       return const Scaffold(body: Center(child: Text("Not logged in")));
//     }

//     print(
//       "RestaurantOrdersPage: Querying orders for Restaurant ID: $restaurantId",
//     ); // Debug log

//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Incoming Orders"),
//             Text("ID: $restaurantId", style: const TextStyle(fontSize: 10)),
//           ],
//         ),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const RestaurantProfilePage(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('orders')
//             .where('restaurantId', isEqualTo: restaurantId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             print("Firestore Error: ${snapshot.error}"); // Debug log
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData) {
//             print("No data in snapshot"); // Debug log
//             return const Center(child: Text("No orders found"));
//           }

//           // Create a modifiable list of all orders (removed BYOD filter)
//           final orders = List<QueryDocumentSnapshot>.from(snapshot.data!.docs);

//           // Sort by createdAt descending (client-side to avoid index requirement)
//           orders.sort((a, b) {
//             final aData = a.data() as Map<String, dynamic>;
//             final bData = b.data() as Map<String, dynamic>;
//             final aTime = aData['createdAt'] as Timestamp?;
//             final bTime = bData['createdAt'] as Timestamp?;
//             if (aTime == null && bTime == null) return 0;
//             if (aTime == null) return 1;
//             if (bTime == null) return -1;
//             return bTime.compareTo(aTime);
//           });

//           print("Loaded ${orders.length} orders"); // Debug log

//           if (orders.isEmpty) {
//             return const Center(child: Text("No orders yet"));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: orders.length,
//             itemBuilder: (context, index) {
//               final order = orders[index];
//               return _RestaurantOrderCard(order: order);
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class _RestaurantOrderCard extends StatefulWidget {
//   final QueryDocumentSnapshot order;

//   const _RestaurantOrderCard({required this.order});

//   @override
//   State<_RestaurantOrderCard> createState() => _RestaurantOrderCardState();
// }

// class _RestaurantOrderCardState extends State<_RestaurantOrderCard> {
//   bool _isLoading = false;

//   final DateFormat _timeFormat = DateFormat('hh:mm a, MMM d');
//   final NumberFormat _currencyFormat = NumberFormat.currency(
//     locale: 'en_IN',
//     symbol: '₹',
//     decimalDigits: 2,
//   );

//   Color _getStatusColor(String status) {
//     switch (status.trim().toLowerCase()) {
//       case 'pending':
//       case 'placed':
//       case 'paid':
//         return Colors.orange;
//       case 'accepted':
//         return Colors.lightBlue;
//       case 'preparing':
//         return Colors.blue;
//       case 'ready':
//         return Colors.green;
//       case 'out for delivery':
//         return Colors.teal;
//       case 'completed':
//         return Colors.grey;
//       case 'rejected':
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _getStatusLabel(String status) {
//     final s = status.trim().toLowerCase();
//     switch (s) {
//       case 'pending':
//       case 'placed':
//       case 'paid':
//         return 'Pending';
//       case 'accepted':
//         return 'Accepted';
//       case 'preparing':
//         return 'Preparing';
//       case 'ready':
//         return 'Ready for Pickup';
//       case 'out for delivery':
//         return 'Out for Delivery';
//       case 'completed':
//         return 'Completed';
//       case 'rejected':
//       case 'cancelled':
//         return 'Rejected';
//       default:
//         return status.toUpperCase();
//     }
//   }

//   Future<void> _updateStatus(String newStatus) async {
//     setState(() => _isLoading = true);
//     try {
//       // Update both 'status' and 'orderStatus' to ensure compatibility across the app
//       await widget.order.reference.update({
//         'status': newStatus,
//         'orderStatus': newStatus,
//       });
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showOrderDetails(Map<String, dynamic> data, String orderId) {
//     final items = (data['items'] as List<dynamic>? ?? []);
//     final status = data['orderStatus'] ?? data['status'] ?? 'Pending';
//     final total = data['totalAmount'] ?? 0.0;
//     final timestamp = data['createdAt'] as Timestamp?;
//     log('${data['restaurantId']} -------------');

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         expand: false,
//         initialChildSize: 0.6,
//         minChildSize: 0.3,
//         maxChildSize: 0.95,
//         builder: (context, scrollController) {
//           return Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//             ),
//             padding: const EdgeInsets.only(top: 16),
//             child: SingleChildScrollView(
//               controller: scrollController,
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Order $orderId',
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Chip(
//                         backgroundColor: _getStatusColor(
//                           status,
//                         ).withOpacity(0.15),
//                         label: Text(
//                           _getStatusLabel(status),
//                           style: TextStyle(
//                             color: _getStatusColor(status),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Placed: ${timestamp != null ? _timeFormat.format(timestamp.toDate()) : 'Unknown'}',
//                   ),
//                   const Divider(height: 24),
//                   const Text(
//                     'Items Ordered',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   ...items.map((item) {
//                     final itemMap = item as Map<String, dynamic>;
//                     final price = itemMap['price'] ?? 0;
//                     final qty = itemMap['quantity'] ?? 1;
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Flexible(
//                             child: Text(
//                               '${itemMap['name']} x$qty',
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           ),
//                           Text(
//                             _currencyFormat.format(price * qty),
//                             style: const TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                   const Divider(height: 24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Total',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         _currencyFormat.format(total),
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.deepPurple,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: _buildActionButtons(status, closeOnAction: true),
//                   ),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildStatusProgress(String currentStatus) {
//     final steps = [
//       'pending',
//       'accepted',
//       'preparing',
//       'ready',
//       'out for delivery',
//       'completed',
//     ];

//     // Normalize status for comparison
//     String status = currentStatus.trim().toLowerCase();
//     if (status == 'placed' || status == 'paid') status = 'pending';

//     int currentIndex = steps.indexOf(status);
//     if (currentIndex == -1 && (status == 'rejected' || status == 'cancelled')) {
//       return const Text(
//         "Order Rejected",
//         style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//       );
//     }

//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: List.generate(steps.length, (i) {
//           final s = steps[i];
//           final done = i <= currentIndex;
//           return Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: Chip(
//               backgroundColor:
//                   (done ? _getStatusColor(s) : Colors.grey.shade200)
//                       .withOpacity(done ? 0.18 : 1.0),
//               label: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (done)
//                     Icon(
//                       Icons.check_circle,
//                       size: 14,
//                       color: _getStatusColor(s),
//                     )
//                   else
//                     const Icon(
//                       Icons.radio_button_unchecked,
//                       size: 14,
//                       color: Colors.grey,
//                     ),
//                   const SizedBox(width: 6),
//                   Text(
//                     s == 'ready' ? 'Packing' : _getStatusLabel(s),
//                     style: TextStyle(
//                       color: done ? _getStatusColor(s) : Colors.grey.shade700,
//                       fontWeight: done ? FontWeight.bold : FontWeight.normal,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildOrderItem(Map<String, dynamic> itemMap) {
//     final isHealthy = itemMap['isHealthy'] == true;
//     final imageUrl = itemMap['imageUrl'] ?? '';
//     final name = itemMap['name'] ?? 'Unknown';
//     final quantity = itemMap['quantity'] ?? 1;
//     final price = itemMap['price'] ?? 0;
//     final customizations = itemMap['customizations'] as List<dynamic>?;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   imageUrl,
//                   width: 50,
//                   height: 50,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     width: 50,
//                     height: 50,
//                     color: Colors.grey[200],
//                     child: const Icon(
//                       Icons.fastfood,
//                       color: Colors.grey,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ),
//               if (isHealthy)
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: Container(
//                     padding: const EdgeInsets.all(2),
//                     decoration: const BoxDecoration(
//                       color: Colors.green,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.spa, size: 8, color: Colors.white),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(width: 12),
//           // Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                   ),
//                 ),
//                 if (customizations != null && customizations.isNotEmpty)
//                   Text(
//                     customizations.join(', '),
//                     style: TextStyle(fontSize: 11, color: Colors.grey[600]),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "x$quantity • ${_currencyFormat.format(price)}",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[800],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Item Total
//           Text(
//             _currencyFormat.format(price * quantity),
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final data = widget.order.data() as Map<String, dynamic>;
//     final status = data['orderStatus'] ?? data['status'] ?? 'Pending';
//     final items = (data['items'] as List<dynamic>? ?? []);
//     final total = data['totalAmount'] ?? 0.0;
//     final timestamp = data['createdAt'] as Timestamp?;

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: InkWell(
//         onTap: () => _showOrderDetails(data, widget.order.id),
//         borderRadius: BorderRadius.circular(10),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     widget.order.id.substring(0, 8).toUpperCase(), // Short ID
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w900,
//                       fontSize: 16,
//                       color: Colors.deepPurple,
//                     ),
//                   ),
//                   Chip(
//                     visualDensity: VisualDensity.compact,
//                     backgroundColor: _getStatusColor(status).withOpacity(0.12),
//                     label: Text(
//                       _getStatusLabel(status),
//                       style: TextStyle(
//                         color: _getStatusColor(status),
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Customer • ${timestamp != null ? _timeFormat.format(timestamp.toDate()) : 'Unknown'}',
//                 style: const TextStyle(color: Colors.grey, fontSize: 13),
//               ),
//               const SizedBox(height: 8),
//               const Divider(),
//               ...items.map((it) => _buildOrderItem(it as Map<String, dynamic>)),
//               const Divider(),
//               const SizedBox(height: 8),
//               Text(
//                 '${items.length} item(s) • Total: ${_currencyFormat.format(total)}',
//                 style: const TextStyle(fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 8),
//               _buildStatusProgress(status),
//               const Divider(height: 20),
//               // Action buttons: show primary action only
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: _buildActionButtons(status)
//                     .take(1)
//                     .map(
//                       (w) => Padding(
//                         padding: const EdgeInsets.only(left: 8.0),
//                         child: FittedBox(child: w),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildActionButtons(
//     String currentStatus, {
//     bool closeOnAction = false,
//   }) {
//     List<Widget> actions = [];
//     final statusLower = currentStatus.trim().toLowerCase();

//     if (statusLower == 'pending' ||
//         statusLower == 'placed' ||
//         statusLower == 'paid') {
//       actions.add(
//         ElevatedButton.icon(
//           icon: const Icon(Icons.check),
//           onPressed: _isLoading
//               ? null
//               : () {
//                   _updateStatus('Accepted');
//                   if (closeOnAction) Navigator.pop(context);
//                 },
//           label: const Text('Accept Order'),
//         ),
//       );
//       actions.add(
//         OutlinedButton.icon(
//           icon: const Icon(Icons.close),
//           onPressed: _isLoading
//               ? null
//               : () {
//                   _updateStatus('Rejected');
//                   if (closeOnAction) Navigator.pop(context);
//                 },
//           label: const Text('Reject'),
//           style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
//         ),
//       );
//     } else if (statusLower == 'accepted') {
//       actions.add(
//         ElevatedButton.icon(
//           icon: const Icon(Icons.kitchen),
//           onPressed: _isLoading
//               ? null
//               : () {
//                   _updateStatus('Preparing');
//                   if (closeOnAction) Navigator.pop(context);
//                 },
//           label: const Text('Start Preparing'),
//         ),
//       );
//     } else if (statusLower == 'preparing') {
//       actions.add(
//         ElevatedButton.icon(
//           icon: const Icon(Icons.local_dining),
//           onPressed: _isLoading
//               ? null
//               : () {
//                   _updateStatus('Ready');
//                   if (closeOnAction) Navigator.pop(context);
//                 },
//           label: const Text('Mark Ready'),
//         ),
//       );
//     } else if (statusLower == 'ready') {
//       actions.add(
//         ElevatedButton.icon(
//           icon: const Icon(Icons.delivery_dining),
//           onPressed: _isLoading
//               ? null
//               : () {
//                   _updateStatus('Out for Delivery');
//                   if (closeOnAction) Navigator.pop(context);
//                 },
//           label: const Text('Out for Delivery'),
//         ),
//       );
//     } else if (statusLower == 'out for delivery') {
//       actions.add(
//         ElevatedButton.icon(
//           icon: const Icon(Icons.done_all),
//           onPressed: _isLoading
//               ? null
//               : () {
//                   _updateStatus('Completed');
//                   if (closeOnAction) Navigator.pop(context);
//                 },
//           label: const Text('Complete Order'),
//         ),
//       );
//     }

//     return actions;
//   }
// }
