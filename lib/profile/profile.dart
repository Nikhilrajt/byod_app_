import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/auth/firebase/fibase_serviece.dart';
import 'package:project/auth/loginscreen.dart';
import 'package:project/homescreen/my_orders.dart';
import 'package:project/profile/delivery.dart';
import 'package:project/profile/personalinformation.dart';
import 'package:project/profile/setting.dart';

// -----------------------------------------------------------------
// MOCK CLASSES (Required for navigation)
// -----------------------------------------------------------------

class TermsAndConditiions extends StatelessWidget {
  const TermsAndConditiions({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms and Conditions')),
      body: const Center(child: Text('Terms and Conditions Content')),
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
// LANGUAGE SELECTOR WIDGET
// -----------------------------------------------------------------

class LanguageSelector extends StatefulWidget {
  final String selectedLanguage;
  final String selectedCountry;
  final Function(String, String) onSelected;

  const LanguageSelector({
    required this.selectedLanguage,
    required this.selectedCountry,
    required this.onSelected,
    super.key,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final List<Map<String, String>> languages = const [
    {'lang': 'English', 'country': 'United Kingdom'},
    {'lang': 'हिंदी', 'country': 'भारत'},
    {'lang': 'العربية', 'country': 'العالم'},
    {'lang': 'বাংলা', 'country': 'বাংলাদেশ'},
    {'lang': '简体中文', 'country': '中国'},
    {'lang': 'Français', 'country': 'France'},
    {'lang': 'Português', 'country': 'Portugal'},
    {'lang': 'Русский', 'country': 'Россия'},
    {'lang': 'Español', 'country': 'España'},
    {'lang': 'اردو', 'country': 'پاکستان'},
  ];

  void _showLanguagesheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView(
            children: languages.map((lang) {
              final isSelected =
                  lang['lang'] == widget.selectedLanguage &&
                  lang['country'] == widget.selectedCountry;
              return ListTile(
                title: Row(
                  children: [
                    Text(lang['lang'] ?? ''),
                    const SizedBox(width: 8),
                    Text(
                      lang['country'] ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: Color.fromARGB(255, 32, 5, 150),
                      )
                    : null,
                onTap: () {
                  widget.onSelected(lang['lang']!, lang['country']!);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showLanguagesheet,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.language, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              widget.selectedLanguage,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              widget.selectedCountry,
              style: const TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// PROFILE SCREEN WIDGET (Updated with OrdersPage link)
// -----------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool pushNotifications = true;
  bool promotionalNotifications = false;
  String selectedLanguage = 'English';
  String selectedCountry = 'United Kingdom';

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

                // Delivery Page
                ListTile(
                  leading: const Icon(
                    Icons.delivery_dining,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Delivery'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Delivery()),
                    );
                  },
                ),

                // 3. Language Selector
                LanguageSelector(
                  selectedLanguage: selectedLanguage,
                  selectedCountry: selectedCountry,
                  onSelected: (lang, country) {
                    setState(() {
                      selectedLanguage = lang;
                      selectedCountry = country;
                    });
                  },
                ),

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
                        builder: (context) => const TermsAndConditiions(),
                      ),
                    );
                  },
                ),

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

                // Divider and Notifications Section Title
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),

                // 6. Push Notifications Switch
                SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications_active,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Push Notifications'),
                  value: pushNotifications,
                  onChanged: (bool value) {
                    setState(() {
                      pushNotifications = value;
                    });
                  },
                  activeThumbColor: Colors.deepPurple,
                ),

                // 7. Promotional Notifications Switch
                SwitchListTile(
                  secondary: const Icon(
                    Icons.local_offer,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Promotional Notifications'),
                  value: promotionalNotifications,
                  onChanged: (bool value) {
                    setState(() {
                      promotionalNotifications = value;
                    });
                  },
                  activeThumbColor: Colors.deepPurple,
                ),

                // Divider
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),

                // 8. Help Center
                ListTile(
                  leading: const Icon(
                    Icons.help_center,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Placeholder for navigation/action
                  },
                ),

                // 9. Logout
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.black),
                  title: const Text("Logout"),
                  subtitle: const Text("Sign out from this account"),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to log out?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                AuthService().signOut();
                                // Navigator.of(context).pop();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Loginscreen(),
                                  ),
                                  (route) => true,
                                );
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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
