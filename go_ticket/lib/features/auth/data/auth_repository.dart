// =============================================================================
// FILE: lib/features/auth/data/auth_repository.dart
// RESPONSIBILITY: Repository untuk semua operasi autentikasi di Go Ticket.
// Bertanggung jawab untuk:
// - Login Customer via OTP HP atau Google Sign In
// - Login Staff FO & Maintenance via username/password
// - Login Admin Hotel via Hotel ID + email + password
// - Login Super Admin platform
// - Refresh JWT Token
// - Logout dan clear session
// - Mendapatkan profil user yang sedang login
// =============================================================================

import 'dart:convert';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../models/user_model.dart';

/// Repository autentikasi Go Ticket.
///
/// Semua method mengembalikan data atau melempar [ApiException].
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ---------------------------------------------------------------------------
  // CUSTOMER AUTH — Login via OTP
  // ---------------------------------------------------------------------------

  /// [Step 1] Request OTP ke nomor HP Customer.
  ///
  /// [phoneNumber] — Nomor HP dalam format: '08123456789'
  /// Mengembalikan `true` jika OTP berhasil dikirim.
  Future<bool> requestOtp(String phoneNumber) async {
    await _apiClient.post(
      ApiEndpoints.requestOtp,
      body: {'phone_number': phoneNumber},
      requireAuth: false,
    );
    return true;
  }

  /// [Step 2] Verifikasi OTP dan login Customer.
  ///
  /// [phoneNumber] — Nomor HP yang didaftarkan
  /// [otpCode] — Kode OTP 6 digit dari SMS
  /// Menyimpan token dan data user ke local storage setelah sukses.
  /// Mengembalikan [UserModel] Customer yang berhasil login.
  Future<UserModel> verifyOtpAndLogin({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyOtp,
      body: {
        'phone_number': phoneNumber,
        'otp_code': otpCode,
      },
      requireAuth: false,
    );

    return await _handleAuthSuccess(response);
  }

  /// Login Customer menggunakan Google Sign In.
  ///
  /// [googleIdToken] — Token dari Google Sign In SDK
  Future<UserModel> googleSignIn(String googleIdToken) async {
    final response = await _apiClient.post(
      ApiEndpoints.googleSignIn,
      body: {'id_token': googleIdToken},
      requireAuth: false,
    );

    return await _handleAuthSuccess(response);
  }

  // ---------------------------------------------------------------------------
  // HOTEL STAFF AUTH — Login Staff FO & Maintenance
  // ---------------------------------------------------------------------------

  /// Login Staff FO atau Maintenance dengan username dan password.
  ///
  /// Staff tidak menggunakan OTP — mereka login dengan kredensial yang
  /// diberikan oleh Admin Hotel.
  Future<UserModel> staffLogin({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.staffLogin,
      body: {
        'username': username,
        'password': password,
      },
      requireAuth: false,
    );

    return await _handleAuthSuccess(response);
  }

  // ---------------------------------------------------------------------------
  // HOTEL ADMIN AUTH — Login Manager / Owner Hotel
  // ---------------------------------------------------------------------------

  /// Login Admin Hotel dengan Hotel ID + Email Bisnis + Password.
  ///
  /// [hotelId] — ID unik hotel yang terdaftar di platform
  /// [businessEmail] — Email bisnis yang terdaftar
  /// [password] — Password akun
  Future<UserModel> adminHotelLogin({
    required String hotelId,
    required String businessEmail,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.adminHotelLogin,
      body: {
        'hotel_id': hotelId,
        'business_email': businessEmail,
        'password': password,
      },
      requireAuth: false,
    );

    return await _handleAuthSuccess(response);
  }

  // ---------------------------------------------------------------------------
  // SUPER ADMIN AUTH
  // ---------------------------------------------------------------------------

  /// Login Super Admin platform Go Ticket.
  Future<UserModel> superAdminLogin({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.superAdminLogin,
      body: {
        'email': email,
        'password': password,
      },
      requireAuth: false,
    );

    return await _handleAuthSuccess(response);
  }

  // ---------------------------------------------------------------------------
  // TOKEN MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Refresh Access Token menggunakan Refresh Token yang tersimpan.
  ///
  /// Dipanggil secara otomatis saat Access Token expired (401).
  /// Mengembalikan `true` jika berhasil, melempar [ApiException] jika gagal.
  Future<bool> refreshToken() async {
    final refreshToken = await StorageHelper.getRefreshToken();
    if (refreshToken == null) {
      throw ApiException(
        statusCode: 401,
        message: 'Session expired. Please login again.',
      );
    }

    final response = await _apiClient.post(
      ApiEndpoints.refreshToken,
      body: {'refresh_token': refreshToken},
      requireAuth: false,
    );

    final newAccessToken = response['access_token'];
    final newRefreshToken = response['refresh_token'];

    if (newAccessToken != null) {
      await StorageHelper.saveAccessToken(newAccessToken);
    }
    if (newRefreshToken != null) {
      await StorageHelper.saveRefreshToken(newRefreshToken);
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // PROFILE
  // ---------------------------------------------------------------------------

  /// Mendapatkan profil user yang sedang login dari API.
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.getProfile);
    return UserModel.fromJson(response['data'] ?? response);
  }

  /// Update profil user yang sedang login.
  ///
  /// [fullName] — Nama baru (opsional)
  /// [avatarUrl] — URL foto profil baru (opsional)
  Future<UserModel> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    final response = await _apiClient.put(
      ApiEndpoints.updateProfile,
      body: body,
    );

    final updatedUser = UserModel.fromJson(response['data'] ?? response);

    // Update cached user data di local storage
    await StorageHelper.saveCurrentUser(jsonEncode(updatedUser.toJson()));

    return updatedUser;
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  /// Logout user dan invalidasi token di server.
  /// Selalu menghapus data local storage meskipun request ke server gagal.
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Abaikan error saat logout dari server,
      // yang penting data lokal dihapus
    } finally {
      await StorageHelper.clearSession();
    }
  }

  // ---------------------------------------------------------------------------
  // PRIVATE HELPERS
  // ---------------------------------------------------------------------------

  /// Memproses response sukses autentikasi: menyimpan token dan user data.
  Future<UserModel> _handleAuthSuccess(dynamic response) async {
    final data = response['data'] ?? response;

    // Simpan token
    final accessToken = data['access_token'] ?? response['access_token'];
    final refreshToken = data['refresh_token'] ?? response['refresh_token'];

    if (accessToken != null) {
      await StorageHelper.saveAccessToken(accessToken);
    }
    if (refreshToken != null) {
      await StorageHelper.saveRefreshToken(refreshToken);
    }

    // Parse dan simpan data user
    final userJson = data['user'] ?? data;
    final user = UserModel.fromJson(userJson);
    await StorageHelper.saveCurrentUser(jsonEncode(user.toJson()));
    await StorageHelper.saveUserRole(user.role.apiValue);

    // Simpan managed hotel ID untuk staff hotel
    if (user.managedHotelId != null) {
      await StorageHelper.saveManagedHotelId(user.managedHotelId!);
    }

    return user;
  }
}
