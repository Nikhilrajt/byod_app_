import 'package:flutter/material.dart';

class TodaysEarningsPage extends StatelessWidget {
  const TodaysEarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Earnings'),
      ),
      body: const Center(
        child: Text('Today\'s Earnings Page'),
      ),
    );
  }
}
