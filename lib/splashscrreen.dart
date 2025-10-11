import 'dart:async';

import 'package:flutter/material.dart';

import 'package:project/auth/intro.dart';
import 'package:project/homescreen/homecontent.dart';
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
          pageBuilder: (context, animation, secondaryAnimation) => Intro(),
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
