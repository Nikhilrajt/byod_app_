import 'package:flutter/material.dart';

class UserManagement extends StatelessWidget {
  const UserManagement({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Core scrollable view for efficiency
      body: ListView.builder(
        itemCount: 10, // We will display 10 placeholder users
        // 2. Function to build each item in the list
        itemBuilder: (BuildContext context, int index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 2,
            child: ListTile(
              // User Icon
              leading: Icon(Icons.person, color: Colors.blueGrey),
    
              // Dynamic Title: User 1, User 2, etc.
              title: Text('User ${index + 1}'),
    
              // User Role/Status
              subtitle: Text('Role: Customer'),
    
              // Action Icon (e.g., Edit)
              trailing: Icon(Icons.edit, color: Colors.grey),
    
              onTap: () {
                // Future function: Navigate to user details or open an edit modal
              },
            ),
          );
        },
      ),
    );
  }
}