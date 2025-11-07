import 'package:flutter/material.dart';
import 'edit_user_role.dart';

class UserModel {
  String name;
  String role;

  UserModel({required this.name, this.role = 'user'});
}

class UserManagement extends StatefulWidget {
  const UserManagement({Key? key}) : super(key: key);

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  final List<UserModel> _users = List.generate(
    10,
    (i) => UserModel(name: 'User ${i + 1}'),
  );

  List<UserModel> get _all => _users;

  Future<void> _editRole(int index) async {
    final current = _users[index].role;
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => EditUserRolePage(
          userName: _users[index].name,
          initialRole: current,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _users[index].role = result);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Role updated to "$result"')));
    }
  }

  void _addUser() async {
    final nameCtrl = TextEditingController();
    final role = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add User'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop('user'),
            child: const Text('Next'),
          ),
        ],
      ),
    );

    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _users.add(UserModel(name: name, role: role ?? 'user')));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('User added')));
  }

  void _showDetails(int index) {
    final user = _users[index];
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Role: ${user.role}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _editRole(index);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      final removed = _users.removeAt(index);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${removed.name} deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              setState(() => _users.insert(index, removed));
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final q = await showSearch<String?>(
                context: context,
                delegate: _UserSearchDelegate(_all),
              );
              if (q != null && q.isNotEmpty) {
                // navigate to first match
                final idx = _users.indexWhere(
                  (u) => u.name.toLowerCase() == q.toLowerCase(),
                );
                if (idx != -1) _showDetails(idx);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: const Icon(Icons.person_add),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (BuildContext context, int index) {
          final user = _users[index];

          return Dismissible(
            key: ValueKey(user.name + index.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              color: Colors.redAccent,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              final removed = _users.removeAt(index);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${removed.name} deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      setState(() => _users.insert(index, removed));
                    },
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade100,
                  child: Text(
                    _initials(user.name),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                minLeadingWidth: 56,
                horizontalTitleGap: 12,
                title: Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Role: ${user.role[0].toUpperCase()}${user.role.substring(1)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () => _editRole(index),
                ),
                onTap: () => _showDetails(index),
              ),
            ),
          );
        },
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _UserSearchDelegate extends SearchDelegate<String?> {
  final List<UserModel> all;
  _UserSearchDelegate(this.all);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.trim().toLowerCase();
    final matches = q.isEmpty
        ? all
        : all.where((u) => u.name.toLowerCase().contains(q)).toList();
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (ctx, i) => ListTile(
        title: Text(matches[i].name),
        subtitle: Text(
          'Role: ${matches[i].role}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => close(context, matches[i].name),
      ),
    );
  }
}
