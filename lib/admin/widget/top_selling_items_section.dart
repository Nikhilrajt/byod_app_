import 'package:flutter/material.dart';

// Renamed to TopSellingItemsSection (removed underscore) to match external usage in DashboardContent.
class TopSellingItemsSection extends StatelessWidget {
  const TopSellingItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: const Color(0xFF1E1E1E),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      // Removed the fixed Container(width: 380) to make it responsive within the GridView.
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Top Selling Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Divider(height: 25, thickness: 1, color: Color(0xFF3A3A3A)),

            // Note: imageUrl parameter is now ignored in _buildSellingItem
            _buildSellingItem(
              'BBQ Ribs',
              '125 Sold',
              'https://via.placeholder.com/40/000080/FFFFFF?text=R',
            ),
            _buildSellingItem(
              'Pulled Pork Sandwich',
              '98 Sold',
              'https://via.placeholder.com/40/800000/FFFFFF?text=P',
            ),
            _buildSellingItem(
              'Brisket Plate',
              '75 Sold',
              'https://via.placeholder.com/40/008000/FFFFFF?text=B',
            ),
            _buildSellingItem(
              'Coleslaw Side',
              '55 Sold',
              'https://via.placeholder.com/40/808000/FFFFFF?text=C',
            ),

            const SizedBox(height: 10),
            // Use SizedBox(width: double.infinity) to make the TextButton full width
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft, // Align text to the left
                ),
                child: const Text(
                  'View Full Menu Performance',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated to remove the image display components.
  Widget _buildSellingItem(String item, String soldAmount, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        // Removed the ClipRRect and Image.network here
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Item Name (now aligned to the left of the expanded row)
                Text(
                  item,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),

                // Sold Amount Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    soldAmount,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
