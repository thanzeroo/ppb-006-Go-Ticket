import 'package:flutter/material.dart';

import '../screens/auth/customer_login_screen.dart';
import '../screens/splash/customer_loading_screen.dart';
import '../screens/dashboard/customer_dashboard_screen.dart';
import '../screens/hotel_detail/hotel_detail_screen.dart';
import '../screens/hotel_detail/room_selection_screen.dart';
import '../screens/booking/guest_detail_form_screen.dart';
import '../screens/booking/payment_process_screen.dart';
import '../screens/ticket/e_ticket_detail_screen.dart';

/// Router navigasi Customer App Go Ticket.
class CustomerRouter {
  CustomerRouter._();

  static const String initial = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String hotelDetail = '/hotel-detail';
  static const String roomSelection = '/room-selection';
  static const String guestDetail = '/booking/guest-detail';
  static const String payment = '/booking/payment';
  static const String eTicket = '/ticket/detail';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return _route(const CustomerLoadingScreen(), settings);
      case login:
        return _route(const CustomerLoginScreen(), settings);
      case dashboard:
        return _route(const CustomerDashboardScreen(), settings);
      case hotelDetail:
        return _route(
            HotelDetailScreen(arguments: settings.arguments), settings);
      case roomSelection:
        return _route(
            RoomSelectionScreen(arguments: settings.arguments), settings);
      case guestDetail:
        return _route(
            GuestDetailFormScreen(arguments: settings.arguments), settings);
      case payment:
        return _route(
            PaymentProcessScreen(arguments: settings.arguments), settings);
      case eTicket:
        return _route(
            ETicketDetailScreen(arguments: settings.arguments), settings);
      default:
        return _route(const CustomerDashboardScreen(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _route(Widget w, RouteSettings s) =>
      MaterialPageRoute(builder: (_) => w, settings: s);
}
