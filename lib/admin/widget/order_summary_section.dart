// // lib/widgets/order_summary_section.dart
// import 'package:flutter/material.dart';

// class OrderSummarySection extends StatelessWidget {
//   const OrderSummarySection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4.0,
//       margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Container(
//         width: 380,
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Latest Order (or Unsettled Debts)', // Title can be dynamic
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const Divider(height: 20, thickness: 1, color: Colors.grey),
//             Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Image.network(
//                     'https://via.placeholder.com/60', // Placeholder image
//                     width: 60,
//                     height: 60,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Order #7AH12B', style: TextStyle(color: Colors.white, fontSize: 16)),
//                       const Text('Value: \$55.20', style: TextStyle(color: Colors.grey)),
//                       const Text('Due: 6 days ago', style: TextStyle(color: Colors.redAccent)),
//                       const SizedBox(height: 5),
//                       // LinearProgressIndicator(
//                       //   value: 0.7, // 70% progress
//                       //   backgroundColor: Colors.grey.shade700,
//                       //   valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
//                       // )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueAccent,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size.fromHeight(40), // Full width button
//               ),
//               child: const Text('View All Orders'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }