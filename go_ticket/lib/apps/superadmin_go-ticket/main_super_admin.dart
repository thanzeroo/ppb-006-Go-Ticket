// =============================================================================
// FILE: lib/apps/super_admin/main_super_admin.dart
// RESPONSIBILITY: Entry point untuk Super Admin Web App Go Ticket.
// Dijalankan di web browser untuk tim internal Go Ticket (Platform Owner).
// Mengelola seluruh platform:
// - Manajemen hotel mitra (approve, suspend, monitoring)
// - Monitoring transaksi dan booking platform-wide
// - Persetujuan dan pencairan payout hotel mitra
// - Konfigurasi komisi dan pengaturan sistem
// =============================================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/storage_helper.dart';
import 'router/super_admin_router.dart';
import 'screens/splash/super_admin_loading_screen.dart';

/// Entry point Super Admin Web App Go Ticket.
///
/// Jalankan dengan:
/// ```
/// flutter run -d chrome -t lib/apps/super_admin/main_super_admin.dart
/// ```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isLoggedIn = await StorageHelper.isLoggedIn();

  runApp(GoTicketSuperAdminApp(isLoggedIn: isLoggedIn));
}

/// Root Widget Super Admin Web App.
class GoTicketSuperAdminApp extends StatelessWidget {
  final bool isLoggedIn;

  const GoTicketSuperAdminApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${AppConstants.appName} — Super Admin',
      debugShowCheckedModeBanner: false,
      // Super Admin menggunakan tema dark agar terasa lebih "enterprise"
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      onGenerateRoute: SuperAdminRouter.onGenerateRoute,
      home: const SuperAdminLoadingScreen(),
    );
  }
}
