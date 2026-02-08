import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Delivery extends StatefulWidget {
  final String? orderId;
  const Delivery({super.key, this.orderId});

  @override
  State<Delivery> createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  int _getStatusStep(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
      case 'orderplaced':
      case 'pending':
      case 'pendingpayment':
        return 1;
      case 'confirmed':
      case 'orderconfirmed':
      case 'accepted':
        return 2;
      case 'preparing':
      case 'ready':
        return 3;
      case 'out_for_delivery':
      case 'outfordelivery':
        return 4;
      case 'delivered':
      case 'completed':
        return 6;
      case 'cancelled':
      case 'rejected':
        return 0;
      default:
        return 1;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orderId == null) {
      return const Scaffold(body: Center(child: Text("No Order ID provided")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Order Tracking',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId!)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status']?.toString() ?? 'placed';
          final currentStep = _getStatusStep(status);
          final estimatedTime = data['estimatedTime'] ?? 'Calculating...';
          final driverName = data['driverName'] ?? 'Assigning...';
          final driverPhone = data['driverPhone'];

          // Extract food details
          final items = (data['items'] as List<dynamic>?) ?? [];
          String foodName = 'Unknown Item';
          String foodImageUrl = '';
          if (items.isNotEmpty) {
            final firstItem = items.first as Map<String, dynamic>;
            foodName = firstItem['name'] ?? 'Unknown Item';
            foodImageUrl = firstItem['imageUrl'] ?? '';
            if (items.length > 1) {
              foodName = "$foodName +${items.length - 1} more";
            }
          }

          // Format time if it's a timestamp
          String timeDisplay = estimatedTime.toString();
          if (estimatedTime is Timestamp) {
            timeDisplay = DateFormat('hh:mm a').format(estimatedTime.toDate());
          }

          String headerLabel = "Estimated Arrival";
          Color statusColor = Colors.black87;

          if (currentStep == 6) {
            headerLabel = "Order Status";
            timeDisplay = "Delivered";
            statusColor = Colors.green;
          } else if (currentStep == 0) {
            headerLabel = "Order Status";
            timeDisplay = "Cancelled";
            statusColor = Colors.red;
          } else if (timeDisplay == 'Calculating...') {
            timeDisplay = "Processing...";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Status
                Center(
                  child: Column(
                    children: [
                      Text(
                        headerLabel,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeDisplay,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (foodImageUrl.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(foodImageUrl),
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        foodName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Progress Timeline
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTimelineTile(
                        title: "Order Placed",
                        subtitle: "We have received your order",
                        time: "",
                        isActive: currentStep == 1,
                        isCompleted: currentStep > 1,
                        isFirst: true,
                      ),
                      _buildTimelineTile(
                        title: "Order Confirmed",
                        subtitle: "Restaurant has confirmed your order",
                        time: "",
                        isActive: currentStep == 2,
                        isCompleted: currentStep > 2,
                      ),
                      _buildTimelineTile(
                        title: "Preparing",
                        subtitle: "Your food is being prepared",
                        time: "",
                        isActive: currentStep == 3,
                        isCompleted: currentStep > 3,
                      ),
                      _buildTimelineTile(
                        title: "Out for Delivery",
                        subtitle: "Rider is on the way",
                        time: "",
                        isActive: currentStep == 4,
                        isCompleted: currentStep > 4,
                      ),
                      _buildTimelineTile(
                        title: "Delivered",
                        subtitle: "Enjoy your meal",
                        time: "",
                        isActive: currentStep == 5,
                        isCompleted: currentStep > 5,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Rider Info
                if (currentStep >= 4 && driverName != 'Assigning...') ...[
                  const Text(
                    "Delivery Partner",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            FontAwesomeIcons.bicycle,
                            color: Colors.deepOrange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "4.8",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (driverPhone != null)
                          IconButton(
                            onPressed: () => _makePhoneCall(driverPhone),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.phone),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineTile({
    required String title,
    required String subtitle,
    required String time,
    required bool isActive,
    required bool isCompleted,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? Colors.green : Colors.grey[200],
              ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : (isActive ? Colors.deepOrange : Colors.white),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted || isActive
                      ? Colors.transparent
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted
                    ? Colors.green
                    : (isActive ? Colors.deepOrange : Colors.grey[200]),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isActive || isCompleted
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive || isCompleted
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
