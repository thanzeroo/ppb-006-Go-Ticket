import 'package:flutter/material.dart';

import '../../core/services/app_initializer.dart';
import 'screens/splash/admin_splash_screen.dart';

/// Aplikasi Mandiri untuk Pihak Go Ticket (Super Admin).
/// Berjalan mandiri tanpa portal pemilihan.
void main() async {
  await AppInitializer.init();
  runApp(const PihakGoTicketApp());
}

class PihakGoTicketApp extends StatelessWidget {
  const PihakGoTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoTicket — Super Admin Platform',
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
