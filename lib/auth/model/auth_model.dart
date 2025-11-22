import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final DateTime? createdAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.createdAt,
    required this.isActive,
  });

  // From Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'isActive': isActive,
    };
  }

  // Copy with
  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? role,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}