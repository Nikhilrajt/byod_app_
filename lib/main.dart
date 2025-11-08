// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/splashscrreen.dart';
import 'state/health_mode_notifier.dart'; // make sure this path matches your project

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: load saved health mode from SharedPreferences before app starts.
  // If you don't want persistence across restarts, remove this line and pass false below.
  final saved = await HealthModeNotifier.loadSaved();

  runApp(
    ChangeNotifierProvider(
      create: (_) => HealthModeNotifier(saved),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Keep your splash screen as the initial route/screen
      home: const Splashscrreen(),
    );
  }
}
