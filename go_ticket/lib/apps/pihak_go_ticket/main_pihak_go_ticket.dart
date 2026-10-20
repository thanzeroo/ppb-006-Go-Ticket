import 'package:flutter/material.dart';

import 'screens/splash/admin_splash_screen.dart';

/// Aplikasi root untuk Pihak Go Ticket.
void main() {
  runApp(const PihakGoTicketApp());
}

class PihakGoTicketApp extends StatelessWidget {
  const PihakGoTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoTicket — Pihak Go Ticket',
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
      home: const AdminSplashScreen(),
    );
  }
}
