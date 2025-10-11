import 'package:flutter/material.dart';

class Staff {
  String name;
  String role;
  String contact;

  Staff({this.name = '', this.role = '', this.contact = ''});
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
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // customers removed as requested
  final List<Staff> _staff = [];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // For now just show snackbar; persist to backend as needed.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    }
  }

  // customer dialogs removed

  Future<void> _showCoordinatesDialog() async {
    final latCtrl = TextEditingController(text: _latController.text);
    final lngCtrl = TextEditingController(text: _lngController.text);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set precise location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: latCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
              TextFormField(
                controller: lngCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Longitude'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _latController.text = latCtrl.text.trim();
                  _lngController.text = lngCtrl.text.trim();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Staff management
  Future<void> _showStaffDialog({Staff? staff, int? index}) async {
    final isEdit = staff != null && index != null;
    final nameCtrl = TextEditingController(text: staff?.name ?? '');
    final roleCtrl = TextEditingController(text: staff?.role ?? '');
    final contactCtrl = TextEditingController(text: staff?.contact ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Staff' : 'Add Staff'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                TextFormField(
                  controller: contactCtrl,
                  decoration: const InputDecoration(labelText: 'Contact'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newStaff = Staff(
                  name: nameCtrl.text.trim(),
                  role: roleCtrl.text.trim(),
                  contact: contactCtrl.text.trim(),
                );
                setState(() {
                  if (isEdit) {
                    _staff[index] = newStaff;
                  } else {
                    _staff.add(newStaff);
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteStaff(int index) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete staff'),
        content: const Text(
          'Are you sure you want to delete this staff member?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _staff.removeAt(index));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Restaurant Name',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter name'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.location_on),
                            onPressed: _showCoordinatesDialog,
                            tooltip: 'Set precise location',
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              child: const Text('Save Profile'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_latController.text.isNotEmpty &&
                          _lngController.text.isNotEmpty)
                        SelectableText(
                          'Coordinates: ${_latController.text}, ${_lngController.text}',
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Customers section removed
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Staff',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showStaffDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: _staff.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No staff added yet.'),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _staff.length,
                      separatorBuilder: (context, i) =>
                          const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final s = _staff[i];
                        return ListTile(
                          title: Text(s.name.isEmpty ? 'Unnamed' : s.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (s.role.isNotEmpty) Text(s.role),
                              if (s.contact.isNotEmpty) Text(s.contact),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit')
                                _showStaffDialog(staff: s, index: i);
                              if (v == 'delete') _deleteStaff(i);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
