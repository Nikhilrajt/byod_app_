import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ================= COLOR THEME =================
const Color kPrimary = Color(0xFF3F2B96);
const Color kSecondary = Color(0xFF5F5AA2);
const Color kAccent = Color(0xFF4CAF50);
const Color kBg = Color(0xFFF6F7FB);
const Color kTextDark = Color(0xFF2E2E2E);
const Color kTextLight = Color(0xFF7A7A7A);

// =====================================================
// SLIDE TO TOGGLE BYOD (ENABLE / DISABLE)
// =====================================================
class SlideEnableBYOD extends StatefulWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const SlideEnableBYOD({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<SlideEnableBYOD> createState() => _SlideEnableBYODState();
}

class _SlideEnableBYODState extends State<SlideEnableBYOD> {
  double _dragX = 0;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width - 80;
    const double knobSize = 56;
    final double maxX = width - knobSize;

    // Base position depends on state
    final double basePosition = widget.enabled ? maxX : 0;

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.enabled),
      child: Container(
        height: 56,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: widget.enabled
                ? [
                    const Color.fromARGB(255, 197, 137, 15),
                    const Color.fromARGB(255, 51, 2, 11).withOpacity(0.8),
                  ] // DISABLED → left
                : [
                    kPrimary,
                    const Color.fromARGB(255, 40, 2, 74),
                  ], // ENABLED → right
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                widget.enabled ? 'B Y O D' : 'B Y O D',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),

            // SLIDER KNOB
            Positioned(
              left: (basePosition + _dragX).clamp(0.0, maxX),
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragX += details.delta.dx;
                  });
                },
                onHorizontalDragEnd: (_) {
                  final double finalPos = basePosition + _dragX;

                  if (finalPos > maxX / 2) {
                    widget.onChanged(true); // ENABLE
                  } else {
                    widget.onChanged(false); // DISABLE
                  }

                  setState(() {
                    _dragX = 0; // reset drag offset
                  });
                },
                child: Container(
                  height: knobSize,
                  width: knobSize,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.enabled
                        ? Icons.arrow_back_ios_new
                        : Icons.arrow_forward_ios,
                    color: kPrimary,
                    size: 18,
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

// =====================================================
// RESTAURANT PROFILE PAGE
// =====================================================
class RestaurantProfilePage extends StatefulWidget {
  const RestaurantProfilePage({super.key});

  @override
  State<RestaurantProfilePage> createState() => _RestaurantProfilePageState();
}

class _RestaurantProfilePageState extends State<RestaurantProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditing = false;
  bool _byodEnabled = false;
  bool _isLoading = true;

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _imageFile;

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['fullName'] ?? '';
          _addressController.text = data['address'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _emailController.text = data['email'] ?? '';
          _byodEnabled = data['isByodEnabled'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleBYOD(bool value) async {
    setState(() => _byodEnabled = value);
    try {
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'isByodEnabled': value});
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(value ? 'BYOD enabled' : 'BYOD disabled')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _byodEnabled = !value); // Revert on failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update setting')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageFile = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Restaurant Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [kPrimary, kSecondary]),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ================= PROFILE HEADER =================
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _imageFile != null
                                  ? FileImage(File(_imageFile!.path))
                                  : null,
                              child: _imageFile == null
                                  ? const Icon(
                                      Icons.restaurant,
                                      size: 46,
                                      color: kPrimary,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _nameController.text,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kTextDark,
                            ),
                          ),
                          Text(
                            _emailController.text,
                            style: const TextStyle(color: kTextLight),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= INFO CARD =================
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Restaurant Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kTextDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              _nameController,
                              'Restaurant Name',
                              Icons.store,
                            ),
                            _buildField(
                              _addressController,
                              'Address',
                              Icons.location_on,
                            ),
                            _buildField(_phoneController, 'Phone', Icons.phone),
                            _buildField(_emailController, 'Email', Icons.email),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= BYOD CARD =================
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.restaurant_menu, color: kAccent),
                              SizedBox(width: 8),
                              Text(
                                'BYOD Feature',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kTextDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Allow customers to order a food item which can be customisable as their desire.',
                            style: TextStyle(color: kTextLight),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: SlideEnableBYOD(
                              enabled: _byodEnabled,
                              onChanged: _toggleBYOD,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .update({
                                  'fullName': _nameController.text.trim(),
                                  'address': _addressController.text.trim(),
                                  'phoneNumber': _phoneController.text.trim(),
                                  'email': _emailController.text.trim(),
                                });
                          }
                          setState(() => _isEditing = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile Updated')),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: kPrimary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
