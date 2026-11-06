import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/supabase_config.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

/// Service untuk data dinamis spesifik tiap Customer (Saved Hotels, Tamu Tersimpan, Poin).
/// Menggunakan Supabase untuk data yang perlu persistent di cloud,
/// SharedPreferences sebagai cache lokal.
class CustomerDataService {
  CustomerDataService._();
  static final CustomerDataService instance = CustomerDataService._();

  static const String demoUserId = 'usr-customer-01';

  /// Cek apakah pengguna saat ini adalah pengguna baru / fresh account
  bool get isFreshUser {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;
    return user.id != demoUserId && !user.id.contains('demo');
  }

  // ---------------------------------------------------------------------------
  // POIN & MEMBERSHIP TIER
  // ---------------------------------------------------------------------------
  Future<int> getRewardPoints() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return 0;

    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final userIdNum = int.tryParse(user.id);
        if (userIdNum != null) {
          final res = await sb
              .table(SupabaseConfig.tableUsers)
              ?.select('saldo_poin')
              .eq('id_user', userIdNum)
              .maybeSingle();
          if (res != null) {
            return (res['saldo_poin'] as num?)?.toInt() ?? 0;
          }
        }
        return 0;
      } catch (e) {
        debugPrint('⚠️ [CustomerDataService] getRewardPoints error: $e');
        return 0;
      }
    }

    // Fallback offline
    if (isFreshUser) return 0;
    return 1250; // Demo user
  }

  Future<String> getMembershipTier() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return 'MEMBER BRONZE GO TICKET';

    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final userIdNum = int.tryParse(user.id);
        if (userIdNum != null) {
          final res = await sb
              .table(SupabaseConfig.tableUsers)
              ?.select('tier_membership')
              .eq('id_user', userIdNum)
              .maybeSingle();
          if (res != null) {
            final tier = res['tier_membership']?.toString() ?? 'Bronze';
            return 'MEMBER ${tier.toUpperCase()} GO TICKET';
          }
        }
        return 'MEMBER BRONZE GO TICKET';
      } catch (e) {
        debugPrint('⚠️ [CustomerDataService] getMembershipTier error: $e');
        return 'MEMBER BRONZE GO TICKET';
      }
    }

    // Fallback offline
    if (isFreshUser) return 'MEMBER BRONZE GO TICKET';
    return 'MEMBER PLATINUM GO TICKET';
  }

  // ---------------------------------------------------------------------------
  // SAVED HOTELS PER USER — Supabase + SharedPreferences cache
  // ---------------------------------------------------------------------------
  static final ValueNotifier<int> savedHotelsCountNotifier = ValueNotifier<int>(0);

  Future<List<Map<String, dynamic>>> getSavedHotels() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];

    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final userIdNum = int.tryParse(user.id);
        if (userIdNum != null) {
          final res = await sb
              .table(SupabaseConfig.tableSavedHotels)
              ?.select('*, mitra_penginapan(nama_properti, kota_wilayah, alamat_lengkap)')
              .eq('id_user', userIdNum);
          if (res != null) {
            final list = (res as List).map((item) {
              final m = Map<String, dynamic>.from(item);
              final hotel = m['mitra_penginapan'] as Map<String, dynamic>?;
              return {
                'id': m['id_penginapan']?.toString() ?? '',
                'name': hotel?['nama_properti'] ?? 'Hotel',
                'location': '${hotel?['kota_wilayah'] ?? ''} • ${hotel?['alamat_lengkap'] ?? ''}',
                'isFavorite': true,
              };
            }).toList();
            savedHotelsCountNotifier.value = list.length;
            return list;
          }
        }
        savedHotelsCountNotifier.value = 0;
        return [];
      } catch (e) {
        debugPrint('⚠️ [CustomerDataService] getSavedHotels Supabase error: $e');
        // Fallthrough to local cache
      }
    }

    // Fallback: SharedPreferences (offline cache)
    final prefs = await SharedPreferences.getInstance();
    final key = 'saved_hotels_${user.id}';
    final raw = prefs.getString(key);

    if (raw != null) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        final list = decoded.cast<Map<String, dynamic>>();
        savedHotelsCountNotifier.value = list.length;
        return list;
      } catch (_) {}
    }

    savedHotelsCountNotifier.value = 0;
    return [];
  }

  Future<bool> toggleSavedHotel(Map<String, dynamic> hotel) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;

    final hotelId = hotel['id']?.toString() ?? hotel['name']?.toString() ?? '';

    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final userIdNum = int.tryParse(user.id);
        final hotelIdNum = int.tryParse(hotelId);
        if (userIdNum != null && hotelIdNum != null) {
          // Cek apakah sudah tersimpan
          final existing = await sb
              .table(SupabaseConfig.tableSavedHotels)
              ?.select()
              .eq('id_user', userIdNum)
              .eq('id_penginapan', hotelIdNum)
              .maybeSingle();

          if (existing != null) {
            // Hapus dari saved
            await sb
                .table(SupabaseConfig.tableSavedHotels)
                ?.delete()
                .eq('id_user', userIdNum)
                .eq('id_penginapan', hotelIdNum);
            savedHotelsCountNotifier.value = (savedHotelsCountNotifier.value - 1).clamp(0, 9999);
            return false; // Unsaved
          } else {
            // Tambah ke saved
            await sb.table(SupabaseConfig.tableSavedHotels)?.insert({
              'id_user': userIdNum,
              'id_penginapan': hotelIdNum,
            });
            savedHotelsCountNotifier.value += 1;
            return true; // Saved
          }
        }
      } catch (e) {
        debugPrint('⚠️ [CustomerDataService] toggleSavedHotel Supabase error: $e');
        // Fallthrough to local
      }
    }

    // Fallback: SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final key = 'saved_hotels_${user.id}';
    final currentList = await getSavedHotels();

    final existingIndex = currentList.indexWhere(
      (h) => (h['id']?.toString() ?? h['name']?.toString()) == hotelId,
    );

    bool isSavedNow;
    if (existingIndex >= 0) {
      currentList.removeAt(existingIndex);
      isSavedNow = false;
    } else {
      currentList.add(Map<String, dynamic>.from(hotel));
      isSavedNow = true;
    }

    await prefs.setString(key, jsonEncode(currentList));
    savedHotelsCountNotifier.value = currentList.length;
    return isSavedNow;
  }

  Future<bool> isHotelSaved(String hotelIdOrName) async {
    final list = await getSavedHotels();
    return list.any((h) =>
        h['id']?.toString() == hotelIdOrName ||
        h['name']?.toString().toLowerCase() == hotelIdOrName.toLowerCase());
  }

  // ---------------------------------------------------------------------------
  // DATA TAMU TERSIMPAN (SAVED GUESTS) PER USER — Supabase + local
  // ---------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getSavedGuests() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];

    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final userIdNum = int.tryParse(user.id);
        if (userIdNum != null) {
          final res = await sb
              .table(SupabaseConfig.tableSavedGuests)
              ?.select()
              .eq('id_user', userIdNum);
          if (res != null) {
            return (res as List).map((item) {
              final m = Map<String, dynamic>.from(item);
              return {
                'name': m['nama_tamu'] ?? '',
                'title': m['gelar'] ?? 'Tn.',
                'phone': m['no_telepon'] ?? '',
                'email': m['email'] ?? '',
                'isPrimary': m['is_primary'] ?? false,
              };
            }).toList();
          }
        }
        return [];
      } catch (e) {
        debugPrint('⚠️ [CustomerDataService] getSavedGuests Supabase error: $e');
        // Fallthrough to local
      }
    }

    // Fallback: SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final key = 'saved_guests_${user.id}';
    final raw = prefs.getString(key);

    if (raw != null) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        return decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }

    return [];
  }
}
