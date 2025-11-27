import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/admin/dashboard_admin.dart';
import 'package:project/admin/dashboard_admin.dart';
import 'package:project/auth/firebase/fibase_serviece.dart';

import 'package:project/auth/intro.dart';
import 'package:project/auth/loginscreen.dart';
import 'package:project/homescreen/home.dart';
import 'package:project/homescreen/homecontent.dart';
import 'package:project/restaurent/home.dart';
// import 'package:project/auth/loginscreen.dart';

class Splashscrreen extends StatefulWidget {
  const Splashscrreen({super.key});

  @override
  State<Splashscrreen> createState() => _SplashscrreenState();
}

class _SplashscrreenState extends State<Splashscrreen> {
  @override
  void initState() {
    super.initState();

    // wait 3 seconds and navigate
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(seconds: 1), // animation duration
          pageBuilder: (context, animation, secondaryAnimation) =>
              AuthWrapper(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade Animation
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: Image(image: AssetImage('assets/images/foodflex.png')),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // User is not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          return Loginscreen();
        }

        // User is logged in - check role and navigate
        return FutureBuilder<String?>(
          future: _authService.getUserRole(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            String? role = roleSnapshot.data;

            // Navigate based on role
            switch (role) {
              case 'admin':
                return AdminDashboard();
              case 'restaurant':
                return restaurent_home_page();
              case 'user':
              default:
                return HomeScreen();
            }
          },
        );
      },
    );
  }
}
