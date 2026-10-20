// =============================================================================
// FILE: lib/apps/customer/router/customer_router.dart
// RESPONSIBILITY: Mendefinisikan semua named route dan navigasi untuk
// Customer App Go Ticket. Semua navigasi antar halaman di Customer App
// dilakukan melalui router ini untuk konsistensi dan maintainability.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/auth/customer_login_screen.dart';
import '../screens/auth/terms_screen.dart';
import '../screens/splash/customer_loading_screen.dart';
import '../screens/booking/guest_detail_form_screen.dart';
import '../screens/booking/interactive_calendar_screen.dart';
import '../screens/booking/payment_process_screen.dart';
import '../screens/booking/payment_success_screen.dart';
import '../screens/dashboard/customer_dashboard_screen.dart';
import '../screens/dashboard/tabs/saved_hotel_screen.dart';
import '../screens/hotel_detail/hotel_detail_screen.dart';
import '../screens/hotel_detail/hotel_reviews_screen.dart';
import '../screens/hotel_detail/room_selection_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/settings/saved_guests_screen.dart';
import '../screens/settings/security_screen.dart';
import '../screens/settings/voucher_screen.dart';
import '../screens/ticket/e_ticket_detail_screen.dart';
import '../screens/ticket/post_checkout_review_screen.dart';

/// Router utama Customer App Go Ticket.
///
/// Cara navigasi:
/// ```dart
/// Navigator.pushNamed(context, CustomerRouter.hotelDetail, arguments: hotel);
/// ```
class CustomerRouter {
  CustomerRouter._();

  // ---------------------------------------------------------------------------
  // ROUTE NAMES — Konstanta nama route
  // ---------------------------------------------------------------------------

  /// Halaman awal / loading (Splash screen)
  static const String initial = '/';

  /// Halaman loading Customer
  static const String loading = '/loading';

  /// Halaman login Customer (OTP / Google)
  static const String login = '/login';

  /// Dashboard utama Customer (cari & rekomendasi hotel)
  static const String dashboard = '/dashboard';

  /// Halaman detail hotel
  static const String hotelDetail = '/hotel-detail';

  /// Halaman pemilihan kamar
  static const String roomSelection = '/room-selection';

  /// Kalender interaktif check-in / check-out
  static const String calendar = '/booking/calendar';

  /// Form data diri tamu
  static const String guestDetail = '/booking/guest-detail';

  /// Proses pembayaran
  static const String payment = '/booking/payment';

  /// Pembayaran berhasil + E-Tiket ringkas
  static const String paymentSuccess = '/booking/payment-success';

  /// Ulasan hotel
  static const String hotelReviews = '/hotel-reviews';

  /// Detail E-Tiket (QR Code)
  static const String eTicket = '/ticket/detail';

  /// Halaman review setelah checkout
  static const String postCheckoutReview = '/ticket/review';

  /// Halaman Syarat & Ketentuan
  static const String terms = '/auth/terms';

  /// Halaman edit profil
  static const String profile = '/settings/profile';

  /// Halaman daftar tamu tersimpan
  static const String savedGuests = '/settings/saved-guests';

  /// Halaman keamanan akun
  static const String security = '/settings/security';

  /// Halaman voucher promo
  static const String voucher = '/settings/voucher';

  /// Halaman hotel tersimpan
  static const String savedHotel = '/settings/saved-hotel';

  // ---------------------------------------------------------------------------
  // ROUTE GENERATOR
  // ---------------------------------------------------------------------------

  /// Generator route dinamis untuk MaterialApp.onGenerateRoute
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
      case loading:
        return _buildRoute(const CustomerLoadingScreen(), settings);

      case login:
        return _buildRoute(const CustomerLoginScreen(), settings);

      case dashboard:
        return _buildRoute(const CustomerDashboardScreen(), settings);

      case hotelDetail:
        // arguments: HotelModel atau String hotelId
        return _buildRoute(
          HotelDetailScreen(arguments: settings.arguments),
          settings,
        );

      case roomSelection:
        // arguments: Map berisi hotelId dan tanggal check-in/out
        return _buildRoute(
          RoomSelectionScreen(arguments: settings.arguments),
          settings,
        );

      case calendar:
        return _buildRoute(
          InteractiveCalendarScreen(arguments: settings.arguments),
          settings,
        );

      case guestDetail:
        return _buildRoute(
          GuestDetailFormScreen(arguments: settings.arguments),
          settings,
        );

      case payment:
        return _buildRoute(
          PaymentProcessScreen(arguments: settings.arguments),
          settings,
        );

      case paymentSuccess:
        return _buildRoute(
          PaymentSuccessScreen(arguments: settings.arguments),
          settings,
        );

      case hotelReviews:
        return _buildRoute(
          HotelReviewsScreen(arguments: settings.arguments),
          settings,
        );

      case eTicket:
        // arguments: BookingModel atau String bookingId
        return _buildRoute(
          ETicketDetailScreen(arguments: settings.arguments),
          settings,
        );

      case postCheckoutReview:
        // arguments: BookingModel
        return _buildRoute(
          PostCheckoutReviewScreen(arguments: settings.arguments),
          settings,
        );

      case terms:
        return _buildRoute(const TermsScreen(), settings);

      case profile:
        return _buildRoute(const ProfileScreen(), settings);

      case savedGuests:
        return _buildRoute(const SavedGuestsScreen(), settings);

      case security:
        return _buildRoute(const SecurityScreen(), settings);

      case voucher:
        return _buildRoute(const VoucherScreen(), settings);

      case savedHotel:
        return _buildRoute(const SavedHotelScreen(), settings);

      default:
        // Fallback ke dashboard jika route tidak dikenali
        return _buildRoute(const CustomerDashboardScreen(), settings);
    }
  }

  /// Helper untuk membuat MaterialPageRoute dengan transisi default
  static MaterialPageRoute<dynamic> _buildRoute(
    Widget widget,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => widget,
      settings: settings,
    );
  }
}
