import 'package:flutter/material.dart';

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({super.key});

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  final List<Map<String, dynamic>> _users = [
    {
      "name": "Alice Johnson",
      "email": "alice.j@example.com",
      "isActive": true,
    },
    {
      "name": "Bob Williams",
      "email": "bob.w@example.com",
      "isActive": false,
    },
    {
      "name": "Charlie Brown",
      "email": "charlie.b@example.com",
      "isActive": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Users'),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return _buildUserTile(_users[index], index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your logic here to add a new user
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['name'],
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(user['email']),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _users[index]['isActive'] =
                          !_users[index]['isActive'];
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        user['isActive'] ? Colors.green : Colors.grey,
                  ),
                  child: Text(user['isActive'] ? 'Active' : 'Deactivated'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _users.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
