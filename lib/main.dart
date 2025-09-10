import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gopumplog/authentication/landing.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // GOIL Branding Theme
      theme: ThemeData(
        primaryColor: const Color(0xFFF15A29), // GOIL Orange
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF15A29),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFF15A29),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF15A29),
          secondary: const Color(0xFFFBB040), // GOIL Yellow Accent
        ),
      ),

      home:LandingPage(),
    );
  }
}
