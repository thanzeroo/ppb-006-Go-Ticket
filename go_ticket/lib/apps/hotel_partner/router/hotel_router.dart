// =============================================================================
// FILE: lib/apps/hotel_partner/router/hotel_router.dart
// RESPONSIBILITY: Mendefinisikan semua named route untuk Hotel Partner App.
// Router ini mencakup route untuk 3 role: FO, Maintenance, dan Admin Hotel.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/admin_hotel/employee_management_screen.dart';
import '../screens/admin_hotel/executive_dashboard_screen.dart';
import '../screens/admin_hotel/financial_payout_screen.dart';
import '../screens/admin_hotel/room_pricing_screen.dart';
import '../screens/auth/staff_login_screen.dart';
import '../screens/front_office/checkout_process_screen.dart';
import '../screens/front_office/fo_dashboard_screen.dart';
import '../screens/front_office/qr_scanner_checkin_screen.dart';
import '../screens/front_office/verify_booking_screen.dart';
import '../screens/maintenance/create_maintenance_ticket_screen.dart';
import '../screens/maintenance/maintenance_dashboard_screen.dart';
import '../screens/maintenance/room_cleaning_task_screen.dart';
import 'role_guard.dart';

/// Router Hotel Partner App Go Ticket.
class HotelRouter {
  HotelRouter._();

  // ---------------------------------------------------------------------------
  // ROUTE NAMES
  // ---------------------------------------------------------------------------

  static const String initial = '/';
  static const String staffLogin = '/auth/staff-login';
  static const String adminHotelLogin = '/auth/admin-hotel-login';

  // Front Office Routes
  static const String foDashboard = '/fo/dashboard';
  static const String verifyBooking = '/fo/verify-booking';
  static const String qrScanCheckin = '/fo/qr-checkin';
  static const String checkout = '/fo/checkout';

  // Maintenance Routes
  static const String maintenanceDashboard = '/maintenance/dashboard';
  static const String cleaningTask = '/maintenance/cleaning-task';
  static const String createTicket = '/maintenance/create-ticket';

  // Admin Hotel Routes
  static const String executiveDashboard = '/admin/dashboard';
  static const String employeeManagement = '/admin/employees';
  static const String roomPricing = '/admin/room-pricing';
  static const String financialPayout = '/admin/financial-payout';

  // ---------------------------------------------------------------------------
  // ROUTE GENERATOR
  // ---------------------------------------------------------------------------

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return _buildRoute(const RoleGuard(), settings);
      case staffLogin:
        return _buildRoute(const StaffLoginScreen(), settings);
      case adminHotelLogin:
        return _buildRoute(const StaffLoginScreen(initialRole: 2), settings);
      case foDashboard:
        return _buildRoute(const FoDashboardScreen(), settings);
      case verifyBooking:
        return _buildRoute(VerifyBookingScreen(arguments: settings.arguments), settings);
      case qrScanCheckin:
        return _buildRoute(const QrScannerCheckinScreen(), settings);
      case checkout:
        return _buildRoute(CheckoutProcessScreen(arguments: settings.arguments), settings);
      case maintenanceDashboard:
        return _buildRoute(const MaintenanceDashboardScreen(), settings);
      case cleaningTask:
        return _buildRoute(RoomCleaningTaskScreen(arguments: settings.arguments), settings);
      case createTicket:
        return _buildRoute(CreateMaintenanceTicketScreen(arguments: settings.arguments), settings);
      case executiveDashboard:
        return _buildRoute(const ExecutiveDashboardScreen(), settings);
      case employeeManagement:
        return _buildRoute(const EmployeeManagementScreen(), settings);
      case roomPricing:
        return _buildRoute(const RoomPricingScreen(), settings);
      case financialPayout:
        return _buildRoute(const FinancialPayoutScreen(), settings);
      default:
        return _buildRoute(const RoleGuard(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(Widget widget, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => widget, settings: settings);
  }
}
