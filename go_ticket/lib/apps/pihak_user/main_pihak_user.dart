import 'package:flutter/material.dart';

import 'screens/splash/customer_loading_screen.dart';

/// Aplikasi root untuk Pihak User / Customer Go Ticket.
void main() {
  runApp(const PihakUserApp());
}

class PihakUserApp extends StatelessWidget {
  const PihakUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoTicket — Pihak User',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B4D8),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFD),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      home: const CustomerLoadingScreen(),
    );
  }
}
