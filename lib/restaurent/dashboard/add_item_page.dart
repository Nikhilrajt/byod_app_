import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/menu_item_model.dart';
import 'package:project/services/upload_image.dart';

// Adjust path if needed

class AddItemPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final MenuItem? initialItem;

  const AddItemPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.initialItem,
  });

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _nutritionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final CloudneryUploader _cloudUploader = CloudneryUploader();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  XFile? _pickedImage;
  bool _isUploading = false;
  bool _isVeg = true;
  bool _isAvailable = true;
  bool _isCustomizable = false;
  bool _isHealthy = false;

  List<VariantGroup> _variantGroups = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialItem != null) {
      final item = widget.initialItem!;
      _nameController.text = item.name;
      _descController.text = item.description;
      _priceController.text = item.price.toString();
      _nutritionController.text = item.nutrition ?? "";
      _isAvailable = item.isAvailable;
      _isVeg = item.isVeg;
      _isCustomizable = item.isCustomizable;
      _variantGroups = List.from(item.variantGroups);
      _isHealthy = item.isHealthy;
    }
  }

  Future<void> pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _pickedImage = img);
  }

  Future<void> saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      String currentUserId = _auth.currentUser!.uid;

      // ============================================================
      // ⭐ FETCH RESTAURANT NAME FROM FIREBASE
      // ============================================================
      String restaurantName = "Unknown Restaurant";

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>?;

          if (userData != null) {
            restaurantName = userData['fullName'] ?? "Unknown Restaurant";
            print("✅ Restaurant Name fetched: $restaurantName");
            print("📋 Restaurant ID: $currentUserId");
          } else {
            print("❌ User data is null");
          }
        } else {
          print("❌ User document does not exist for ID: $currentUserId");
        }
      } catch (e) {
        print("❌ Error fetching restaurant name: $e");
      }
      // ============================================================

      // 1. Upload Image (if selected)
      String? imageUrl = widget.initialItem?.imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _cloudUploader.uploadFile(_pickedImage!);
      }

      final itemId =
          widget.initialItem?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // 2. Sync Variants with healthy flag
      for (var e in _variantGroups) {
        e.isHealthy = _isHealthy;
      }

      // 3. Create Item Object
      final item = MenuItem(
        id: itemId,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        nutrition: _nutritionController.text.trim(),
        imageUrl: imageUrl,
        isAvailable: _isAvailable,
        isVeg: _isVeg,
        restaurantId: currentUserId,
        isCustomizable: _isCustomizable,
        variantGroups: _variantGroups,
        isHealthy: _isHealthy,
      );

      // 4. Prepare Data Map
      Map<String, dynamic> itemData = item.toMap();

      // ⭐ EXPLICITLY ADD RESTAURANT NAME TO THE MAP
      itemData['restaurantName'] = restaurantName;
      itemData['restaurantId'] = currentUserId;
      itemData['categoryKey'] = widget.categoryId;
      itemData['rating'] = 4.5;
      itemData['createdAt'] = FieldValue.serverTimestamp();

      print("💾 Saving item data:");
      print("   - Item Name: ${itemData['name']}");
      print("   - Restaurant Name: ${itemData['restaurantName']}");
      print("   - Restaurant ID: ${itemData['restaurantId']}");
      print("   - Category: ${itemData['categoryKey']}");

      // 5. Save to Firestore
      await FirebaseFirestore.instance
          .collection("categories")
          .doc(widget.categoryId)
          .collection("items")
          .doc(itemId)
          .set(itemData, SetOptions(merge: true));

      print("✅ Item saved successfully with restaurantName: $restaurantName");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Item saved successfully as '$restaurantName'!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      print("❌ Error saving item: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ---------------------------------------------------------
  // UI WIDGETS (Unchanged)
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final editing = widget.initialItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing
              ? "Edit ${widget.categoryName} Item"
              : "Add Item to ${widget.categoryName}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: saveItem,
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildFoodTypeSelector(),
              const SizedBox(height: 20),
              _buildFormFields(),
              const SizedBox(height: 20),
              _buildHealthySwitch(),
              const SizedBox(height: 20),
              _buildAvailabilitySwitch(),
              const SizedBox(height: 20),
              _buildCustomizationSwitch(),
              if (_isCustomizable) ...[
                const SizedBox(height: 20),
                _buildCustomizationGroups(),
              ],
              const SizedBox(height: 30),
              _buildSaveButton(editing),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: _pickedImage != null
              ? DecorationImage(
                  image: FileImage(File(_pickedImage!.path)),
                  fit: BoxFit.cover,
                )
              : widget.initialItem?.imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(widget.initialItem!.imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _pickedImage == null && widget.initialItem?.imageUrl == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 40,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text("Add Image", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildFoodTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile(
            value: true,
            groupValue: _isVeg,
            onChanged: (v) => setState(() => _isVeg = true),
            title: const Text("Veg"),
            activeColor: Colors.green,
          ),
        ),
        Expanded(
          child: RadioListTile(
            value: false,
            groupValue: _isVeg,
            onChanged: (v) => setState(() => _isVeg = false),
            title: const Text("Non-Veg"),
            activeColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: "Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) => v!.isEmpty ? "Enter food name" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descController,
          decoration: InputDecoration(
            labelText: "Description",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Price",
            prefixText: "₹ ",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) =>
              double.tryParse(v!) == null ? "Enter valid price" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nutritionController,
          decoration: InputDecoration(
            labelText: "Nutrition (Optional)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthySwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: SwitchListTile(
        title: Text(
          "Healthy Food",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
        ),
        subtitle: const Text("Enable for Health Mode"),
        value: _isHealthy,
        activeThumbColor: Colors.white,
        activeTrackColor: Colors.green,
        onChanged: (v) => setState(() => _isHealthy = v),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildAvailabilitySwitch() {
    return SwitchListTile(
      value: _isAvailable,
      title: const Text("Available"),
      subtitle: Text(_isAvailable ? "Visible on menu" : "Hidden from menu"),
      onChanged: (v) => setState(() => _isAvailable = v),
      secondary: Icon(
        _isAvailable ? Icons.visibility : Icons.visibility_off,
        color: _isAvailable ? Colors.deepPurple : Colors.grey,
      ),
    );
  }

  Widget _buildCustomizationSwitch() {
    return SwitchListTile(
      value: _isCustomizable,
      title: const Text("Customization"),
      subtitle: const Text("Add variants (Size, toppings)"),
      onChanged: (v) => setState(() => _isCustomizable = v),
      secondary: const Icon(Icons.tune),
    );
  }

  Widget _buildCustomizationGroups() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Variant Groups",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () => _openVariantGroupDialog(),
              icon: const Icon(Icons.add),
              label: const Text("Add Group"),
            ),
          ],
        ),
        if (_variantGroups.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "No customization groups added yet.\nTap 'Add Group' to start.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ..._variantGroups.map(
          (g) => Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                g.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${g.options.length} options • ${g.isRequired ? 'Required' : 'Optional'}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _openVariantGroupDialog(group: g),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => _variantGroups.remove(g));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool editing) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: saveItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                editing ? "Save Changes" : "Add Item",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
    );
  }

  void _openVariantGroupDialog({VariantGroup? group}) {
    showDialog(
      context: context,
      builder: (context) => _VariantGroupDialog(
        initialGroup: group,
        onSave: (updatedGroup) {
          setState(() {
            if (group != null) {
              final index = _variantGroups.indexOf(group);
              _variantGroups[index] = updatedGroup;
            } else {
              _variantGroups.add(updatedGroup);
            }
          });
        },
      ),
    );
  }
}

// ========================================
// HELPER DIALOGS (Keep these inside same file or separate)
// ========================================

class _VariantGroupDialog extends StatefulWidget {
  final VariantGroup? initialGroup;
  final Function(VariantGroup) onSave;

  const _VariantGroupDialog({this.initialGroup, required this.onSave});

  @override
  State<_VariantGroupDialog> createState() => _VariantGroupDialogState();
}

class _VariantGroupDialogState extends State<_VariantGroupDialog> {
  final _nameController = TextEditingController();
  bool _isRequired = false;
  bool _allowMultiple = false;
  List<VariantOption> _options = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialGroup != null) {
      final group = widget.initialGroup!;
      _nameController.text = group.name;
      _isRequired = group.isRequired;
      _allowMultiple = group.allowMultiple;
      _options = List.from(group.options);
    }
  }

  void _addOption() {
    showDialog(
      context: context,
      builder: (context) => _VariantOptionDialog(
        onSave: (option) => setState(() => _options.add(option)),
      ),
    );
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) return;
    if (_options.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add at least one option")));
      return;
    }

    final group = VariantGroup(
      id:
          widget.initialGroup?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      isRequired: _isRequired,
      allowMultiple: _allowMultiple,
      options: _options,
    );

    widget.onSave(group);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.initialGroup == null ? "Add Group" : "Edit Group",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Group Name (e.g. Size)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text("Required?"),
              value: _isRequired,
              onChanged: (v) => setState(() => _isRequired = v),
            ),
            SwitchListTile(
              title: const Text("Allow Multiple?"),
              value: _allowMultiple,
              onChanged: (v) => setState(() => _allowMultiple = v),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Options"),
                TextButton(onPressed: _addOption, child: const Text("Add")),
              ],
            ),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _options.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(_options[i].name),
                  subtitle: Text("+₹${_options[i].priceModifier}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _options.removeAt(i)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text(
                "Save Group",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantOptionDialog extends StatefulWidget {
  final Function(VariantOption) onSave;

  const _VariantOptionDialog({required this.onSave});

  @override
  State<_VariantOptionDialog> createState() => _VariantOptionDialogState();
}

class _VariantOptionDialogState extends State<_VariantOptionDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  void _save() {
    if (_nameController.text.isEmpty) return;
    final option = VariantOption(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      priceModifier: double.tryParse(_priceController.text.trim()) ?? 0,
      isAvailable: true,
    );
    widget.onSave(option);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Option"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Option Name (e.g. Large)",
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Extra Price (₹)"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: _save, child: const Text("Add")),
      ],
    );
  }
}
