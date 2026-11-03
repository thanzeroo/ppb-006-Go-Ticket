// =============================================================================
// FILE: lib/core/config/supabase_config.dart
// RESPONSIBILITY: Konfigurasi Supabase Client & Nama Tabel Database.
// Diselaraskan 100% dengan database Supabase proyek: yujbnwaapualgliixsmm
// =============================================================================

class SupabaseConfig {
  SupabaseConfig._();

  /// URL Project Supabase
  static const String supabaseUrl = 'https://yujbnwaapualgliixsmm.supabase.co';

  /// Anon Public Key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl1amJud2FhcHVhbGdsaWl4c21tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA3MTQyOTgsImV4cCI6MjEwNjI5MDI5OH0.1X577clY9bGzv0pvlcFEHu0nZa-f0BeGveOyBKk_UE8';

  /// Service Role Key (Bypass RLS untuk kebutuhan testing & sinkronisasi data internal)
  static const String supabaseServiceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl1amJud2FhcHVhbGdsaWl4c21tIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MDcxNDI5OCwiZXhwIjoyMTA2MjkwMjk4fQ.qITSNur3IqKZ-7r_3XcQPH2tidA2RaR56ZQZjBhJ-gw';

  /// Gunakan Service Role Key saat development agar data tabel langsung terbaca
  /// tanpa terhalang RLS Policy yang belum diaktifkan untuk publik.
  static const String activeApiKey = supabaseServiceRoleKey;

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
