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

  // 🔥 NEW: Batch update existing categories
  Future<void> _fixExistingCategories() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Fix Existing Categories"),
        content: const Text(
          "This will add the 'isHealthy' field to all existing categories "
          "that don't have it. They will be set as NON-HEALTHY by default.\n\n"
          "You can then edit individual categories to mark them as healthy.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text("Fix Categories"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final snapshot = await _firestore.collection('categories').get();

      int updated = 0;
      int skipped = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (!data.containsKey('isHealthy')) {
          await doc.reference.update({'isHealthy': false});
          print("✅ Updated: ${data['name']} → isHealthy: false");
          updated++;
        } else {
          print("⏭️ Skipped: ${data['name']}");
          skipped++;
        }
      }

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Update Complete"),
          content: Text(
            "✅ Updated: $updated categories\n"
            "⏭️ Skipped: $skipped categories\n\n"
            "All updated categories are set as NON-HEALTHY.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar('Error: $e', Colors.red);
    }
  }

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
          // 🔥 NEW: Fix button
          IconButton(
            icon: const Icon(Icons.build, color: Colors.white),
            tooltip: "Fix Existing Categories",
            onPressed: _fixExistingCategories,
          ),
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
              stream: _firestore
                  .collection('categories')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
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

                final searchedDocs = docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  return _searchQuery.isEmpty || name.contains(_searchQuery);
                }).toList();

                final normalCategories = searchedDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['isHealthy'] == false ||
                      data['isHealthy'] == null;
                }).toList();

                final healthyCategories = searchedDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['isHealthy'] == true;
                }).toList();

                if (searchedDocs.isEmpty) {
                  return const Center(child: Text("No categories found"));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (normalCategories.isNotEmpty) ...[
                        _buildSectionHeader(
                          "Standard Menu",
                          Icons.restaurant_menu,
                        ),
                        _buildGrid(normalCategories),
                      ],
                      if (healthyCategories.isNotEmpty) ...[
                        const Divider(thickness: 2, height: 40),
                        _buildSectionHeader(
                          "Healthy Corner",
                          Icons.spa,
                          color: Colors.green,
                        ),
                        _buildGrid(healthyCategories),
                      ],
                    ],
                  ),
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
        label: const Text(
          'Add Category',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<QueryDocumentSnapshot> docs) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) => _buildCategoryCard(docs[index]),
    );
  }

  Widget _buildCategoryCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'];
    final imageUrl = data['imageUrl'];
    final isHealthy = data['isHealthy'] ?? false;

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
                    backgroundColor: Colors.red.withOpacity(0.9),
                    radius: 16,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: () => _showDeleteConfirmation(doc.id, name),
                    ),
                  ),
                ),
                if (isHealthy)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Healthy",
                        style: TextStyle(color: Colors.white, fontSize: 10),
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
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => _showEditCategoryDialog(
                      doc.id,
                      name,
                      imageUrl,
                      isHealthy,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      elevation: 0,
                    ),
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        color: Colors.white,
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

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    XFile? pickedImage;
    bool isUploading = false;
    bool isHealthyCategory = false;

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
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Category Name",
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text(
                        "Is this Healthy Food?",
                        style: TextStyle(color: Colors.green, fontSize: 14),
                      ),
                      subtitle: const Text(
                        "Appears in Healthy Section",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 12,
                        ),
                      ),
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                      value: isHealthyCategory,
                      onChanged: (val) {
                        print("🔄 Switch toggled: $val");
                        setStateDialog(() => isHealthyCategory = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 150,
                      width: double.infinity,
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
                        if (img != null)
                          setStateDialog(() => pickedImage = img);
                      },
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
                          if (nameController.text.trim().isEmpty ||
                              pickedImage == null) {
                            _showSnackBar(
                              "Enter name & select image",
                              Colors.red,
                            );
                            return;
                          }

                          setStateDialog(() => isUploading = true);

                          try {
                            final url = await _uploader.uploadFile(
                              pickedImage!,
                            );

                            print("📝 Saving category:");
                            print("   Name: ${nameController.text.trim()}");
                            print("   isHealthy: $isHealthyCategory");
                            print("   URL: $url");

                            // 🔥 EXPLICIT MAP to ensure field is saved
                            final categoryData = {
                              'name': nameController.text.trim(),
                              'imageUrl': url,
                              'isHealthy':
                                  isHealthyCategory, // ← Explicitly save as boolean
                              'createdAt': FieldValue.serverTimestamp(),
                            };

                            await _firestore
                                .collection('categories')
                                .add(categoryData);

                            print("✅ Category saved!");

                            Navigator.pop(context);
                            _showSnackBar("Category Added", Colors.green);
                          } catch (e) {
                            print("❌ Error: $e");
                            _showSnackBar("Error: $e", Colors.red);
                            setStateDialog(() => isUploading = false);
                          }
                        },
                  child: isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Add",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCategoryDialog(
    String docId,
    String oldName,
    String oldImageUrl,
    bool oldIsHealthy,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: oldName,
    );
    XFile? pickedImage;
    bool isUploading = false;
    bool isHealthyCategory = oldIsHealthy;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Edit Category"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Category Name",
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Is this Healthy Food?"),
                    subtitle: const Text(
                      "Toggle to change category type",
                      style: TextStyle(fontSize: 12),
                    ),
                    activeColor: Colors.green,
                    contentPadding: EdgeInsets.zero,
                    value: isHealthyCategory,
                    onChanged: (val) {
                      print("🔄 Edit switch: $val");
                      setStateDialog(() => isHealthyCategory = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: double.infinity,
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
                      if (img != null) setStateDialog(() => pickedImage = img);
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Change Image"),
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
                        setStateDialog(() => isUploading = true);

                        try {
                          String finalImage = oldImageUrl;
                          if (pickedImage != null) {
                            finalImage =
                                await _uploader.uploadFile(pickedImage!) ??
                                oldImageUrl;
                          }

                          print("📝 Updating:");
                          print("   Name: ${nameController.text.trim()}");
                          print("   isHealthy: $isHealthyCategory");

                          // 🔥 EXPLICIT MAP
                          final updateData = {
                            'name': nameController.text.trim(),
                            'imageUrl': finalImage,
                            'isHealthy':
                                isHealthyCategory, // ← Explicitly update as boolean
                          };

                          await _firestore
                              .collection('categories')
                              .doc(docId)
                              .update(updateData);

                          print("✅ Updated!");

                          Navigator.pop(context);
                          _showSnackBar("Updated Successfully", Colors.green);
                        } catch (e) {
                          print("❌ Error: $e");
                          _showSnackBar("Error: $e", Colors.red);
                          setStateDialog(() => isUploading = false);
                        }
                      },
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Update",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
