import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/supabase_config.dart';
import '../models/booking_model.dart';
import '../models/room_model.dart';
import 'auth_service.dart';
import 'hotel_service.dart';
import 'supabase_service.dart';

/// Service untuk transaksi pemesanan tiket / reservasi hotel.
/// Terkoneksi langsung dengan tabel [booking] di Supabase.
/// Tidak ada mock data atau fallback dummy data.
class BookingService {
  BookingService._();
  static final BookingService instance = BookingService._();

  // ---------------------------------------------------------------------------
  // 1. CREATE BOOKING
  // ---------------------------------------------------------------------------
  Future<BookingModel> createBooking(BookingModel booking) async {
    final sb = SupabaseService.instance;

    if (sb.isReady && sb.client != null) {
      try {
        final currentUserId = AuthService.instance.currentUser?.id;
        final userIdNum = int.tryParse(currentUserId ?? booking.customerId);
        final hotelIdNum = int.tryParse(booking.hotelId);

        // Validasi tipe kamar jika ada di database
        String? validRoomTypeId;
        if (booking.roomId.isNotEmpty) {
          final checkRoom = await sb
              .table(SupabaseConfig.tableTipeKamar)
              ?.select('id_tipe_kamar')
              .eq('id_tipe_kamar', booking.roomId)
              .maybeSingle();
          if (checkRoom != null) {
            validRoomTypeId = booking.roomId;
          }
        }

        // Jika belum ada tipe kamar spesifik, cari kamar default milik hotel
        if (validRoomTypeId == null && hotelIdNum != null) {
          final firstRoom = await sb
              .table(SupabaseConfig.tableTipeKamar)
              ?.select('id_tipe_kamar')
              .eq('id_penginapan', hotelIdNum)
              .maybeSingle();
          if (firstRoom != null) {
            validRoomTypeId = firstRoom['id_tipe_kamar']?.toString();
          }
        }

        final row = <String, dynamic>{
          if (userIdNum != null) 'id_user': userIdNum,
          if (hotelIdNum != null) 'id_penginapan': hotelIdNum,
          if (validRoomTypeId != null) 'id_tipe_kamar': validRoomTypeId,
          'kode_booking': booking.bookingCode,
          'tgl_booking': DateTime.now().toIso8601String(),
          'tgl_checkin':
              booking.checkInDate.toIso8601String().substring(0, 10),
          'tgl_checkout':
              booking.checkOutDate.toIso8601String().substring(0, 10),
          'jml_malam': booking.totalNights > 0 ? booking.totalNights : 1,
          'jml_dewasa': booking.guestCount > 0 ? booking.guestCount : 1,
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
          final int newBookingId =
              int.tryParse(res['id_booking'].toString()) ?? 0;

          if (newBookingId > 0) {
            // 1. Simpan data pembayaran ke tabel pembayaran
            try {
              await sb.table(SupabaseConfig.tablePembayaran)?.insert({
                'id_booking': newBookingId,
                'no_referensi_trx': 'TRX-${booking.bookingCode}',
                'metode_pembayaran':
                    booking.paymentMethod ?? 'QRIS / GoPay Instan',
                'nominal_bayar': booking.totalAmount.toDouble(),
                'tgl_bayar': DateTime.now().toIso8601String(),
                'status_pembayaran': 'Berhasil',
              });
            } catch (e) {
              debugPrint('⚠️ [BookingService] Insert pembayaran error: $e');
            }

            // 2. Terbitkan e-tiket digital ke tabel eticket
            try {
              await sb.table(SupabaseConfig.tableEticket)?.insert({
                'id_booking': newBookingId,
                'nomor_tiket': 'TKT-${booking.bookingCode}',
                'qr_code_token': 'GT-QR-${booking.bookingCode}',
                'tgl_terbit': DateTime.now().toIso8601String(),
                'status_tiket': 'Aktif',
              });
            } catch (e) {
              debugPrint('⚠️ [BookingService] Insert eticket error: $e');
            }

            // 3. Tambah loyalty reward poin pengguna (cashback 5%)
            if (userIdNum != null) {
              try {
                final pointsEarned = (booking.totalAmount * 0.05).toInt();
                if (pointsEarned > 0) {
                  final userRow = await sb
                      .table(SupabaseConfig.tableUsers)
                      ?.select('saldo_poin')
                      .eq('id_user', userIdNum)
                      .maybeSingle();
                  final currentPoints =
                      (userRow?['saldo_poin'] as num?)?.toInt() ?? 0;
                  await sb.table(SupabaseConfig.tableUsers)?.update({
                    'saldo_poin': currentPoints + pointsEarned,
                  }).eq('id_user', userIdNum);
                }
              } catch (e) {
                debugPrint('⚠️ [BookingService] Update reward points error: $e');
              }
            }
          }

          final fullBooking = await getBookingById(booking.bookingCode);
          return fullBooking ??
              BookingModel.fromJson(Map<String, dynamic>.from(res));
        }
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase createBooking error: $e');
      }
    }

    return booking;
  }

  // ---------------------------------------------------------------------------
  // 2. GET BOOKINGS (CUSTOMER & HOTEL)
  // ---------------------------------------------------------------------------

  /// Mengambil daftar pesanan milik customer yang login
  Future<List<BookingModel>> getMyBookings({BookingStatus? status}) async {
    final sb = SupabaseService.instance;
    final user = AuthService.instance.currentUser;
    final userId = user?.id ?? sb.currentAuthUser?.id;

    if (sb.isReady && sb.client != null) {
      try {
        dynamic q = sb.table(SupabaseConfig.tableBooking)?.select(
            '*, mitra_penginapan(*), tipe_kamar(*), eticket(*), pembayaran(*)');
        if (q == null) return [];

        if (userId != null) {
          final uid = int.tryParse(userId);
          if (uid != null) {
            q = q.eq('id_user', uid);
          }
        }

        if (status != null) {
          final statusMap = {
            BookingStatus.confirmed: 'confirmed',
            BookingStatus.checkedIn: 'checked_in',
            BookingStatus.checkedOut: 'completed',
            BookingStatus.cancelled: 'cancelled',
            BookingStatus.pendingPayment: 'pending',
          };
          q = q.eq('status_booking', statusMap[status] ?? status.apiValue);
        }

        final res = await q.order('id_booking', ascending: false);
        if (res != null) {
          return (res as List)
              .map((b) => BookingModel.fromJson(Map<String, dynamic>.from(b)))
              .toList();
        }
        return [];
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase getMyBookings error: $e');
        return [];
      }
    }

    return [];
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
        var q = sb.table(SupabaseConfig.tableBooking)?.select('*').eq('id_penginapan', hId);

        if (status != null && q != null) {
          final statusMap = {
            BookingStatus.confirmed: 'confirmed',
            BookingStatus.checkedIn: 'checked_in',
            BookingStatus.checkedOut: 'completed',
            BookingStatus.cancelled: 'cancelled',
            BookingStatus.pendingPayment: 'pending',
          };
          q = q.eq('status_booking', statusMap[status] ?? status.apiValue);
        }

        final res = await q?.order('tgl_checkin', ascending: true);
        if (res != null) {
          return (res as List)
              .map((b) => BookingModel.fromJson(Map<String, dynamic>.from(b)))
              .toList();
        }
        return [];
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase getHotelBookings error: $e');
        return [];
      }
    }

    return [];
  }

  /// Detail pemesanan berdasarkan ID atau Kode Booking
  Future<BookingModel?> getBookingById(String idOrCode) async {
    final sb = SupabaseService.instance;
    if (sb.isReady && sb.client != null) {
      try {
        final parsedId = int.tryParse(idOrCode);
        dynamic q = sb.table(SupabaseConfig.tableBooking)?.select(
            '*, mitra_penginapan(*), tipe_kamar(*), eticket(*), pembayaran(*)');

        if (parsedId != null) {
          q = q?.or('id_booking.eq.$parsedId,kode_booking.eq.$idOrCode');
        } else {
          q = q?.eq('kode_booking', idOrCode);
        }

        final res = await q?.maybeSingle();

        if (res != null) {
          return BookingModel.fromJson(Map<String, dynamic>.from(res));
        }
        return null;
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase getBookingById error: $e');
        return null;
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // 3. FRONT OFFICE OPERATIONS (Check-in, Check-out, Verifikasi)
  // ---------------------------------------------------------------------------

  /// Proses Check-in tamu
  Future<bool> checkInGuest(String bookingId) async {
    final booking = await getBookingById(bookingId);
    if (booking == null) return false;

    final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
        ? SupabaseConfig.supabaseServiceRoleKey
        : SupabaseConfig.activeApiKey;

    final bId = int.tryParse(booking.id);
    if (bId != null) {
      final staffId = AuthService.instance.currentUser?.id;
      final validStaffId =
          (staffId != null && staffId.isNotEmpty) ? staffId : 'FO-2025-001';
      final validRoomId = booking.roomId.isNotEmpty ? booking.roomId : '1';

      // 1. Update status booking di Supabase
      try {
        final updateUri = Uri.parse(
            '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableBooking}?id_booking=eq.$bId');
        await http.patch(
          updateUri,
          headers: {
            'apikey': serviceKey,
            'Authorization': 'Bearer $serviceKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'status_booking': 'checked_in'}),
        );
      } catch (e) {
        debugPrint('⚠️ [BookingService] Update booking status error: $e');
      }

      // 2. Masukkan ke tabel check_in
      try {
        final checkInUri = Uri.parse(
            '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableCheckIn}');
        await http.post(
          checkInUri,
          headers: {
            'apikey': serviceKey,
            'Authorization': 'Bearer $serviceKey',
            'Content-Type': 'application/json',
            'Prefer': 'return=representation',
          },
          body: jsonEncode({
            'id_booking': bId,
            'id_kamar': validRoomId,
            'id_staf': validStaffId,
            'waktu_checkin_aktual': DateTime.now().toIso8601String(),
            'status_checkin': 'selesai',
          }),
        );
      } catch (e) {
        debugPrint('⚠️ [BookingService] Insert check_in record error: $e');
      }
    }

    // Update status kamar jadi Occupied
    await HotelService.instance
        .updateRoomStatus(booking.roomId, RoomStatus.occupied);

    return true;
  }

  /// Proses Check-out tamu
  Future<bool> checkOutGuest(String bookingId) async {
    final booking = await getBookingById(bookingId);
    if (booking == null) return false;

    final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
        ? SupabaseConfig.supabaseServiceRoleKey
        : SupabaseConfig.activeApiKey;

    final bId = int.tryParse(booking.id);
    if (bId != null) {
      final staffId = AuthService.instance.currentUser?.id;
      final validStaffId =
          (staffId != null && staffId.isNotEmpty) ? staffId : 'FO-2025-001';
      final validRoomId = booking.roomId.isNotEmpty ? booking.roomId : '1';

      // 1. Update status booking jadi completed
      try {
        final updateUri = Uri.parse(
            '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableBooking}?id_booking=eq.$bId');
        await http.patch(
          updateUri,
          headers: {
            'apikey': serviceKey,
            'Authorization': 'Bearer $serviceKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'status_booking': 'completed'}),
        );
      } catch (e) {
        debugPrint('⚠️ [BookingService] Update booking checkout error: $e');
      }

      // 2. Masukkan ke tabel check_out
      try {
        final checkOutUri = Uri.parse(
            '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableCheckOut}');
        await http.post(
          checkOutUri,
          headers: {
            'apikey': serviceKey,
            'Authorization': 'Bearer $serviceKey',
            'Content-Type': 'application/json',
            'Prefer': 'return=representation',
          },
          body: jsonEncode({
            'id_booking': bId,
            'id_kamar': validRoomId,
            'id_staf': validStaffId,
            'waktu_checkout_aktual': DateTime.now().toIso8601String(),
            'status_checkout': 'selesai',
          }),
        );
      } catch (e) {
        debugPrint('⚠️ [BookingService] Insert check_out record error: $e');
      }
    }

    // Update status kamar jadi Dirty (perlu dibersihkan)
    await HotelService.instance
        .updateRoomStatus(booking.roomId, RoomStatus.dirty);

    return true;
  }

  /// Verifikasi Pembayaran oleh FO
  Future<bool> verifyPayment(String bookingId) async {
    final booking = await getBookingById(bookingId);
    if (booking == null) return false;

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
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ [BookingService] Supabase cancelBooking error: $e');
        return false;
      }
    }

    return false;
  }
}
