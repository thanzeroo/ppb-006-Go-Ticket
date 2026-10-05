// =============================================================================
// FILE: lib/core/utils/storage_helper.dart
// RESPONSIBILITY: Wrapper untuk penyimpanan lokal data sensitif dan preferensi
// pengguna. Menggunakan SharedPreferences untuk data non-sensitif dan
// flutter_secure_storage untuk JWT Token (enkripsi). Bertanggung jawab:
// - Simpan/baca/hapus Access Token & Refresh Token JWT
// - Simpan/baca data user yang login (JSON)
// - Simpan preferensi pengguna (tema, bahasa, kota terakhir)
// - Clear semua data saat logout
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Helper untuk manajemen penyimpanan lokal (local storage).
///
/// Gunakan kelas ini untuk semua operasi read/write ke SharedPreferences.
/// Token JWT disimpan menggunakan SharedPreferences (tambahkan
/// flutter_secure_storage untuk keamanan lebih di production).
///
/// Semua method bersifat static dan async:
/// ```dart
/// await StorageHelper.saveAccessToken('eyJhbGci...');
/// final token = await StorageHelper.getAccessToken();
/// ```
class StorageHelper {
  StorageHelper._();

  /// Mendapatkan instance SharedPreferences
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // ---------------------------------------------------------------------------
  // ACCESS TOKEN
  // ---------------------------------------------------------------------------

  /// Menyimpan JWT Access Token ke local storage
  static Future<void> saveAccessToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.keyAccessToken, token);
    debugPrint('[StorageHelper] Access token saved.');
  }

  /// Membaca JWT Access Token dari local storage.
  /// Mengembalikan null jika belum ada token.
  static Future<String?> getAccessToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConstants.keyAccessToken);
  }

  /// Menghapus JWT Access Token (misalnya saat token expired)
  static Future<void> clearAccessToken() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConstants.keyAccessToken);
  }

  // ---------------------------------------------------------------------------
  // REFRESH TOKEN
  // ---------------------------------------------------------------------------

  /// Menyimpan JWT Refresh Token ke local storage
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.keyRefreshToken, token);
  }

  /// Membaca JWT Refresh Token dari local storage.
  static Future<String?> getRefreshToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConstants.keyRefreshToken);
  }

  /// Menghapus Refresh Token
  static Future<void> clearRefreshToken() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConstants.keyRefreshToken);
  }

  // ---------------------------------------------------------------------------
  // USER SESSION DATA
  // ---------------------------------------------------------------------------

  /// Menyimpan data user yang sedang login sebagai JSON string.
  /// [userJson] — string JSON dari UserModel.toJson()
  static Future<void> saveCurrentUser(String userJson) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.keyCurrentUser, userJson);
  }

  /// Membaca data user yang sedang login sebagai JSON string.
  /// Mengembalikan null jika belum ada data.
  static Future<String?> getCurrentUser() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConstants.keyCurrentUser);
  }

  /// Menyimpan role user yang sedang login
  /// [role] — String role (misalnya: 'customer', 'staff_fo', 'super_admin')
  static Future<void> saveUserRole(String role) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.keyUserRole, role);
  }

  /// Membaca role user yang sedang login
  static Future<String?> getUserRole() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConstants.keyUserRole);
  }

  /// Menyimpan Hotel ID yang dikelola oleh staff (Hotel Partner app)
  static Future<void> saveManagedHotelId(String hotelId) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.keyManagedHotelId, hotelId);
  }

  /// Membaca Hotel ID yang dikelola staff
  static Future<String?> getManagedHotelId() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConstants.keyManagedHotelId);
  }

  // ---------------------------------------------------------------------------
  // USER PREFERENCES
  // ---------------------------------------------------------------------------

  /// Menyimpan preferensi tema ('light' / 'dark' / 'system')
  static Future<void> saveThemeMode(String themeMode) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.keyThemeMode, themeMode);
  }

  /// Membaca preferensi tema. Default: 'system'
  static Future<String> getThemeMode() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConstants.keyThemeMode) ?? 'system';
  }

  /// Menyimpan preferensi bahasa ('id' / 'en')
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.keyLanguage, languageCode);
  }

  /// Membaca preferensi bahasa. Default: 'id' (Indonesia)
  static Future<String> getLanguage() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConstants.keyLanguage) ?? 'id';
  }

  /// Menyimpan kota terakhir yang dipilih di Customer app
  static Future<void> saveLastCity(String city) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.keyLastCity, city);
  }

  /// Membaca kota terakhir yang dipilih
  static Future<String?> getLastCity() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConstants.keyLastCity);
  }

  // ---------------------------------------------------------------------------
  // ONBOARDING
  // ---------------------------------------------------------------------------

  /// Menandai bahwa onboarding sudah ditampilkan
  static Future<void> setOnboardingDone() async {
    final prefs = await _getPrefs();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
  }

  /// Mengecek apakah onboarding sudah ditampilkan sebelumnya
  static Future<bool> isOnboardingDone() async {
    final prefs = await _getPrefs();
    return prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
  }

  // ---------------------------------------------------------------------------
  // SESSION STATUS
  // ---------------------------------------------------------------------------

  /// Mengecek apakah user sudah login (ada access token yang tersimpan)
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // LOGOUT / CLEAR ALL
  // ---------------------------------------------------------------------------

  /// Menghapus semua data sesi user dari local storage.
  /// Dipanggil saat user logout atau token tidak valid.
  static Future<void> clearSession() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConstants.keyAccessToken);
    await prefs.remove(AppConstants.keyRefreshToken);
    await prefs.remove(AppConstants.keyCurrentUser);
    await prefs.remove(AppConstants.keyUserRole);
    await prefs.remove(AppConstants.keyManagedHotelId);
    debugPrint('[StorageHelper] Session cleared (logout).');
  }

  /// Menghapus SEMUA data dari SharedPreferences (reset factory).
  /// Gunakan dengan hati-hati!
  static Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.clear();
    debugPrint('[StorageHelper] All storage cleared.');
  }
}
