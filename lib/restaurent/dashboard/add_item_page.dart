// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:project/models/menu_item_model.dart';
// import 'package:project/services/upload_image.dart';

// class AddItemPage extends StatefulWidget {
//   final String categoryId;
//   final String categoryName;
//   final MenuItem? initialItem;

//   const AddItemPage({
//     super.key,
//     required this.categoryId,
//     required this.categoryName,
//     this.initialItem,
//   });

//   @override
//   State<AddItemPage> createState() => _AddItemPageState();
// }

// class _AddItemPageState extends State<AddItemPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _nutritionController = TextEditingController();

//   final ImagePicker _picker = ImagePicker();
//   final CloudneryUploader _cloudUploader = CloudneryUploader();
//   FirebaseAuth _auth = FirebaseAuth.instance;
//   XFile? _pickedImage;
//   bool _isUploading = false;
//   bool _isVeg = true; // true for Veg, false for Non-Veg
//   bool _isAvailable = true;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.initialItem != null) {
//       final item = widget.initialItem!;
//       _nameController.text = item.name;
//       _descController.text = item.description;
//       _priceController.text = item.price.toString();
//       _nutritionController.text = item.nutrition ?? "";
//       _isAvailable = item.isAvailable;
//       // Note: You might want to add veg/non-veg field to your MenuItem model
//     }
//   }

//   Future<void> pickImage() async {
//     final img = await _picker.pickImage(source: ImageSource.gallery);
//     if (img != null) setState(() => _pickedImage = img);
//   }

//   Future<void> saveItem() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isUploading = true);

//     String? imageUrl = widget.initialItem?.imageUrl;

//     if (_pickedImage != null) {
//       imageUrl = await _cloudUploader.uploadFile(_pickedImage!);
//     }

//     final itemId =
//         widget.initialItem?.id ??
//         DateTime.now().millisecondsSinceEpoch.toString();

//     final item = MenuItem(
//       id: itemId,
//       name: _nameController.text.trim(),
//       description: _descController.text.trim(),
//       price: double.tryParse(_priceController.text.trim()) ?? 0,
//       nutrition: _nutritionController.text.trim(),
//       imageUrl: imageUrl,
//       isAvailable: _isAvailable,
//       restaurantId: _auth.currentUser!.uid,
//       // Add this field to your MenuItem model:
//       // isVeg: _isVeg,
//     );

//     await FirebaseFirestore.instance
//         .collection("categories")
//         .doc(widget.categoryId)
//         .collection("items")
//         .doc(itemId)
//         .set(item.toMap());

//     if (mounted) Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final editing = widget.initialItem != null;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           editing
//               ? "Edit ${widget.categoryName} Item"
//               : "Add Item to ${widget.categoryName}",
//         ),
//         backgroundColor: Colors.deepPurple,
//         actions: [
//           TextButton(
//             onPressed: saveItem,
//             child: const Text("Save", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // 🖼️ ENHANCED IMAGE PICKER
//               _buildImagePicker(),
//               const SizedBox(height: 24),

//               // 🍽️ FOOD TYPE SELECTOR (Veg/Non-Veg)
//               _buildFoodTypeSelector(),
//               const SizedBox(height: 20),

//               // 📝 ENHANCED FORM FIELDS
//               _buildFormFields(),
//               const SizedBox(height: 20),

//               // ✅ AVAILABILITY SWITCH
//               _buildAvailabilitySwitch(),
//               const SizedBox(height: 24),

//               // 💾 SAVE BUTTON
//               _buildSaveButton(editing),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildImagePicker() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Food Image",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: pickImage,
//           child: Container(
//             height: 180,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               color: Colors.grey.shade100,
//               border: Border.all(color: Colors.grey.shade300),
//               image: _buildBackgroundImage(),
//             ),
//             child: _buildImagePickerContent(),
//           ),
//         ),
//       ],
//     );
//   }

//   DecorationImage? _buildBackgroundImage() {
//     if (_pickedImage != null) {
//       return DecorationImage(
//         image: FileImage(File(_pickedImage!.path)),
//         fit: BoxFit.cover,
//       );
//     } else if (widget.initialItem?.imageUrl != null) {
//       return DecorationImage(
//         image: NetworkImage(widget.initialItem!.imageUrl!),
//         fit: BoxFit.cover,
//       );
//     }
//     return null;
//   }

//   Widget _buildImagePickerContent() {
//     if (_pickedImage != null || widget.initialItem?.imageUrl != null) {
//       return Stack(
//         children: [
//           Container(),
//           Positioned(
//             bottom: 8,
//             right: 8,
//             child: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.black54,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(Icons.edit, color: Colors.white, size: 20),
//             ),
//           ),
//         ],
//       );
//     }

//     return const Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
//         SizedBox(height: 8),
//         Text(
//           "Tap to add food image",
//           style: TextStyle(color: Colors.grey, fontSize: 14),
//         ),
//       ],
//     );
//   }

//   Widget _buildFoodTypeSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Food Type",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: _buildFoodTypeCard(
//                 "Vegetarian",
//                 _isVeg,
//                 Colors.green,
//                 Icons.eco_rounded,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildFoodTypeCard(
//                 "Non-Vegetarian",
//                 !_isVeg,
//                 Colors.red,
//                 Icons.restaurant_rounded,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildFoodTypeCard(
//     String title,
//     bool isSelected,
//     Color color,
//     IconData icon,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _isVeg = title == "Vegetarian";
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? color : Colors.transparent,
//             width: 2,
//           ),
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: isSelected ? color : Colors.grey,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: Colors.white, size: 20),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: isSelected ? color : Colors.grey.shade700,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFormFields() {
//     return Column(
//       children: [
//         // NAME FIELD
//         _buildTextField(
//           controller: _nameController,
//           label: "Food Name",
//           hintText: "Enter food name",
//           validator: (v) => v!.trim().isEmpty ? "Please enter food name" : null,
//           icon: Icons.fastfood_rounded,
//         ),
//         const SizedBox(height: 16),

//         // DESCRIPTION FIELD
//         _buildTextField(
//           controller: _descController,
//           label: "Description",
//           hintText: "Describe the food item...",
//           maxLines: 3,
//           icon: Icons.description_rounded,
//         ),
//         const SizedBox(height: 16),

//         // PRICE FIELD
//         _buildTextField(
//           controller: _priceController,
//           label: "Price",
//           hintText: "0.00",
//           keyboardType: TextInputType.number,
//           validator: (v) {
//             if (v!.trim().isEmpty) return "Please enter price";
//             if (double.tryParse(v) == null) return "Please enter valid price";
//             return null;
//           },
//           icon: Icons.currency_rupee_rounded,
//           prefix: const Text("₹ "),
//         ),
//         const SizedBox(height: 16),

//         // NUTRITION FIELD
//         _buildTextField(
//           controller: _nutritionController,
//           label: "Nutrition Info (Optional)",
//           hintText: "Calories, protein, carbs, etc.",
//           icon: Icons.fitness_center_rounded,
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hintText,
//     String? Function(String?)? validator,
//     TextInputType? keyboardType,
//     int maxLines = 1,
//     IconData? icon,
//     Widget? prefix,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 6),
//         TextFormField(
//           controller: controller,
//           validator: validator,
//           keyboardType: keyboardType,
//           maxLines: maxLines,
//           decoration: InputDecoration(
//             hintText: hintText,
//             prefixIcon: icon != null
//                 ? Icon(icon, color: Colors.deepPurple)
//                 : null,
//             prefix: prefix,
//             filled: true,
//             fillColor: Colors.grey.shade50,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAvailabilitySwitch() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             _isAvailable
//                 ? Icons.check_circle_rounded
//                 : Icons.remove_circle_rounded,
//             color: _isAvailable ? Colors.green : Colors.orange,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _isAvailable ? "Available" : "Not Available",
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: _isAvailable ? Colors.green : Colors.orange,
//                   ),
//                 ),
//                 Text(
//                   _isAvailable
//                       ? "This item is available for ordering"
//                       : "This item is temporarily unavailable",
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//           Switch(
//             value: _isAvailable,
//             onChanged: (value) => setState(() => _isAvailable = value),
//             activeColor: Colors.deepPurple,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSaveButton(bool editing) {
//     return _isUploading
//         ? const CircularProgressIndicator(color: Colors.deepPurple)
//         : SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 2,
//               ),
//               onPressed: saveItem,
//               child: Text(
//                 editing ? "Save Changes" : "Add Food Item",
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           );
//   }
// }
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

    String? imageUrl = widget.initialItem?.imageUrl;

    if (_pickedImage != null) {
      imageUrl = await _cloudUploader.uploadFile(_pickedImage!);
    }

    final itemId =
        widget.initialItem?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
_variantGroups.forEach((e) {
  e.isHealthy = _isHealthy;
});

    final item = MenuItem(
      id: itemId,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      nutrition: _nutritionController.text.trim(),
      imageUrl: imageUrl,
      isAvailable: _isAvailable,
      isVeg: _isVeg,
      restaurantId: _auth.currentUser!.uid,
      isCustomizable: _isCustomizable,
      variantGroups: _variantGroups,
      isHealthy: _isHealthy,
    );

    await FirebaseFirestore.instance
        .collection("categories")
        .doc(widget.categoryId)
        .collection("items")
        .doc(itemId)
        .set(item.toMap(), SetOptions(merge: true));

    if (mounted) Navigator.pop(context);
  }

  // -------- UI BELOW REMAINS SAME (NO BREAKING CHANGES) --------

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
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildFoodTypeSelector(),
              const SizedBox(height: 20),
              _buildFormFields(),
              const SizedBox(height: 20),
              _buildHealthySwitch(), // ⭐ ADD THIS
              const SizedBox(height: 20),
              _buildAvailabilitySwitch(),

              const SizedBox(height: 20),

              // ⭐ CUSTOMIZATION GROUP LIST
              if (_isCustomizable) _buildCustomizationGroups(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI METHODS REMAIN UNCHANGED ----------------
  // (image picker, fields, save button etc.)

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
        ),
        child: _pickedImage == null && widget.initialItem?.imageUrl == null
            ? const Center(
                child: Icon(
                  Icons.add_photo_alternate,
                  size: 40,
                  color: Colors.grey,
                ),
              )
            : Container(),
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
          ),
        ),
        Expanded(
          child: RadioListTile(
            value: false,
            groupValue: _isVeg,
            onChanged: (v) => setState(() => _isVeg = false),
            title: const Text("Non-Veg"),
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
          decoration: const InputDecoration(labelText: "Name"),
          validator: (v) => v!.isEmpty ? "Enter food name" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descController,
          decoration: const InputDecoration(labelText: "Description"),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Price"),
          validator: (v) =>
              double.tryParse(v!) == null ? "Enter valid price" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nutritionController,
          decoration: const InputDecoration(labelText: "Nutrition"),
        ),
      ],
    );
  }

  Widget _buildHealthySwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.health_and_safety, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Healthy Food",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Enable this if this food is suitable for Health Mode",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Switch(
            value: _isHealthy,
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
            onChanged: (v) => setState(() => _isHealthy = v),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySwitch() {
    return SwitchListTile(
      value: _isAvailable,
      title: Text(_isAvailable ? "Available" : "Unavailable"),
      onChanged: (v) => setState(() => _isAvailable = v),
    );
  }

  Widget _buildCustomizationSwitch() {
    return SwitchListTile(
      value: _isCustomizable,
      title: const Text("Enable Customization"),
      subtitle: const Text("Let customers choose variants"),
      onChanged: (v) => setState(() => _isCustomizable = v),
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
              "Customization Groups",
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
          const Text(
            "No customization groups",
            style: TextStyle(color: Colors.grey),
          ),
        ..._variantGroups.map(
          (g) => Card(
            child: ListTile(
              title: Text(g.name),
              subtitle: Text(
                "${g.options.length} options • "
                "${g.isRequired ? 'Required' : 'Optional'}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
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

  Widget _buildSaveButton(bool editing) {
    return _isUploading
        ? const CircularProgressIndicator()
        : ElevatedButton(
            onPressed: saveItem,
            child: Text(editing ? "Save Changes" : "Add Item"),
          );
  }
}

// ========================================
// VARIANT GROUP DIALOG
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
  int? _minSelection;
  bool _isHealthy = false;
  int? _maxSelection;
  List<VariantOption> _options = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialGroup != null) {
      final group = widget.initialGroup!;
      _nameController.text = group.name;
      _isRequired = group.isRequired;
      _allowMultiple = group.allowMultiple;
      _minSelection = group.minSelection;
      _maxSelection = group.maxSelection;
      _options = List.from(group.options);
      _isHealthy = group.isHealthy;
    }
  }

  void _addOption() {
    showDialog(
      context: context,
      builder: (context) => _VariantOptionDialog(
        onSave: (option) {
          setState(() => _options.add(option));
        },
      ),
    );
  }

  void _editOption(int index) {
    showDialog(
      context: context,
      builder: (context) => _VariantOptionDialog(
        initialOption: _options[index],
        onSave: (option) {
          setState(() => _options[index] = option);
        },
      ),
    );
  }

  void _deleteOption(int index) {
    setState(() => _options.removeAt(index));
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter group name")));
      return;
    }

    if (_options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one option")),
      );
      return;
    }

    final group = VariantGroup(
      id:
          widget.initialGroup?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      isRequired: _isRequired,
      allowMultiple: _allowMultiple,
      minSelection: _minSelection,
      maxSelection: _maxSelection,
      options: _options,
    );

    widget.onSave(group);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialGroup == null
                    ? "Add Customization Group"
                    : "Edit Customization Group",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // GROUP NAME
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Group Name (e.g., Size, Toppings, Spice Level)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SETTINGS
              SwitchListTile(
                title: const Text("Required"),
                subtitle: const Text("Customer must select an option"),
                value: _isRequired,
                onChanged: (v) => setState(() => _isRequired = v),
              ),
              SwitchListTile(
                title: const Text("Allow Multiple Selection"),
                subtitle: const Text("Customer can choose multiple options"),
                value: _allowMultiple,
                onChanged: (v) => setState(() => _allowMultiple = v),
              ),

              const Divider(),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text(
                  "Healthy Food",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                value: _isHealthy,
                activeColor: Colors.white,
                activeTrackColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    _isHealthy = value;
                  });
                },
              ),

              // OPTIONS LIST
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Options",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add"),
                  ),
                ],
              ),

              Expanded(
                child: _options.isEmpty
                    ? const Center(
                        child: Text(
                          "No options added yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _options.length,
                        itemBuilder: (context, index) {
                          final option = _options[index];
                          return Card(
                            child: ListTile(
                              title: Text(option.name),
                              subtitle: Text(
                                option.priceModifier != 0
                                    ? "+₹${option.priceModifier.toStringAsFixed(0)}"
                                    : "No extra charge",
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _editOption(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () => _deleteOption(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),

              // ACTION BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// VARIANT OPTION DIALOG
// ========================================

class _VariantOptionDialog extends StatefulWidget {
  final VariantOption? initialOption;
  final Function(VariantOption) onSave;

  const _VariantOptionDialog({this.initialOption, required this.onSave});

  @override
  State<_VariantOptionDialog> createState() => _VariantOptionDialogState();
}

class _VariantOptionDialogState extends State<_VariantOptionDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialOption != null) {
      final option = widget.initialOption!;
      _nameController.text = option.name;
      _priceController.text = option.priceModifier.toString();
      _isAvailable = option.isAvailable;
    }
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter option name")));
      return;
    }

    final option = VariantOption(
      id:
          widget.initialOption?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      priceModifier: double.tryParse(_priceController.text.trim()) ?? 0,
      isAvailable: _isAvailable,
    );

    widget.onSave(option);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialOption == null ? "Add Option" : "Edit Option"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Option Name (e.g., Large, Extra Cheese)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Additional Price (₹)",
              hintText: "0 for no extra charge",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text("Available"),
            value: _isAvailable,
            onChanged: (v) => setState(() => _isAvailable = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          child: const Text("Save"),
        ),
      ],
    );
  }
}
