import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.grey[900],
              height: MediaQuery.of(context).size.height * 100,

              margin: EdgeInsets.only(top: 40),
              padding: EdgeInsets.only(top: 40, bottom: 20),
              child: Column(children: [Text('Admin Dashboard')]),
            ),
          ],
        ),
      ),
    );
  }
}
