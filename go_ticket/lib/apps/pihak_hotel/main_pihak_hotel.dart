import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/supabase_service.dart';
import 'screens/splash/hotel_splash_screen.dart';

/// Aplikasi root untuk Pihak Hotel.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Muat environment config
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('❌ [ENV ERROR] File .env tidak ditemukan: $e');
  }

  // 2. Inisialisasi Supabase Database & Auth Session
  await SupabaseService.instance.initialize();
  await AuthService.instance.loadSavedSession();

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
