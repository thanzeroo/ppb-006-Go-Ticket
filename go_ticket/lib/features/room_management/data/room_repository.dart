// =============================================================================
// FILE: lib/features/room_management/data/room_repository.dart
// RESPONSIBILITY: Repository untuk manajemen kamar hotel di Go Ticket.
// Digunakan oleh:
// - Customer App: Melihat kamar tersedia dan detailnya
// - Hotel Partner App: Mengelola status kamar, harga, dan data kamar
// - Maintenance App: Update status kebersihan kamar
// =============================================================================

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../models/room_model.dart';

/// Repository manajemen kamar hotel Go Ticket.
class RoomRepository {
  final ApiClient _apiClient;

  RoomRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ---------------------------------------------------------------------------
  // READ — Mendapatkan data kamar
  // ---------------------------------------------------------------------------

  /// Mendapatkan daftar semua kamar dalam satu hotel.
  ///
  /// [hotelId] — ID hotel
  /// [status] — Filter by status (opsional)
  /// [checkIn] — Tanggal check-in untuk cek ketersediaan (opsional)
  /// [checkOut] — Tanggal check-out untuk cek ketersediaan (opsional)
  Future<List<RoomModel>> getRooms({
    required String hotelId,
    String? status,
    DateTime? checkIn,
    DateTime? checkOut,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (checkIn != null) {
      queryParams['check_in'] = checkIn.toIso8601String().substring(0, 10);
    }
    if (checkOut != null) {
      queryParams['check_out'] = checkOut.toIso8601String().substring(0, 10);
    }

    final response = await _apiClient.get(
      ApiEndpoints.getRooms.replaceAll('{hotelId}', hotelId),
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] ?? response ?? [];
    return data.map((json) => RoomModel.fromJson(json)).toList();
  }

  /// Mendapatkan detail satu kamar berdasarkan ID.
  Future<RoomModel> getRoomById(String roomId) async {
    final response = await _apiClient.get(
      ApiEndpoints.roomById(roomId),
    );
    return RoomModel.fromJson(response['data'] ?? response);
  }

  /// Cek ketersediaan kamar berdasarkan tanggal.
  ///
  /// Mengembalikan Map dengan field `is_available` dan daftar tanggal blocked.
  Future<Map<String, dynamic>> checkAvailability({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.checkRoomAvailability.replaceAll('{roomId}', roomId),
      queryParams: {
        'check_in': checkIn.toIso8601String().substring(0, 10),
        'check_out': checkOut.toIso8601String().substring(0, 10),
      },
    );
    return response['data'] ?? response;
  }

  // ---------------------------------------------------------------------------
  // CRUD — Manajemen kamar oleh Admin Hotel
  // ---------------------------------------------------------------------------

  /// Menambah kamar baru ke hotel.
  Future<RoomModel> addRoom({
    required String hotelId,
    required String roomNumber,
    required String typeName,
    required int pricePerNight,
    required int maxGuests,
    String? description,
    String? bedType,
    int? weekendPrice,
    int discountPercent = 0,
    List<String> facilities = const [],
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.addRoom.replaceAll('{hotelId}', hotelId),
      body: {
        'room_number': roomNumber,
        'type_name': typeName,
        'price_per_night': pricePerNight,
        'max_guests': maxGuests,
        'description': description,
        'bed_type': bedType,
        'weekend_price': weekendPrice,
        'discount_percent': discountPercent,
        'facilities': facilities,
      },
    );
    return RoomModel.fromJson(response['data'] ?? response);
  }

  /// Update data atau harga kamar.
  Future<RoomModel> updateRoom({
    required String roomId,
    int? pricePerNight,
    int? weekendPrice,
    int? discountPercent,
    String? description,
    List<String>? facilities,
  }) async {
    final body = <String, dynamic>{};
    if (pricePerNight != null) body['price_per_night'] = pricePerNight;
    if (weekendPrice != null) body['weekend_price'] = weekendPrice;
    if (discountPercent != null) body['discount_percent'] = discountPercent;
    if (description != null) body['description'] = description;
    if (facilities != null) body['facilities'] = facilities;

    final response = await _apiClient.put(
      ApiEndpoints.updateRoom.replaceAll('{roomId}', roomId),
      body: body,
    );
    return RoomModel.fromJson(response['data'] ?? response);
  }

  /// Hapus / nonaktifkan kamar dari hotel.
  Future<void> deleteRoom(String roomId) async {
    await _apiClient.delete(
      ApiEndpoints.deleteRoom.replaceAll('{roomId}', roomId),
    );
  }

  // ---------------------------------------------------------------------------
  // STATUS MANAGEMENT — Digunakan oleh Staff FO & Maintenance
  // ---------------------------------------------------------------------------

  /// Update status kamar.
  ///
  /// Digunakan oleh:
  /// - Staff FO: Set `occupied` saat check-in, set `dirty` saat checkout
  /// - Maintenance: Set `cleaning`, lalu `available` setelah bersih
  /// - Admin Hotel: Set `maintenance` untuk kamar yang diperbaiki
  Future<RoomModel> updateRoomStatus({
    required String roomId,
    required RoomStatus newStatus,
    String? notes,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.updateRoomStatus.replaceAll('{roomId}', roomId),
      body: {
        'status': newStatus.apiValue,
        'notes': ?notes,
      },
    );
    return RoomModel.fromJson(response['data'] ?? response);
  }

  /// Mendapatkan daftar kamar dengan status Dirty (untuk dashboard Maintenance).
  Future<List<RoomModel>> getDirtyRooms(String hotelId) async {
    return getRooms(hotelId: hotelId, status: RoomStatus.dirty.apiValue);
  }

  /// Mendapatkan daftar kamar yang sedang di-cleaning.
  Future<List<RoomModel>> getCleaningRooms(String hotelId) async {
    return getRooms(hotelId: hotelId, status: RoomStatus.cleaning.apiValue);
  }

  /// Mendapatkan semua kamar yang tersedia (status Available).
  Future<List<RoomModel>> getAvailableRooms(String hotelId) async {
    return getRooms(hotelId: hotelId, status: RoomStatus.available.apiValue);
  }
}
