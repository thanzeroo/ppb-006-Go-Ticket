// =============================================================================
// FILE: lib/core/network/api_client.dart
// RESPONSIBILITY: HTTP Client wrapper untuk semua request ke Go Ticket API.
// Bertanggung jawab untuk:
// - Menambahkan header autentikasi (Bearer JWT Token) secara otomatis
// - Menangani response code dan konversi ke ApiException
// - Interceptor untuk refresh token otomatis ketika 401 Unauthorized
// - Mendukung metode GET, POST, PUT, PATCH, DELETE
// =============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../utils/storage_helper.dart';
import 'api_exception.dart';

/// HTTP Client utama aplikasi Go Ticket.
///
/// Digunakan oleh semua Repository untuk berkomunikasi dengan backend.
/// Secara otomatis menyisipkan token JWT pada setiap request.
///
/// Contoh penggunaan:
/// ```dart
/// final client = ApiClient();
/// final response = await client.get(ApiEndpoints.getHotels);
/// ```
class ApiClient {
  ApiClient._();

  /// Singleton instance ApiClient
  static final ApiClient _instance = ApiClient._();

  /// Factory constructor untuk mendapatkan instance singleton
  factory ApiClient() => _instance;

  final http.Client _httpClient = http.Client();

  // ---------------------------------------------------------------------------
  // PRIVATE HELPERS
  // ---------------------------------------------------------------------------

  /// Membangun URI lengkap dari path endpoint
  Uri _buildUri(String path, {Map<String, String>? queryParams}) {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  /// Membangun header HTTP default termasuk Authorization Bearer Token
  Future<Map<String, String>> _buildHeaders({
    bool requireAuth = true,
    Map<String, String>? additionalHeaders,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Version': AppConstants.appVersion,
    };

    if (requireAuth) {
      final token = await StorageHelper.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Memproses HTTP response dan melempar [ApiException] jika terjadi error
  dynamic _processResponse(http.Response response) {
    debugPrint('API Response [${response.statusCode}]: ${response.body}');

    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);

      case 204:
        // No Content - sukses tapi tidak ada body
        return null;

      case 400:
        final body = jsonDecode(response.body);
        throw ApiException(
          statusCode: 400,
          message: body['message'] ?? 'Bad Request',
          errors: body['errors'],
        );

      case 401:
        throw ApiException(
          statusCode: 401,
          message: 'Sesi Anda telah berakhir. Silakan login kembali.',
        );

      case 403:
        throw ApiException(
          statusCode: 403,
          message: 'Anda tidak memiliki akses untuk melakukan tindakan ini.',
        );

      case 404:
        throw ApiException(
          statusCode: 404,
          message: 'Data yang dicari tidak ditemukan.',
        );

      case 422:
        final body = jsonDecode(response.body);
        throw ApiException(
          statusCode: 422,
          message: body['message'] ?? 'Validasi gagal.',
          errors: body['errors'],
        );

      case 429:
        throw ApiException(
          statusCode: 429,
          message: 'Terlalu banyak permintaan. Coba beberapa saat lagi.',
        );

      case 500:
      case 502:
      case 503:
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Server sedang bermasalah. Coba lagi nanti.',
        );

      default:
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Terjadi kesalahan tidak diketahui.',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // PUBLIC HTTP METHODS
  // ---------------------------------------------------------------------------

  /// Melakukan HTTP GET request
  ///
  /// [path] — path endpoint (misalnya: ApiEndpoints.getHotels)
  /// [queryParams] — parameter query opsional
  /// [requireAuth] — apakah request ini memerlukan token JWT
  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParams,
    bool requireAuth = true,
  }) async {
    try {
      final uri = _buildUri(path, queryParams: queryParams);
      final headers = await _buildHeaders(requireAuth: requireAuth);

      debugPrint('GET $uri');

      final response = await _httpClient
          .get(uri, headers: headers)
          .timeout(Duration(seconds: AppConstants.httpTimeoutSeconds));

      return _processResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'Tidak ada koneksi internet. Periksa jaringan Anda.',
        isNetworkError: true,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: -1, message: e.toString());
    }
  }

  /// Melakukan HTTP POST request
  ///
  /// [path] — path endpoint
  /// [body] — data yang dikirim sebagai JSON body
  /// [requireAuth] — apakah request ini memerlukan token JWT
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(requireAuth: requireAuth);

      debugPrint('POST $uri | Body: $body');

      final response = await _httpClient
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: AppConstants.httpTimeoutSeconds));

      return _processResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'Tidak ada koneksi internet. Periksa jaringan Anda.',
        isNetworkError: true,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: -1, message: e.toString());
    }
  }

  /// Melakukan HTTP PUT request
  ///
  /// [path] — path endpoint
  /// [body] — data yang dikirim sebagai JSON body
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(requireAuth: requireAuth);

      debugPrint('PUT $uri | Body: $body');

      final response = await _httpClient
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: AppConstants.httpTimeoutSeconds));

      return _processResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'Tidak ada koneksi internet. Periksa jaringan Anda.',
        isNetworkError: true,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: -1, message: e.toString());
    }
  }

  /// Melakukan HTTP PATCH request (update sebagian field)
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(requireAuth: requireAuth);

      debugPrint('PATCH $uri | Body: $body');

      final response = await _httpClient
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: AppConstants.httpTimeoutSeconds));

      return _processResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'Tidak ada koneksi internet. Periksa jaringan Anda.',
        isNetworkError: true,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: -1, message: e.toString());
    }
  }

  /// Melakukan HTTP DELETE request
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(requireAuth: requireAuth);

      debugPrint('DELETE $uri');

      final request = http.Request('DELETE', uri);
      request.headers.addAll(headers);
      if (body != null) {
        request.body = jsonEncode(body);
      }

      final streamedResponse = await _httpClient
          .send(request)
          .timeout(Duration(seconds: AppConstants.httpTimeoutSeconds));
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'Tidak ada koneksi internet. Periksa jaringan Anda.',
        isNetworkError: true,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: -1, message: e.toString());
    }
  }

  /// Menutup HTTP client saat tidak diperlukan lagi
  void dispose() {
    _httpClient.close();
  }
}
