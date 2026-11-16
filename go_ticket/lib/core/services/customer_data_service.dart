import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/supabase_config.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

/// Service untuk data dinamis spesifik tiap Customer (Saved Hotels, Tamu Tersimpan, Poin).
/// Terhubung langsung dengan tabel Supabase:
/// - [saved_hotels]
/// - [saved_guests]
/// - [users] (saldo_poin, tier_membership)
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
    if (sb.isReady && sb.client != null) {
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

    if (isFreshUser) return 0;
    return 1250;
  }

  Future<String> getMembershipTier() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return 'MEMBER BRONZE GO TICKET';

    final sb = SupabaseService.instance;
    if (sb.isReady && sb.client != null) {
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

    if (isFreshUser) return 'MEMBER BRONZE GO TICKET';
    return 'MEMBER PLATINUM GO TICKET';
  }

  // ---------------------------------------------------------------------------
  // SAVED HOTELS PER USER — Supabase + SharedPreferences cache
  // ---------------------------------------------------------------------------
  static final ValueNotifier<int> savedHotelsCountNotifier =
      ValueNotifier<int>(0);

  Future<List<Map<String, dynamic>>> getSavedHotels() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];

    final sb = SupabaseService.instance;
    if (sb.isReady && sb.client != null) {
      try {
        final userIdNum = int.tryParse(user.id);
        if (userIdNum != null) {
          final res = await sb
              .table(SupabaseConfig.tableSavedHotels)
              ?.select('*, mitra_penginapan(*)')
              .eq('id_user', userIdNum)
              .order('id_saved_hotel', ascending: false);
          if (res != null) {
            final list = (res as List).map((item) {
              final m = Map<String, dynamic>.from(item);
              final hotel = m['mitra_penginapan'] as Map<String, dynamic>?;
              final priceVal =
                  (hotel?['deposit_nominal'] as num?)?.toInt() ?? 850000;
              final folderName = m['nama_folder']?.toString() ?? 'Favorit';

              return {
                'id': m['id_penginapan']?.toString() ?? '',
                'name': hotel?['nama_properti'] ?? 'Hotel',
                'location':
                    '${hotel?['kota_wilayah'] ?? ''} • ${hotel?['alamat_lengkap'] ?? ''}',
                'city': hotel?['kota_wilayah'] ?? 'Bali',
                'address': hotel?['alamat_lengkap'] ?? '',
                'category': 'Semua',
                'folders': <String>[
                  folderName,
                  'Liburan Akhir Tahun',
                  'Staycation Romantis'
                ],
                'priceValue': priceVal,
                'price':
                    'Rp ${priceVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                'rating': '4.8',
                'reviews': '142',
                'features': <String>['WiFi Cepat', 'Kolam Renang', 'AC'],
                'extras': <String>[],
                'availability': 'Tersedia',
                'imageUrl':
                    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600',
                'type': 'Resor • ⭐ 5',
                'badge': 'Bintang 5',
                'discount': 'Hemat 25%',
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

    final hotelId =
        hotel['id']?.toString() ?? hotel['name']?.toString() ?? '';

    final sb = SupabaseService.instance;
    if (sb.isReady && sb.client != null) {
      try {
        final userIdNum = int.tryParse(user.id);
        final hotelIdNum = int.tryParse(hotelId);
        if (userIdNum != null && hotelIdNum != null) {
          // Cek apakah sudah tersimpan di Supabase
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
            savedHotelsCountNotifier.value =
                (savedHotelsCountNotifier.value - 1).clamp(0, 9999);
            return false; // Unsaved
          } else {
            // Tambah ke saved
            await sb.table(SupabaseConfig.tableSavedHotels)?.insert({
              'id_user': userIdNum,
              'id_penginapan': hotelIdNum,
              'nama_folder': 'Favorit',
            });
            savedHotelsCountNotifier.value += 1;
            return true; // Saved
          }
        }
      } catch (e) {
        debugPrint('⚠️ [CustomerDataService] toggleSavedHotel Supabase error: $e');
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
  // DATA TAMU TERSIMPAN (SAVED GUESTS) PER USER — Supabase Cloud CRUD
  // ---------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getSavedGuests() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];

    final sb = SupabaseService.instance;
    if (sb.isReady && sb.client != null) {
      try {
        final userIdNum = int.tryParse(user.id);
        if (userIdNum != null) {
          final res = await sb
              .table(SupabaseConfig.tableSavedGuests)
              ?.select()
              .eq('id_user', userIdNum)
              .order('id_saved_guest', ascending: true);
          if (res != null) {
            return (res as List).map((item) {
              final m = Map<String, dynamic>.from(item);
              final isChild =
                  (m['kategori_usia']?.toString().toLowerCase() == 'anak');
              final isMain =
                  (m['tipe_relasi']?.toString().toLowerCase() == 'akun utama');
              return {
                'id': m['id_saved_guest'],
                'name': m['nama_tamu'] ?? '',
                'nik': m['no_ktp_nik'] ?? '',
                'phone': m['no_handphone'] ?? '',
                'email': m['email'] ?? '',
                'birth': m['tanggal_lahir'] ?? '',
                'relation': m['tipe_relasi'] ??
                    (isChild ? 'Anak Kandung' : 'Keluarga / Rekan'),
                'ageCategory':
                    m['kategori_usia'] ?? (isChild ? 'Anak' : 'Dewasa'),
                'isChild': isChild,
                'isMain': isMain,
              };
            }).toList();
          }
        }
        return [];
      } catch (e) {
        debugPrint('⚠️ [CustomerDataService] getSavedGuests Supabase error: $e');
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

  Future<Map<String, dynamic>?> addSavedGuest({
    required String name,
    String? nik,
    String? phone,
    String? email,
    String? birthDate,
    String relation = 'Keluarga / Rekan',
    bool isChild = false,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return null;

    final sb = SupabaseService.instance;
    if (sb.isReady && sb.client != null) {
      try {
        final userIdNum = int.tryParse(user.id);
        if (userIdNum != null) {
          final payload = <String, dynamic>{
            'id_user': userIdNum,
            'nama_tamu': name.trim(),
            'no_ktp_nik': nik?.trim().isNotEmpty == true ? nik!.trim() : null,
            'no_handphone':
                phone?.trim().isNotEmpty == true ? phone!.trim() : null,
            'email': email?.trim().isNotEmpty == true ? email!.trim() : null,
            'tanggal_lahir':
                birthDate?.trim().isNotEmpty == true ? birthDate!.trim() : null,
            'kategori_usia': isChild ? 'Anak' : 'Dewasa',
            'tipe_relasi': relation.trim(),
          };

          final res = await sb
              .table(SupabaseConfig.tableSavedGuests)
              ?.insert(payload)
              .select()
              .single();

          if (res != null) {
            return Map<String, dynamic>.from(res);
          }
        }
      } catch (e) {
        debugPrint('⚠️ [CustomerDataService] addSavedGuest Supabase error: $e');
        rethrow;
      }
    }
    return null;
  }

  Future<bool> updateSavedGuest({
    required int guestId,
    required String name,
    String? nik,
    String? phone,
    String? email,
    String? birthDate,
    String? relation,
    bool? isChild,
  }) async {
    final sb = SupabaseService.instance;
    if (sb.isReady && sb.client != null) {
      try {
        final payload = <String, dynamic>{
          'nama_tamu': name.trim(),
          if (nik != null) 'no_ktp_nik': nik.trim(),
          if (phone != null) 'no_handphone': phone.trim(),
          if (email != null) 'email': email.trim(),
          if (birthDate != null)
            'tanggal_lahir': birthDate.trim().isNotEmpty ? birthDate.trim() : null,
          if (isChild != null) 'kategori_usia': isChild ? 'Anak' : 'Dewasa',
          if (relation != null) 'tipe_relasi': relation.trim(),
        };

        await sb
            .table(SupabaseConfig.tableSavedGuests)
            ?.update(payload)
            .eq('id_saved_guest', guestId);
        return true;
      } catch (e) {
        debugPrint('⚠️ [CustomerDataService] updateSavedGuest Supabase error: $e');
        rethrow;
      }
    }
    return false;
  }

  Future<bool> deleteSavedGuest(int guestId) async {
    final sb = SupabaseService.instance;
    if (sb.isReady && sb.client != null) {
      try {
        await sb
            .table(SupabaseConfig.tableSavedGuests)
            ?.delete()
            .eq('id_saved_guest', guestId);
        return true;
      } catch (e) {
        debugPrint('⚠️ [CustomerDataService] deleteSavedGuest Supabase error: $e');
        return false;
      }
    }
    return false;
  }
}
