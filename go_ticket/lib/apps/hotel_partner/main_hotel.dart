// =============================================================================
// FILE: lib/apps/hotel_partner/main_hotel.dart
// RESPONSIBILITY: Entry point untuk Hotel Partner App Go Ticket.
// App ini digunakan oleh 3 role berbeda di hotel mitra:
// - Staff Front Office (FO)
// - Staff Maintenance
// - Admin Hotel / Manager / Owner
// Role guard akan mengarahkan ke screen yang sesuai setelah login.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/storage_helper.dart';
import 'router/hotel_router.dart';
import 'screens/auth/staff_login_screen.dart';
import 'router/role_guard.dart';

/// Entry point utama Hotel Partner App Go Ticket.
///
/// Jalankan dengan:
/// ```
/// flutter run -t lib/apps/hotel_partner/main_hotel.dart
/// ```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Cek sesi login dan role user
  final isLoggedIn = await StorageHelper.isLoggedIn();
  final userRole = await StorageHelper.getUserRole();

  runApp(GoTicketHotelApp(
    isLoggedIn: isLoggedIn,
    userRole: userRole,
  ));
}

/// Root Widget untuk Hotel Partner App Go Ticket.
class GoTicketHotelApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userRole;

  const GoTicketHotelApp({
    super.key,
    required this.isLoggedIn,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${AppConstants.appName} — Mitra Hotel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: HotelRouter.onGenerateRoute,
      initialRoute: HotelRouter.initial,
      // Role guard menentukan halaman awal berdasarkan role
      home: isLoggedIn
          ? RoleGuard(userRole: userRole)
          : const StaffLoginScreen(),
    );
  }
}
