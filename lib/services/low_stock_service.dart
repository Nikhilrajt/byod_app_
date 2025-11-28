// services/low_stock_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/ingredient_model.dart';

class LowStockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const double _lowStockThreshold = 5.0;

  // Stream to get low stock ingredients count
  Stream<int> getLowStockCount() {
    final restaurantId = _auth.currentUser?.uid;
    if (restaurantId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('ingredients')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map((snapshot) {
          final ingredients = snapshot.docs
              .map((doc) => IngredientModel.fromFirestore(doc))
              .toList();
          
          // Count ingredients with quantity <= threshold
          return ingredients.where((ingredient) => 
            ingredient.quantityAvailable <= _lowStockThreshold
          ).length;
        });
  }

  // Get low stock ingredients list
  Stream<List<IngredientModel>> getLowStockIngredients() {
    final restaurantId = _auth.currentUser?.uid;
    if (restaurantId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('ingredients')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map((snapshot) {
          final ingredients = snapshot.docs
              .map((doc) => IngredientModel.fromFirestore(doc))
              .toList();
          
          // Filter ingredients with quantity <= threshold
          return ingredients.where((ingredient) => 
            ingredient.quantityAvailable <= _lowStockThreshold
          ).toList();
        });
  }
}