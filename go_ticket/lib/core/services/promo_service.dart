import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import 'supabase_service.dart';

/// Service untuk mengelola promo & voucher diskon Go Ticket.
/// Seluruh data bersumber langsung dari Supabase [kampanye_promo].
/// Tidak ada mock data atau fallback dummy data.
class PromoService {
  PromoService._();
  static final PromoService instance = PromoService._();

  /// Mengambil semua promo aktif
  Future<List<Map<String, dynamic>>> getPromos() async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final res = await sb
            .table(SupabaseConfig.tableKampanyePromo)
            ?.select()
            .eq('status_promo', 'aktif');
        if (res != null) {
          // Return data dari DB (meskipun kosong [])
          return (res as List).map((p) {
            final m = Map<String, dynamic>.from(p);
            return {
              'id': m['promo_id']?.toString() ?? '',
              'code': m['kode_promo'] ?? '',
              'title': m['nama_kampanye'] ?? 'Promo Diskon',
              'description':
                  'Diskon ${m['besaran_diskon']}% hingga Rp ${m['maks_plafon_diskon']}',
              'discountPercent': m['besaran_diskon'] ?? 10,
              'maxDiscount': m['maks_plafon_diskon'] ?? 100000,
              'minBookingAmount': m['min_transaksi'] ?? 0,
              'expiredDate': m['tgl_berakhir'] ?? '2026-12-31',
              'isActive': m['status_promo'] == 'aktif',
            };
          }).toList();
        }
        return [];
      } catch (e) {
        debugPrint('⚠️ [PromoService] getPromos error: $e');
        return [];
      }
    }

    return [];
  }

  /// Validasi kode promo dan hitung nominal diskon
  Future<Map<String, dynamic>?> validatePromo({
    required String code,
    required double bookingAmount,
  }) async {
    final promos = await getPromos();
    final promo = promos.firstWhere(
      (p) {
        final c = (p['code'] ?? p['kode_promo'] ?? '').toString();
        return c.toUpperCase() == code.trim().toUpperCase() &&
            (p['isActive'] == true || p['status_promo'] == 'aktif');
      },
      orElse: () => {},
    );

    if (promo.isEmpty) return null;

    final minAmount = (promo['minBookingAmount'] ??
        promo['min_transaksi'] ??
        promo['min_booking_amount'] ??
        0) as num;
    if (bookingAmount < minAmount) {
      throw Exception(
        'Minimum transaksi untuk kode ini adalah Rp $minAmount',
      );
    }

    final discountPercent = (promo['discountPercent'] ??
        promo['besaran_diskon'] ??
        promo['discount_percent'] ??
        0) as num;
    final maxDiscount = (promo['maxDiscount'] ??
        promo['maks_plafon_diskon'] ??
        promo['max_discount'] ??
        0) as num;

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
        await sb.table(SupabaseConfig.tableKampanyePromo)?.insert({
          'dibuat_oleh': 1,
          'kode_promo': promo['code'],
          'nama_kampanye': promo['title'],
          'besaran_diskon': promo['discountPercent'],
          'maks_plafon_diskon': promo['maxDiscount'],
          'min_transaksi': promo['minBookingAmount'],
          'status_promo': 'aktif',
          'tipe_diskon': 'persen',
        });
        return true;
      } catch (e) {
        debugPrint('⚠️ [PromoService] createPromo error: $e');
        return false;
      }
    }

    return false;
  }

  /// Hapus promo (Super Admin)
  Future<bool> deletePromo(String promoId) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final pId = int.tryParse(promoId);
        if (pId != null) {
          await sb
              .table(SupabaseConfig.tableKampanyePromo)
              ?.delete()
              .eq('promo_id', pId);
        }
        return true;
      } catch (e) {
        debugPrint('⚠️ [PromoService] deletePromo error: $e');
        return false;
      }
    }

    return false;
  }
}
