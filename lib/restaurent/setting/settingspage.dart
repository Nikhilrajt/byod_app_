import 'package:flutter/material.dart';
import 'package:project/auth/firebase/fibase_serviece.dart';
import 'package:project/auth/loginscreen.dart';
import 'package:project/restaurent/Ingredientpage.dart';
import 'package:project/restaurent/setting/customer_feedback.dart';
// removed unused imports
import 'package:project/restaurent/setting/delivery_settings_page.dart';
import 'package:project/restaurent/setting/changepassword.dart/change.dart';
import 'package:project/restaurent/setting/manage_menu_page.dart';
import 'package:project/restaurent/setting/restaurant_profile_page.dart';

class Settingspage extends StatefulWidget {
  const Settingspage({super.key});

  @override
  State<Settingspage> createState() => _SettingspageState();
}

class _SettingspageState extends State<Settingspage> {
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
                  builder: (context) => const CustomerFeedbackPage(),
                ),
              );
            },
          ),
          // Notifications section removed
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
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout"),
            subtitle: const Text("Sign out from this account"),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dialogBackgroundColor: Colors.white),
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                      title: const Text(
                        'Confirm Logout',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      content: const Text(
                        'Are you sure you want to sign out?',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
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
                                builder: (context) => const Loginscreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(
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
            },
          ),
        ],
      ),
    );
  }
}

// Placeholder removed - using ChangePassword from change.dart
