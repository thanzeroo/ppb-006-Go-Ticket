import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import '../models/hotel_model.dart';
import '../models/room_model.dart';
import 'mock_data.dart';
import 'supabase_service.dart';

/// Service untuk mengelola data Hotel dan Kamar.
/// Mengambil data dari Supabase Table [hotels] & [rooms]
/// dengan fallback ke [MockData] saat offline / belum terkoneksi.
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
        var queryBuilder = sb.table(SupabaseConfig.tableHotels)?.select();
        if (queryBuilder != null) {
          if (status != null) {
            queryBuilder = queryBuilder.eq('status', status.apiValue);
          }
          if (city != null && city.isNotEmpty) {
            queryBuilder = queryBuilder.ilike('city', '%$city%');
          }
          if (query != null && query.isNotEmpty) {
            queryBuilder = queryBuilder.ilike('name', '%$query%');
          }

          final response = await queryBuilder;
          final list = (response as List)
              .map((item) => HotelModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();

          if (list.isNotEmpty) return list;
        }
      } catch (e) {
        debugPrint('⚠️ [HotelService] Supabase getHotels error: $e');
      }
    }

    // Fallback Mock Data
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
    final featured = all.where((h) => h.isRecommended || h.isPopular).toList();
    return featured.isNotEmpty ? featured : all;
  }

  /// Detail hotel berdasarkan ID
  Future<HotelModel?> getHotelById(String hotelId) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final res = await sb
            .table(SupabaseConfig.tableHotels)
            ?.select()
            .eq('id', hotelId)
            .maybeSingle();
        if (res != null) {
          return HotelModel.fromJson(Map<String, dynamic>.from(res));
        }
      } catch (e) {
        debugPrint('⚠️ [HotelService] Supabase getHotelById error: $e');
      }
    }

    // Fallback Mock
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
        final res = await sb
            .table(SupabaseConfig.tableRooms)
            ?.select()
            .eq('hotel_id', hotelId);
        if (res != null && (res as List).isNotEmpty) {
          return res
              .map((r) => RoomModel.fromJson(Map<String, dynamic>.from(r)))
              .toList();
        }
      } catch (e) {
        debugPrint('⚠️ [HotelService] Supabase getRooms error: $e');
      }
    }

    // Fallback Mock
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
            .table(SupabaseConfig.tableRooms)
            ?.insert(room.toJson())
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
        await sb
            .table(SupabaseConfig.tableRooms)
            ?.update(room.toJson())
            .eq('id', room.id);
        return true;
      } catch (e) {
        debugPrint('⚠️ [HotelService] Update room Supabase error: $e');
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

  /// Update status kamar (misal dari Available -> Occupied / Dirty / Cleaning)
  Future<bool> updateRoomStatus(String roomId, RoomStatus newStatus) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        await sb.table(SupabaseConfig.tableRooms)?.update({
          'status': newStatus.apiValue,
        }).eq('id', roomId);
        return true;
      } catch (e) {
        debugPrint('⚠️ [HotelService] updateRoomStatus error: $e');
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
        await sb.table(SupabaseConfig.tableRooms)?.delete().eq('id', roomId);
        return true;
      } catch (e) {
        debugPrint('⚠️ [HotelService] deleteRoom error: $e');
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
        await sb.table(SupabaseConfig.tableHotels)?.update({
          'status': status.apiValue,
        }).eq('id', hotelId);
        return true;
      } catch (e) {
        debugPrint('⚠️ [HotelService] updateHotelStatus error: $e');
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
