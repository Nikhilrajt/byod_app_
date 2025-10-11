
import 'package:flutter/material.dart';

class CompletedOrdersPage extends StatelessWidget {
  const CompletedOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Orders'),
      ),
      body: const Center(
        child: Text('Completed Orders Page'),
      ),
    );
  }
}
