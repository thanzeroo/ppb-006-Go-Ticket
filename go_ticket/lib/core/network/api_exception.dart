// =============================================================================
// FILE: lib/core/network/api_exception.dart
// RESPONSIBILITY: Mendefinisikan custom Exception class yang digunakan oleh
// ApiClient ketika terjadi error pada HTTP request. Menyediakan:
// - Status code HTTP
// - Pesan error yang user-friendly (Bahasa Indonesia)
// - Data error detail (misalnya validasi field dari server)
// - Flag untuk tipe error spesifik (network error, auth error, dll.)
// =============================================================================

/// Custom Exception untuk menangani error pada HTTP request Go Ticket API.
///
/// Dilempar oleh [ApiClient] dan harus di-catch di layer Repository.
///
/// Contoh penggunaan:
/// ```dart
/// try {
///   final result = await apiClient.get(ApiEndpoints.getHotels);
/// } on ApiException catch (e) {
///   if (e.isUnauthorized) {
///     // Redirect ke halaman login
///   }
///   showErrorSnackbar(e.message);
/// }
/// ```
class ApiException implements Exception {
  /// HTTP Status Code (0 = network error, -1 = unknown error)
  final int statusCode;

  /// Pesan error yang bisa ditampilkan ke user
  final String message;

  /// Detail error dari server (misalnya: validasi field form)
  /// Format: {"field_name": ["error message 1", "error message 2"]}
  final Map<String, dynamic>? errors;

  /// Flag apakah ini adalah error koneksi internet / network
  final bool isNetworkError;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
    this.isNetworkError = false,
  });

  // ---------------------------------------------------------------------------
  // CONVENIENCE GETTERS — Untuk mempermudah pengecekan tipe error
  // ---------------------------------------------------------------------------

  /// [true] jika user tidak terautentikasi (token expired / invalid)
  bool get isUnauthorized => statusCode == 401;

  /// [true] jika user tidak memiliki izin untuk aksi ini
  bool get isForbidden => statusCode == 403;

  /// [true] jika data tidak ditemukan di server
  bool get isNotFound => statusCode == 404;

  /// [true] jika ada error validasi dari server
  bool get isValidationError => statusCode == 422;

  /// [true] jika server sedang bermasalah
  bool get isServerError => statusCode >= 500;

  /// [true] jika error disebabkan oleh request berlebihan (rate limiting)
  bool get isRateLimited => statusCode == 429;

  /// [true] jika ini adalah error yang disebabkan masalah jaringan
  bool get isConnectionError => isNetworkError || statusCode == 0;

  // ---------------------------------------------------------------------------
  // DISPLAY HELPERS
  // ---------------------------------------------------------------------------

  /// Mendapatkan pesan error untuk field tertentu dari response validasi server.
  /// Berguna untuk menampilkan error inline di bawah TextField.
  ///
  /// Contoh: getFieldError('email') → 'Email sudah terdaftar'
  String? getFieldError(String fieldName) {
    if (errors == null || !errors!.containsKey(fieldName)) return null;
    final fieldErrors = errors![fieldName];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    return fieldErrors?.toString();
  }

  /// Mendapatkan semua pesan error field sebagai satu string gabungan
  String get allFieldErrors {
    if (errors == null || errors!.isEmpty) return message;
    final buffer = StringBuffer();
    errors!.forEach((field, value) {
      if (value is List) {
        buffer.writeln('• ${value.join(', ')}');
      } else {
        buffer.writeln('• $value');
      }
    });
    return buffer.toString().trim();
  }

  // ---------------------------------------------------------------------------
  // OVERRIDES
  // ---------------------------------------------------------------------------

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, message: "$message", '
        'errors: $errors, isNetworkError: $isNetworkError)';
  }
}

// =============================================================================
// EXTENSION — Tambahan helper untuk ApiException
// =============================================================================

extension ApiExceptionExtension on ApiException {
  /// Mendapatkan ikon yang sesuai dengan tipe error (untuk UI display)
  String get errorIcon {
    if (isConnectionError) return '📡';
    if (isUnauthorized) return '🔐';
    if (isForbidden) return '🚫';
    if (isNotFound) return '🔍';
    if (isValidationError) return '⚠️';
    if (isServerError) return '🛠️';
    if (isRateLimited) return '⏱️';
    return '❌';
  }

  /// Mendapatkan action label yang direkomendasikan untuk user
  String get suggestedAction {
    if (isConnectionError) return 'Periksa koneksi internet Anda';
    if (isUnauthorized) return 'Silakan login kembali';
    if (isForbidden) return 'Hubungi administrator';
    if (isNotFound) return 'Kembali ke halaman sebelumnya';
    if (isServerError) return 'Coba beberapa saat lagi';
    if (isRateLimited) return 'Tunggu sebentar, lalu coba lagi';
    return 'Coba lagi';
  }
}
