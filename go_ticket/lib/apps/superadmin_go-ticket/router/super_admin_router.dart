// =============================================================================
// FILE: lib/apps/super_admin/router/super_admin_router.dart
// RESPONSIBILITY: Router untuk Super Admin Web App Go Ticket.
// Mencakup semua halaman pengelolaan platform.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/auth/super_admin_login_screen.dart';
import '../screens/dashboard/super_admin_dashboard_screen.dart';
import '../screens/hotel_management/hotel_list_screen.dart';
import '../screens/hotel_management/hotel_detail_admin_screen.dart';
import '../screens/payout_management/payout_approval_screen.dart';
import '../screens/transaction_monitoring/transaction_list_screen.dart';

/// Router Super Admin Web App Go Ticket.
class SuperAdminRouter {
  SuperAdminRouter._();

  static const String initial = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String hotelList = '/hotels';
  static const String hotelDetailAdmin = '/hotels/detail';
  static const String payoutApproval = '/payouts';
  static const String transactionMonitoring = '/transactions';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
      case login:
        return _build(const SuperAdminLoginScreen(), settings);
      case dashboard:
        return _build(const SuperAdminDashboardScreen(), settings);
      case hotelList:
        return _build(const HotelListScreen(), settings);
      case hotelDetailAdmin:
        return _build(HotelDetailAdminScreen(arguments: settings.arguments), settings);
      case payoutApproval:
        return _build(const PayoutApprovalScreen(), settings);
      case transactionMonitoring:
        return _build(const TransactionListScreen(), settings);
      default:
        return _build(const SuperAdminDashboardScreen(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _build(Widget w, RouteSettings s) =>
      MaterialPageRoute(builder: (_) => w, settings: s);
}
