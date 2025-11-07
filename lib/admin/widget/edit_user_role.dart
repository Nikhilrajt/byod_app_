import 'package:flutter/material.dart';

class EditUserRolePage extends StatefulWidget {
  final String userName;
  final String initialRole;
  const EditUserRolePage({
    super.key,
    required this.userName,
    required this.initialRole,
  });

  @override
  State<EditUserRolePage> createState() => _EditUserRolePageState();
}

class _EditUserRolePageState extends State<EditUserRolePage> {
  static const List<String> _roles = ['user', 'restaurant', 'admin'];
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  void _save() {
    Navigator.of(context).pop(_selectedRole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Role - ${widget.userName}'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select role',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._roles.map((r) {
              final display = r[0].toUpperCase() + r.substring(1);
              return RadioListTile<String>(
                value: r,
                groupValue: _selectedRole,
                title: Text(display),
                onChanged: (v) =>
                    setState(() => _selectedRole = v ?? _selectedRole),
              );
            }).toList(),
            const SizedBox(height: 12),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text(
              '"Restaurant" users can access the restaurant module only.',
            ),
          ],
        ),
      ),
    );
  }
}
