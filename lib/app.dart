import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

class ChessTournamentApp extends StatelessWidget {
  const ChessTournamentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chess Tournament',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xffF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0F172A),
          primary: const Color(0xff0F172A),
          secondary: const Color(0xffD4AF37),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xff0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: SplashScreen(),
    );
  }
}