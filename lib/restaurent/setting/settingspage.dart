import 'package:flutter/material.dart';
import 'package:project/auth/firebase/fibase_serviece.dart';
import 'package:project/auth/intro.dart';
import 'package:project/auth/loginscreen.dart';
import 'package:project/restaurent/Ingredientpage.dart';
// removed unused imports
import 'package:project/restaurent/setting/delivery_settings_page.dart';
import 'package:project/restaurent/setting/changepassword.dart/change.dart';
import 'package:project/restaurent/setting/feedbackpage.dart';
import 'package:project/restaurent/setting/manage_ingredients_page.dart';
import 'package:project/restaurent/setting/manage_menu_page.dart';
import 'package:project/restaurent/setting/restaurant_profile_page.dart';

class Settingspage extends StatefulWidget {
  const Settingspage({super.key});

  @override
  State<Settingspage> createState() => _SettingspageState();
}

class _SettingspageState extends State<Settingspage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.store, color: Colors.deepOrange),
            title: const Text("Restaurant Profile"),
            subtitle: const Text("Update name, address & contact details"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RestaurantProfilePage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delivery_dining, color: Colors.green),
            title: const Text("Delivery Settings"),
            subtitle: const Text("Set delivery time & radius"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeliverySettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restaurant_menu, color: Colors.blue),
            title: const Text("Manage Menu"),
            subtitle: const Text("Add or edit regular dishes"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageMenuPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.kitchen, color: Colors.purple),
            title: const Text("Manage Ingredients"),
            subtitle: const Text("Add or update stock for BYOD"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IngredientPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.feedback, color: Colors.amber),
            title: const Text("Customer Feedback"),
            subtitle: const Text("View and manage user reviews"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Feedbackpage(),
                ),
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.redAccent),
            title: const Text("Notifications"),
            subtitle: const Text("Enable or disable push notifications"),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _notificationsEnabled
                        ? "Notifications Enabled"
                        : "Notifications Disabled",
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.teal),
            title: const Text("Change Password"),
            subtitle: const Text("Update login password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePassword()),
              );
            },
          ),
          const Divider(),
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
                    content: const Text('Are you sure you want to log out?'),
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
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Loginscreen(),
                            ),
                            (route) => false,
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
        ],
      ),
    );
  }
}

// Placeholder removed - using ChangePassword from change.dart
