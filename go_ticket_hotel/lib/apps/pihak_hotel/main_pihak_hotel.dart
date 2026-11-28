import 'package:flutter/material.dart';

import '../../core/services/app_initializer.dart';
import 'screens/splash/hotel_splash_screen.dart';

/// Aplikasi Mandiri untuk Pihak Hotel (Front Office, Maintenance, Admin Hotel).
/// Berjalan mandiri tanpa portal pemilihan.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppInitializer.init();
  } catch (e) {
    debugPrint('⚠️ [main] Inisialisasi mengalami kendala: $e');
  }
  runApp(const PihakHotelApp());
}

/// Root widget aplikasi Mitra Hotel (`go_ticket_hotel`) untuk Administrator, Front Office, dan Maintenance.
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
