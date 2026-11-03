import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import '../models/booking_model.dart';
import '../models/room_model.dart';
import 'hotel_service.dart';
import 'mock_data.dart';
import 'supabase_service.dart';

/// Service untuk transaksi pemesanan tiket / reservasi hotel.
/// Terkoneksi dengan tabel [bookings] di Supabase dengan fallback lokal.
class BookingService {
  BookingService._();
  static final BookingService instance = BookingService._();

  // ---------------------------------------------------------------------------
  // 1. CREATE BOOKING
  // ---------------------------------------------------------------------------
  Future<BookingModel> createBooking(BookingModel booking) async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final res = await sb
            .table(SupabaseConfig.tableBookings)
            ?.insert(booking.toJson())
            .select()
            .single();

        if (res != null) {
          return BookingModel.fromJson(Map<String, dynamic>.from(res));
        }
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase createBooking error: $e');
      }
    }

    // Fallback Mock
    await Future.delayed(const Duration(milliseconds: 500));
    MockData.bookings.insert(0, booking);
    return booking;
  }

  // ---------------------------------------------------------------------------
  // 2. GET BOOKINGS (CUSTOMER & HOTEL)
  // ---------------------------------------------------------------------------

  /// Mengambil daftar pesanan milik customer yang login
  Future<List<BookingModel>> getMyBookings({BookingStatus? status}) async {
    final sb = SupabaseService.instance;
    final currentUserId = sb.currentAuthUser?.id;

    if (sb.isReady && currentUserId != null) {
      try {
        var q = sb
            .table(SupabaseConfig.tableBookings)
            ?.select()
            .eq('user_id', currentUserId);

        if (status != null) {
          q = q?.eq('status', status.apiValue);
        }

        final res = await q?.order('created_at', ascending: false);
        if (res != null && (res as List).isNotEmpty) {
          return res
              .map((b) => BookingModel.fromJson(Map<String, dynamic>.from(b)))
              .toList();
        }
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase getMyBookings error: $e');
      }
    }

    // Fallback Mock
    await Future.delayed(const Duration(milliseconds: 300));
    var list = List<BookingModel>.from(MockData.bookings);
    if (status != null) {
      list = list.where((b) => b.status == status).toList();
    }
    return list;
  }

  /// Mengambil daftar pesanan untuk Front Office Hotel Partner
  Future<List<BookingModel>> getHotelBookings(
    String hotelId, {
    BookingStatus? status,
  }) async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        var q = sb
            .table(SupabaseConfig.tableBookings)
            ?.select()
            .eq('hotel_id', hotelId);

        if (status != null) {
          q = q?.eq('status', status.apiValue);
        }

        final res = await q?.order('check_in_date', ascending: true);
        if (res != null && (res as List).isNotEmpty) {
          return res
              .map((b) => BookingModel.fromJson(Map<String, dynamic>.from(b)))
              .toList();
        }
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase getHotelBookings error: $e');
      }
    }

    // Fallback Mock
    await Future.delayed(const Duration(milliseconds: 300));
    var list = MockData.bookings.where((b) => b.hotelId == hotelId).toList();
    if (status != null) {
      list = list.where((b) => b.status == status).toList();
    }
    return list.isNotEmpty ? list : MockData.bookings;
  }

  /// Detail pemesanan berdasarkan ID atau Kode Booking
  Future<BookingModel?> getBookingById(String idOrCode) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final res = await sb
            .table(SupabaseConfig.tableBookings)
            ?.select()
            .or('id.eq.$idOrCode,booking_code.eq.$idOrCode')
            .maybeSingle();

        if (res != null) {
          return BookingModel.fromJson(Map<String, dynamic>.from(res));
        }
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase getBookingById error: $e');
      }
    }

    try {
      return MockData.bookings.firstWhere(
        (b) => b.id == idOrCode || b.bookingCode == idOrCode,
      );
    } catch (_) {
      return MockData.bookings.isNotEmpty ? MockData.bookings.first : null;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. FRONT OFFICE OPERATIONS (Check-in, Check-out, Verifikasi)
  // ---------------------------------------------------------------------------

  /// Proses Check-in tamu
  Future<bool> checkInGuest(String bookingId) async {
    final booking = await getBookingById(bookingId);
    if (booking == null) return false;

    final updated = booking.copyWith(
      status: BookingStatus.checkedIn,
      checkedInAt: DateTime.now(),
    );

    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        await sb.table(SupabaseConfig.tableBookings)?.update({
          'status': BookingStatus.checkedIn.apiValue,
          'checked_in_at': DateTime.now().toIso8601String(),
        }).eq('id', booking.id);
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase checkInGuest error: $e');
      }
    }

    // Update status kamar jadi Occupied
    await HotelService.instance
        .updateRoomStatus(booking.roomId, RoomStatus.occupied);

    final idx = MockData.bookings.indexWhere((b) => b.id == booking.id);
    if (idx != -1) {
      MockData.bookings[idx] = updated;
    }
    return true;
  }

  /// Proses Check-out tamu
  Future<bool> checkOutGuest(String bookingId) async {
    final booking = await getBookingById(bookingId);
    if (booking == null) return false;

    final updated = booking.copyWith(
      status: BookingStatus.checkedOut,
      checkedOutAt: DateTime.now(),
    );

    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        await sb.table(SupabaseConfig.tableBookings)?.update({
          'status': BookingStatus.checkedOut.apiValue,
          'checked_out_at': DateTime.now().toIso8601String(),
        }).eq('id', booking.id);
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase checkOutGuest error: $e');
      }
    }

    // Update status kamar jadi Dirty (perlu dibersihkan)
    await HotelService.instance
        .updateRoomStatus(booking.roomId, RoomStatus.dirty);

    final idx = MockData.bookings.indexWhere((b) => b.id == booking.id);
    if (idx != -1) {
      MockData.bookings[idx] = updated;
    }
    return true;
  }

  /// Verifikasi Pembayaran oleh FO
  Future<bool> verifyPayment(String bookingId) async {
    final booking = await getBookingById(bookingId);
    if (booking == null) return false;

    final updated = booking.copyWith(
      status: BookingStatus.confirmed,
      isPaid: true,
      paidAt: DateTime.now(),
    );

    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        await sb.table(SupabaseConfig.tableBookings)?.update({
          'status': BookingStatus.confirmed.apiValue,
          'is_paid': true,
          'paid_at': DateTime.now().toIso8601String(),
        }).eq('id', booking.id);
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase verifyPayment error: $e');
      }
    }

    final idx = MockData.bookings.indexWhere((b) => b.id == booking.id);
    if (idx != -1) {
      MockData.bookings[idx] = updated;
    }
    return true;
  }

  /// Batalkan pemesanan
  Future<bool> cancelBooking(String bookingId) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        await sb.table(SupabaseConfig.tableBookings)?.update({
          'status': BookingStatus.cancelled.apiValue,
        }).eq('id', bookingId);
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase cancelBooking error: $e');
      }
    }

    final idx = MockData.bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      MockData.bookings[idx] = MockData.bookings[idx]
          .copyWith(status: BookingStatus.cancelled);
      return true;
    }
    return false;
  }
}
