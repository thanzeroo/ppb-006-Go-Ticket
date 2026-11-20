import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:go_ticket_user/core/models/booking_model.dart';
import 'package:go_ticket_user/core/models/review_model.dart';

/// Helper penyimpanan lokal untuk pihak_user (Customer App).
/// Memastikan pesanan, nomor kamar, status reject, dan ulasan terverifikasi
/// tersimpan persisten bahkan saat offline atau tabel Supabase belum siap.
class UserBookingStorage {
  UserBookingStorage._();
  static final UserBookingStorage instance = UserBookingStorage._();

  static const String _keyBookings = 'user_bookings_cache_v2';
  static const String _keyReviews = 'user_reviews_cache_v2';

  // ---------------------------------------------------------------------------
  // 1. BOOKING LOCAL STORAGE
  // ---------------------------------------------------------------------------

  /// Simpan booking baru ke penyimpanan lokal
  Future<void> saveBooking(BookingModel booking) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = await getBookings();
      // Replace if exists, else prepend
      list.removeWhere((b) => b.id == booking.id || b.bookingCode == booking.bookingCode);
      list.insert(0, booking);

      final jsonList = list.map((b) => b.toJson()).toList();
      await prefs.setString(_keyBookings, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('⚠️ [UserBookingStorage] saveBooking error: $e');
    }
  }

  /// Ambil semua booking lokal
  Future<List<BookingModel>> getBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyBookings);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => BookingModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ [UserBookingStorage] getBookings error: $e');
    }
    return [];
  }

  /// Batalkan / Reject booking lokal
  Future<bool> cancelBooking(
    String idOrCode, {
    String? reason,
    BookingModel? fallbackBooking,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = await getBookings();
      bool found = false;

      final updated = list.map((b) {
        if (b.id == idOrCode || b.bookingCode == idOrCode) {
          found = true;
          return b.copyWith(
            status: BookingStatus.cancelled,
          );
        }
        return b;
      }).toList();

      if (!found && fallbackBooking != null) {
        updated.insert(
          0,
          fallbackBooking.copyWith(
            status: BookingStatus.cancelled,
          ),
        );
        found = true;
      }

      if (found) {
        final jsonList = updated.map((b) => b.toJson()).toList();
        await prefs.setString(_keyBookings, jsonEncode(jsonList));
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ [UserBookingStorage] cancelBooking error: $e');
    }
    return false;
  }

  /// Update status booking (misal confirmed / selesai)
  Future<bool> updateBookingStatus(String idOrCode, BookingStatus newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = await getBookings();
      bool found = false;

      final updated = list.map((b) {
        if (b.id == idOrCode || b.bookingCode == idOrCode) {
          found = true;
          return b.copyWith(status: newStatus);
        }
        return b;
      }).toList();

      if (found) {
        final jsonList = updated.map((b) => b.toJson()).toList();
        await prefs.setString(_keyBookings, jsonEncode(jsonList));
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ [UserBookingStorage] updateBookingStatus error: $e');
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // 2. REVIEWS LOCAL STORAGE
  // ---------------------------------------------------------------------------

  /// Simpan review terverifikasi dari tamu
  Future<void> saveReview(ReviewModel review) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allReviews = await getAllReviews();
      allReviews.removeWhere((r) => r.id == review.id && r.id.isNotEmpty);
      allReviews.insert(0, review);

      final jsonList = allReviews.map((r) => r.toJson()).toList();
      await prefs.setString(_keyReviews, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('⚠️ [UserBookingStorage] saveReview error: $e');
    }
  }

  /// Ambil semua review lokal
  Future<List<ReviewModel>> getAllReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyReviews);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => ReviewModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ [UserBookingStorage] getAllReviews error: $e');
    }
    return [];
  }

  /// Ambil review lokal berdasarkan hotelId
  Future<List<ReviewModel>> getReviewsByHotel(String hotelId) async {
    final all = await getAllReviews();
    if (hotelId.isEmpty) return all;
    return all.where((r) => r.hotelId == hotelId || r.hotelId.isEmpty).toList();
  }
}

