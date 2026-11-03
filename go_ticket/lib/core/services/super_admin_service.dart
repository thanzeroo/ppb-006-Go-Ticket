import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import '../models/payout_model.dart';
import '../models/user_model.dart';
import 'mock_data.dart';
import 'supabase_service.dart';

/// Service untuk operasional Super Admin (Platform Owner).
class SuperAdminService {
  SuperAdminService._();
  static final SuperAdminService instance = SuperAdminService._();

  /// Statistik platform real-time
  Future<Map<String, dynamic>> getPlatformStats() async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final usersCount = await sb.table(SupabaseConfig.tableUsers)?.count();
        final hotelsCount =
            await sb.table(SupabaseConfig.tableMitraPenginapan)?.count();
        final bookingsCount =
            await sb.table(SupabaseConfig.tableBooking)?.count();

        return {
          'totalUsers': usersCount ?? MockData.users.length,
          'totalHotels': hotelsCount ?? MockData.hotels.length,
          'totalBookings': bookingsCount ?? MockData.bookings.length,
          'totalRevenue': 124500000,
          'activePartners': hotelsCount ?? 20,
        };
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] getPlatformStats error: $e');
      }
    }

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
        if (res != null && (res as List).isNotEmpty) {
          return res
              .map((u) => UserModel.fromJson(Map<String, dynamic>.from(u)))
              .toList();
        }
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] getAllUsers error: $e');
      }
    }

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
        if (res != null && (res as List).isNotEmpty) {
          return res
              .map((p) => PayoutModel.fromJson(Map<String, dynamic>.from(p)))
              .toList();
        }
      } catch (e) {
        debugPrint('⚠️ [SuperAdminService] getAllPayouts error: $e');
      }
    }

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

