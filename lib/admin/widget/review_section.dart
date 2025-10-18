// lib/widgets/review_section.dart
import 'package:flutter/material.dart';

class ReviewSection extends StatelessWidget {
  const ReviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Latest Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Divider(height: 20, thickness: 1, color: Colors.grey),
            _buildReviewItem('BBQ Ribs (230 sold)', 'Amazing food, definitely a must-try!', 4.5),
            _buildReviewItem('Chicken Tenders', 'Good, but ribs were a bit dry.', 3.0),
            _buildReviewItem('Burger Deluxe', 'Fantastic!', 5.0),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All Reviews',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String item, String reviewText, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              Text('\$90 sold', style: TextStyle(color: Colors.grey.shade600)), // Example data
            ],
          ),
          Row(
            children: [
              _buildStarRating(rating),
              const SizedBox(width: 5),
              Text(reviewText, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.grey.shade600, size: 16));
      }
    }
    return Row(children: stars);
  }
}