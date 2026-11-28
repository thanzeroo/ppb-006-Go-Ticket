import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';
import '../constants/app_constants.dart';

/// Service untuk upload dan rendering gambar di seluruh ekosistem Go Ticket.
/// Mengunggah gambar (hotel, kamar, bukti kerusakan, foto profil) langsung ke Supabase Storage (bucket avatars)
/// sehingga gambar tersimpan di cloud dan dapat ditampilkan tanpa error di berbagai platform.
class HotelImageUploadService {
  HotelImageUploadService._();
  static final HotelImageUploadService instance = HotelImageUploadService._();

  /// Bucket penyimpanan umum di Supabase yang sudah aktif
  static const String defaultBucket = AppConstants.defaultAvatarBucket;

  /// Unggah berkas gambar tunggal ke Supabase Storage
  /// Mengembalikan public URL jika berhasil, atau null jika gagal/offline
  Future<String?> uploadFile(
    File file, {
    String prefix = 'img',
    String bucket = defaultBucket,
  }) async {
    if (!file.existsSync()) {
      debugPrint('⚠️ [HotelImageUploadService] File tidak ditemukan: ${file.path}');
      return null;
    }

    try {
      final bytes = await file.readAsBytes();
      final ext = file.path.split('.').last.toLowerCase();
      final contentType = _getContentType(ext);

      final cleanPrefix = prefix.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final rand = math.Random().nextInt(9000) + 1000;
      final filename = '${cleanPrefix}_${DateTime.now().millisecondsSinceEpoch}_$rand.$ext';

      final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
          ? SupabaseConfig.supabaseServiceRoleKey
          : SupabaseConfig.activeApiKey;

      if (SupabaseConfig.supabaseUrl.isEmpty || serviceKey.isEmpty) {
        debugPrint('⚠️ [HotelImageUploadService] Supabase URL / API Key belum dikonfigurasi.');
        return null;
      }

      final uploadUri = Uri.parse(
        '${SupabaseConfig.supabaseUrl}/storage/v1/object/$bucket/$filename',
      );

      final response = await http.post(
        uploadUri,
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
          'Content-Type': contentType,
          'x-upsert': 'true',
        },
        body: bytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final publicUrl =
            '${SupabaseConfig.supabaseUrl}/storage/v1/object/public/$bucket/$filename';
        debugPrint('✅ [HotelImageUploadService] Berhasil upload: $publicUrl');
        return publicUrl;
      } else {
        debugPrint(
          '⚠️ [HotelImageUploadService] Gagal upload (${response.statusCode}): ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('⚠️ [HotelImageUploadService] Exception saat upload: $e');
      return null;
    }
  }

  /// Unggah banyak gambar sekaligus (misalnya galeri foto kamar)
  Future<List<String>> uploadMultipleFiles(
    List<File> files, {
    String prefix = 'room',
    String bucket = defaultBucket,
  }) async {
    final List<String> results = [];
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final url = await uploadFile(file, prefix: '${prefix}_idx$i', bucket: bucket);
      if (url != null && url.isNotEmpty) {
        results.add(url);
      }
    }
    return results;
  }

  /// Menentukan Content-Type dari ekstensi berkas
  String _getContentType(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// Widget helper untuk merender gambar dengan aman:
  /// Mendukung URL internet (http/https) dan berkas lokal (File)
  /// Menyediakan loading indicator dan graceful error builder agar tidak red-screen/crash di komputer lain
  Widget buildSafeImage(
    String? pathOrUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    BorderRadius? borderRadius,
  }) {
    Widget content;

    if (pathOrUrl == null || pathOrUrl.trim().isEmpty) {
      content = placeholder ?? _defaultPlaceholder(width, height);
    } else if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      content = Image.network(
        pathOrUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00758F)),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return placeholder ?? _defaultPlaceholder(width, height);
        },
      );
    } else {
      // Cek apakah berkas lokal ada di perangkat ini
      final file = File(pathOrUrl);
      if (file.existsSync()) {
        content = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return placeholder ?? _defaultPlaceholder(width, height);
          },
        );
      } else {
        // Berkas lokal dari komputer lain tidak ada di komputer ini: tampilkan placeholder elegan
        content = placeholder ?? _defaultPlaceholder(width, height);
      }
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: content);
    }
    return content;
  }

  Widget _defaultPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 28),
      ),
    );
  }
}

