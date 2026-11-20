import 'package:flutter/material.dart';

import '../../core/services/app_initializer.dart';
import 'router/customer_router.dart';

/// Aplikasi Mandiri untuk Pihak User / Tamu Go Ticket.
/// Berjalan mandiri tanpa portal pemilihan.
void main() async {
  await AppInitializer.init();
  runApp(const PihakUserApp());
}

class PihakUserApp extends StatelessWidget {
  const PihakUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoTicket — User & Tamu',
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
      onGenerateRoute: CustomerRouter.onGenerateRoute,
      initialRoute: CustomerRouter.initial,
    );
  }
}
