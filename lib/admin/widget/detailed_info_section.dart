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
    // Determine the screen width to set flexible constraints
    final screenWidth = MediaQuery.of(context).size.width;
    // Note: cardWidth calculation is now redundant since we use ConstrainedBox, 
    // but leaving it in for reference if dynamic width logic were needed later.
    final cardWidth = screenWidth > 900 ? (screenWidth / 2) - 100 : screenWidth - 40;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 360, // Minimum sensible width
        maxWidth: 420, // Maximum width to ensure two columns fit comfortably on a standard desktop
      ),
      child: Card(
        elevation: 4.0,
        color: const Color(0xFF1E1E1E), // Dark background for the card
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
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
      ),
    );
  }
}
