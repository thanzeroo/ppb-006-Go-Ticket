// =============================================================================
// FILE: lib/apps/hotel_partner/router/role_guard.dart
// RESPONSIBILITY: Widget guard yang memeriksa role user yang sedang login
// dan mengarahkan mereka ke dashboard yang sesuai:
// - staffFo → FO Dashboard
// - maintenance → Maintenance Dashboard
// - adminHotel → Executive Dashboard (Admin Hotel)
// Jika role tidak dikenali, redirect ke halaman login.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../screens/admin_hotel/executive_dashboard_screen.dart';
import '../screens/auth/staff_login_screen.dart';
import '../screens/front_office/fo_dashboard_screen.dart';
import '../screens/maintenance/maintenance_dashboard_screen.dart';

/// Widget guard yang menentukan halaman awal berdasarkan role user.
///
/// Diarahkan dari [main_hotel.dart] setelah session check.
class RoleGuard extends StatelessWidget {
  /// String role dari local storage (dari UserRole.apiValue)
  final String? userRole;

  const RoleGuard({super.key, this.userRole});

  @override
  Widget build(BuildContext context) {
    // Parse role dari string
    final role = userRole != null
        ? UserRoleExtension.fromApiString(userRole!)
        : null;

    switch (role) {
      case UserRole.staffFo:
        return const FoDashboardScreen();

      case UserRole.maintenance:
        return const MaintenanceDashboardScreen();

      case UserRole.adminHotel:
        return const ExecutiveDashboardScreen();

      default:
        // Jika role tidak dikenali atau null, kembali ke login
        return const StaffLoginScreen();
    }
  }
}
