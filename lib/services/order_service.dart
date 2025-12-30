import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category_models.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> placeOrder({
    required String restaurantId,
    required List<CartItem> items,
    required int totalAmount,
    required String paymentMethod,
    required String paymentStatus,
    String orderType = 'normal',
  }) async {
    if (restaurantId.isEmpty) {
      throw ArgumentError('Restaurant ID cannot be empty');
    }

    final user = _auth.currentUser;

    // Use root 'orders' collection to match RestaurantOrdersPage query
    final orderRef = _firestore.collection('orders').doc();

    await orderRef.set({
      'orderId': orderRef.id,
      'restaurantId': restaurantId,
      'restaurantName': items.isNotEmpty ? items.first.restaurantName : '',
      'userId': user?.uid,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': 'pending',
      'orderType': orderType,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
