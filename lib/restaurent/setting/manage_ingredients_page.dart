
import 'package:flutter/material.dart';

class ManageIngredientsPage extends StatelessWidget {
  const ManageIngredientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Ingredients'),
      ),
      body: const Center(
        child: Text('Manage Ingredients Page'),
      ),
    );
  }
}
