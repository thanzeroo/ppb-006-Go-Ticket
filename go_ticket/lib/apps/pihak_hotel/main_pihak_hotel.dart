import 'package:flutter/material.dart';

import 'screens/splash/hotel_splash_screen.dart';

/// Aplikasi root untuk Pihak Hotel.
void main() {
  runApp(const PihakHotelApp());
}

class PihakHotelApp extends StatelessWidget {
  const PihakHotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoTicket — Pihak Hotel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D3B55),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const HotelSplashScreen(),
    );
  }
}
