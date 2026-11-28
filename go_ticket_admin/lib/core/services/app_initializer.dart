// =============================================================================
// FILE: lib/core/services/app_initializer.dart
// RESPONSIBILITY: Orkestrasi inisialisasi startup aplikasi secara non-blocking
// dengan timeout terukur agar aplikasi terhindar dari ANR (Application Not Responding).
// =============================================================================

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/app_constants.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

/// Mengelola tahapan inisialisasi awal aplikasi (`.env`, Supabase, dan sesi lokal).
///
/// Pemanggilan berulang aman karena dilindungi flag [_initialized] (idempoten).
class AppInitializer {
  AppInitializer._();

  static bool _initialized = false;

  /// Menjalankan seluruh proses startup aplikasi secara berurutan dengan timeout:
  /// 1. Memuat variabel lingkungan dari file `.env`
  /// 2. Menginisialisasi [SupabaseService]
  /// 3. Memulihkan sesi pengguna tersimpan via [AuthService]
  static Future<void> init() async {
    if (_initialized) return;

    WidgetsFlutterBinding.ensureInitialized();

    // 1. Muat .env dengan timeout terkonfigurasi di AppConstants
    try {
      await dotenv.load(fileName: '.env').timeout(
        const Duration(milliseconds: AppConstants.dotenvTimeoutMs),
        onTimeout: () {
          debugPrint(
            '⚠️ [AppInitializer] dotenv.load timeout, mencoba konfigurasi --dart-define.',
          );
        },
      );
    } catch (e) {
      debugPrint('⚠️ [AppInitializer] Gagal memuat .env: $e');
    }

    // 2. Inisialisasi Supabase client dengan timeout aman
    try {
      await SupabaseService.instance.initialize().timeout(
        const Duration(seconds: AppConstants.supabaseInitTimeoutSeconds),
        onTimeout: () {
          debugPrint('⚠️ [AppInitializer] SupabaseService.initialize timeout.');
        },
      );
    } catch (e) {
      debugPrint('⚠️ [AppInitializer] Exception saat inisialisasi Supabase: $e');
    }

    // 3. Muat sesi tersimpan dari SharedPreferences dengan timeout aman
    try {
      await AuthService.instance.loadSavedSession().timeout(
        const Duration(seconds: AppConstants.sessionLoadTimeoutSeconds),
        onTimeout: () {
          debugPrint('⚠️ [AppInitializer] AuthService.loadSavedSession timeout.');
          return false;
        },
      );
    } catch (e) {
      debugPrint('⚠️ [AppInitializer] Exception saat load sesi: $e');
    }

    _initialized = true;
    debugPrint('✅ [AppInitializer] Inisialisasi startup selesai tanpa hambatan.');
  }
}
