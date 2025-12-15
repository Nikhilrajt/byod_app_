// services/ingredient_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/ingredient_model.dart';

class IngredientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get stream of ingredients for current restaurant
  Stream<List<IngredientModel>> getRestaurantIngredients() {
    final restaurantId = _auth.currentUser?.uid;
    if (restaurantId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('ingredients')
        .where('restaurantId', isEqualTo: restaurantId)
        // .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => IngredientModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Add new ingredient
  Future<void> addIngredient(IngredientModel ingredient) async {
    try {
      final docRef = _firestore.collection('ingredients').doc();
      final newIngredient = ingredient.copyWith(id: docRef.id);

      await docRef.set(newIngredient.toFirestore());
    } catch (e) {
      throw Exception('Failed to add ingredient: $e');
    }
  }

  // Update ingredient quantity
  Future<void> updateIngredientQuantity(
    String ingredientId,
    double newQuantity,
  ) async {
    try {
      await _firestore.collection('ingredients').doc(ingredientId).update({
        'quantityAvailable': newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  // Seed default ingredients
  Future<void> seedDefaultIngredients() async {
    final restaurantId = _auth.currentUser?.uid;
    if (restaurantId == null) throw Exception('User not logged in');

    final defaultIngredients = [
      IngredientModel(
        id: '',
        name: 'Carrot',
        category: 'Vegetables',
        price: 40.0,
        calories: 41.0,
        protein: 0.9,
        unit: 'kg',
        quantityAvailable: 10.0,
        iconName: 'carrot',
        restaurantId: restaurantId,
        createdAt: DateTime.now(),
      ),
      IngredientModel(
        id: '',
        name: 'Tomato',
        category: 'Vegetables',
        price: 30.0,
        calories: 18.0,
        protein: 0.9,
        unit: 'kg',
        quantityAvailable: 15.0,
        iconName: 'apple_whole',
        restaurantId: restaurantId,
        createdAt: DateTime.now(),
      ),
      IngredientModel(
        id: '',
        name: 'Chicken Breast',
        category: 'Meat',
        price: 200.0,
        calories: 165.0,
        protein: 31.0,
        unit: 'kg',
        quantityAvailable: 5.0,
        iconName: 'drumstick_bite',
        restaurantId: restaurantId,
        createdAt: DateTime.now(),
      ),
      IngredientModel(
        id: '',
        name: 'Rice',
        category: 'Grains',
        price: 60.0,
        calories: 130.0,
        protein: 2.7,
        unit: 'kg',
        quantityAvailable: 20.0,
        iconName: 'bowl_rice',
        restaurantId: restaurantId,
        createdAt: DateTime.now(),
      ),
      IngredientModel(
        id: '',
        name: 'Milk',
        category: 'Dairy',
        price: 50.0,
        calories: 42.0,
        protein: 3.4,
        unit: 'liter',
        quantityAvailable: 8.0,
        iconName: 'mug_hot',
        restaurantId: restaurantId,
        createdAt: DateTime.now(),
      ),
      IngredientModel(
        id: '',
        name: 'Eggs',
        category: 'Dairy',
        price: 6.0,
        calories: 78.0,
        protein: 6.3,
        unit: 'piece',
        quantityAvailable: 24.0,
        iconName: 'egg',
        restaurantId: restaurantId,
        createdAt: DateTime.now(),
      ),
    ];

    try {
      final batch = _firestore.batch();

      for (final ingredient in defaultIngredients) {
        final docRef = _firestore.collection('ingredients').doc();
        final newIngredient = ingredient.copyWith(id: docRef.id);
        batch.set(docRef, newIngredient.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to seed ingredients: $e');
    }
  }

  // Delete ingredient
  Future<void> deleteIngredient(String ingredientId) async {
    try {
      await _firestore.collection('ingredients').doc(ingredientId).delete();
    } catch (e) {
      throw Exception('Failed to delete ingredient: $e');
    }
  }
}
