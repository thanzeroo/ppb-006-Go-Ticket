import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import 'mock_data.dart';
import 'supabase_service.dart';

/// Service untuk mengelola promo & voucher diskon Go Ticket.
class PromoService {
  PromoService._();
  static final PromoService instance = PromoService._();

  /// Mengambil semua promo aktif
  Future<List<Map<String, dynamic>>> getPromos() async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final res = await sb
            .table(SupabaseConfig.tablePromos)
            ?.select()
            .eq('is_active', true);
        if (res != null && (res as List).isNotEmpty) {
          return List<Map<String, dynamic>>.from(res);
        }
      } catch (e) {
        debugPrint('⚠️ [PromoService] getPromos error: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    return List<Map<String, dynamic>>.from(MockData.promos);
  }

  /// Validasi kode promo dan hitung nominal diskon
  Future<Map<String, dynamic>?> validatePromo({
    required String code,
    required double bookingAmount,
  }) async {
    final promos = await getPromos();
    final promo = promos.firstWhere(
      (p) =>
          (p['code'] as String).toUpperCase() == code.trim().toUpperCase() &&
          (p['isActive'] == true || p['is_active'] == true),
      orElse: () => {},
    );

    if (promo.isEmpty) return null;

    final minAmount = (promo['minBookingAmount'] ?? promo['min_booking_amount'] ?? 0) as num;
    if (bookingAmount < minAmount) {
      throw Exception(
        'Minimum transaksi untuk kode ini adalah Rp $minAmount',
      );
    }

    final discountPercent = (promo['discountPercent'] ?? promo['discount_percent'] ?? 0) as num;
    final maxDiscount = (promo['maxDiscount'] ?? promo['max_discount'] ?? 0) as num;

    double calculatedDiscount = (bookingAmount * discountPercent) / 100;
    if (maxDiscount > 0 && calculatedDiscount > maxDiscount) {
      calculatedDiscount = maxDiscount.toDouble();
    }

    return {
      'promo': promo,
      'discountAmount': calculatedDiscount,
    };
  }

  /// Tambah promo baru (Super Admin)
  Future<bool> createPromo(Map<String, dynamic> promo) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        await sb.table(SupabaseConfig.tablePromos)?.insert(promo);
        return true;
      } catch (e) {
        debugPrint('⚠️ [PromoService] createPromo error: $e');
      }
    }

    MockData.promos.add(promo);
    return true;
  }

  /// Hapus promo (Super Admin)
  Future<bool> deletePromo(String promoId) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        await sb.table(SupabaseConfig.tablePromos)?.delete().eq('id', promoId);
        return true;
      } catch (e) {
        debugPrint('⚠️ [PromoService] deletePromo error: $e');
      }
    }

    MockData.promos.removeWhere((p) => p['id'] == promoId);
    return true;
  }
}
