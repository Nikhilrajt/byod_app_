// lib/widgets/sales_performance_section.dart
import 'package:flutter/material.dart';

class SalesPerformanceSection extends StatelessWidget {
  const SalesPerformanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Performance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Divider(height: 20, thickness: 1, color: Colors.grey),
            const Text(
              'Weekly Revenue Trends',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 10),
            // Placeholder for a graph/chart
            Container(
              height: 100,
              color:
                  Colors.blueGrey.shade800, // Darker placeholder for chart area
              alignment: Alignment.center,
              child: const Text(
                'Graph/Chart Placeholder',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '\$12,345',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                    Text(
                      'Avg. Order Value:',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text('\$8.80', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
