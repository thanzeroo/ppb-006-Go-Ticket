// =============================================================================
// FILE: lib/core/config/supabase_config.dart
// RESPONSIBILITY: Konfigurasi Supabase Client & Nama Tabel Database.
// Ketika Anda sudah memiliki Project URL dan Anon Key dari Supabase Dashboard,
// masukkan ke variabel di bawah ini.
// =============================================================================

class SupabaseConfig {
  SupabaseConfig._();

  /// URL Project Supabase Anda
  /// Contoh: 'https://xyzcompany.supabase.co'
  static const String supabaseUrl = 'https://your-project-ref.supabase.co';

  /// Anon Public Key Supabase Anda (bukan service role key)
  /// Didapat dari: Project Settings -> API -> Project API keys -> anon public
  static const String supabaseAnonKey = 'your-anon-key';

  /// Mengecek apakah URL & Anon Key sudah diisi nilai riil (bukan dummy/placeholder)
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('your-project-ref') &&
        !supabaseAnonKey.contains('your-anon-key');
  }

  // ---------------------------------------------------------------------------
  // NAMA-NAMA TABEL SUPABASE (Database Tables Mapping)
  // ---------------------------------------------------------------------------
  static const String tableProfiles = 'profiles';
  static const String tableHotels = 'hotels';
  static const String tableRooms = 'rooms';
  static const String tableBookings = 'bookings';
  static const String tableMaintenanceTickets = 'maintenance_tickets';
  static const String tablePromos = 'promos';
  static const String tablePayouts = 'payouts';
  static const String tableReviews = 'reviews';
  static const String tableStaff = 'staff';
}
