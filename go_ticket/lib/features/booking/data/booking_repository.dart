// =============================================================================
// FILE: lib/features/booking/data/booking_repository.dart
// RESPONSIBILITY: Repository untuk semua operasi terkait Booking / Pemesanan
// hotel di Go Ticket. Bertanggung jawab untuk:
// - Customer: Buat booking, lihat riwayat, batalkan booking
// - Customer: Proses pembayaran, lihat E-Tiket
// - Staff FO: Verifikasi pembayaran, proses check-in & check-out
// - Hotel Partner: Melihat semua booking hotel
// =============================================================================

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../models/booking_model.dart';

/// Repository pemesanan hotel Go Ticket.
class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ---------------------------------------------------------------------------
  // CUSTOMER — Membuat dan mengelola booking
  // ---------------------------------------------------------------------------

  /// Membuat booking baru.
  ///
  /// Mengembalikan [BookingModel] yang baru dibuat dengan status pendingPayment.
  Future<BookingModel> createBooking({
    required String hotelId,
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guestCount,
    String? specialRequest,
    String? promoCode,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.createBooking,
      body: {
        'hotel_id': hotelId,
        'room_id': roomId,
        'check_in_date': checkInDate.toIso8601String().substring(0, 10),
        'check_out_date': checkOutDate.toIso8601String().substring(0, 10),
        'guest_count': guestCount,
        'special_request': specialRequest,
        'promo_code': promoCode,
        'payment_method': paymentMethod,
      },
    );

    return BookingModel.fromJson(response['data'] ?? response);
  }

  /// Mendapatkan daftar riwayat booking milik Customer yang sedang login.
  ///
  /// [status] — Filter by status (opsional)
  /// [page] — Halaman untuk paginasi (default: 1)
  Future<List<BookingModel>> getMyBookings({
    String? status,
    int page = 1,
    int limit = 15,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) queryParams['status'] = status;

    final response = await _apiClient.get(
      ApiEndpoints.getMyBookings,
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] ?? response ?? [];
    return data.map((json) => BookingModel.fromJson(json)).toList();
  }

  /// Mendapatkan detail satu booking berdasarkan ID.
  Future<BookingModel> getBookingById(String bookingId) async {
    final response = await _apiClient.get(
      ApiEndpoints.bookingById(bookingId),
    );
    return BookingModel.fromJson(response['data'] ?? response);
  }

  /// Membatalkan booking.
  ///
  /// [bookingId] — ID booking yang akan dibatalkan
  /// [reason] — Alasan pembatalan (opsional)
  Future<BookingModel> cancelBooking(String bookingId, {String? reason}) async {
    final response = await _apiClient.post(
      ApiEndpoints.cancelBooking.replaceAll('{bookingId}', bookingId),
      body: {'reason': reason},
    );
    return BookingModel.fromJson(response['data'] ?? response);
  }

  // ---------------------------------------------------------------------------
  // HOTEL PARTNER — Mengelola booking di hotel
  // ---------------------------------------------------------------------------

  /// Mendapatkan semua booking yang ada di hotel tertentu.
  ///
  /// [hotelId] — ID hotel
  /// [status] — Filter by status booking
  /// [date] — Filter by tanggal (format: 'yyyy-MM-dd')
  Future<List<BookingModel>> getHotelBookings({
    required String hotelId,
    String? status,
    String? date,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
    };
    if (status != null) queryParams['status'] = status;
    if (date != null) queryParams['date'] = date;

    final response = await _apiClient.get(
      ApiEndpoints.getHotelBookings.replaceAll('{hotelId}', hotelId),
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] ?? response ?? [];
    return data.map((json) => BookingModel.fromJson(json)).toList();
  }

  /// Verifikasi pembayaran booking oleh Staff FO.
  ///
  /// Mengubah status dari `pendingVerification` menjadi `confirmed`.
  Future<BookingModel> verifyPayment(String bookingId) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyPayment.replaceAll('{bookingId}', bookingId),
    );
    return BookingModel.fromJson(response['data'] ?? response);
  }

  /// Proses check-in tamu oleh Staff FO (setelah scan QR).
  ///
  /// Mengubah status booking menjadi `checkedIn` dan
  /// status kamar menjadi `occupied`.
  Future<BookingModel> processCheckin({
    required String bookingId,
    required String qrCodeData,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.processCheckin.replaceAll('{bookingId}', bookingId),
      body: {'qr_code_data': qrCodeData},
    );
    return BookingModel.fromJson(response['data'] ?? response);
  }

  /// Proses check-out tamu oleh Staff FO.
  ///
  /// Mengubah status booking menjadi `checkedOut` dan
  /// status kamar menjadi `dirty` (perlu dibersihkan).
  /// [checkoutNotes] — Catatan kerusakan / penggunaan minibar
  Future<BookingModel> processCheckout({
    required String bookingId,
    String? checkoutNotes,
    bool hasDamage = false,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.processCheckout.replaceAll('{bookingId}', bookingId),
      body: {
        'checkout_notes': checkoutNotes,
        'has_damage': hasDamage,
      },
    );
    return BookingModel.fromJson(response['data'] ?? response);
  }

  // ---------------------------------------------------------------------------
  // PAYMENT
  // ---------------------------------------------------------------------------

  /// Inisiasi pembayaran — mendapatkan URL/token dari payment gateway.
  ///
  /// Mengembalikan Map yang berisi payment_url atau snap_token.
  Future<Map<String, dynamic>> initiatePayment({
    required String bookingId,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.initiatePayment,
      body: {
        'booking_id': bookingId,
        'payment_method': paymentMethod,
      },
    );
    return response['data'] ?? response;
  }

  /// Cek status pembayaran dari payment gateway.
  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    final response = await _apiClient.get(
      ApiEndpoints.getPaymentStatus.replaceAll('{paymentId}', paymentId),
    );
    return response['data'] ?? response;
  }
}
