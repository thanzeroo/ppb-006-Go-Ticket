// =============================================================================
// FILE: lib/core/config/supabase_config.dart
// RESPONSIBILITY: Konfigurasi Supabase Client & Nama Tabel Database.
// Membaca URL dan Key dari file .env via flutter_dotenv.
// =============================================================================

import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  /// URL Project Supabase dari file .env
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Anon Public Key dari file .env
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Gunakan anon key dari .env sebagai active API key
  static String get activeApiKey => supabaseAnonKey;

  /// Mengecek apakah URL & Key sudah diisi
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && activeApiKey.isNotEmpty;

  // ---------------------------------------------------------------------------
  // NAMA-NAMA TABEL SUPABASE (Sesuai Skema Database Aktual)
  // ---------------------------------------------------------------------------
  static const String tableUsers = 'users';
  static const String tableSuperAdmin = 'super_admin';
  static const String tableStafHotel = 'staf_hotel';
  static const String tableMitraPenginapan = 'mitra_penginapan';
  static const String tableTipeKamar = 'tipe_kamar';
  static const String tableKamar = 'kamar';
  static const String tableKetersediaanKamar = 'ketersediaan_kamar';
  static const String tableHargaKhususKamar = 'harga_khusus_kamar';
  static const String tableFasilitasProperti = 'fasilitas_properti';
  static const String tableBooking = 'booking';
  static const String tablePembayaran = 'pembayaran';
  static const String tableVerifikasiBooking = 'verifikasi_booking';
  static const String tableCheckIn = 'check_in';
  static const String tableCheckOut = 'check_out';
  static const String tableEticket = 'eticket';
  static const String tableKampanyePromo = 'kampanye_promo';
  static const String tablePromoKamar = 'promo_kamar';
  static const String tableLaporanKebersihan = 'laporan_kebersihan';
  static const String tableLaporanKerusakan = 'laporan_kerusakan';
  static const String tableMonitoringDana = 'monitoring_dana';
  static const String tableUlasan = 'ulasan';
  static const String tableSavedHotels = 'saved_hotels';
  static const String tableSavedGuests = 'saved_guests';
  static const String tableNotifikasi = 'notifikasi';
  static const String tableAuditLogSistem = 'audit_log_sistem';
}
