import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import '../models/booking_model.dart';
import '../models/room_model.dart';
import 'auth_service.dart';
import 'customer_data_service.dart';
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
        final row = {
          'id_user': int.tryParse(booking.customerId) ?? 1,
          'id_penginapan': int.tryParse(booking.hotelId) ?? 1,
          'id_tipe_kamar': booking.roomId.isNotEmpty ? booking.roomId : '1',
          'kode_booking': booking.bookingCode,
          'tgl_booking': DateTime.now().toIso8601String(),
          'tgl_checkin': booking.checkInDate.toIso8601String().substring(0, 10),
          'tgl_checkout': booking.checkOutDate.toIso8601String().substring(0, 10),
          'jml_malam': booking.totalNights,
          'jml_dewasa': booking.guestCount,
          'jml_anak': 0,
          'total_harga': booking.totalAmount.toDouble(),
          'potongan_diskon': booking.discountAmount.toDouble(),
          'status_booking': 'confirmed',
          'permintaan_khusus': booking.specialRequest,
        };

        final res = await sb
            .table(SupabaseConfig.tableBooking)
            ?.insert(row)
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

    if (sb.isReady) {
      try {
        var q = sb.table(SupabaseConfig.tableBooking)?.select(
              '*, mitra_penginapan(nama_properti), tipe_kamar(nama_tipe), users(nama_lengkap)',
            );

        if (currentUserId != null && int.tryParse(currentUserId) != null) {
          q = q?.eq('id_user', int.parse(currentUserId));
        }

        if (status != null) {
          final statusMap = {
            BookingStatus.confirmed: 'confirmed',
            BookingStatus.checkedIn: 'checked_in',
            BookingStatus.checkedOut: 'completed',
            BookingStatus.cancelled: 'cancelled',
            BookingStatus.pendingPayment: 'pending',
          };
          q = q?.eq('status_booking', statusMap[status] ?? status.apiValue);
        }

        final res = await q?.order('tgl_booking', ascending: false);
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
    final currentUser = AuthService.instance.currentUser;
    if (currentUser != null && CustomerDataService.instance.isFreshUser) {
      // Pengguna baru -> Fresh (hanya pesanan yang benar-benar dibuat oleh akun ini)
      var userList = MockData.bookings
          .where((b) =>
              b.customerId == currentUser.id || b.userId == currentUser.id)
          .toList();
      if (status != null) {
        userList = userList.where((b) => b.status == status).toList();
      }
      return userList;
    }

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
        final hId = int.tryParse(hotelId) ?? 1;
        var q = sb.table(SupabaseConfig.tableBooking)?.select(
              '*, mitra_penginapan(nama_properti), tipe_kamar(nama_tipe), users(nama_lengkap)',
            ).eq('id_penginapan', hId);

        if (status != null) {
          final statusMap = {
            BookingStatus.confirmed: 'confirmed',
            BookingStatus.checkedIn: 'checked_in',
            BookingStatus.checkedOut: 'completed',
            BookingStatus.cancelled: 'cancelled',
            BookingStatus.pendingPayment: 'pending',
          };
          q = q?.eq('status_booking', statusMap[status] ?? status.apiValue);
        }

        final res = await q?.order('tgl_checkin', ascending: true);
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
        final parsedId = int.tryParse(idOrCode);
        var q = sb.table(SupabaseConfig.tableBooking)?.select(
              '*, mitra_penginapan(nama_properti), tipe_kamar(nama_tipe), users(nama_lengkap)',
            );

        if (parsedId != null) {
          q = q?.or('id_booking.eq.$parsedId,kode_booking.eq.$idOrCode');
        } else {
          q = q?.eq('kode_booking', idOrCode);
        }

        final res = await q?.maybeSingle();

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
        final bId = int.tryParse(booking.id);
        if (bId != null) {
          await sb.table(SupabaseConfig.tableBooking)?.update({
            'status_booking': 'checked_in',
          }).eq('id_booking', bId);

          // Masukkan ke tabel check_in
          await sb.table(SupabaseConfig.tableCheckIn)?.insert({
            'id_booking': bId,
            'id_kamar': booking.roomNumber,
            'id_staf': '1',
            'waktu_checkin_aktual': DateTime.now().toIso8601String(),
            'status_checkin': 'selesai',
          });
        }
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
        final bId = int.tryParse(booking.id);
        if (bId != null) {
          await sb.table(SupabaseConfig.tableBooking)?.update({
            'status_booking': 'completed',
          }).eq('id_booking', bId);

          // Masukkan ke tabel check_out
          await sb.table(SupabaseConfig.tableCheckOut)?.insert({
            'id_booking': bId,
            'id_kamar': booking.roomNumber,
            'id_staf': '1',
            'waktu_checkout_aktual': DateTime.now().toIso8601String(),
            'status_checkout': 'selesai',
          });
        }
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
        final bId = int.tryParse(booking.id);
        if (bId != null) {
          await sb.table(SupabaseConfig.tableBooking)?.update({
            'status_booking': 'confirmed',
          }).eq('id_booking', bId);

          // Catat ke tabel verifikasi_booking
          await sb.table(SupabaseConfig.tableVerifikasiBooking)?.insert({
            'id_booking': bId,
            'id_staf': '1',
            'status_verifikasi': 'disetujui',
            'tgl_verifikasi': DateTime.now().toIso8601String(),
            'catatan_verifikasi': 'Pembayaran diverifikasi otomatis/manual',
          });
        }
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
        final bId = int.tryParse(bookingId);
        if (bId != null) {
          await sb.table(SupabaseConfig.tableBooking)?.update({
            'status_booking': 'cancelled',
          }).eq('id_booking', bId);
        }
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

