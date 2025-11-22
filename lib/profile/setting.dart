import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // Settings state variables
  bool _notificationsEnabled = true;
  String _selectedTheme = 'System Default';
  String _selectedLanguage = 'English';

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('System Default'),
                value: 'System Default',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Light Mode'),
                value: 'Light Mode',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Dark Mode'),
                value: 'Dark Mode',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('हिंदी'),
                value: 'हिंदी',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('العربية'),
                value: 'العربية',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'BYOD App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.phone_android, size: 48),
      children: [
        const Text('Bring Your Own Device Application'),
        const SizedBox(height: 8),
        const Text('© 2024 BYOD App. All rights reserved.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Preferences Section
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Preferences',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.brightness_6,
                      color: Colors.deepPurple,
                    ),
                    title: const Text('Theme'),
                    subtitle: Text(_selectedTheme),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showThemeDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.language,
                      color: Colors.deepPurple,
                    ),
                    title: const Text('Language'),
                    subtitle: Text(_selectedLanguage),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showLanguageDialog,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.notifications_active,
                      color: Colors.deepPurple,
                    ),
                    title: const Text('Notifications'),
                    subtitle: const Text('Enable push notifications'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeColor: Colors.deepPurple,
                  ),
                ],
              ),
            ),

            // About Section
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'About',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.info_outline,
                  color: Colors.deepPurple,
                ),
                title: const Text('About App'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showAboutDialog,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
