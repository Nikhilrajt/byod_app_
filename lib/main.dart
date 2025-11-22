// // lib/main.dart

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:project/splashscrreen.dart';
// import 'state/health_mode_notifier.dart'; // make sure this path matches your project

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   // Optional: load saved health mode from SharedPreferences before app starts.
//   // If you don't want persistence across restarts, remove this line and pass false below.
//   final saved = await HealthModeNotifier.loadSaved();

//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => HealthModeNotifier(saved),
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       // Keep your splash screen as the initial route/screen
//       home: const Splashscrreen(),
//     );
//   }
// }
// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/splashscrreen.dart';
import 'state/health_mode_notifier.dart';
import 'state/cart_notifier.dart';

Future<void> main() async {
  // CRITICAL: This MUST be called first, before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Now initialize Firebase
  await Firebase.initializeApp();

  // Load saved health mode from SharedPreferences
  final saved = await HealthModeNotifier.loadSaved();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HealthModeNotifier(saved)),
        ChangeNotifierProvider(create: (_) => CartNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Flex',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const Splashscrreen(),
    );
  }
}
