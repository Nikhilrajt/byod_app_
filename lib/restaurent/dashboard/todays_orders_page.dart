import 'package:flutter/material.dart';

class TodaysOrdersPage extends StatelessWidget {
  const TodaysOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Today\'s Orders'),
      ),
      body: const Center(
        child: Text('Today\'s Orders Page'),
      ),
    );
  }
}
