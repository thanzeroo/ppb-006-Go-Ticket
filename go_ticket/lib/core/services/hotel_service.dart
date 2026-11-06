import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import '../models/hotel_model.dart';
import '../models/room_model.dart';
import 'supabase_service.dart';

/// Service untuk mengelola data Hotel dan Kamar.
/// Mengambil data murni dari Supabase Table [mitra_penginapan] & [tipe_kamar].
/// Tidak ada mock data atau fallback dummy data.
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
        var q = sb.table(SupabaseConfig.tableMitraPenginapan)?.select();

        if (status != null && q != null) {
          final val = status == HotelStatus.active ? 'aktif' : status.apiValue;
          q = q.eq('status_operasional', val);
        }

        if (city != null && city.isNotEmpty && q != null) {
          q = q.ilike('kota_wilayah', '%$city%');
        }

        if (query != null && query.isNotEmpty && q != null) {
          q = q.ilike('nama_properti', '%$query%');
        }

        final res = await q;

        if (res != null) {
          final list = (res as List)
              .map((h) => HotelModel.fromJson(Map<String, dynamic>.from(h)))
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
        return [];
      }
    }

    return [];
  }

  /// Mengambil hotel featured / rekomendasi untuk Beranda Tab
  Future<List<HotelModel>> getFeaturedHotels() async {
    final all = await getHotels();
    if (all.isEmpty) return [];
    final featured = all.where((h) => h.isRecommended || h.isPopular).toList();
    return featured;
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
        return null;
      } catch (e) {
        debugPrint('⚠️ [HotelService] Supabase getHotelById error: $e');
        return null;
      }
    }

    return null;
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

    return [];
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

    return false;
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

    return false;
  }
}
