import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logActivity({
    required String action,
    required String details,
  }) async {
    try {
      final user = _auth.currentUser;
      await _firestore.collection('admin_activities').add({
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'adminEmail': user?.email ?? 'Unknown',
      });
    } catch (e) {
      print("Error logging activity: $e");
    }
  }
}