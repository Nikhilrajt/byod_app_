import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/auth/firebase/fibase_serviece.dart';
import 'package:project/auth/loginscreen.dart';
import 'package:project/homescreen/my_orders.dart';
import 'package:project/profile/delivery.dart';
import 'package:project/profile/feedback_page.dart';
import 'package:project/profile/help_center.dart';
import 'package:project/profile/personalinformation.dart';
import 'package:project/profile/setting.dart';

// -----------------------------------------------------------------
// TERMS AND CONDITIONS PAGE
// -----------------------------------------------------------------

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Legal',
          style: GoogleFonts.playfairDisplay(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  size: 40,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Terms & Conditions',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Last Updated: ${DateFormat('MMMM d, y').format(DateTime.now())}',
                style: GoogleFonts.lato(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              '1. Introduction',
              'Welcome to our BYOD (Build Your Own Dish) App. By accessing or using our mobile application, you agree to be bound by these Terms and Conditions and our Privacy Policy.',
            ),
            _buildDivider(),
            _buildSection(
              '2. Use of Service',
              'You agree to use the application only for lawful purposes and in a way that does not infringe the rights of, restrict or inhibit anyone else\'s use and enjoyment of the application.',
            ),
            _buildDivider(),
            _buildSection(
              '3. User Accounts',
              'To access certain features of the app, you may be required to create an account. You are responsible for maintaining the confidentiality of your account and password and for restricting access to your device.',
            ),
            _buildDivider(),
            _buildSection(
              '4. Orders and Payments',
              'All orders placed through the app are subject to acceptance and availability. Prices and availability of items are subject to change without notice. Payment must be made at the time of ordering or via Cash on Delivery where applicable.',
            ),
            _buildDivider(),
            _buildSection(
              '5. BYOD Policy',
              'For "Build Your Own Dish" orders, you are responsible for providing accurate recipes and instructions. The restaurant reserves the right to reject requests that are not feasible or violate safety standards.',
            ),
            _buildDivider(),
            _buildSection(
              '6. Intellectual Property',
              'The content, organization, graphics, design, compilation, and other matters related to the app are protected under applicable copyrights and other proprietary laws.',
            ),
            _buildDivider(),
            _buildSection(
              '7. Limitation of Liability',
              'We shall not be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses.',
            ),
            _buildDivider(),
            _buildSection(
              '8. Changes to Terms',
              'We reserve the right to modify these terms at any time. We will notify users of any changes by posting the new Terms and Conditions on this page.',
            ),
            _buildDivider(),
            _buildSection(
              '9. Contact Us',
              'If you have any questions about these Terms, please contact us at support@FoodFlexapp.com.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Thank you for trusting Food Flex App",
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(color: Colors.grey.withOpacity(0.2)),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.lato(
            fontSize: 15,
            height: 1.6,
            color: Colors.black54,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}

// class Personalinformation extends StatelessWidget {
//   const Personalinformation({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Personal Information')),
//       body: const Center(child: Text('Personal Information Form')),
//     );
//   }
// }

// -----------------------------------------------------------------
// PROFILE SCREEN WIDGET (Updated with OrdersPage link)
// -----------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _navigateToDelivery() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to track orders')),
      );
      return;
    }

    try {
      // Fetch the latest order for the user
      // We use a broad query and sort client-side to avoid index errors
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No active orders found')),
          );
        }
        return;
      }

      // Sort by createdAt descending to get the latest
      final docs = querySnapshot.docs;
      docs.sort((a, b) {
        final aTime = a.data()['createdAt'] as Timestamp?;
        final bTime = b.data()['createdAt'] as Timestamp?;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Delivery(orderId: docs.first.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching order: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.person_outline_outlined,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          width: containerWidth,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. My Account Section Title
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'My Account',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),

                const SizedBox(height: 10),

                // 2. Personal Information
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.deepPurple),
                  title: const Text('Personal Information'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Personalinformation(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
                // 2.5. My Orders (NEW)
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.deepPurple),
                  title: const Text('My Orders'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyOrdersPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
                // Delivery Page
                ListTile(
                  leading: const Icon(
                    Icons.delivery_dining,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Delivery'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _navigateToDelivery,
                ),

                const SizedBox(height: 12),
                // 4. Privacy and Policy
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Privacy and Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsAndConditions(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
                // 5. Settings
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.deepPurple),
                  title: const Text('Setting'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingPage(),
                      ),
                    );
                  },
                ),

                // Divider
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),

                const SizedBox(height: 12),
                // 8. Help Center
                ListTile(
                  leading: const Icon(
                    Icons.help_center,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpCenterPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
                // 8.5 Feedback
                ListTile(
                  leading: const Icon(
                    Icons.feedback_outlined,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Feedback'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeedbackPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
                // 9. Logout
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Sign out from this account",
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () => _showLogoutDialog(context),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: const Icon(
              Icons.logout,
              color: Colors.redAccent,
              size: 40,
            ),
            title: Text(
              'Confirm Logout',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            content: Text(
              'Are you sure you want to sign out?',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  AuthService().signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Loginscreen(),
                    ),
                    (route) => true,
                  );
                },
                child: Text(
                  'Logout',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------
// MAIN APP ENTRY POINT
// -----------------------------------------------------------------

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Profile Example',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         useMaterial3: true,
//       ),
//       home: const ProfileScreen(),
//     );
//   }
// }
