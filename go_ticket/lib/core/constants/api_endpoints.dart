// =============================================================================
// FILE: lib/core/constants/api_endpoints.dart
// RESPONSIBILITY: Mendefinisikan semua URL dan endpoint API Go Ticket Backend.
// Struktur dibagi menjadi:
// - Base URL (environment: dev, staging, production)
// - Auth Endpoints (login, register, OTP, refresh token)
// - Booking Endpoints (CRUD booking, status update)
// - Hotel Endpoints (hotel, kamar, review, fasilitas)
// - Admin Endpoints (platform management, payout, user management)
// =============================================================================

/// Kelas yang menyimpan semua definisi endpoint API Go Ticket.
/// Gunakan [ApiEndpoints.baseUrl] sebagai prefix untuk semua request.
class ApiEndpoints {
  ApiEndpoints._();

  // ---------------------------------------------------------------------------
  // BASE URL — Sesuaikan dengan environment yang aktif
  // ---------------------------------------------------------------------------

  /// Base URL API Go Ticket (Development)
  static const String baseUrlDev = 'https://api-dev.goticket.id/v1';

  /// Base URL API Go Ticket (Staging)
  static const String baseUrlStaging = 'https://api-staging.goticket.id/v1';

  /// Base URL API Go Ticket (Production)
  static const String baseUrlProd = 'https://api.goticket.id/v1';

  /// Base URL yang aktif saat ini — ubah sesuai environment build
  static const String baseUrl = baseUrlDev;

  // ---------------------------------------------------------------------------
  // AUTH ENDPOINTS — Autentikasi untuk semua tipe user
  // ---------------------------------------------------------------------------

  /// [POST] Request OTP ke nomor HP (Customer)
  static const String requestOtp = '/auth/otp/request';

  /// [POST] Verifikasi OTP dan login Customer
  static const String verifyOtp = '/auth/otp/verify';

  /// [POST] Login dengan Google OAuth2 (Customer)
  static const String googleSignIn = '/auth/google/signin';

  /// [POST] Login dengan username/password (Staff FO & Maintenance)
  static const String staffLogin = '/auth/staff/login';

  /// [POST] Login dengan Hotel ID + email bisnis + password (Admin Hotel)
  static const String adminHotelLogin = '/auth/hotel-admin/login';

  /// [POST] Login Super Admin platform Go Ticket
  static const String superAdminLogin = '/auth/super-admin/login';

  /// [POST] Refresh JWT Access Token menggunakan Refresh Token
  static const String refreshToken = '/auth/token/refresh';

  /// [POST] Logout dan invalidasi token di server
  static const String logout = '/auth/logout';

  /// [GET] Mendapatkan profil user yang sedang login
  static const String getProfile = '/auth/profile';

  /// [PUT] Update profil user
  static const String updateProfile = '/auth/profile/update';

  /// [POST] Register akun Customer baru (setelah OTP terverifikasi)
  static const String registerCustomer = '/auth/customer/register';

  // ---------------------------------------------------------------------------
  // HOTEL ENDPOINTS — Data hotel dan pencarian
  // ---------------------------------------------------------------------------

  /// [GET] Mendapatkan daftar hotel (dengan filter dan paginasi)
  static const String getHotels = '/hotels';

  /// [GET] Detail hotel berdasarkan ID → /hotels/{hotelId}
  static const String getHotelById = '/hotels/{hotelId}';

  /// [GET] Mendapatkan hotel rekomendasi / featured
  static const String getFeaturedHotels = '/hotels/featured';

  /// [GET] Mencari hotel berdasarkan keyword, kota, tanggal
  static const String searchHotels = '/hotels/search';

  /// [POST] Mendaftarkan hotel mitra baru (Super Admin approval)
  static const String registerHotel = '/hotels/register';

  /// [PUT] Update data hotel → /hotels/{hotelId}
  static const String updateHotel = '/hotels/{hotelId}';

  /// [GET] Review / ulasan hotel → /hotels/{hotelId}/reviews
  static const String getHotelReviews = '/hotels/{hotelId}/reviews';

  // ---------------------------------------------------------------------------
  // ROOM ENDPOINTS — Manajemen kamar hotel
  // ---------------------------------------------------------------------------

  /// [GET] Daftar semua kamar dalam hotel → /hotels/{hotelId}/rooms
  static const String getRooms = '/hotels/{hotelId}/rooms';

  /// [GET] Detail kamar berdasarkan ID → /rooms/{roomId}
  static const String getRoomById = '/rooms/{roomId}';

  /// [POST] Tambah kamar baru → /hotels/{hotelId}/rooms
  static const String addRoom = '/hotels/{hotelId}/rooms';

  /// [PUT] Update data/harga kamar → /rooms/{roomId}
  static const String updateRoom = '/rooms/{roomId}';

  /// [DELETE] Hapus kamar → /rooms/{roomId}
  static const String deleteRoom = '/rooms/{roomId}';

  /// [GET] Cek ketersediaan kamar berdasarkan tanggal
  static const String checkRoomAvailability = '/rooms/{roomId}/availability';

  /// [PUT] Update status kamar (Available/Dirty/Cleaning/Occupied/Maintenance)
  static const String updateRoomStatus = '/rooms/{roomId}/status';

  // ---------------------------------------------------------------------------
  // BOOKING ENDPOINTS — Pemesanan hotel
  // ---------------------------------------------------------------------------

  /// [GET] Riwayat booking milik Customer yang sedang login
  static const String getMyBookings = '/bookings/my';

  /// [GET] Detail booking berdasarkan ID → /bookings/{bookingId}
  static const String getBookingById = '/bookings/{bookingId}';

  /// [POST] Buat booking baru
  static const String createBooking = '/bookings';

  /// [PUT] Update status booking → /bookings/{bookingId}/status
  static const String updateBookingStatus = '/bookings/{bookingId}/status';

  /// [POST] Batalkan booking → /bookings/{bookingId}/cancel
  static const String cancelBooking = '/bookings/{bookingId}/cancel';

  /// [GET] Mendapatkan daftar booking untuk hotel tertentu (Hotel Partner)
  static const String getHotelBookings = '/hotels/{hotelId}/bookings';

  /// [POST] Verifikasi pembayaran booking oleh Staff FO
  static const String verifyPayment = '/bookings/{bookingId}/verify-payment';

  /// [POST] Proses check-in dengan QR code
  static const String processCheckin = '/bookings/{bookingId}/checkin';

  /// [POST] Proses check-out
  static const String processCheckout = '/bookings/{bookingId}/checkout';

  // ---------------------------------------------------------------------------
  // PAYMENT ENDPOINTS — Proses pembayaran
  // ---------------------------------------------------------------------------

  /// [POST] Inisiasi pembayaran (mendapatkan payment URL/token gateway)
  static const String initiatePayment = '/payments/initiate';

  /// [GET] Cek status pembayaran → /payments/{paymentId}/status
  static const String getPaymentStatus = '/payments/{paymentId}/status';

  /// [POST] Webhook notifikasi dari payment gateway (server-to-server)
  static const String paymentWebhook = '/payments/webhook';

  // ---------------------------------------------------------------------------
  // REVIEW ENDPOINTS — Ulasan dan rating hotel
  // ---------------------------------------------------------------------------

  /// [POST] Submit ulasan setelah checkout → /bookings/{bookingId}/review
  static const String submitReview = '/bookings/{bookingId}/review';

  /// [GET] Semua review milik Customer
  static const String getMyReviews = '/reviews/my';

  // ---------------------------------------------------------------------------
  // MAINTENANCE ENDPOINTS — Tiket maintenance kamar
  // ---------------------------------------------------------------------------

  /// [GET] Daftar maintenance ticket hotel → /hotels/{hotelId}/maintenance
  static const String getMaintenanceTickets = '/hotels/{hotelId}/maintenance';

  /// [POST] Buat maintenance ticket baru
  static const String createMaintenanceTicket = '/hotels/{hotelId}/maintenance';

  /// [PUT] Update status maintenance ticket → /maintenance/{ticketId}
  static const String updateMaintenanceTicket = '/maintenance/{ticketId}';

  // ---------------------------------------------------------------------------
  // PAYOUT ENDPOINTS — Keuangan dan pencairan dana mitra
  // ---------------------------------------------------------------------------

  /// [GET] Laporan keuangan hotel → /hotels/{hotelId}/financial/report
  static const String getFinancialReport = '/hotels/{hotelId}/financial/report';

  /// [GET] Daftar payout hotel → /hotels/{hotelId}/payouts
  static const String getHotelPayouts = '/hotels/{hotelId}/payouts';

  /// [POST] Ajukan request payout → /hotels/{hotelId}/payouts/request
  static const String requestPayout = '/hotels/{hotelId}/payouts/request';

  /// [GET] Semua payout di platform (Super Admin)
  static const String getAllPayouts = '/admin/payouts';

  /// [PUT] Proses / approve payout → /admin/payouts/{payoutId}
  static const String processPayout = '/admin/payouts/{payoutId}';

  // ---------------------------------------------------------------------------
  // SUPER ADMIN ENDPOINTS — Manajemen platform
  // ---------------------------------------------------------------------------

  /// [GET] Statistik global platform (GMV, user, booking)
  static const String getPlatformStats = '/admin/dashboard/stats';

  /// [GET] Daftar hotel yang menunggu persetujuan
  static const String getPendingHotels = '/admin/hotels/pending';

  /// [PUT] Approve hotel mitra → /admin/hotels/{hotelId}/approve
  static const String approveHotel = '/admin/hotels/{hotelId}/approve';

  /// [PUT] Reject hotel mitra → /admin/hotels/{hotelId}/reject
  static const String rejectHotel = '/admin/hotels/{hotelId}/reject';

  /// [GET] Semua user di platform
  static const String getAllUsers = '/admin/users';

  /// [PUT] Update status user (aktif/nonaktif) → /admin/users/{userId}
  static const String updateUserStatus = '/admin/users/{userId}/status';

  /// [GET] Semua promo/voucher platform
  static const String getAllPromos = '/admin/promos';

  /// [POST] Buat promo baru
  static const String createPromo = '/admin/promos';

  /// [PUT] Update promo → /admin/promos/{promoId}
  static const String updatePromo = '/admin/promos/{promoId}';

  /// [DELETE] Hapus promo → /admin/promos/{promoId}
  static const String deletePromo = '/admin/promos/{promoId}';

  // ---------------------------------------------------------------------------
  // EMPLOYEE ENDPOINTS — Manajemen karyawan hotel
  // ---------------------------------------------------------------------------

  /// [GET] Daftar karyawan hotel → /hotels/{hotelId}/employees
  static const String getHotelEmployees = '/hotels/{hotelId}/employees';

  /// [POST] Tambah karyawan (Staff FO / Maintenance) → /hotels/{hotelId}/employees
  static const String addEmployee = '/hotels/{hotelId}/employees';

  /// [PUT] Update data karyawan → /hotels/{hotelId}/employees/{employeeId}
  static const String updateEmployee =
      '/hotels/{hotelId}/employees/{employeeId}';

  /// [DELETE] Nonaktifkan karyawan → /hotels/{hotelId}/employees/{employeeId}
  static const String removeEmployee =
      '/hotels/{hotelId}/employees/{employeeId}';

  // ---------------------------------------------------------------------------
  // HELPER METHODS — Untuk mengganti parameter dinamis di URL
  // ---------------------------------------------------------------------------

  /// Mengganti placeholder {hotelId} dengan nilai aktual
  static String hotelById(String hotelId) =>
      getHotelById.replaceAll('{hotelId}', hotelId);

  /// Mengganti placeholder {roomId} dengan nilai aktual
  static String roomById(String roomId) =>
      getRoomById.replaceAll('{roomId}', roomId);

  /// Mengganti placeholder {bookingId} dengan nilai aktual
  static String bookingById(String bookingId) =>
      getBookingById.replaceAll('{bookingId}', bookingId);

  /// Mengganti placeholder {ticketId} dengan nilai aktual
  static String maintenanceById(String ticketId) =>
      updateMaintenanceTicket.replaceAll('{ticketId}', ticketId);
}
