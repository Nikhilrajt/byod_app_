import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/services/upload_image.dart';

class AdminIngredientPage extends StatefulWidget {
  const AdminIngredientPage({super.key});

  @override
  State<AdminIngredientPage> createState() => _AdminIngredientPageState();
}

class _AdminIngredientPageState extends State<AdminIngredientPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final CloudneryUploader _uploader = CloudneryUploader();
  String _searchQuery = '';

  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Please login first")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Manage Collections',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            tooltip: "Sync Collections to Restaurants",
            onPressed: _syncCollectionsToAllRestaurants,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search ingredients...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('ingredient_collections')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text("Error loading data"));
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return _searchQuery.isEmpty || name.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty)
                  return const Center(child: Text("No collections found"));

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) =>
                      _buildIngredientCard(docs[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showIngredientDialog(),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Collection',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildIngredientCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unknown';
    final imageUrl = data['imageUrl'] ?? '';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.fastfood)),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.9),
                    radius: 16,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: () => _deleteIngredient(doc.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => _showIngredientDialog(doc: doc),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Text(
                      "Edit",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showIngredientDialog({QueryDocumentSnapshot? doc}) {
    final isEdit = doc != null;
    final data = isEdit ? doc.data() as Map<String, dynamic> : {};

    final nameCtrl = TextEditingController(text: data['name'] ?? '');

    XFile? pickedImage;
    bool isUploading = false;
    String currentImageUrl = data['imageUrl'] ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(isEdit ? "Edit Collection" : "Create Collection"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Collection Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final img = await _picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (img != null) setStateDialog(() => pickedImage = img);
                    },
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: pickedImage != null
                          ? Image.file(
                              File(pickedImage!.path),
                              fit: BoxFit.cover,
                            )
                          : (currentImageUrl.isNotEmpty
                                ? Image.network(
                                    currentImageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey,
                                    ),
                                  )),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: isUploading
                    ? null
                    : () async {
                        if (nameCtrl.text.isEmpty) return;
                        setStateDialog(() => isUploading = true);
                        try {
                          String imageUrl = currentImageUrl;
                          if (pickedImage != null) {
                            imageUrl =
                                await _uploader.uploadFile(pickedImage!) ?? '';
                          }

                          final ingredientData = {
                            'name': nameCtrl.text.trim(),
                            'imageUrl': imageUrl,
                            'createdAt': FieldValue.serverTimestamp(),
                          };

                          if (isEdit) {
                            await doc!.reference.update(ingredientData);
                          } else {
                            // 1. Add to Global Collection
                            final newDoc = await _firestore
                                .collection('ingredient_collections')
                                .add(ingredientData);

                            // 2. Propagate to ALL Restaurants
                            final restaurants = await _firestore
                                .collection('users')
                                .where('role', isEqualTo: 'restaurant')
                                .get();

                            final batch = _firestore.batch();
                            for (var r in restaurants.docs) {
                              final ref = _firestore
                                  .collection('users')
                                  .doc(r.id)
                                  .collection('ingredient_collections')
                                  .doc(newDoc.id);
                              batch.set(ref, ingredientData);
                            }
                            await batch.commit();
                            print(
                              "✅ Collection propagated to ${restaurants.size} restaurants",
                            );
                          }
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          print(e);
                        } finally {
                          setStateDialog(() => isUploading = false);
                        }
                      },
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        isEdit ? "Update" : "Add",
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteIngredient(String docId) async {
    await _firestore.collection('ingredient_collections').doc(docId).delete();
  }

  Future<void> _syncCollectionsToAllRestaurants() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Syncing collections to all restaurants..."),
        ),
      );

      final collections = await _firestore
          .collection('ingredient_collections')
          .get();
      final restaurants = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'restaurant')
          .get();

      final batch = _firestore.batch();
      int count = 0;

      for (var r in restaurants.docs) {
        for (var c in collections.docs) {
          final ref = _firestore
              .collection('users')
              .doc(r.id)
              .collection('ingredient_collections')
              .doc(c.id);
          batch.set(ref, c.data());
          count++;
        }
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Synced $count items to ${restaurants.size} restaurants",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
    }
  }
}
