// =============================================================================
// FILE: lib/core/constants/app_constants.dart
// RESPONSIBILITY: Pusat konstanta dan parameter konfigurasi aplikasi Go Ticket.
// Semua nilai operasional (versi, timeout, paginasi, aturan bisnis, AI Tiko)
// ditempatkan di sini agar mudah diubah dari satu file tanpa menyentuh logic UI.
// =============================================================================

/// Kelas utama yang mengelompokkan semua konstanta global aplikasi Go Ticket.
class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // APP INFO — Identitas dan metadata aplikasi
  // ---------------------------------------------------------------------------

  /// Nama resmi platform.
  static const String appName = 'Go Ticket';

  /// Versi aplikasi saat ini (selaras dengan `pubspec.yaml`).
  static const String appVersion = '2.0.0';

  /// Slogan resmi aplikasi.
  static const String appTagline = 'Hotel & Travel, Simplified';

  /// Email kontak resmi dukungan & operasional Go Ticket.
  static const String supportEmail = 'admin@goticket.id';

  // ---------------------------------------------------------------------------
  // STORAGE KEYS — Key untuk SharedPreferences / Secure Storage
  // ---------------------------------------------------------------------------

  /// Key untuk menyimpan JWT Access Token.
  static const String keyAccessToken = 'go_ticket_access_token';

  /// Key untuk menyimpan JWT Refresh Token.
  static const String keyRefreshToken = 'go_ticket_refresh_token';

  /// Key untuk menyimpan data user yang sedang login (JSON string).
  static const String keyCurrentUser = 'go_ticket_current_user';

  /// Key untuk menyimpan role user aktif.
  static const String keyUserRole = 'go_ticket_user_role';

  /// Key untuk menyimpan ID hotel yang dikelola staff (aplikasi Hotel Partner).
  static const String keyManagedHotelId = 'go_ticket_managed_hotel_id';

  /// Key untuk menyimpan preferensi tema (light/dark).
  static const String keyThemeMode = 'go_ticket_theme_mode';

  /// Key untuk menyimpan bahasa pilihan.
  static const String keyLanguage = 'go_ticket_language';

  /// Key penanda apakah onboarding sudah pernah ditampilkan.
  static const String keyOnboardingDone = 'go_ticket_onboarding_done';

  /// Key untuk menyimpan kota terakhir yang dipilih di Customer App.
  static const String keyLastCity = 'go_ticket_last_city';

  // ---------------------------------------------------------------------------
  // STARTUP & NETWORK CONFIGURATION — Batas timeout & retry
  // ---------------------------------------------------------------------------

  /// Batas waktu memuat file `.env` saat startup (milidetik).
  static const int dotenvTimeoutMs = 1500;

  /// Batas waktu inisialisasi Supabase client saat startup (detik).
  static const int supabaseInitTimeoutSeconds = 3;

  /// Batas waktu memuat sesi tersimpan dari penyimpanan lokal (detik).
  static const int sessionLoadTimeoutSeconds = 2;

  /// Durasi timeout HTTP request umum (detik).
  static const int httpTimeoutSeconds = 30;

  /// Durasi timeout koneksi awal HTTP (detik).
  static const int connectTimeoutSeconds = 15;

  /// Jumlah maksimal percobaan ulang saat request jaringan gagal.
  static const int maxRetryAttempts = 3;

  // ---------------------------------------------------------------------------
  // PAGINATION DEFAULTS — Ukuran halaman daftar data
  // ---------------------------------------------------------------------------

  /// Jumlah item per halaman standar.
  static const int defaultPageSize = 10;

  /// Jumlah item per halaman untuk daftar hotel di dashboard.
  static const int hotelListPageSize = 12;

  /// Jumlah item per halaman untuk riwayat booking.
  static const int bookingHistoryPageSize = 15;

  // ---------------------------------------------------------------------------
  // BUSINESS RULES — Aturan bisnis yang mudah disesuaikan
  // ---------------------------------------------------------------------------

  /// Minimal durasi menginap (dalam malam).
  static const int minNightsStay = 1;

  /// Maksimal durasi menginap per transaksi (dalam malam).
  static const int maxNightsStay = 30;

  /// Maksimal jumlah tamu per kamar secara default.
  static const int defaultMaxGuests = 4;

  /// Batas maksimal akun Administrator yang diperbolehkan per hotel.
  static const int maxAdminPerHotel = 3;

  /// Batas jam minimal sebelum check-in untuk pembatalan gratis.
  static const int freeCancellationHours = 24;

  /// Persentase komisi platform Go Ticket dari mitra hotel (%).
  static const double platformCommissionPercent = 10.0;

  /// Rasio pajak dan biaya layanan default pada kalkulasi booking (10%).
  static const double taxAndServiceRate = 0.10;

  /// Harga fallback per malam jika hotel belum memiliki tarif kamar aktif (Rp).
  static const int defaultHotelFallbackPrice = 350000;

  /// Minimal nominal pencairan dana (payout) oleh mitra hotel (Rp).
  static const int minPayoutAmountRupiah = 100000;

  /// Waktu check-in default hotel.
  static const String defaultCheckinTime = '14:00';

  /// Waktu check-out default hotel.
  static const String defaultCheckoutTime = '12:00';

  // ---------------------------------------------------------------------------
  // TIKO AI CHATBOT CONFIGURATION — Pengaturan model & token Gemini
  // ---------------------------------------------------------------------------

  /// Jumlah maksimum pesan riwayat percakapan yang dikirim sebagai konteks AI.
  static const int tikoMaxHistoryMessages = 10;

  /// Batas maksimum token output respons Tiko agar jawaban tetap ringkas.
  static const int tikoMaxOutputTokens = 350;

  /// Parameter kreativitas (temperature) Gemini API.
  static const double tikoTemperature = 0.5;

  /// Parameter nucleus sampling (topP) Gemini API.
  static const double tikoTopP = 0.85;

  /// Parameter topK sampling Gemini API.
  static const int tikoTopK = 20;

  /// Urutan prioritas model Gemini yang dicoba oleh Tiko (ringan -> fallback).
  static const List<String> tikoModels = [
    'gemini-flash-lite-latest',
    'gemini-3.5-flash-lite',
    'gemini-flash-latest',
  ];

  // ---------------------------------------------------------------------------
  // OTP CONFIGURATION — Pengaturan verifikasi OTP
  // ---------------------------------------------------------------------------

  /// Panjang digit kode OTP.
  static const int otpLength = 6;

  /// Masa berlaku kode OTP (detik).
  static const int otpExpirySeconds = 300; // 5 menit

  /// Cooldown sebelum pengguna dapat meminta ulang kode OTP (detik).
  static const int otpResendCooldownSeconds = 60;

  // ---------------------------------------------------------------------------
  // IMAGE / MEDIA & STORAGE — Pengaturan unggah media
  // ---------------------------------------------------------------------------

  /// Nama bucket default pada Supabase Storage untuk foto properti, kamar, dan avatar.
  static const String defaultAvatarBucket = 'avatars';

  /// Ukuran maksimal berkas unggahan foto hotel (MB).
  static const int maxImageUploadMB = 5;

  /// Jumlah maksimal foto per tipe kamar.
  static const int maxRoomPhotos = 10;

  /// URL gambar fallback hotel saat properti belum memiliki foto.
  static const String placeholderHotelImage =
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800';

  /// URL avatar fallback jika pengguna belum mengunggah foto profil.
  static const String placeholderAvatarImage =
      'https://via.placeholder.com/100x100?text=User';

  // ---------------------------------------------------------------------------
  // DATE FORMAT STRINGS — Pola pemformatan tanggal standar
  // ---------------------------------------------------------------------------

  /// Format tanggal tampilan antarmuka (contoh: 01 Jan 2025).
  static const String dateDisplayFormat = 'dd MMM yyyy';

  /// Format tanggal untuk parameter API/database (contoh: 2025-01-01).
  static const String dateApiFormat = 'yyyy-MM-dd';

  /// Format tanggal & waktu ISO-8601 UTC untuk API.
  static const String dateTimeApiFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  /// Format waktu saja (contoh: 14:00).
  static const String timeFormat = 'HH:mm';

  // ---------------------------------------------------------------------------
  // ANIMATION DURATIONS — Durasi transisi UI standar
  // ---------------------------------------------------------------------------

  /// Durasi animasi cepat (hover, ripple, micro-interaction).
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Durasi animasi standar (transisi halaman/dialog).
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Durasi animasi lambat (splash screen, onboarding).
  static const Duration animationSlow = Duration(milliseconds: 600);

  // ---------------------------------------------------------------------------
  // RATING — Skala penilaian ulasan
  // ---------------------------------------------------------------------------

  /// Skala bintang maksimum pada fitur ulasan.
  static const int maxRating = 5;

  /// Batas rating minimal untuk masuk kategori hotel unggulan.
  static const double minFeaturedRating = 4.0;
}
