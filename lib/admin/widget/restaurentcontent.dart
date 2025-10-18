import 'package:flutter/material.dart';

class RestaurentContent extends StatelessWidget {
  const RestaurentContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.restaurant),
              title: Text('Restaurant Management'),
              subtitle: Text('Manage your restaurants here'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle tap event
              },
            ),
          );
        },
      ),
    );
  }
}
