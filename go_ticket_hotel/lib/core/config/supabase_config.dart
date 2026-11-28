// =============================================================================
// FILE: lib/core/config/supabase_config.dart
// RESPONSIBILITY: Konfigurasi Supabase Client, Storage Helper, & Nama Tabel.
// Membaca kredensial secara aman dari:
// 1. Compile-time `--dart-define` / `--dart-define-from-file=.env`
// 2. Runtime file `.env` via `flutter_dotenv` (gitignored)
// PENTING: Tidak ada kredensial/API key yang di-hardcode di source code.
// =============================================================================

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Pusat konfigurasi koneksi Supabase dan pemetaan nama tabel PostgreSQL Go Ticket.
class SupabaseConfig {
  SupabaseConfig._();

  // Compile-time environment overrides (opsional lewat --dart-define).
  static const String _defineUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _defineAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _defineServiceRoleKey =
      String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY');

  /// Mengambil nilai variabel lingkungan secara aman dari `flutter_dotenv`.
  /// Mengembalikan string kosong jika `.env` belum dimuat (misalnya di environment test).
  static String _safeEnv(String key) {
    try {
      return dotenv.env[key]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// URL Project Supabase (prioritas: `--dart-define` -> `.env`).
  static String get supabaseUrl {
    if (_defineUrl.isNotEmpty) return _defineUrl.trim();
    return _safeEnv('SUPABASE_URL');
  }

  /// Anon / Publishable Public Key dari `.env` atau `--dart-define`.
  static String get supabaseAnonKey {
    if (_defineAnonKey.isNotEmpty) return _defineAnonKey.trim();
    return _safeEnv('SUPABASE_ANON_KEY');
  }

  /// Service Role Key dari `.env` atau `--dart-define` (hanya untuk environment tepercaya).
  static String get supabaseServiceRoleKey {
    if (_defineServiceRoleKey.isNotEmpty) return _defineServiceRoleKey.trim();
    return _safeEnv('SUPABASE_SERVICE_ROLE_KEY');
  }

  /// Key aktif yang dipakai oleh Supabase client:
  /// menggunakan [supabaseServiceRoleKey] jika tersedia di `.env`,
  /// atau fallback ke [supabaseAnonKey].
  static String get activeApiKey => supabaseServiceRoleKey.isNotEmpty
      ? supabaseServiceRoleKey
      : supabaseAnonKey;

  /// Mengembalikan `true` apabila URL dan API Key Supabase sudah terkonfigurasi.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && activeApiKey.isNotEmpty;

  /// Membangun URL publik objek pada Supabase Storage.
  /// Mengembalikan `null` jika [supabaseUrl] belum terkonfigurasi atau [objectPath] kosong.
  static String? storagePublicUrl(String bucket, String objectPath) {
    final base = supabaseUrl;
    final cleanPath = objectPath.trim();
    if (base.isEmpty || cleanPath.isEmpty) return null;
    final normalizedBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return '$normalizedBase/storage/v1/object/public/$bucket/$cleanPath';
  }

  // ---------------------------------------------------------------------------
  // NAMA-NAMA TABEL SUPABASE (Sesuai Skema Database Aktual)
  // ---------------------------------------------------------------------------

  /// Tabel data akun pelanggan (Customer).
  static const String tableUsers = 'users';

  /// Tabel akun Super Admin platform Go Ticket.
  static const String tableSuperAdmin = 'super_admin';

  /// Tabel akun staf pengelola hotel (Administrator, Front Office, Maintenance).
  static const String tableStafHotel = 'staf_hotel';

  /// Tabel master data mitra penginapan / hotel.
  static const String tableMitraPenginapan = 'mitra_penginapan';

  /// Tabel tipe kamar milik masing-masing penginapan.
  static const String tableTipeKamar = 'tipe_kamar';

  /// Tabel unit fisik kamar hotel beserta status kebersihan & ketersediaan.
  static const String tableKamar = 'kamar';

  /// Tabel jadwal ketersediaan kuota kamar per tanggal.
  static const String tableKetersediaanKamar = 'ketersediaan_kamar';

  /// Tabel penyesuaian harga khusus / musiman per tipe kamar.
  static const String tableHargaKhususKamar = 'harga_khusus_kamar';

  /// Tabel fasilitas dan galeri properti penginapan.
  static const String tableFasilitasProperti = 'fasilitas_properti';

  /// Tabel transaksi pemesanan kamar (booking).
  static const String tableBooking = 'booking';

  /// Tabel catatan transaksi pembayaran booking.
  static const String tablePembayaran = 'pembayaran';

  /// Tabel log verifikasi booking oleh Front Office.
  static const String tableVerifikasiBooking = 'verifikasi_booking';

  /// Tabel pencatatan proses check-in tamu.
  static const String tableCheckIn = 'check_in';

  /// Tabel pencatatan proses check-out tamu.
  static const String tableCheckOut = 'check_out';

  /// Tabel tiket elektronik (QR Code / kode e-tiket) setelah booking terkonfirmasi.
  static const String tableEticket = 'eticket';

  /// Tabel kampanye promo dan kode voucher platform.
  static const String tableKampanyePromo = 'kampanye_promo';

  /// Tabel relasi promo yang berlaku pada kamar tertentu.
  static const String tablePromoKamar = 'promo_kamar';

  /// Tabel laporan sanitasi & kebersihan kamar oleh Maintenance.
  static const String tableLaporanKebersihan = 'laporan_kebersihan';

  /// Tabel tiket laporan kerusakan fasilitas kamar / properti.
  static const String tableLaporanKerusakan = 'laporan_kerusakan';

  /// Tabel monitoring dana dan pengajuan pencairan dana mitra hotel.
  static const String tableMonitoringDana = 'monitoring_dana';

  /// Tabel ulasan dan rating bintang tamu setelah check-out.
  static const String tableUlasan = 'ulasan';

  /// Tabel daftar hotel favorit yang disimpan oleh pelanggan.
  static const String tableSavedHotels = 'saved_hotels';

  /// Tabel daftar profil tamu yang sering dipakai pelanggan saat memesan.
  static const String tableSavedGuests = 'saved_guests';

  /// Tabel notifikasi in-app untuk seluruh peran pengguna.
  static const String tableNotifikasi = 'notifikasi';

  /// Tabel audit log aktivitas sistem dan keamanan platform.
  static const String tableAuditLogSistem = 'audit_log_sistem';
}
