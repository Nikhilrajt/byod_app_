import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project/admin/admin_category.dart';
import 'package:project/admin/admin_ingredient.dart';
import 'package:project/admin/admin_carousel.dart';
import 'package:project/admin/restaurant_admin.dart';
import 'package:project/admin/settings_admin.dart';
import 'package:project/admin/user_admin.dart';
import 'package:project/admin/review_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Users',
      'icon': Icons.people,
      'color': Colors.blue,
      'page': const AdminUserPage(),
      'description': 'Manage user accounts',
    },
    {
      'title': 'Restaurants',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'page': const AdminRestaurantPage(),
      'description': 'Manage restaurants',
    },
    {
      'title': 'Categories',
      'icon': Icons.category,
      'color': Colors.purple,
      'page': const AdminCategoryPage(),
      'description': 'Manage food categories',
    },
    {
      'title': 'Reviews',
      'icon': Icons.rate_review,
      'color': Colors.red,
      'page': const AdminReviewPage(),
      'description': 'Monitor reviews',
    },

    {
      'title': 'Collections',
      'icon': Icons.grid_view,
      'color': Colors.green,
      'page': const AdminIngredientPage(),
      'description': 'Manage collections',
    },
    {
      'title': 'Carousel',
      'icon': Icons.view_carousel,
      'color': Colors.teal,
      'page': const AdminCarouselPage(),
      'description': 'Manage home banners',
    },
    {
      'title': 'Settings',
      'icon': Icons.settings,
      'color': Colors.grey,
      'page': const AdminSettingsPage(),
      'description': 'System settings',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            const SizedBox(height: 32),

            // Stats Section
            _buildStatsSection(),
            const SizedBox(height: 32),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildGridCards(),
            const SizedBox(height: 32),

            // Recent Activities
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back, Admin!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here\'s what\'s happening with your platform today.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickStat('Last Updated', 'Just now'),
              const SizedBox(width: 24),
              _buildQuickStat('System Status', 'Healthy'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Platform Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildStatCardFromStream(
              'Total Users',
              _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'user')
                  .snapshots(),
              Colors.blue,
              Icons.people,
            ),
            _buildStatCardFromStream(
              'Restaurants',
              _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'restaurant')
                  .snapshots(),
              Colors.orange,
              Icons.restaurant,
            ),
            _buildStatCardFromStream(
              'Categories',
              _firestore.collection('categories').snapshots(),
              Colors.purple,
              Icons.category,
            ),
            _buildStatCardFromStream(
              'Reviews',
              _firestore.collection('feedbacks').snapshots(),
              Colors.red,
              Icons.rate_review,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCardFromStream(
    String title,
    Stream<QuerySnapshot> stream,
    Color color,
    IconData icon,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.size : 0;
        return _buildStatCard(title, count.toString(), color, icon);
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: menuItems
          .map(
            (item) => _buildDashboardCard(
              title: item['title'],
              icon: item['icon'],
              color: item['color'],
              description: item['description'],
              page: item['page'],
            ),
          )
          .toList(),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required Widget page,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 36, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .where('role', isEqualTo: 'user')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, userSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('feedbacks')
              .orderBy('createdAt', descending: true)
              .limit(10)
              .snapshots(),
          builder: (context, feedbackSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('admin_activities')
                  .orderBy('timestamp', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, adminSnapshot) {
                if (!userSnapshot.hasData &&
                    !feedbackSnapshot.hasData &&
                    !adminSnapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final List<Map<String, dynamic>> activities = [];

                // Process Users
                if (userSnapshot.hasData) {
                  for (var doc in userSnapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final createdAt =
                        (data['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now();
                    activities.add({
                      'type': 'user',
                      'title': 'New User Registered',
                      'subtitle':
                          '${data['fullName'] ?? 'Unknown'} (${data['email'] ?? 'No Email'})',
                      'time': createdAt,
                      'icon': Icons.person_add,
                      'color': Colors.blue,
                    });
                  }
                }

                // Process Reviews
                if (feedbackSnapshot.hasData) {
                  for (var doc in feedbackSnapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final createdAt =
                        (data['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now();
                    final rating = data['rating'] ?? 0;
                    final userName = data['userName'] ?? 'Anonymous';
                    activities.add({
                      'type': 'review',
                      'title': 'New Review ($rating Stars)',
                      'subtitle': '$userName: ${data['comment'] ?? ''}',
                      'time': createdAt,
                      'icon': Icons.star,
                      'color': Colors.amber,
                    });
                  }
                }

                // Process Admin Activities
                if (adminSnapshot.hasData) {
                  for (var doc in adminSnapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final timestamp =
                        (data['timestamp'] as Timestamp?)?.toDate() ??
                        DateTime.now();
                    activities.add({
                      'type': 'admin',
                      'title': data['action'] ?? 'Admin Action',
                      'subtitle':
                          '${data['details'] ?? ''} by ${data['adminEmail'] ?? 'Admin'}',
                      'time': timestamp,
                      'icon': Icons.security,
                      'color': Colors.red,
                    });
                  }
                }

                // Sort and Limit
                activities.sort(
                  (a, b) =>
                      (b['time'] as DateTime).compareTo(a['time'] as DateTime),
                );
                final displayActivities = activities.take(10).toList();

                if (displayActivities.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayActivities.length,
                      itemBuilder: (context, index) {
                        final activity = displayActivities[index];
                        final timeStr = DateFormat(
                          'MMM d, h:mm a',
                        ).format(activity['time']);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (activity['color'] as Color)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  activity['icon'] as IconData,
                                  color: activity['color'] as Color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      activity['subtitle'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
