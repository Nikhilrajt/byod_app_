
import 'package:flutter/material.dart';

class RestaurantProfilePage extends StatelessWidget {
  const RestaurantProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Profile'),
      ),
      body: const Center(
        child: Text('Restaurant Profile Page'),
      ),
    );
  }
}
