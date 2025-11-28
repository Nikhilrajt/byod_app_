import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/services/upload_image.dart';

class AdminCategoryPage extends StatefulWidget {
  const AdminCategoryPage({super.key});

  @override
  State<AdminCategoryPage> createState() => _AdminCategoryPageState();
}

class _AdminCategoryPageState extends State<AdminCategoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final CloudneryUploader _uploader = CloudneryUploader();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Manage Categories',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() {}),
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search categories...',
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
              stream: _firestore.collection('categories').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading categories"));
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  );
                }

                final docs = snapshot.data!.docs;

                final filtered = docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  return _searchQuery.isEmpty || name.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No categories found"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Category'),
      ),
    );
  }

  // -------------------------------
  // CATEGORY CARD
  // -------------------------------

  Widget _buildCategoryCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'];
    final imageUrl = data['imageUrl'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: () => _showDeleteConfirmation(doc.id, name),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
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
                  child: ElevatedButton(
                    onPressed: () =>
                        _showEditCategoryDialog(doc.id, name, imageUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      elevation: 0,
                    ),
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
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

  // -------------------------------
  // ADD CATEGORY DIALOG
  // -------------------------------

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    XFile? pickedImage;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text("Add Category"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Category Name",
                    ),
                  ),
                  const SizedBox(height: 16),

                  // IMAGE PREVIEW FIXED
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: pickedImage == null
                        ? const Center(child: Text("No image selected"))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(pickedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),

                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Select Image"),
                    onPressed: () async {
                      final img = await _picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (img != null) {
                        setStateDialog(() => pickedImage = img);
                      }
                    },
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty ||
                              pickedImage == null) {
                            _showSnackBar(
                              "Enter name & select image",
                              Colors.red,
                            );
                            return;
                          }

                          setStateDialog(() => isUploading = true);

                          final url = await _uploader.uploadFile(pickedImage!);

                          await _firestore.collection('categories').add({
                            'name': nameController.text.trim(),
                            'imageUrl': url,
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          Navigator.pop(context);
                          _showSnackBar("Category Added", Colors.green);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -------------------------------
  // EDIT CATEGORY DIALOG
  // -------------------------------

  void _showEditCategoryDialog(
    String docId,
    String oldName,
    String oldImageUrl,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: oldName,
    );

    XFile? pickedImage;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Edit Category"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Category Name"),
                ),
                const SizedBox(height: 16),

                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: pickedImage != null
                      ? Image.file(File(pickedImage!.path), fit: BoxFit.cover)
                      : Image.network(oldImageUrl, fit: BoxFit.cover),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () async {
                    final img = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (img != null) {
                      setStateDialog(() => pickedImage = img);
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Change Image"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),

              ElevatedButton(
                onPressed: isUploading
                    ? null
                    : () async {
                        setStateDialog(() => isUploading = true);

                        String finalImage = oldImageUrl;

                        if (pickedImage != null) {
                          finalImage =
                              await _uploader.uploadFile(pickedImage!) ??
                              oldImageUrl;
                        }

                        await _firestore
                            .collection('categories')
                            .doc(docId)
                            .update({
                              'name': nameController.text.trim(),
                              'imageUrl': finalImage,
                            });

                        Navigator.pop(context);
                        _showSnackBar("Updated Successfully", Colors.green);
                      },
                child: isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------------------
  // DELETE CATEGORY CONFIRMATION
  // -------------------------------

  void _showDeleteConfirmation(String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Category"),
        content: Text("Are you sure you want to delete '$name'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('categories').doc(docId).delete();
              Navigator.pop(context);
              _showSnackBar("Category Deleted", Colors.red);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // SNACKBAR
  // -------------------------------
  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
