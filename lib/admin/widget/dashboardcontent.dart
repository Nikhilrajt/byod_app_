import 'package:flutter/material.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GridView.builder(
        // 1. Define the grid layout (e.g., how many columns)
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 2 items per row
          crossAxisSpacing: 10.0, // horizontal spacing
          mainAxisSpacing: 10.0, // vertical spacing
          childAspectRatio: 0.8, // ratio of width to height for each item
        ),
        padding: const EdgeInsets.all(10.0), // padding around the entire grid
        itemCount: 10, // Total number of items in the grid
        // 2. The builder function for each item
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
            // Optional: Specify a fixed size for the container if needed,
            // though the GridView's gridDelegate usually handles sizing.
            // If you set a size here, it might be constrained by the delegate.
            // For this specific requirement, we'll use the available space.
            // The delegate defines the size, so we wrap the Card directly.
            child: Card(
              elevation: 4.0, // Shadow for the card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'Item ${index + 1}',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}