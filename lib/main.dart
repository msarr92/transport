import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'PageAcceuil/onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'acceuil/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // OBLIGATOIRE avant d'utiliser SharedPreferences
  runApp(const MyApp());
  // Ralentir les animations pour la démo
  timeDilation = 2.0;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OnboardingScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

