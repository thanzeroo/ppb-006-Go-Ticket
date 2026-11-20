import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../config/supabase_config.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

/// Inisialisasi terpusat untuk ketiga aplikasi Go Ticket:
/// 1. Pihak User (Customer)
/// 2. Pihak Hotel (Mitra Penginapan)
/// 3. Pihak Go Ticket (Super Admin)
class AppInitializer {
  AppInitializer._();

  static bool _initialized = false;

  /// Memuat file .env, menginisialisasi client Supabase, dan memulihkan sesi autentikasi.
  static Future<void> init() async {
    if (_initialized) return;

    WidgetsFlutterBinding.ensureInitialized();

    // 1. Muat file .env
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('⚠️ [AppInitializer] File .env tidak ditemukan atau gagal dimuat: $e');
    }

    // 2. Log status koneksi
    debugPrint('🚀 [Startup] Menghubungkan ke Supabase Project: ${SupabaseConfig.supabaseUrl}');

    // 3. Inisialisasi Supabase client
    await SupabaseService.instance.initialize();

    // 4. Muat sesi tersimpan dari SharedPreferences
    await AuthService.instance.loadSavedSession();

    _initialized = true;
  }
}
