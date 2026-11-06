import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import '../models/payout_model.dart';
import '../models/user_model.dart';
import 'mock_data.dart';
import 'supabase_service.dart';

/// Service untuk operasional Super Admin (Platform Owner).
/// Data dari Supabase. MockData HANYA saat offline.
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

        // Hitung total revenue dari booking yang completed
        double totalRevenue = 0;
        if (bookingsRes != null) {
          for (final b in (bookingsRes as List)) {
            final m = Map<String, dynamic>.from(b);
            if (m['status_booking'] == 'confirmed' || m['status_booking'] == 'completed') {
              totalRevenue += (m['total_harga'] as num?)?.toDouble() ?? 0;
            }
          }
        }

        return {
          'totalUsers': usersCount,
          'totalHotels': hotelsCount,
          'totalBookings': bookingsCount,
          'totalRevenue': totalRevenue.toInt(),
          'activePartners': hotelsCount,
        };
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] getPlatformStats error: $e');
        return {
          'totalUsers': 0,
          'totalHotels': 0,
          'totalBookings': 0,
          'totalRevenue': 0,
          'activePartners': 0,
        };
      }
    }

    // Fallback Mock — HANYA kalau Supabase belum terkoneksi
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'totalUsers': MockData.users.length,
      'totalHotels': MockData.hotels.length,
      'totalBookings': MockData.bookings.length,
      'totalRevenue': 124500000,
      'activePartners': 42,
    };
  }

  /// Mengambil semua akun user di platform
  Future<List<UserModel>> getAllUsers() async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final res = await sb
            .table(SupabaseConfig.tableUsers)
            ?.select()
            .order('created_at', ascending: false);
        if (res != null) {
          return (res as List)
              .map((u) => UserModel.fromJson(Map<String, dynamic>.from(u)))
              .toList();
        }
        return [];
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] getAllUsers error: $e');
        return [];
      }
    }

    // Fallback Mock — HANYA kalau Supabase belum terkoneksi
    await Future.delayed(const Duration(milliseconds: 200));
    return List<UserModel>.from(MockData.users);
  }

  /// Mengaktifkan / memblokir akun user
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
        }
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] toggleUserStatus error: $e');
        return false;
      }
    }

    final idx = MockData.users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      MockData.users[idx] = MockData.users[idx].copyWith(isActive: isActive);
      return true;
    }
    return false;
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

    // Fallback Mock — HANYA kalau Supabase belum terkoneksi
    await Future.delayed(const Duration(milliseconds: 200));
    return List<PayoutModel>.from(MockData.payouts);
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

    final idx = MockData.payouts.indexWhere((p) => p.id == payoutId);
    if (idx != -1) {
      MockData.payouts[idx] = MockData.payouts[idx].copyWith(
        status: newStatus,
        processedAt: DateTime.now(),
        referenceNumber: referenceNumber,
      );
      return true;
    }
    return false;
  }
}
