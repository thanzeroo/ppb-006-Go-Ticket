import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
          if (status == HotelStatus.active) {
            q = q.ilike('status_operasional', '%aktif%');
          } else {
            q = q.ilike('status_operasional', '%${status.apiValue}%');
          }
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
    return featured.isNotEmpty ? featured : all.take(5).toList();
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

  /// Menambah tipe kamar baru (Admin Hotel)
  Future<RoomModel> addRoom(RoomModel room) async {
    final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
        ? SupabaseConfig.supabaseServiceRoleKey
        : SupabaseConfig.activeApiKey;

    final payload = {
      'id_penginapan': int.tryParse(room.hotelId) ?? 1,
      'nama_tipe': room.typeName,
      'kapasitas_tamu': room.maxGuests,
      'harga_dasar': room.pricePerNight,
      'harga_weekend': room.weekendPrice ?? room.pricePerNight,
      'luas_m2': room.areaM2 ?? 24.0,
      'tipe_bed': room.bedType ?? 'King Bed',
      'total_unit': room.totalUnits > 0 ? room.totalUnits : 10,
    };

    try {
      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableTipeKamar}');
      final resp = await http.post(
        uri,
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=representation',
        },
        body: jsonEncode(payload),
      );

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List && data.isNotEmpty) {
          return RoomModel.fromJson(Map<String, dynamic>.from(data.first));
        }
      }
    } catch (e) {
      debugPrint('⚠️ [HotelService] addRoom REST error: $e');
    }

    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final res = await sb
            .table(SupabaseConfig.tableTipeKamar)
            ?.insert(payload)
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
    final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
        ? SupabaseConfig.supabaseServiceRoleKey
        : SupabaseConfig.activeApiKey;

    final payload = {
      'nama_tipe': room.typeName,
      'kapasitas_tamu': room.maxGuests,
      'harga_dasar': room.pricePerNight,
      'harga_weekend': room.weekendPrice ?? room.pricePerNight,
    };

    try {
      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableTipeKamar}?id_tipe_kamar=eq.${room.id}');
      final resp = await http.patch(
        uri,
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ [HotelService] updateRoom REST error: $e');
    }

    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        await sb
            .table(SupabaseConfig.tableTipeKamar)
            ?.update(payload)
            .eq('id_tipe_kamar', room.id);
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
    final statusMap = {
      RoomStatus.available: 'Tersedia',
      RoomStatus.occupied: 'Terisi',
      RoomStatus.dirty: 'Kotor',
      RoomStatus.cleaning: 'Dibersihkan',
      RoomStatus.maintenance: 'Perbaikan',
    };

    final statusVal = statusMap[newStatus] ?? newStatus.apiValue;

    final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
        ? SupabaseConfig.supabaseServiceRoleKey
        : SupabaseConfig.activeApiKey;

    try {
      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableKamar}?id_kamar=eq.$roomId');
      final resp = await http.patch(
        uri,
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status_kamar': statusVal}),
      );
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ [HotelService] updateRoomStatus REST error: $e');
    }

    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        await sb.table(SupabaseConfig.tableKamar)?.update({
          'status_kamar': statusVal,
        }).eq('id_kamar', roomId);
        return true;
      } catch (e) {
        debugPrint('⚠️ [HotelService] updateRoomStatus error: $e');
        return false;
      }
    }

    return false;
  }

  /// Menghapus tipe kamar atau kamar
  Future<bool> deleteRoom(String roomId) async {
    final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
        ? SupabaseConfig.supabaseServiceRoleKey
        : SupabaseConfig.activeApiKey;

    try {
      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableKamar}?id_kamar=eq.$roomId');
      final resp = await http.delete(
        uri,
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
        },
      );
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ [HotelService] deleteRoom REST error: $e');
    }

    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        await sb
            .table(SupabaseConfig.tableKamar)
            ?.delete()
            .eq('id_kamar', roomId);
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

  /// Menambahkan Mitra Penginapan baru ke database Supabase (Pihak Go Ticket / Super Admin)
  Future<HotelModel> createHotel({
    required String name,
    required String address,
    required String city,
    String? ptName,
    String? npwp,
    String? nib,
    String? phone,
    String? whatsapp,
    String? checkInTime,
    String? checkOutTime,
    double? deposit,
    String? cancellationPolicy,
    List<String>? facilities,
    double? latitude,
    double? longitude,
    String? mainImageUrl,
    List<String>? imageUrls,
    // Spesifikasi kamar awal
    String? roomName,
    int? roomCapacity,
    double? roomSizeM2,
    String? bedType,
    double? weekdayPrice,
    double? weekendPrice,
    List<String>? roomAmenities,
    List<Map<String, dynamic>>? roomTypes,
  }) async {
    final sb = SupabaseService.instance;
    if (!sb.isReady || sb.client == null) {
      throw Exception('Koneksi Supabase belum siap');
    }

    // 1. Insert ke tabel mitra_penginapan
    final hotelRow = <String, dynamic>{
      'nama_properti': name.trim(),
      'nama_pt': ptName?.trim().isNotEmpty == true ? ptName!.trim() : null,
      'npwp_perusahaan': npwp?.trim().isNotEmpty == true ? npwp!.trim() : null,
      'nib_perusahaan': nib?.trim().isNotEmpty == true ? nib!.trim() : null,
      'alamat_lengkap': address.trim(),
      'kota_wilayah': city.trim(),
      'no_telepon': phone?.trim().isNotEmpty == true ? phone!.trim() : null,
      'whatsapp': whatsapp?.trim().isNotEmpty == true ? whatsapp!.trim() : null,
      'waktu_checkin': checkInTime ?? '14:00:00',
      'waktu_checkout': checkOutTime ?? '12:00:00',
      'deposit_nominal': deposit ?? 0.0,
      'kebijakan_batal': cancellationPolicy ?? 'Bebas Pembatalan (H-3)',
      'status_operasional': 'Aktif',
      'saldo_escrow': 0.0,
      'persentase_komisi': 10.0,
      if (latitude != null && longitude != null)
        'koordinat_gps': '$latitude, $longitude',
    };

    final insertedHotel = await sb
        .table(SupabaseConfig.tableMitraPenginapan)
        ?.insert(hotelRow)
        .select()
        .single();

    if (insertedHotel == null) {
      throw Exception('Gagal menyimpan hotel ke database Supabase');
    }

    final int newHotelId =
        int.tryParse(insertedHotel['id_penginapan'].toString()) ?? 0;

    // 2. Insert tipe kamar (bisa satu atau banyak tipe kamar)
    if (newHotelId > 0) {
      final List<Map<String, dynamic>> roomsToInsert = [];
      if (roomTypes != null && roomTypes.isNotEmpty) {
        roomsToInsert.addAll(roomTypes);
      } else if (roomName != null && roomName.trim().isNotEmpty) {
        roomsToInsert.add({
          'name': roomName.trim(),
          'capacity': roomCapacity ?? 2,
          'sizeM2': roomSizeM2 ?? 30.0,
          'bedType': bedType ?? '1 King Bed',
          'weekdayPrice': weekdayPrice ?? 500000.0,
          'weekendPrice': weekendPrice ?? ((weekdayPrice ?? 500000.0) * 1.2),
          'amenities': roomAmenities ?? const ['AC', 'WiFi', 'Kamar Mandi Dalam'],
          'totalUnit': 5,
        });
      }

      for (int i = 0; i < roomsToInsert.length; i++) {
        final r = roomsToInsert[i];
        final rName = (r['name'] ?? r['nama_tipe'] ?? '').toString().trim();
        if (rName.isEmpty) continue;

        try {
          final basePrice = (r['weekdayPrice'] as num?)?.toDouble() ??
              (r['harga_dasar'] as num?)?.toDouble() ??
              500000.0;
          final wkndPrice = (r['weekendPrice'] as num?)?.toDouble() ??
              (r['harga_weekend'] as num?)?.toDouble() ??
              (r['harga_akhir_pekan'] as num?)?.toDouble() ??
              (basePrice * 1.2);
          final uniqueRoomTypeId =
              '${newHotelId}_${i + 1}_${DateTime.now().millisecondsSinceEpoch % 100000}';
          final dynamic rawAmenities = r['amenities'] ?? r['fasilitas_kamar'];
          final roomAmenitiesStr = rawAmenities is List
              ? rawAmenities.join(', ')
              : (rawAmenities?.toString() ?? 'AC, WiFi, Kamar Mandi Dalam');
          final totalUnits = (r['totalUnit'] as num?)?.toInt() ??
              (r['total_unit'] as num?)?.toInt() ??
              5;

          final roomTypeRow = <String, dynamic>{
            'id_tipe_kamar': uniqueRoomTypeId,
            'id_penginapan': newHotelId,
            'nama_tipe': rName,
            'kapasitas_tamu': (r['capacity'] as num?)?.toInt() ??
                (r['kapasitas'] as num?)?.toInt() ??
                2,
            'luas_m2': (r['sizeM2'] as num?)?.toDouble() ??
                (r['ukuran_kamar'] as num?)?.toDouble() ??
                30.0,
            'tipe_bed': (r['bedType'] ?? r['tipe_kasur'] ?? '1 King Bed').toString(),
            'harga_dasar': basePrice,
            'harga_weekend': wkndPrice,
            'total_unit': totalUnits,
            'fasilitas_kamar': roomAmenitiesStr,
          };

          await sb.table(SupabaseConfig.tableTipeKamar)?.insert(roomTypeRow);

          // 3. Insert unit fisik kamar di tabel kamar
          final List<Map<String, dynamic>> unitKamar = [];
          final int count = totalUnits > 0 ? (totalUnits > 10 ? 10 : totalUnits) : 2;
          for (int u = 1; u <= count; u++) {
            unitKamar.add({
              'id_kamar': '${uniqueRoomTypeId}_${(i + 1) * 100 + u}',
              'id_tipe_kamar': uniqueRoomTypeId,
              'id_penginapan': newHotelId,
              'nomor_kamar': '${(i + 1) * 100 + u}',
              'lantai': '${i + 1}',
              'status_kamar': 'Tersedia',
            });
          }
          await sb.table(SupabaseConfig.tableKamar)?.insert(unitKamar);
        } catch (e) {
          debugPrint('⚠️ [HotelService] Gagal menambahkan kamar index $i: $e');
        }
      }
    }

    // 3. Simpan fasilitas properti jika ada
    if (newHotelId > 0 && facilities != null && facilities.isNotEmpty) {
      try {
        final facRows = facilities.map((f) => {
          'id_penginapan': newHotelId,
          'nama_fasilitas': f,
        }).toList();
        await sb.table(SupabaseConfig.tableFasilitasProperti)?.insert(facRows);
      } catch (e) {
        debugPrint('⚠️ [HotelService] Gagal simpan fasilitas properti: $e');
      }
    }

    final resMap = Map<String, dynamic>.from(insertedHotel);
    if (mainImageUrl != null && mainImageUrl.isNotEmpty) {
      resMap['main_image_url'] = mainImageUrl;
      resMap['foto_utama'] = mainImageUrl;
    }
    if (imageUrls != null && imageUrls.isNotEmpty) {
      resMap['image_urls'] = imageUrls;
      resMap['photo_urls'] = imageUrls;
    }
    if (latitude != null) resMap['latitude'] = latitude;
    if (longitude != null) resMap['longitude'] = longitude;
    if (facilities != null && facilities.isNotEmpty) {
      resMap['amenities'] = facilities;
    }

    return HotelModel.fromJson(resMap);
  }

  /// Mengubah status verifikasi hotel (Approve / Reject oleh Super Admin)
  Future<bool> updateHotelStatus(String hotelId, HotelStatus status) async {
    final sb = SupabaseService.instance;
    if (sb.isReady) {
      try {
        final parsedId = int.tryParse(hotelId);
        final val = status == HotelStatus.active ? 'Aktif' : 'Nonaktif';
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

  /// Update data hotel/mitra penginapan (Super Admin / Admin Hotel)
  Future<bool> updateHotel({
    required String hotelId,
    required String name,
    required String city,
    required String address,
    String? phone,
    String? whatsapp,
    String? statusOperasional,
    String? checkInTime,
    String? checkOutTime,
    double? deposit,
    String? cancellationPolicy,
    double? latitude,
    double? longitude,
    String? mainImageUrl,
    String? ptName,
    String? npwp,
    String? nib,
  }) async {
    final sb = SupabaseService.instance;
    if (!sb.isReady || sb.client == null) return false;

    try {
      final parsedId = int.tryParse(hotelId);
      final updateData = <String, dynamic>{
        'nama_properti': name.trim(),
        'kota_wilayah': city.trim(),
        'alamat_lengkap': address.trim(),
      };

      if (phone != null) updateData['no_telepon'] = phone.trim();
      if (whatsapp != null) updateData['whatsapp'] = whatsapp.trim();
      if (statusOperasional != null) {
        updateData['status_operasional'] = statusOperasional.trim();
      }
      if (checkInTime != null) updateData['waktu_checkin'] = checkInTime.trim();
      if (checkOutTime != null) {
        updateData['waktu_checkout'] = checkOutTime.trim();
      }
      if (deposit != null) updateData['deposit_nominal'] = deposit;
      if (cancellationPolicy != null) {
        updateData['kebijakan_batal'] = cancellationPolicy.trim();
      }
      if (latitude != null && longitude != null) {
        updateData['koordinat_gps'] = '$latitude, $longitude';
      }
      if (ptName != null) updateData['nama_pt'] = ptName.trim();
      if (npwp != null) updateData['npwp_perusahaan'] = npwp.trim();
      if (nib != null) updateData['nib_perusahaan'] = nib.trim();

      var q = sb.table(SupabaseConfig.tableMitraPenginapan)?.update(updateData);
      if (parsedId != null) {
        await q?.eq('id_penginapan', parsedId);
      } else {
        await q?.eq('id_penginapan', hotelId);
      }
      return true;
    } catch (e) {
      debugPrint('⚠️ [HotelService] updateHotel error: $e');
      return false;
    }
  }

  /// Hapus mitra hotel beserta tipe kamar & unit kamar
  Future<bool> deleteHotel(String hotelId) async {
    final sb = SupabaseService.instance;
    if (!sb.isReady || sb.client == null) return false;

    try {
      final parsedId = int.tryParse(hotelId);

      // 1. Hapus unit kamar
      if (parsedId != null) {
        await sb
            .table(SupabaseConfig.tableKamar)
            ?.delete()
            .eq('id_penginapan', parsedId);
        // 2. Hapus tipe kamar
        await sb
            .table(SupabaseConfig.tableTipeKamar)
            ?.delete()
            .eq('id_penginapan', parsedId);
        // 3. Hapus mitra penginapan
        await sb
            .table(SupabaseConfig.tableMitraPenginapan)
            ?.delete()
            .eq('id_penginapan', parsedId);
      } else {
        await sb
            .table(SupabaseConfig.tableKamar)
            ?.delete()
            .eq('id_penginapan', hotelId);
        await sb
            .table(SupabaseConfig.tableTipeKamar)
            ?.delete()
            .eq('id_penginapan', hotelId);
        await sb
            .table(SupabaseConfig.tableMitraPenginapan)
            ?.delete()
            .eq('id_penginapan', hotelId);
      }
      return true;
    } catch (e) {
      debugPrint('⚠️ [HotelService] deleteHotel error: $e');
      return false;
    }
  }
}
