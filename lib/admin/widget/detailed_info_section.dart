import 'package:flutter/material.dart';

// NOTE: This class is defined with an underscore (_) to match how it's used in dashboard_content.dart.
// It is now a StatefulWidget to allow for internal state management (e.g., toggles).
class DetailedInfoSection extends StatefulWidget {
  final String title;
  final List<Widget> children; // List of rows, toggles, etc.
  final Widget? footer; // Optional buttons or actions at the bottom

  const DetailedInfoSection({
    super.key,
    required this.title,
    required this.children,
    this.footer,
  });

  @override
  State<DetailedInfoSection> createState() => DetailedInfoSectionState();
}

class DetailedInfoSectionState extends State<DetailedInfoSection> {
  @override
  Widget build(BuildContext context) {
    // Let the parent (GridView) control the width of each card. Avoid fixed
    // min/max widths which can force children larger than their grid cell and
    // cause overflow on narrow screens. Cards will take available space.
    return Card(
      elevation: 4.0,
      color: const Color(0xFF1E1E1E), // Dark background for the card
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              // Accessing property via widget.title
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Divider(height: 25, thickness: 1, color: Color(0xFF3A3A3A)),

            // Content rows (e.g., Status, Cuisine, Address)
            // Accessing property via widget.children
            ...widget.children,

            if (widget.footer != null) ...[
              const SizedBox(height: 20),
              // Accessing property via widget.footer
              widget.footer!,
            ],
          ],
        ),
      ),
    );
  }
}
