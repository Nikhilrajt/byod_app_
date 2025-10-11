
import 'package:flutter/material.dart';

class DeliverySettingsPage extends StatelessWidget {
  const DeliverySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Settings'),
      ),
      body: const Center(
        child: Text('Delivery Settings Page'),
      ),
    );
  }
}
