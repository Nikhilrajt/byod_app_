import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, restaurant, admin }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up with Email and Password
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    UserRole role = UserRole.user,
  }) async {
    try {
      // Create user account
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user?.updateDisplayName(fullName);

      // Store user data in Firestore with role
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'role': role.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return {
        'success': true,
        'user': userCredential.user,
        'message': 'Account created successfully',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Sign In with Email/Phone and Password
  Future<Map<String, dynamic>> signInWithEmailOrPhone({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      String email = emailOrPhone;

      // If phone number, get email from Firestore
      if (RegExp(r'^[6-9]\d{9}$').hasMatch(emailOrPhone)) {
        QuerySnapshot query = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: emailOrPhone)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          return {
            'success': false,
            'message': 'No account found with this phone number',
          };
        }

        email = query.docs.first.get('email');
      }

      // Sign in with email
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user document
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      String role = userDoc['role'];

      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'fullName': userCredential.user!.displayName,
          'phoneNumber': emailOrPhone.contains('@') ? '' : emailOrPhone,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });

        print('Created new user document with role: $role');
      } else {
        // Get role from document data
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('role')) {
          role = userData['role'];
          print('Found existing user with role: $role');
        } else {
          // Update document if role field was missing
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'role': role});
          print('Updated user document with default role: $role');
        }
      }

      print(
        'Login successful - User: ${userCredential.user!.email}, Role: $role',
      );

      return {
        'success': true,
        'user': userCredential.user,
        'role': role,
        'message': 'Signed in successfully',
      };
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      print('Unexpected Error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Sign In with specific role
  Future<Map<String, dynamic>> signInWithRole({
    required String email,
    required String password,
    required UserRole expectedRole,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user role from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'User data not found. Please sign up first.',
        };
      }

      // Get user data safely
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String userRole = userData['role'] ?? 'user';
      String expectedRoleStr = expectedRole.toString().split('.').last;

      if (userRole != expectedRoleStr) {
        await _auth.signOut();
        return {
          'success': false,
          'message':
              'Access denied. You do not have $expectedRoleStr privileges.',
        };
      }

      return {
        'success': true,
        'user': userCredential.user,
        'role': userRole,
        'message': 'Signed in successfully as $userRole',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Get User Role
  Future<String?> getUserRole() async {
    try {
      if (currentUser == null) return null;

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!userDoc.exists) return null;

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return userData['role'] ?? 'user';
    } catch (e) {
      return null;
    }
  }

  // Get User Data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) return null;

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!userDoc.exists) return null;

      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // Send Password Reset Email
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'Failed to send reset email'};
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Delete Account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      User? user = currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
      }
      return {'success': true, 'message': 'Account deleted successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete account: ${e.toString()}',
      };
    }
  }

  // Update User Profile
  Future<Map<String, dynamic>> updateUserProfile({
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      Map<String, dynamic> updates = {};

      if (fullName != null) {
        updates['fullName'] = fullName;
        await currentUser!.updateDisplayName(fullName);
      }

      if (phoneNumber != null) {
        updates['phoneNumber'] = phoneNumber;
      }

      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .update(updates);
      }

      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile: ${e.toString()}',
      };
    }
  }

  // Helper: Add or update role for existing user (Admin function)
  Future<Map<String, dynamic>> updateUserRole({
    required String userId,
    required UserRole newRole,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.toString().split('.').last,
      });

      return {'success': true, 'message': 'User role updated successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update role: ${e.toString()}',
      };
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'An error occurred. Please try again';
    }
  }
}
