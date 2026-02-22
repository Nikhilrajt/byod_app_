import 'package:flutter/material.dart';
import 'package:project/admin/carousel_widget.dart';

class AdminCarouselPage extends StatelessWidget {
  const AdminCarouselPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Carousels'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.restaurant),
                text: 'Normal',
              ),
              Tab(
                icon: Icon(Icons.health_and_safety),
                text: 'Health Mode',
              ),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70, // Make unselected tabs visible
          ),
        ),
        body: const TabBarView(
          children: [
            CarouselManagementWidget(collectionName: 'carousel_banners'),
            CarouselManagementWidget(collectionName: 'health_mode_carousel'),
          ],
        ),
      ),
    );
  }
}
