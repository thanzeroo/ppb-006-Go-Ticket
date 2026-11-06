import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import '../models/hotel_model.dart';
import '../models/room_model.dart';
import 'mock_data.dart';
import 'supabase_service.dart';

/// Service untuk mengelola data Hotel dan Kamar.
/// Mengambil data dari Supabase Table [mitra_penginapan] & [tipe_kamar]
/// dengan fallback ke [MockData] HANYA saat Supabase belum terkoneksi.
class HotelService {
  HotelService._();
  static final HotelService instance = HotelService._();

  // ---------------------------------------------------------------------------
  // 1. HOTEL RETRIEVAL
  // ---------------------------------------------------------------------------

  /// Mengambil daftar hotel dengan filter pencarian, kota, kategori, dan sorting
  Future<List<HotelModel>> getHotels({
    String? query,
    String? city,
    String? category,
    String? sortBy,
    HotelStatus? status,
  }) async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        var queryBuilder =
            sb.table(SupabaseConfig.tableMitraPenginapan)?.select();
        if (queryBuilder != null) {
          if (status != null) {
            final st = status == HotelStatus.active ? 'aktif' : status.apiValue;
            queryBuilder = queryBuilder.eq('status_operasional', st);
          }
          if (city != null && city.isNotEmpty) {
            queryBuilder = queryBuilder.ilike('kota_wilayah', '%$city%');
          }
          if (query != null && query.isNotEmpty) {
            queryBuilder = queryBuilder.ilike('nama_properti', '%$query%');
          }

          final response = await queryBuilder;
          final list = (response as List)
              .map((item) =>
                  HotelModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();

          // Sorting
          if (sortBy == 'Harga Terendah') {
            list.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
          } else if (sortBy == 'Rating Tertinggi') {
            list.sort((a, b) => b.rating.compareTo(a.rating));
          }

          // Return data dari DB (meskipun kosong)
          return list;
        }
      } catch (e) {
        debugPrint('⚠️ [HotelService] Supabase getHotels error: $e');
        return []; // Error saat query → return kosong, bukan MockData
      }
    }

    // Fallback Mock Data — HANYA kalau Supabase belum terkoneksi
    await Future.delayed(const Duration(milliseconds: 300));
    var results = List<HotelModel>.from(MockData.hotels);

    if (status != null) {
      results = results.where((h) => h.status == status).toList();
    }
    if (city != null && city.isNotEmpty) {
      results = results
          .where((h) => h.city.toLowerCase().contains(city.toLowerCase()))
          .toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((h) {
        return h.name.toLowerCase().contains(q) ||
            h.address.toLowerCase().contains(q) ||
            (h.shortDescription?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Sorting
    if (sortBy == 'Harga Terendah') {
      results.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
    } else if (sortBy == 'Rating Tertinggi') {
      results.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return results;
  }

  /// Mengambil hotel featured / rekomendasi untuk Beranda Tab
  Future<List<HotelModel>> getFeaturedHotels() async {
    final all = await getHotels();
    if (all.isEmpty) return [];
    final featured = all.where((h) => h.isRecommended || h.isPopular).toList();
    return featured.isNotEmpty ? featured : all;
  }

  /// Detail hotel berdasarkan ID
  Future<HotelModel?> getHotelById(String hotelId) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final parsedId = int.tryParse(hotelId);
        var q = sb.table(SupabaseConfig.tableMitraPenginapan)?.select();
        if (parsedId != null) {
          q = q?.eq('id_penginapan', parsedId);
        } else {
          q = q?.eq('id_penginapan', hotelId);
        }
        final res = await q?.maybeSingle();
        if (res != null) {
          return HotelModel.fromJson(Map<String, dynamic>.from(res));
        }
        return null; // Tidak ditemukan di DB
      } catch (e) {
        debugPrint('⚠️ [HotelService] Supabase getHotelById error: $e');
        return null;
      }
    }

    // Fallback Mock — HANYA kalau Supabase belum terkoneksi
    try {
      return MockData.hotels.firstWhere((h) => h.id == hotelId);
    } catch (_) {
      return MockData.hotels.isNotEmpty ? MockData.hotels.first : null;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. ROOM RETRIEVAL & MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Mengambil daftar kamar milik hotel tertentu
  Future<List<RoomModel>> getRoomsByHotel(String hotelId) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final parsedId = int.tryParse(hotelId);
        var q = sb.table(SupabaseConfig.tableTipeKamar)?.select('*, kamar(*)');
        if (parsedId != null) {
          q = q?.eq('id_penginapan', parsedId);
        } else {
          q = q?.eq('id_penginapan', hotelId);
        }
        final res = await q;
        if (res != null) {
          return (res as List)
              .map((r) => RoomModel.fromJson(Map<String, dynamic>.from(r)))
              .toList();
        }
        return [];
      } catch (e) {
        debugPrint('⚠️ [HotelService] Supabase getRooms error: $e');
        return [];
      }
    }

    // Fallback Mock — HANYA kalau Supabase belum terkoneksi
    await Future.delayed(const Duration(milliseconds: 250));
    final rooms = MockData.rooms.where((r) => r.hotelId == hotelId).toList();
    return rooms.isNotEmpty ? rooms : MockData.rooms;
  }

  /// Menambah kamar baru (Admin Hotel)
  Future<RoomModel> addRoom(RoomModel room) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final res = await sb
            .table(SupabaseConfig.tableTipeKamar)
            ?.insert({
              'id_penginapan': int.tryParse(room.hotelId) ?? 1,
              'nama_tipe': room.typeName,
              'kapasitas_tamu': room.maxGuests,
              'harga_dasar': room.pricePerNight,
              'harga_weekend': room.weekendPrice ?? room.pricePerNight,
              'luas_m2': room.roomSizeM2 ?? 24.0,
              'tipe_bed': room.bedType ?? 'King Bed',
              'total_unit': 10,
            })
            .select()
            .single();
        if (res != null) {
          return RoomModel.fromJson(Map<String, dynamic>.from(res));
        }
      } catch (e) {
        debugPrint('⚠️ [HotelService] Gagal insert room di Supabase: $e');
      }
    }

    // Fallback Mock
    MockData.rooms.add(room);
    return room;
  }

  /// Memperbarui data kamar
  Future<bool> updateRoom(RoomModel room) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        await sb.table(SupabaseConfig.tableTipeKamar)?.update({
          'nama_tipe': room.typeName,
          'kapasitas_tamu': room.maxGuests,
          'harga_dasar': room.pricePerNight,
          'harga_weekend': room.weekendPrice ?? room.pricePerNight,
        }).eq('id_tipe_kamar', room.id);
        return true;
      } catch (e) {
        debugPrint('⚠️ [HotelService] Update room Supabase error: $e');
        return false;
      }
    }

    // Fallback Mock
    final index = MockData.rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      MockData.rooms[index] = room;
      return true;
    }
    return false;
  }

  /// Update status kamar (Available -> Occupied / Dirty / Cleaning)
  Future<bool> updateRoomStatus(String roomId, RoomStatus newStatus) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final statusMap = {
          RoomStatus.available: 'tersedia',
          RoomStatus.occupied: 'terisi',
          RoomStatus.dirty: 'kotor',
          RoomStatus.cleaning: 'dibersihkan',
          RoomStatus.maintenance: 'maintenance',
        };
        await sb.table(SupabaseConfig.tableKamar)?.update({
          'status_kamar': statusMap[newStatus] ?? newStatus.apiValue,
        }).eq('id_kamar', roomId);
        return true;
      } catch (e) {
        debugPrint('⚠️ [HotelService] updateRoomStatus error: $e');
        return false;
      }
    }

    final index = MockData.rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      MockData.rooms[index] =
          MockData.rooms[index].copyWith(status: newStatus);
      return true;
    }
    return false;
  }

  /// Menghapus kamar
  Future<bool> deleteRoom(String roomId) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        await sb.table(SupabaseConfig.tableKamar)?.delete().eq('id_kamar', roomId);
        return true;
      } catch (e) {
        debugPrint('⚠️ [HotelService] deleteRoom error: $e');
        return false;
      }
    }

    MockData.rooms.removeWhere((r) => r.id == roomId);
    return true;
  }

  // ---------------------------------------------------------------------------
  // 3. HOTEL ADMIN / SUPER ADMIN ACTIONS
  // ---------------------------------------------------------------------------

  /// Mengubah status verifikasi hotel (Approve / Reject oleh Super Admin)
  Future<bool> updateHotelStatus(String hotelId, HotelStatus status) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final parsedId = int.tryParse(hotelId);
        final val = status == HotelStatus.active ? 'aktif' : status.apiValue;
        var q = sb.table(SupabaseConfig.tableMitraPenginapan)?.update({
          'status_operasional': val,
        });
        if (parsedId != null) {
          await q?.eq('id_penginapan', parsedId);
        } else {
          await q?.eq('id_penginapan', hotelId);
        }
        return true;
      } catch (e) {
        debugPrint('⚠️ [HotelService] updateHotelStatus error: $e');
        return false;
      }
    }

    final idx = MockData.hotels.indexWhere((h) => h.id == hotelId);
    if (idx != -1) {
      MockData.hotels[idx] = MockData.hotels[idx].copyWith(status: status);
      return true;
    }
    return false;
  }
}
