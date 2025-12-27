import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/services/upload_image.dart';

class RestaurantIngredientPage extends StatefulWidget {
  const RestaurantIngredientPage({super.key});

  @override
  State<RestaurantIngredientPage> createState() =>
      _RestaurantIngredientPageState();
}

class _RestaurantIngredientPageState extends State<RestaurantIngredientPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final CloudneryUploader _uploader = CloudneryUploader();
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
          'Manage Menu Ingredients',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 1. Fetch Global Collections (Admin defined)
        stream: _firestore
            .collection('ingredient_collections')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, collectionSnapshot) {
          if (collectionSnapshot.hasError) {
            return Center(child: Text("Error: ${collectionSnapshot.error}"));
          }
          if (!collectionSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final collections = collectionSnapshot.data!.docs;

          if (collections.isEmpty) {
            return const Center(
              child: Text("No collections found. Contact Admin."),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            // 2. Fetch Restaurant's Ingredients
            stream: _firestore
                .collection('users')
                .doc(currentUser!.uid)
                .collection('ingredients')
                .snapshots(),
            builder: (context, ingredientSnapshot) {
              if (!ingredientSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allIngredients = ingredientSnapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final collectionData =
                      collections[index].data() as Map<String, dynamic>;
                  final collectionName =
                      collectionData['name'] ?? 'Uncategorized';
                  final collectionImage = collectionData['imageUrl'] ?? '';

                  // Filter ingredients for this specific collection
                  final sectionIngredients = allIngredients.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['category'] == collectionName;
                  }).toList();

                  return _buildCollectionSection(
                    collectionName,
                    collectionImage,
                    sectionIngredients,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCollectionSection(
    String title,
    String imageUrl,
    List<QueryDocumentSnapshot> ingredients,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          child: imageUrl.isEmpty
              ? const Icon(Icons.category, color: Colors.deepPurple)
              : null,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        children: [
          // List of Ingredients in this Collection
          if (ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "No ingredients in $title yet.",
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ingredients.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildIngredientTile(ingredients[index]);
              },
            ),

          // "Add Item" Button for this Collection
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showIngredientDialog(category: title),
                icon: const Icon(Icons.add),
                label: Text("Add Item to $title"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientTile(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unknown';
    final price = data['price'] ?? 0;
    final unit = data['unit'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';
    final isHealthy = data['isHealthy'] ?? false;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl.isNotEmpty
            ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
            : Container(
                width: 50,
                height: 50,
                color: Colors.grey[200],
                child: const Icon(Icons.fastfood, size: 20),
              ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (isHealthy) const Icon(Icons.spa, size: 16, color: Colors.green),
        ],
      ),
      subtitle: Text("₹$price / $unit"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showIngredientDialog(doc: doc),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteIngredient(doc.id),
          ),
        ],
      ),
    );
  }

  void _showIngredientDialog({QueryDocumentSnapshot? doc, String? category}) {
    final isEdit = doc != null;
    final data = isEdit ? doc.data() as Map<String, dynamic> : {};

    final nameCtrl = TextEditingController(text: data['name'] ?? '');
    final priceCtrl = TextEditingController(
      text: (data['price'] ?? 0).toString(),
    );
    final unitCtrl = TextEditingController(text: data['unit'] ?? '1 pc');
    final calCtrl = TextEditingController(text: (data['cal'] ?? 0).toString());
    final proCtrl = TextEditingController(
      text: (data['protein'] ?? 0).toString(),
    );
    final carbCtrl = TextEditingController(
      text: (data['carbs'] ?? 0).toString(),
    );
    final fatCtrl = TextEditingController(text: (data['fat'] ?? 0).toString());

    // Use passed category or existing one
    String currentCategory = category ?? data['category'] ?? 'Uncategorized';
    bool isHealthy = data['isHealthy'] ?? false;

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
            title: Text(isEdit ? "Edit Item" : "Add to $currentCategory"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Price (₹)",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: unitCtrl,
                          decoration: const InputDecoration(
                            labelText: "Unit",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Nutrition Info",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _numField(calCtrl, "Cal")),
                      const SizedBox(width: 5),
                      Expanded(child: _numField(proCtrl, "Prot")),
                      const SizedBox(width: 5),
                      Expanded(child: _numField(carbCtrl, "Carb")),
                      const SizedBox(width: 5),
                      Expanded(child: _numField(fatCtrl, "Fat")),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text("Is Healthy?"),
                    value: isHealthy,
                    onChanged: (val) => setStateDialog(() => isHealthy = val),
                    contentPadding: EdgeInsets.zero,
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
                            'category': currentCategory,
                            'price': double.tryParse(priceCtrl.text) ?? 0,
                            'unit': unitCtrl.text.trim(),
                            'cal': int.tryParse(calCtrl.text) ?? 0,
                            'protein': int.tryParse(proCtrl.text) ?? 0,
                            'carbs': int.tryParse(carbCtrl.text) ?? 0,
                            'fat': int.tryParse(fatCtrl.text) ?? 0,
                            'isHealthy': isHealthy,
                            'imageUrl': imageUrl,
                            'createdAt': FieldValue.serverTimestamp(),
                          };

                          if (isEdit) {
                            await doc!.reference.update(ingredientData);
                          } else {
                            await _firestore
                                .collection('users')
                                .doc(currentUser!.uid)
                                .collection('ingredients')
                                .add(ingredientData);
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

  Widget _numField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(fontSize: 12),
    );
  }

  Future<void> _deleteIngredient(String docId) async {
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('ingredients')
        .doc(docId)
        .delete();
  }
}
