import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

/// Service untuk mengelola promo & voucher diskon Go Ticket.
/// Seluruh data bersumber langsung dari Supabase [kampanye_promo].
/// Tidak ada mock data atau fallback dummy data.
class PromoService {
  PromoService._();
  static final PromoService instance = PromoService._();

  /// Mengambil semua promo aktif
  Future<List<Map<String, dynamic>>> getPromos({bool activeOnly = false}) async {
    final sb = SupabaseService.instance;

    if (sb.isReady && sb.client != null) {
      try {
        dynamic query = sb.table(SupabaseConfig.tableKampanyePromo)?.select();
        if (query == null) return [];

        if (activeOnly) {
          query = query.ilike('status_promo', '%aktif%');
        }

        final res = await query.order('promo_id', ascending: false);
        if (res != null) {
          return (res as List).map((p) {
            final m = Map<String, dynamic>.from(p);
            final besaran = (m['besaran_diskon'] is num)
                ? (m['besaran_diskon'] as num).toDouble()
                : double.tryParse(m['besaran_diskon']?.toString() ?? '0') ?? 0.0;
            final plafon = (m['maks_plafon_diskon'] is num)
                ? (m['maks_plafon_diskon'] as num).toDouble()
                : double.tryParse(m['maks_plafon_diskon']?.toString() ?? '0') ?? 0.0;
            final tipe = m['tipe_diskon']?.toString() ?? 'Persen';

            String desc = m['deskripsi_promo']?.toString() ?? '';
            if (desc.isEmpty) {
              if (tipe.toLowerCase() == 'nominal') {
                desc = 'Potongan langsung Rp ${besaran.toInt()}';
              } else {
                desc = 'Diskon ${besaran.toInt()}% hingga Rp ${plafon.toInt()}';
              }
            }

            final isActive = (m['status_promo'] ?? '')
                .toString()
                .toLowerCase()
                .contains('aktif');

            return {
              'id': m['promo_id']?.toString() ?? '',
              'code': m['kode_promo'] ?? '',
              'title': m['nama_kampanye'] ?? 'Promo Diskon',
              'description': desc,
              'discountPercent': besaran,
              'discountType': tipe,
              'maxDiscount': plafon,
              'minBookingAmount': (m['min_transaksi'] is num)
                  ? (m['min_transaksi'] as num).toDouble()
                  : double.tryParse(m['min_transaksi']?.toString() ?? '0') ?? 0.0,
              'totalQuota': m['total_kuota'] ?? 0,
              'usedQuota': m['kuota_terpakai'] ?? 0,
              'startDate': m['tgl_mulai']?.toString() ?? '',
              'expiredDate': m['tgl_berakhir']?.toString() ?? '2026-12-31',
              'status': m['status_promo'] ?? 'Aktif',
              'isActive': isActive,
              'seasonCategory': m['kategori_musim'] ?? '',
              'visibility': m['visibilitas'] ?? 'Publik',
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
    final promos = await getPromos(activeOnly: true);
    final promo = promos.firstWhere(
      (p) {
        final c = (p['code'] ?? p['kode_promo'] ?? '').toString();
        return c.toUpperCase() == code.trim().toUpperCase() &&
            (p['isActive'] == true ||
                p['status_promo']?.toString().toLowerCase() == 'aktif');
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
    final discountType = (promo['discountType'] ?? 'Persen').toString().toLowerCase();

    double calculatedDiscount = 0.0;
    if (discountType == 'nominal') {
      calculatedDiscount = discountPercent.toDouble();
    } else {
      calculatedDiscount = (bookingAmount * discountPercent) / 100;
      if (maxDiscount > 0 && calculatedDiscount > maxDiscount) {
        calculatedDiscount = maxDiscount.toDouble();
      }
    }

    return {
      'promo': promo,
      'discountAmount': calculatedDiscount,
    };
  }

  /// Tambah promo baru ke Supabase database (Super Admin / Mitra)
  Future<Map<String, dynamic>> createPromo({
    required String code,
    required String name,
    required double discountValue,
    String discountType = 'Persen',
    double? maxDiscount,
    double? minTransaction,
    int? totalQuota,
    String? seasonCategory,
    DateTime? startDate,
    DateTime? endDate,
    bool isPublic = true,
    String status = 'Aktif',
  }) async {
    final sb = SupabaseService.instance;
    if (!sb.isReady || sb.client == null) {
      throw Exception('Koneksi Supabase belum siap');
    }

    try {
      final payload = <String, dynamic>{
        'kode_promo': code.trim().toUpperCase(),
        'nama_kampanye': name.trim(),
        'besaran_diskon': discountValue,
        'tipe_diskon': discountType,
        'maks_plafon_diskon': maxDiscount ?? 0.0,
        'min_transaksi': minTransaction ?? 0.0,
        'total_kuota': totalQuota ?? 100,
        'kuota_terpakai': 0,
        'status_promo': status,
        'visibilitas': isPublic ? 'Publik' : 'Privat',
      };

      if (seasonCategory != null && seasonCategory.trim().isNotEmpty) {
        payload['kategori_musim'] = seasonCategory.trim();
      }
      if (startDate != null) {
        payload['tgl_mulai'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        payload['tgl_berakhir'] = endDate.toIso8601String();
      }

      final currentUserId =
          int.tryParse(AuthService.instance.currentUser?.id ?? '');
      if (currentUserId != null) {
        payload['dibuat_oleh'] = currentUserId;
      }

      final res = await sb
          .table(SupabaseConfig.tableKampanyePromo)
          ?.insert(payload)
          .select()
          .single();

      if (res == null) {
        throw Exception('Gagal menyimpan kampanye promo ke Supabase');
      }

      return Map<String, dynamic>.from(res);
    } catch (e) {
      debugPrint('⚠️ [PromoService] createPromo error: $e');
      rethrow;
    }
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
