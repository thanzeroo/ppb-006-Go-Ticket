// =============================================================================
// FILE: lib/apps/customer/main_customer.dart
// RESPONSIBILITY: Entry point untuk Customer App Go Ticket.
// Ini adalah main() yang dijalankan saat target build 'customer' dipilih.
// Menginisialisasi:
// - Flutter bindings dan paket intl untuk locale Indonesia
// - MaterialApp dengan tema Go Ticket
// - Router navigasi Customer
// - Pengecekan sesi (apakah sudah login atau belum)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/storage_helper.dart';
import 'router/customer_router.dart';
import 'screens/splash/customer_loading_screen.dart';

/// Entry point utama Customer App Go Ticket.
///
/// Jalankan dengan:
/// ```
/// flutter run -t lib/apps/customer/main_customer.dart
/// ```
void main() async {
  // Pastikan Flutter sudah diinisialisasi sebelum memanggil kode platform
  WidgetsFlutterBinding.ensureInitialized();

  // Paksa orientasi portrait untuk Customer App
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Cek apakah user sudah login sebelumnya
  final isLoggedIn = await StorageHelper.isLoggedIn();

  runApp(GoTicketCustomerApp(isLoggedIn: isLoggedIn));
}

/// Root Widget untuk Customer App Go Ticket.
class GoTicketCustomerApp extends StatelessWidget {
  /// Apakah user sudah memiliki sesi aktif (sudah login sebelumnya)
  final bool isLoggedIn;

  const GoTicketCustomerApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Metadata aplikasi
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Tema Go Ticket
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Router navigasi Customer
      onGenerateRoute: CustomerRouter.onGenerateRoute,
      initialRoute: CustomerRouter.initial,

      // Halaman awal loading screen
      home: const CustomerLoadingScreen(),
    );
  }
}
