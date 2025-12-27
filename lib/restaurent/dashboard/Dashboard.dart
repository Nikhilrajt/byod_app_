import 'package:project/restaurent/Ingredientpage.dart';
import 'package:flutter/material.dart';
import 'package:project/restaurent/Orderpage.dart';
import 'package:project/restaurent/dashboard/restaurent_category.dart';
import 'package:project/restaurent/dashboard/todays_orders_page.dart';
import 'package:project/restaurent/dashboard/pending_byod_requests_page.dart';
import 'package:project/restaurent/dashboard/completed_orders_page.dart';
import 'package:project/restaurent/dashboard/todays_earnings_page.dart';
import 'package:project/restaurent/dashboard/low_stock_ingredients_page.dart';
import 'package:project/restaurent/setting/restaurant_profile_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/services/low_stock_service.dart';
import 'dart:async';
import 'package:intl/intl.dart';

// Placeholder `items` list — do not populate here. This list is expected to
// be filled from the app's existing menu/data sources (DB, provider, etc.).
final List<dynamic> items = [];

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LowStockService _lowStockService = LowStockService();

  String _restaurantName = "Restaurant";
  String? _restaurantImageUrl;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadRestaurantData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurantData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _restaurantName = data['fullName']?.isNotEmpty == true
              ? data['fullName']
              : "Restaurant";
          _restaurantImageUrl = data['imageUrl'];
        });
        _animationController.forward();
      }
    } catch (e) {
      print('Error loading restaurant data: $e');
    }
  }

  Widget _buildNotificationBadge(int count) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      child: Text(
        count > 9 ? '9+' : count.toString(),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildModernAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: user != null
            ? _firestore
                  .collection('orders')
                  .where('restaurantId', isEqualTo: user.uid)
                  .snapshots()
            : const Stream.empty(),
        builder: (context, snapshot) {
          int totalOrdersToday = 0;
          int allTimeCompleted = 0;
          double totalEarnings = 0.0;

          if (snapshot.hasData) {
            final now = DateTime.now();
            final startOfDay = DateTime(now.year, now.month, now.day);

            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              final status =
                  data['orderStatus'] as String? ??
                  data['status'] as String? ??
                  '';
              final amount = (data['totalAmount'] is int)
                  ? (data['totalAmount'] as int).toDouble()
                  : (data['totalAmount'] as double? ?? 0.0);

              // Count ALL completed orders (All Time) so the number updates lively
              if (status.toLowerCase() == 'completed') {
                allTimeCompleted++;
                totalEarnings += amount;
              }

              // Calculate Today's specific stats
              if (createdAt != null && createdAt.isAfter(startOfDay)) {
                totalOrdersToday++;
              }
            }
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildHeaderSection(),
                    _buildQuickStatsSection(totalOrdersToday, allTimeCompleted),
                    _buildMainDashboardCards(
                      totalOrdersToday,
                      allTimeCompleted,
                      totalEarnings,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D1B4E), Color(0xFF4A2C6B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D1B4E).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome Back",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _restaurantName,
                        style: GoogleFonts.pacifico(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RestaurantProfilePage(),
                      ),
                    ).then((_) {
                      _loadRestaurantData();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          _restaurantImageUrl != null &&
                              _restaurantImageUrl!.isNotEmpty
                          ? NetworkImage(_restaurantImageUrl!)
                          : null,
                      child:
                          _restaurantImageUrl == null ||
                              _restaurantImageUrl!.isEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2D1B4E),
                                    Color(0xFF4A2C6B),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                size: 24,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Overview",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D1B4E),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Manage your restaurant at a glance",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection(int totalOrders, int completedOrders) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              "Total Orders",
              totalOrders.toString(),
              Icons.receipt_long,
              const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              "Completed",
              completedOrders.toString(),
              Icons.check_circle,
              const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    LinearGradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainDashboardCards(
    int totalOrders,
    int completedOrders,
    double totalEarnings,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Management",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D1B4E),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          // Row 1: Orders Management
          Row(
            children: [
              Expanded(
                child: _buildEnhancedDashboardCard(
                  title: "Today's Orders",
                  value: totalOrders.toString(),
                  icon: Icons.receipt_long,
                  color: const Color(0xFFFF6B6B),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Orderpage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedDashboardCard(
                  title: "Pending BYOD",
                  value: "4",
                  icon: Icons.fastfood,
                  color: const Color(0xFF4ECDC4),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PendingByodRequestsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Completed & Earnings
          Row(
            children: [
              Expanded(
                child: _buildEnhancedDashboardCard(
                  title: "Completed",
                  value: completedOrders.toString(),
                  icon: Icons.check_circle,
                  color: const Color(0xFF44A08D),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompletedOrdersPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedDashboardCard(
                  title: "Total Earnings",
                  value: NumberFormat.currency(
                    locale: 'en_IN',
                    symbol: '₹',
                  ).format(totalEarnings),
                  icon: Icons.attach_money,
                  color: const Color(0xFFFFB84D),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TodaysEarningsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 3: Menu & Ingredients
          Row(
            children: [
              Expanded(
                child: _buildEnhancedDashboardCard(
                  title: "Menu Setup",
                  value: "Edit Items",
                  icon: Icons.restaurant_menu,
                  color: const Color(0xFF6C63FF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MenuPage()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedDashboardCard(
                  title: "Ingredients",
                  value: "View & Manage",
                  icon: Icons.kitchen,
                  color: const Color(0xFFF77F88),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IngredientPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Full Width: Low Stock Alerts
          StreamBuilder<int>(
            stream: _lowStockService.getLowStockCount(),
            builder: (context, snapshot) {
              final lowStockCount = snapshot.data ?? 0;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LowStockIngredientsPage(),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: lowStockCount > 0
                              ? [
                                  const Color(0xFFFF6B6B),
                                  const Color(0xFFEE5A6F),
                                ]
                              : [
                                  const Color(0xFFFFB84D),
                                  const Color(0xFFFFA500),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.warning_amber,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Stock Alert",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lowStockCount > 0
                                      ? "$lowStockCount items need attention"
                                      : "All stock is good",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    if (lowStockCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildNotificationBadge(lowStockCount),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D1B4E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reverted DashboardCard widget (single ListTile model)
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color.fromARGB(255, 197, 190, 190),
        ),
      ),
    );
  }
}
