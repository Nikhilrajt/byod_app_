import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/state/health_mode_notifier.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeBannerCarousel extends StatefulWidget {
  final bool healthMode;

  const HomeBannerCarousel({super.key, required this.healthMode});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  int _currentOffer = 0;
  Future<QuerySnapshot>? _bannersFuture;

  @override
  void initState() {
    super.initState();
    _bannersFuture = _getBanners();
  }

  Future<QuerySnapshot> _getBanners() {
    final collectionName = widget.healthMode
        ? 'health_mode_carousel'
        : 'carousel_banners';
    return FirebaseFirestore.instance
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .get();
  }

  @override
  void didUpdateWidget(covariant HomeBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.healthMode != widget.healthMode) {
      setState(() {
        _bannersFuture = _getBanners();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 900;

    return FutureBuilder<QuerySnapshot>(
      future: _bannersFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('No banners found.'));
        }

        return Column(
          children: [
            CarouselSlider.builder(
              itemCount: docs.length,
              options: CarouselOptions(
                height: isWide ? 340 : 260,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.95,
                onPageChanged: (i, _) => setState(() => _currentOffer = i),
              ),
              itemBuilder: (_, i, __) {
                final data = docs[i].data() as Map<String, dynamic>;
                final imageUrl = data['imageUrl'] ?? '';
                return GestureDetector(
                  onTap: () {
                    // Example of a custom action. You might want to remove this
                    // or adapt it to your needs.
                    if (imageUrl.contains('your_special_identifier')) {
                      context.read<HealthModeNotifier>().toggle();
                      final enabled = context.read<HealthModeNotifier>().isOn;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            enabled
                                ? 'Health mode was toggled via banner! 🥗'
                                : 'Health mode was deactivated via banner.',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.healthMode
                                ? Colors.green
                                : Colors.deepOrange,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                docs.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _currentOffer == i ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _currentOffer == i
                        ? (widget.healthMode ? Colors.green : Colors.deepOrange)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
