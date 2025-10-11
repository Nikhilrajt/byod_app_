import 'package:flutter/material.dart';
import 'package:project/auth/intro.dart';

import 'package:project/homescreen/terms_and_conditiions.dart';
import 'package:project/profile/personalinformation.dart';

import '../auth/intro.dart';

class LanguageSelector extends StatefulWidget {
  final String selectedLanguage;
  final String selectedCountry;
  final Function(String, String) onSelected;

  const LanguageSelector({
    required this.selectedLanguage,
    required this.selectedCountry,
    required this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final List<Map<String, String>> languages = [
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          children: languages.map((lang) {
            final isSelected =
                lang['lang'] == widget.selectedLanguage &&
                lang['country'] == widget.selectedCountry;
            return ListTile(
              title: Row(
                children: [
                  Text(lang['lang'] ?? ''),
                  SizedBox(width: 8),
                  Text(
                    lang['country'] ?? '',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: const Color.fromARGB(255, 32, 5, 150),
                    )
                  : null,
              onTap: () {
                widget.onSelected(lang['lang']!, lang['country']!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showLanguagesheet,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.language, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text(
              widget.selectedLanguage,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4),
            Text(widget.selectedCountry, style: TextStyle(color: Colors.grey)),
            Spacer(),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}

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
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'),
        actions: [Icon(Icons.person_outline_outlined)],
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
          ),
          width: 380,
          height: 550,
          child: SingleChildScrollView(
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'My account',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Personal Information'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Personalinformation(),
                      ),
                    );
                  },
                ),
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
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text('Language :$selectedLanguage($selectedCountry)'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.privacy_tip),
                  title: Text('Privacy and Policy'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TermsAndConditiions(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Setting'),
                  onTap: () {
                    print('object');
                  },
                ),
                //notification
                Text(
                  'Notifications',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: Icon(Icons.help),
                  title: Text('Help Center'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Intro()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
