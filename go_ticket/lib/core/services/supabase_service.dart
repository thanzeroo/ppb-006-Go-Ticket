import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Singleton service pengelola koneksi dan client Supabase.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool _isInitialized = false;

  /// Status apakah Supabase client sudah berhasil terhubung
  bool get isReady => _isInitialized && SupabaseConfig.isConfigured;

  /// Mengambil SupabaseClient aktif jika sudah terhubung
  SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Inisialisasi Supabase saat aplikasi pertama kali dijalankan
  Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint(
        'ℹ️ [SupabaseService] Belum dikonfigurasi. Menggunakan Fallback Mock Engine.',
      );
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.activeApiKey,
      );
      _isInitialized = true;
      debugPrint('✅ [SupabaseService] Supabase client berhasil diinisialisasi.');
    } catch (e) {
      _isInitialized = false;
      debugPrint('⚠️ [SupabaseService] Gagal inisialisasi Supabase: $e');
    }
  }

  /// Mengambil tabel tertentu secara aman
  SupabaseQueryBuilder? table(String tableName) {
    return client?.from(tableName);
  }

  /// Mendapatkan user autentikasi aktif dari Supabase Auth
  User? get currentAuthUser => client?.auth.currentUser;

  /// Stream perubahan status autentikasi
  Stream<AuthState>? get authStateChanges => client?.auth.onAuthStateChange;
}

