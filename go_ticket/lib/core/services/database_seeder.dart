import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import 'supabase_service.dart';

/// Helper untuk mengisi (seed) data awal ke Supabase database jika tabel masih kosong.
class DatabaseSeeder {
  DatabaseSeeder._();
  static final DatabaseSeeder instance = DatabaseSeeder._();

  /// Jalankan seeding otomatis saat app start jika tabel masih kosong
  Future<void> seedIfEmpty() async {
    final sb = SupabaseService.instance;
    if (!sb.isReady || sb.client == null) {
      debugPrint('ℹ️ [DatabaseSeeder] Supabase belum siap, skip seeding.');
      return;
    }

    try {
      await _seedHotelsIfEmpty(sb);
      await _seedPromosIfEmpty(sb);
      await _seedUsersIfEmpty(sb);
      debugPrint('✅ [DatabaseSeeder] Selesai memeriksa & melakukan seeding.');
    } catch (e) {
      debugPrint('⚠️ [DatabaseSeeder] Error saat seeding: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 1. SEED HOTELS & ROOMS
  // ---------------------------------------------------------------------------
  Future<void> _seedHotelsIfEmpty(SupabaseService sb) async {
    try {
      final existing = await sb.table(SupabaseConfig.tableMitraPenginapan)?.select('id_penginapan').limit(1);
      if (existing != null && (existing as List).isNotEmpty) {
        return; // Sudah ada data
      }

      debugPrint('🌱 [DatabaseSeeder] Menyemai data hotel ke Supabase...');

      final hotels = [
        {
          'nama_properti': 'The Grand Amora Resort & Spa',
          'alamat_lengkap': 'Jl. Petitenget No. 88, Seminyak',
          'kota_wilayah': 'Bali',
          'deposit_nominal': 850000,
          'status_operasional': 'aktif',
        },
        {
          'nama_properti': 'The Alila Cliff Sanctuary',
          'alamat_lengkap': 'Jl. Belimbing Sari, Uluwatu',
          'kota_wilayah': 'Bali',
          'deposit_nominal': 1450000,
          'status_operasional': 'aktif',
        },
        {
          'nama_properti': 'Kayumanis Private Villa',
          'alamat_lengkap': 'Jl. Kayu Aya, Seminyak',
          'kota_wilayah': 'Bali',
          'deposit_nominal': 1650000,
          'status_operasional': 'aktif',
        },
        {
          'nama_properti': 'Seminyak Beach Breeze Hotel',
          'alamat_lengkap': 'Jl. Double Six No. 12, Seminyak',
          'kota_wilayah': 'Bali',
          'deposit_nominal': 620000,
          'status_operasional': 'aktif',
        },
      ];

      for (final h in hotels) {
        final inserted = await sb.table(SupabaseConfig.tableMitraPenginapan)?.insert(h).select().maybeSingle();
        if (inserted != null) {
          final hotelId = inserted['id_penginapan'];

          // Seed tipe kamar untuk hotel ini
          final roomType = await sb.table(SupabaseConfig.tableTipeKamar)?.insert({
            'id_penginapan': hotelId,
            'nama_tipe': 'Deluxe King Room',
            'kapasitas_tamu': 2,
            'harga_dasar': h['deposit_nominal'],
            'harga_weekend': (h['deposit_nominal'] as int) + 100000,
            'luas_m2': 42.0,
            'tipe_bed': '1 King Bed',
            'total_unit': 10,
          }).select().maybeSingle();

          if (roomType != null) {
            final typeId = roomType['id_tipe_kamar'];
            // Seed 2 unit kamar fisik
            await sb.table(SupabaseConfig.tableKamar)?.insert([
              {
                'id_tipe_kamar': typeId,
                'id_penginapan': hotelId,
                'nomor_kamar': '101',
                'status_kamar': 'tersedia',
              },
              {
                'id_tipe_kamar': typeId,
                'id_penginapan': hotelId,
                'nomor_kamar': '102',
                'status_kamar': 'tersedia',
              },
            ]);
          }
        }
      }
      debugPrint('✅ [DatabaseSeeder] Data hotel & kamar berhasil disemai.');
    } catch (e) {
      debugPrint('⚠️ [DatabaseSeeder] Gagal menyemai hotel: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 2. SEED KAMPANYE PROMO
  // ---------------------------------------------------------------------------
  Future<void> _seedPromosIfEmpty(SupabaseService sb) async {
    try {
      final existing = await sb.table(SupabaseConfig.tableKampanyePromo)?.select('promo_id').limit(1);
      if (existing != null && (existing as List).isNotEmpty) {
        return; // Sudah ada data
      }

      debugPrint('🌱 [DatabaseSeeder] Menyemai data promo ke Supabase...');

      final promos = [
        {
          'dibuat_oleh': 1,
          'kode_promo': 'STAYHEMAT',
          'nama_kampanye': 'Diskon Staycation Spesial',
          'besaran_diskon': 15,
          'maks_plafon_diskon': 150000,
          'min_transaksi': 500000,
          'tgl_berakhir': '2026-12-31',
          'status_promo': 'aktif',
          'tipe_diskon': 'persen',
        },
        {
          'dibuat_oleh': 1,
          'kode_promo': 'LIBURANASIK',
          'nama_kampanye': 'Weekend Escape Cashback',
          'besaran_diskon': 20,
          'maks_plafon_diskon': 250000,
          'min_transaksi': 1000000,
          'tgl_berakhir': '2026-11-30',
          'status_promo': 'aktif',
          'tipe_diskon': 'persen',
        },
        {
          'dibuat_oleh': 1,
          'kode_promo': 'GOHOTEL50',
          'nama_kampanye': 'Pengguna Baru Go Ticket',
          'besaran_diskon': 10,
          'maks_plafon_diskon': 50000,
          'min_transaksi': 0,
          'tgl_berakhir': '2027-01-31',
          'status_promo': 'aktif',
          'tipe_diskon': 'persen',
        },
      ];

      await sb.table(SupabaseConfig.tableKampanyePromo)?.insert(promos);
      debugPrint('✅ [DatabaseSeeder] Data promo berhasil disemai.');
    } catch (e) {
      debugPrint('⚠️ [DatabaseSeeder] Gagal menyemai promo: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 3. SEED INITIAL USERS
  // ---------------------------------------------------------------------------
  Future<void> _seedUsersIfEmpty(SupabaseService sb) async {
    try {
      final existing = await sb.table(SupabaseConfig.tableUsers)?.select('id_user').limit(1);
      if (existing != null && (existing as List).isNotEmpty) {
        return;
      }

      debugPrint('🌱 [DatabaseSeeder] Menyemai user demo ke Supabase...');

      await sb.table(SupabaseConfig.tableUsers)?.insert({
        'nama_lengkap': 'Sulthan Pratama',
        'email': 'customer@goticket.id',
        'password': 'DummyPass123!',
        'no_telepon': '081234567890',
        'status_akun': 'aktif',
        'saldo_poin': 1250,
        'tier_membership': 'Platinum',
      });

      debugPrint('✅ [DatabaseSeeder] User demo berhasil disemai.');
    } catch (e) {
      debugPrint('⚠️ [DatabaseSeeder] Gagal menyemai user: $e');
    }
  }
}
