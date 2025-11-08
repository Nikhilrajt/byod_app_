import 'package:flutter/material.dart';
import 'package:project/auth/loginscreen.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.35;

    return Scaffold(
      body: Stack(
        children: [
          // Background image at the top
          Container(
            height: headerHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/loginman.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Add top spacing equal to the image height
                SizedBox(height: headerHeight),

                // The content section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: const Loginscreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
