import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth_service.dart';
import 'supabase_service.dart';

/// Inisialisasi cepat dan aman dengan timeout agar tidak pernah Not Responding (ANR).
class AppInitializer {
  AppInitializer._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    WidgetsFlutterBinding.ensureInitialized();

    // 1. Muat .env dengan timeout 1.5 detik
    try {
      await dotenv.load(fileName: ".env").timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () {
          debugPrint('⚠️ [AppInitializer] dotenv.load timeout, menggunakan fallback.');
        },
      );
    } catch (e) {
      debugPrint('⚠️ [AppInitializer] Gagal memuat .env: $e');
    }

    // 2. Inisialisasi Supabase client dengan timeout 3 detik
    try {
      await SupabaseService.instance.initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('⚠️ [AppInitializer] SupabaseService.initialize timeout.');
        },
      );
    } catch (e) {
      debugPrint('⚠️ [AppInitializer] Exception saat inisialisasi Supabase: $e');
    }

    // 3. Muat sesi tersimpan dari SharedPreferences dengan timeout 2 detik
    try {
      await AuthService.instance.loadSavedSession().timeout(
        const Duration(seconds: 2),
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
