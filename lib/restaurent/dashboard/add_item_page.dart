import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/menu_item_model.dart';
import 'package:project/services/upload_image.dart';

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
  FirebaseAuth _auth = FirebaseAuth.instance;
  XFile? _pickedImage;
  bool _isUploading = false;
  bool _isVeg = true; // true for Veg, false for Non-Veg
  bool _isAvailable = true;

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
      // Note: You might want to add veg/non-veg field to your MenuItem model
    }
  }

  Future<void> pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _pickedImage = img);
  }

  Future<void> saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    String? imageUrl = widget.initialItem?.imageUrl;

    if (_pickedImage != null) {
      imageUrl = await _cloudUploader.uploadFile(_pickedImage!);
    }

    final itemId =
        widget.initialItem?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final item = MenuItem(
      id: itemId,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      nutrition: _nutritionController.text.trim(),
      imageUrl: imageUrl,
      isAvailable: _isAvailable,
      restaurantId: _auth.currentUser!.uid,
      // Add this field to your MenuItem model:
      // isVeg: _isVeg,
    );

    await FirebaseFirestore.instance
        .collection("categories")
        .doc(widget.categoryId)
        .collection("items")
        .doc(itemId)
        .set(item.toMap());

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initialItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing
              ? "Edit ${widget.categoryName} Item"
              : "Add Item to ${widget.categoryName}",
        ),
        backgroundColor: Colors.deepPurple,
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
              // 🖼️ ENHANCED IMAGE PICKER
              _buildImagePicker(),
              const SizedBox(height: 24),

              // 🍽️ FOOD TYPE SELECTOR (Veg/Non-Veg)
              _buildFoodTypeSelector(),
              const SizedBox(height: 20),

              // 📝 ENHANCED FORM FIELDS
              _buildFormFields(),
              const SizedBox(height: 20),

              // ✅ AVAILABILITY SWITCH
              _buildAvailabilitySwitch(),
              const SizedBox(height: 24),

              // 💾 SAVE BUTTON
              _buildSaveButton(editing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Food Image",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
              image: _buildBackgroundImage(),
            ),
            child: _buildImagePickerContent(),
          ),
        ),
      ],
    );
  }

  DecorationImage? _buildBackgroundImage() {
    if (_pickedImage != null) {
      return DecorationImage(
        image: FileImage(File(_pickedImage!.path)),
        fit: BoxFit.cover,
      );
    } else if (widget.initialItem?.imageUrl != null) {
      return DecorationImage(
        image: NetworkImage(widget.initialItem!.imageUrl!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Widget _buildImagePickerContent() {
    if (_pickedImage != null || widget.initialItem?.imageUrl != null) {
      return Stack(
        children: [
          Container(),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ],
      );
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          "Tap to add food image",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFoodTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Food Type",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFoodTypeCard(
                "Vegetarian",
                _isVeg,
                Colors.green,
                Icons.eco_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFoodTypeCard(
                "Non-Vegetarian",
                !_isVeg,
                Colors.red,
                Icons.restaurant_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodTypeCard(
    String title,
    bool isSelected,
    Color color,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isVeg = title == "Vegetarian";
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // NAME FIELD
        _buildTextField(
          controller: _nameController,
          label: "Food Name",
          hintText: "Enter food name",
          validator: (v) => v!.trim().isEmpty ? "Please enter food name" : null,
          icon: Icons.fastfood_rounded,
        ),
        const SizedBox(height: 16),

        // DESCRIPTION FIELD
        _buildTextField(
          controller: _descController,
          label: "Description",
          hintText: "Describe the food item...",
          maxLines: 3,
          icon: Icons.description_rounded,
        ),
        const SizedBox(height: 16),

        // PRICE FIELD
        _buildTextField(
          controller: _priceController,
          label: "Price",
          hintText: "0.00",
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v!.trim().isEmpty) return "Please enter price";
            if (double.tryParse(v) == null) return "Please enter valid price";
            return null;
          },
          icon: Icons.currency_rupee_rounded,
          prefix: const Text("₹ "),
        ),
        const SizedBox(height: 16),

        // NUTRITION FIELD
        _buildTextField(
          controller: _nutritionController,
          label: "Nutrition Info (Optional)",
          hintText: "Calories, protein, carbs, etc.",
          icon: Icons.fitness_center_rounded,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? icon,
    Widget? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.deepPurple)
                : null,
            prefix: prefix,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            _isAvailable
                ? Icons.check_circle_rounded
                : Icons.remove_circle_rounded,
            color: _isAvailable ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAvailable ? "Available" : "Not Available",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _isAvailable ? Colors.green : Colors.orange,
                  ),
                ),
                Text(
                  _isAvailable
                      ? "This item is available for ordering"
                      : "This item is temporarily unavailable",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (value) => setState(() => _isAvailable = value),
            activeColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool editing) {
    return _isUploading
        ? const CircularProgressIndicator(color: Colors.deepPurple)
        : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: saveItem,
              child: Text(
                editing ? "Save Changes" : "Add Food Item",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
  }
}
