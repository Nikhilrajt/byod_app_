
import 'package:flutter/material.dart';

class PendingByodRequestsPage extends StatelessWidget {
  const PendingByodRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending BYOD Requests'),
      ),
      body: const Center(
        child: Text('Pending BYOD Requests Page'),
      ),
    );
  }
}
