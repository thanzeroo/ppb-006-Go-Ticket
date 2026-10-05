// =============================================================================
// FILE: lib/core/constants/app_constants.dart
// RESPONSIBILITY: Mendefinisikan semua konstanta global aplikasi Go Ticket,
// mencakup:
// - Key untuk local storage (SharedPreferences / SecureStorage)
// - Nilai default aplikasi (timeout, pagination, dll.)
// - Nama route
// - Konfigurasi bisnis (min booking, maks tamu, dll.)
// =============================================================================

/// Kelas utama yang mengelompokkan semua konstanta aplikasi Go Ticket.
class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // APP INFO
  // ---------------------------------------------------------------------------

  static const String appName = 'Go Ticket';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Hotel & Travel, Simplified';

  // ---------------------------------------------------------------------------
  // STORAGE KEYS — Key yang digunakan di SharedPreferences / FlutterSecureStorage
  // ---------------------------------------------------------------------------

  /// Key untuk menyimpan JWT Access Token
  static const String keyAccessToken = 'go_ticket_access_token';

  /// Key untuk menyimpan JWT Refresh Token
  static const String keyRefreshToken = 'go_ticket_refresh_token';

  /// Key untuk menyimpan data user yang sedang login (JSON string)
  static const String keyCurrentUser = 'go_ticket_current_user';

  /// Key untuk menyimpan role user aktif
  static const String keyUserRole = 'go_ticket_user_role';

  /// Key untuk menyimpan hotel ID yang dikelola staff (Hotel Partner app)
  static const String keyManagedHotelId = 'go_ticket_managed_hotel_id';

  /// Key untuk menyimpan preferensi tema (light/dark)
  static const String keyThemeMode = 'go_ticket_theme_mode';

  /// Key untuk menyimpan bahasa pilihan
  static const String keyLanguage = 'go_ticket_language';

  /// Key apakah onboarding sudah ditampilkan
  static const String keyOnboardingDone = 'go_ticket_onboarding_done';

  /// Key untuk menyimpan last selected city di Customer App
  static const String keyLastCity = 'go_ticket_last_city';

  // ---------------------------------------------------------------------------
  // NETWORK CONFIGURATION
  // ---------------------------------------------------------------------------

  /// Durasi timeout HTTP request (dalam detik)
  static const int httpTimeoutSeconds = 30;

  /// Durasi timeout untuk koneksi
  static const int connectTimeoutSeconds = 15;

  /// Jumlah maksimal retry saat request gagal
  static const int maxRetryAttempts = 3;

  // ---------------------------------------------------------------------------
  // PAGINATION DEFAULTS
  // ---------------------------------------------------------------------------

  /// Jumlah item per halaman (default pagination)
  static const int defaultPageSize = 10;

  /// Jumlah item per halaman untuk list hotel (dashboard)
  static const int hotelListPageSize = 12;

  /// Jumlah item per halaman untuk riwayat booking
  static const int bookingHistoryPageSize = 15;

  // ---------------------------------------------------------------------------
  // BUSINESS RULES — Aturan bisnis platform Go Ticket
  // ---------------------------------------------------------------------------

  /// Minimal durasi menginap (dalam malam)
  static const int minNightsStay = 1;

  /// Maksimal durasi menginap (dalam malam)
  static const int maxNightsStay = 30;

  /// Maksimal jumlah tamu per booking (default)
  static const int defaultMaxGuests = 4;

  /// Minimal jam sebelum check-in untuk bisa cancel tanpa biaya
  static const int freeCancellationHours = 24;

  /// Persentase komisi platform Go Ticket dari mitra hotel
  static const double platformCommissionPercent = 10.0;

  /// Minimal payout yang bisa diajukan oleh mitra hotel (dalam Rupiah)
  static const int minPayoutAmountRupiah = 100000;

  /// Waktu check-in default hotel (jam)
  static const String defaultCheckinTime = '14:00';

  /// Waktu check-out default hotel (jam)
  static const String defaultCheckoutTime = '12:00';

  // ---------------------------------------------------------------------------
  // OTP CONFIGURATION
  // ---------------------------------------------------------------------------

  /// Panjang kode OTP
  static const int otpLength = 6;

  /// Durasi OTP berlaku (dalam detik)
  static const int otpExpirySeconds = 300; // 5 menit

  /// Durasi cooldown sebelum bisa kirim ulang OTP
  static const int otpResendCooldownSeconds = 60;

  // ---------------------------------------------------------------------------
  // IMAGE / MEDIA
  // ---------------------------------------------------------------------------

  /// Ukuran maksimal upload foto hotel (dalam MB)
  static const int maxImageUploadMB = 5;

  /// Jumlah maksimal foto per kamar
  static const int maxRoomPhotos = 10;

  /// URL placeholder gambar hotel
  static const String placeholderHotelImage =
      'https://via.placeholder.com/400x300?text=Hotel+Image';

  /// URL placeholder avatar user
  static const String placeholderAvatarImage =
      'https://via.placeholder.com/100x100?text=User';

  // ---------------------------------------------------------------------------
  // DATE FORMAT STRINGS
  // ---------------------------------------------------------------------------

  /// Format tanggal standar tampilan (dd MMM yyyy -> 01 Jan 2025)
  static const String dateDisplayFormat = 'dd MMM yyyy';

  /// Format tanggal untuk API request (yyyy-MM-dd -> 2025-01-01)
  static const String dateApiFormat = 'yyyy-MM-dd';

  /// Format tanggal + waktu untuk API
  static const String dateTimeApiFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  /// Format waktu saja (HH:mm -> 14:00)
  static const String timeFormat = 'HH:mm';

  // ---------------------------------------------------------------------------
  // ANIMATION DURATIONS
  // ---------------------------------------------------------------------------

  /// Durasi animasi cepat (untuk hover, ripple)
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Durasi animasi normal (untuk transisi halaman)
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Durasi animasi lambat (untuk splash, onboarding)
  static const Duration animationSlow = Duration(milliseconds: 600);

  // ---------------------------------------------------------------------------
  // RATING
  // ---------------------------------------------------------------------------

  /// Skala rating maksimal
  static const int maxRating = 5;

  /// Minimal rating untuk ditampilkan di halaman utama
  static const double minFeaturedRating = 4.0;
}
