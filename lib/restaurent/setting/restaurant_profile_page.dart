import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:mime/mime.dart';

// CloudneryUploader class (keep as is)
class CloudneryUploader {
  final String cloudinaryCloudName = 'daai1jedw';
  final String cloudinaryUploadPreset = 'byodapp';

  Future<String?> uploadFile(XFile file) async {
    try {
      final mimeTypeData = lookupMimeType(file.path)?.split('/');

      String resourceType = 'image';
      if (mimeTypeData != null) {
        if (mimeTypeData[0] == 'application' && mimeTypeData[1] == 'pdf') {
          resourceType = 'raw';
        } else if (mimeTypeData[0] == 'video') {
          resourceType = 'video';
        }
      }

      final uploadUrl =
          "https://api.cloudinary.com/v1_1/$cloudinaryCloudName/$resourceType/upload";

      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['upload_preset'] = cloudinaryUploadPreset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: mimeTypeData != null
                ? http.MediaType(mimeTypeData[0], mimeTypeData[1])
                : null,
          ),
        );

      final response = await request.send();
      final result = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(result.body);
        log("✅ Upload success ($resourceType): ${data['secure_url']}");
        return data['secure_url'];
      } else {
        log("❌ Upload failed: ${result.body}");
        return null;
      }
    } catch (e) {
      log("❌ Upload error: $e");
      return null;
    }
  }
}

class RestaurantProfilePage extends StatefulWidget {
  const RestaurantProfilePage({super.key});

  @override
  State<RestaurantProfilePage> createState() => _RestaurantProfilePageState();
}

class _RestaurantProfilePageState extends State<RestaurantProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _restaurantImageUrl;
  bool _isLoading = false;
  bool _isEditing = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudneryUploader _uploader = CloudneryUploader();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurantData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ Fetch from 'users' collection where role is restaurant
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        print('🔥 Loaded restaurant data: $data');

        setState(() {
          // ✅ Use existing user fields - no restaurant-specific fields needed
          _nameController.text = data['fullName'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _emailController.text = data['email'] ?? '';
          _addressController.text =
              data['address'] ?? ''; // This might be empty initially
          _restaurantImageUrl =
              data['imageUrl'] ?? ''; // This might be empty initially
        });
      } else {
        print('❌ No user document found for UID: ${user.uid}');
      }
    } catch (e) {
      print('❌ Error loading restaurant data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() {
        _isLoading = true;
      });

      try {
        // ✅ Save to existing user fields - no restaurant-specific fields
        Map<String, dynamic> updateData = {
          'fullName': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
          'imageUrl': _restaurantImageUrl ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
          // Keep existing role and other fields
          'role': 'restaurant', // Ensure role remains restaurant
          'isActive': true,
        };

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(updateData, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!')),
          );
        }
      } catch (e) {
        print('❌ Error saving profile: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isEditing = false;
          });
        }
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        final String? imageUrl = await _uploader.uploadFile(image);

        if (imageUrl != null && mounted) {
          setState(() {
            _restaurantImageUrl = imageUrl;
          });

          // ✅ Auto-save to user document
          final user = _auth.currentUser;
          if (user != null) {
            await _firestore.collection('users').doc(user.uid).set({
              'imageUrl': imageUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeImage() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Profile Image'),
        content: const Text(
          'Are you sure you want to remove your profile image?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _isLoading = true;
              });

              try {
                final user = _auth.currentUser;
                if (user != null) {
                  await _firestore.collection('users').doc(user.uid).set({
                    'imageUrl': '',
                    'updatedAt': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
                }

                setState(() {
                  _restaurantImageUrl = null;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile image removed!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error removing image: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey.shade200,
          backgroundImage:
              _restaurantImageUrl != null && _restaurantImageUrl!.isNotEmpty
              ? NetworkImage(_restaurantImageUrl!)
              : null,
          child: _restaurantImageUrl == null || _restaurantImageUrl!.isEmpty
              ? const Icon(Icons.restaurant, size: 50, color: Colors.grey)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              onPressed: _pickAndUploadImage,
              tooltip: 'Change profile image',
            ),
          ),
        ),
        if (_restaurantImageUrl != null && _restaurantImageUrl!.isNotEmpty)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(top: 2, right: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 12),
                onPressed: _removeImage,
                tooltip: 'Remove profile image',
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Edit Profile',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
                _loadRestaurantData(); // Reload original data
              },
              tooltip: 'Cancel Editing',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Image Section
                  Center(
                    child: Column(
                      children: [
                        _buildProfileImage(),
                        const SizedBox(height: 16),
                        Text(
                          _restaurantImageUrl != null &&
                                  _restaurantImageUrl!.isNotEmpty
                              ? 'Tap camera to change or X to remove image'
                              : 'Tap camera icon to add profile image',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Restaurant Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Restaurant Information',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Restaurant Name *',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditing,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter restaurant name'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              enabled: _isEditing,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter phone number'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              enabled: _isEditing,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter email'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            if (_isEditing) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('Save Profile'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
