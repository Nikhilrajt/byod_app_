// Below HomeContent or in a new file (e.g., carousel_section.dart)
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/state/health_mode_notifier.dart';

class HomeBannerCarousel extends StatefulWidget {
  final List<String> banners;
  final bool healthMode;

  const HomeBannerCarousel({
    super.key,
    required this.banners,
    required this.healthMode,
  });

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  int _currentOffer = 0; // State is now local to the carousel

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;
    final healthMode = widget.healthMode;
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 900;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: banners.length,
          options: CarouselOptions(
            height: isWide ? 320 : 240,
            autoPlay: true,
            enlargeCenterPage: true,
            onPageChanged: (i, _) => setState(() => _currentOffer = i), // 🔥 This setState only rebuilds this widget!
          ),
          itemBuilder: (_, i, __) {
            return GestureDetector(
              onTap: () {
                if (banners[i] == 'assets/images/4.png') {
                  context.read<HealthModeNotifier>().toggle();
                  final enabled = context.read<HealthModeNotifier>().isOn;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        enabled
                            ? 'Health mode activated via banner! 🥗'
                            : 'Health mode deactivated.',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isWide ? 18 : 14),
                child: Image.asset(banners[i], fit: BoxFit.cover),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _currentOffer == i ? 18 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _currentOffer == i
                    ? (healthMode ? Colors.green : Colors.deepOrange)
                    : Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}