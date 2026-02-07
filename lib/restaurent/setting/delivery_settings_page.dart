import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeliverySettingsPage extends StatefulWidget {
  const DeliverySettingsPage({super.key});

  @override
  State<DeliverySettingsPage> createState() => _DeliverySettingsPageState();
}

class _DeliverySettingsPageState extends State<DeliverySettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _radiusController = TextEditingController();
  final TextEditingController _baseFeeController = TextEditingController();
  final TextEditingController _minOrderController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _freeDeliveryController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final settings =
            data['deliverySettings'] as Map<String, dynamic>? ?? {};

        setState(() {
          _radiusController.text = (settings['deliveryRadius'] ?? 5).toString();
          _baseFeeController.text = (settings['baseDeliveryFee'] ?? 40)
              .toString();
          _minOrderController.text = (settings['minOrderValue'] ?? 100)
              .toString();
          _prepTimeController.text = (settings['avgPrepTime'] ?? 20).toString();
          _freeDeliveryController.text =
              (settings['freeDeliveryThreshold'] ?? 500).toString();
        });
      }
    } catch (e) {
      // Handle error silently or show snackbar
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final settings = {
        'deliveryRadius': double.tryParse(_radiusController.text) ?? 5.0,
        'baseDeliveryFee': double.tryParse(_baseFeeController.text) ?? 40.0,
        'minOrderValue': double.tryParse(_minOrderController.text) ?? 100.0,
        'avgPrepTime': int.tryParse(_prepTimeController.text) ?? 20,
        'freeDeliveryThreshold':
            double.tryParse(_freeDeliveryController.text) ?? 500.0,
      };

      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user.uid)
          .set({'deliverySettings': settings}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving settings: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _baseFeeController.dispose();
    _minOrderController.dispose();
    _prepTimeController.dispose();
    _freeDeliveryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Logistics & Timing"),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      children: [
                        _buildTextField(
                          controller: _radiusController,
                          label: 'Delivery Radius (km)',
                          icon: Icons.map_outlined,
                          keyboardType: TextInputType.number,
                          helperText: 'Max distance for delivery',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _prepTimeController,
                          label: 'Avg. Preparation Time (mins)',
                          icon: Icons.timer_outlined,
                          keyboardType: TextInputType.number,
                          helperText: 'Estimated time to prepare food',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Fees & Limits"),
                    const SizedBox(height: 12),
                    _buildSettingsCard(
                      children: [
                        _buildTextField(
                          controller: _baseFeeController,
                          label: 'Base Delivery Fee (₹)',
                          icon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _minOrderController,
                          label: 'Minimum Order Value (₹)',
                          icon: Icons.shopping_cart_outlined,
                          keyboardType: TextInputType.number,
                          helperText: 'Minimum bill amount required',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _freeDeliveryController,
                          label: 'Free Delivery Above (₹)',
                          icon: Icons.local_offer_outlined,
                          keyboardType: TextInputType.number,
                          helperText: 'Cart value for free delivery',
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
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
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (keyboardType == TextInputType.number &&
            double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }
}
