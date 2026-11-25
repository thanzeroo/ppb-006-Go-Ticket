import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/supabase_config.dart';
import '../models/payout_model.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

/// Service untuk operasional Super Admin (Platform Owner).
/// Seluruh data bersumber langsung dari Supabase Database.
/// Tidak ada mock data atau fallback dummy data.
class SuperAdminService {
  SuperAdminService._();
  static final SuperAdminService instance = SuperAdminService._();

  /// Statistik platform real-time
  Future<Map<String, dynamic>> getPlatformStats() async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final usersRes = await sb.table(SupabaseConfig.tableUsers)?.select();
        final hotelsRes = await sb.table(SupabaseConfig.tableMitraPenginapan)?.select();
        final bookingsRes = await sb.table(SupabaseConfig.tableBooking)?.select();

        final usersCount = (usersRes as List?)?.length ?? 0;
        final hotelsCount = (hotelsRes as List?)?.length ?? 0;
        final bookingsCount = (bookingsRes as List?)?.length ?? 0;

        // Hitung total revenue dari booking yang completed / confirmed
        double totalRevenue = 0;
        final List<Map<String, dynamic>> rawBookings = [];
        if (bookingsRes != null) {
          for (final b in (bookingsRes as List)) {
            final m = Map<String, dynamic>.from(b);
            rawBookings.add(m);
            if (m['status_booking'] == 'confirmed' || m['status_booking'] == 'completed') {
              totalRevenue += (m['total_harga'] as num?)?.toDouble() ?? 0;
            }
          }
        }

        // Ambil data transaksi pembayaran untuk laporan keuangan
        final paymentsRes = await sb
            .table(SupabaseConfig.tablePembayaran)
            ?.select()
            .order('tgl_bayar', ascending: false);
        final List<Map<String, dynamic>> rawPayments = [];
        if (paymentsRes != null) {
          for (final p in (paymentsRes as List)) {
            rawPayments.add(Map<String, dynamic>.from(p));
          }
        }

        return {
          'totalUsers': usersCount,
          'totalHotels': hotelsCount,
          'totalBookings': bookingsCount,
          'totalRevenue': totalRevenue.toInt(),
          'activePartners': hotelsCount,
          'bookingsList': rawBookings,
          'paymentsList': rawPayments,
        };
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] getPlatformStats error: $e');
      }
    }

    return {
      'totalUsers': 0,
      'totalHotels': 0,
      'totalBookings': 0,
      'totalRevenue': 0,
      'activePartners': 0,
    };
  }

  /// Mengambil semua akun user di platform (Tamu & Staf Hotel)
  Future<List<UserModel>> getAllUsers() async {
    final sb = SupabaseService.instance;
    final List<UserModel> allUsers = [];

    if (sb.isReady) {
      try {
        // 1. Ambil data customer dari tabel users
        final resUsers = await sb
            .table(SupabaseConfig.tableUsers)
            ?.select()
            .order('created_at', ascending: false);
        if (resUsers != null) {
          for (final u in (resUsers as List)) {
            final m = Map<String, dynamic>.from(u);
            if (!m.containsKey('role') || m['role'] == null) {
              m['role'] = 'customer';
            }
            allUsers.add(UserModel.fromJson(m));
          }
        }
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] getAllUsers (users) error: $e');
      }

      try {
        // 2. Ambil data staf hotel dari tabel staf_hotel
        final resStaff = await sb
            .table(SupabaseConfig.tableStafHotel)
            ?.select()
            .order('created_at', ascending: false);
        if (resStaff != null) {
          for (final s in (resStaff as List)) {
            final m = Map<String, dynamic>.from(s);
            allUsers.add(UserModel.fromJson(m));
          }
        }
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] getAllUsers (staf_hotel) error: $e');
      }
    }

    return allUsers;
  }

  /// Mengaktifkan / memblokir akun user atau staf
  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final parsedId = int.tryParse(userId);
        if (parsedId != null) {
          await sb.table(SupabaseConfig.tableUsers)?.update({
            'status_akun': isActive ? 'aktif' : 'tersuspend',
          }).eq('id_user', parsedId);
          return true;
        } else {
          // Staf hotel dengan string ID (contoh: FO-2025-001)
          await sb.table(SupabaseConfig.tableStafHotel)?.update({
            'status_karyawan': isActive ? 'Aktif' : 'Nonaktif',
            'status_duty': isActive ? 'On' : 'Off',
          }).eq('id_staf', userId);
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] toggleUserStatus error: $e');
        return false;
      }
    }

    return false;
  }

  /// Update data profil user / staf oleh Super Admin
  Future<bool> updateUser({
    required String userId,
    required String fullName,
    String? email,
    String? phoneNumber,
    String? status,
  }) async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final parsedId = int.tryParse(userId);
        if (parsedId != null) {
          final payload = <String, dynamic>{
            'nama_lengkap': fullName.trim(),
          };
          if (email != null && email.trim().isNotEmpty) {
            payload['email'] = email.trim();
          }
          if (phoneNumber != null) {
            payload['no_telepon'] = phoneNumber.trim();
          }
          if (status != null) {
            payload['status_akun'] = status.toLowerCase();
          }

          await sb
              .table(SupabaseConfig.tableUsers)
              ?.update(payload)
              .eq('id_user', parsedId);
          return true;
        } else {
          // Staf hotel
          final payload = <String, dynamic>{
            'nama_staf': fullName.trim(),
          };
          if (email != null && email.trim().isNotEmpty) {
            payload['email'] = email.trim();
          }
          if (phoneNumber != null) {
            payload['no_telepon'] = phoneNumber.trim();
          }
          if (status != null) {
            payload['status_karyawan'] =
                status.toLowerCase() == 'aktif' ? 'Aktif' : 'Nonaktif';
          }

          await sb
              .table(SupabaseConfig.tableStafHotel)
              ?.update(payload)
              .eq('id_staf', userId);
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] updateUser error: $e');
        return false;
      }
    }

    return false;
  }

  /// Hapus akun user / staf dari database
  Future<bool> deleteUser(String userId) async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final parsedId = int.tryParse(userId);
        if (parsedId != null) {
          await sb
              .table(SupabaseConfig.tableUsers)
              ?.delete()
              .eq('id_user', parsedId);
          return true;
        } else {
          await sb
              .table(SupabaseConfig.tableStafHotel)
              ?.delete()
              .eq('id_staf', userId);
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] deleteUser error: $e');
        return false;
      }
    }

    return false;
  }

  /// Menambah user baru ke database Supabase
  Future<bool> createUser({
    required String fullName,
    required String email,
    String? password,
    String? phoneNumber,
    String role = 'customer',
  }) async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final cleanEmail = email.trim().toLowerCase();
        if (password != null && password.trim().isNotEmpty && sb.client != null) {
          try {
            await sb.client!.auth.signUp(
              email: cleanEmail,
              password: password.trim(),
              data: {'full_name': fullName.trim()},
            );
          } catch (authErr) {
            debugPrint('⚠️ [SuperAdminService] createUser auth signUp notice: $authErr');
          }
        }

        final payload = <String, dynamic>{
          'nama_lengkap': fullName.trim(),
          'email': cleanEmail,
          'no_telepon': phoneNumber?.trim() ?? '',
          'password': '',
          'status_akun': 'aktif',
          'tier_membership': 'Bronze',
          'saldo_poin': 0.0,
        };

        await sb.table(SupabaseConfig.tableUsers)?.insert(payload);
        return true;
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] createUser error: $e');
        return false;
      }
    }

    return false;
  }

  /// Menambah akun administrator atau staf hotel baru ke Supabase
  Future<bool> createHotelStaff({
    required int hotelId,
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    String? idKaryawan,
    String roleJabatan = 'administrator',
    String shiftTugas = 'General',
  }) async {
    final sb = SupabaseService.instance;
    if (!sb.isReady) return false;

    try {
      final cleanEmail = email.trim().toLowerCase();
      final svcKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
          ? SupabaseConfig.supabaseServiceRoleKey
          : SupabaseConfig.activeApiKey;

      // 1. Daftarkan akun auth via Admin REST API (Service Role Key).
      //    JANGAN pakai sb.client!.auth.signUp() — itu menggantikan session super admin
      //    yang sedang login dan menyebabkan super admin terlogout.
      try {
        final authUri = Uri.parse('${SupabaseConfig.supabaseUrl}/auth/v1/admin/users');
        await http.post(
          authUri,
          headers: {
            'apikey': svcKey,
            'Authorization': 'Bearer $svcKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': cleanEmail,
            'password': password.trim(),
            'email_confirm': true,
            'user_metadata': {
              'full_name': fullName.trim(),
              'role': roleJabatan,
              'id_penginapan': hotelId,
            },
          }),
        );
      } catch (authErr) {
        debugPrint('⚠️ [SuperAdminService] createHotelStaff auth notice: $authErr');
      }

      // 2. Generate ID Staf terstruktur (contoh: ADM-2025-102)
      final prefix = roleJabatan == 'administrator'
          ? 'ADM'
          : (roleJabatan == 'front_office' ? 'FO' : 'MTC');
      final year = DateTime.now().year;
      final randSuffix = (DateTime.now().millisecondsSinceEpoch % 900 + 100).toString();
      final idStaf = '$prefix-$year-$randSuffix';

      // 3. Masukkan ke tabel staf_hotel via Service Role REST API (bypass RLS)
      final staffUri = Uri.parse('${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableStafHotel}');
      await http.post(
        staffUri,
        headers: {
          'apikey': svcKey,
          'Authorization': 'Bearer $svcKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'id_staf': idStaf,
          'id_penginapan': hotelId,
          'nama_staf': fullName.trim(),
          'email': cleanEmail,
          'password': 'MANAGED_BY_SUPABASE_AUTH',
          'no_telepon': phoneNumber?.trim().isEmpty == false ? phoneNumber!.trim() : null,
          'nik_staf': (idKaryawan != null && idKaryawan.trim().isNotEmpty) ? idKaryawan.trim() : null,
          'role_jabatan': roleJabatan,
          'shift_tugas': shiftTugas,
          'status_karyawan': 'Aktif',
          'status_duty': 'Off',
        }),
      );

      return true;
    } catch (e) {
      debugPrint('⚠️ [SuperAdminService] createHotelStaff error: $e');
      rethrow;
    }
  }

  /// Mengambil semua permohonan pencairan dana (Payout)
  Future<List<PayoutModel>> getAllPayouts() async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final res = await sb
            .table(SupabaseConfig.tableMonitoringDana)
            ?.select()
            .order('tgl_pengajuan', ascending: false);
        if (res != null) {
          return (res as List)
              .map((p) => PayoutModel.fromJson(Map<String, dynamic>.from(p)))
              .toList();
        }
        return [];
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] getAllPayouts error: $e');
        return [];
      }
    }

    return [];
  }

  /// Menyetujui atau menolak permohonan payout
  Future<bool> processPayout(
    String payoutId,
    PayoutStatus newStatus, {
    String? referenceNumber,
  }) async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final parsedId = int.tryParse(payoutId);
        final statusStr = newStatus == PayoutStatus.completed
            ? 'disetujui'
            : (newStatus == PayoutStatus.rejected ? 'ditolak' : 'menunggu');

        final data = <String, dynamic>{
          'status_dana': statusStr,
        };
        if (referenceNumber != null) {
          data['no_referensi_payout'] = referenceNumber;
        }

        if (parsedId != null) {
          await sb
              .table(SupabaseConfig.tableMonitoringDana)
              ?.update(data)
              .eq('id_monitoring', parsedId);
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] processPayout error: $e');
        return false;
      }
    }

    return false;
  }
}
