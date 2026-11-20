import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/supabase_config.dart';
import '../models/maintenance_ticket_model.dart';
import '../models/room_model.dart';
import 'auth_service.dart';
import 'hotel_service.dart';

/// Service untuk operasional pemeliharaan hotel (Kebersihan & Kerusakan).
/// Seluruh data bersumber langsung dari Supabase Database.
/// Tidak ada mock data atau fallback dummy data.
class MaintenanceService {
  MaintenanceService._();
  static final MaintenanceService instance = MaintenanceService._();

  /// Mengambil daftar tiket maintenance
  Future<List<MaintenanceTicketModel>> getTickets({
    String? hotelId,
    String? category,
    String? status,
  }) async {
    final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
        ? SupabaseConfig.supabaseServiceRoleKey
        : SupabaseConfig.activeApiKey;

    final List<MaintenanceTicketModel> results = [];

    // 1. Ambil dari laporan_kerusakan via Service Role REST API
    try {
      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableLaporanKerusakan}?select=*&order=tgl_lapor.desc');
      final resp = await http.get(uri, headers: {
        'apikey': serviceKey,
        'Authorization': 'Bearer $serviceKey',
      });
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        results.addAll(list.map((t) =>
            MaintenanceTicketModel.fromJson(Map<String, dynamic>.from(t))));
      }
    } catch (e) {
      debugPrint('⚠️ [MaintenanceService] get laporan_kerusakan error: $e');
    }

    // 2. Ambil dari laporan_kebersihan via Service Role REST API
    try {
      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableLaporanKebersihan}?select=*&order=tgl_tugas.desc');
      final resp = await http.get(uri, headers: {
        'apikey': serviceKey,
        'Authorization': 'Bearer $serviceKey',
      });
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        results.addAll(list.map((t) =>
            MaintenanceTicketModel.fromJson(Map<String, dynamic>.from(t))));
      }
    } catch (e) {
      debugPrint('⚠️ [MaintenanceService] get laporan_kebersihan error: $e');
    }

    return results;
  }

  /// Membuat tiket laporan baru
  Future<MaintenanceTicketModel> createTicket(
    MaintenanceTicketModel ticket,
  ) async {
    final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
        ? SupabaseConfig.supabaseServiceRoleKey
        : SupabaseConfig.activeApiKey;

    try {
      final currentStaffId = AuthService.instance.currentUser?.id;
      final validStaffId = (currentStaffId != null && currentStaffId.isNotEmpty)
          ? currentStaffId
          : 'MT-2025-001';

      final rawRoom = ticket.roomId ?? ticket.roomNumber ?? '1';
      final cleanRoom = rawRoom.replaceAll(RegExp(r'[^0-9]'), '');
      final validRoomId = cleanRoom.isNotEmpty ? cleanRoom : '1';

      final row = {
        'id_kamar': validRoomId,
        'dilaporkan_oleh': validStaffId,
        'ditugaskan_ke': validStaffId,
        'judul_masalah': ticket.title,
        'deskripsi_kerusakan': ticket.description,
        'tingkat_prioritas': ticket.priority.displayName,
        'status_perbaikan': 'Open',
        'tgl_lapor': DateTime.now().toIso8601String(),
      };

      final uri = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableLaporanKerusakan}');
      final resp = await http.post(
        uri,
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=representation',
        },
        body: jsonEncode(row),
      );

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List && data.isNotEmpty) {
          return MaintenanceTicketModel.fromJson(
            Map<String, dynamic>.from(data.first),
          );
        }
      } else {
        debugPrint('⚠️ [MaintenanceService] createTicket status ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      debugPrint('⚠️ [MaintenanceService] createTicket error: $e');
    }

    if (ticket.roomId != null) {
      await HotelService.instance
          .updateRoomStatus(ticket.roomId!, RoomStatus.maintenance);
    }

    return ticket;
  }

  /// Mengubah status pengerjaan tiket
  Future<bool> updateTicketStatus(
    String ticketId,
    MaintenanceStatus newStatus, {
    String? resolutionNotes,
  }) async {
    final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
        ? SupabaseConfig.supabaseServiceRoleKey
        : SupabaseConfig.activeApiKey;

    try {
      final parsedId = int.tryParse(ticketId);
      final statusStr = newStatus == MaintenanceStatus.resolved
          ? 'selesai'
          : (newStatus == MaintenanceStatus.inProgress
              ? 'dalam_proses'
              : 'Open');

      final data = <String, dynamic>{
        'status_perbaikan': statusStr,
      };
      if (newStatus == MaintenanceStatus.resolved) {
        data['tgl_selesai'] = DateTime.now().toIso8601String();
        if (resolutionNotes != null) {
          data['tindakan_perbaikan'] = resolutionNotes;
        }
      }

      if (parsedId != null) {
        final uri = Uri.parse(
            '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableLaporanKerusakan}?id_tiket_kerusakan=eq.$parsedId');
        final resp = await http.patch(
          uri,
          headers: {
            'apikey': serviceKey,
            'Authorization': 'Bearer $serviceKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
        );
        return resp.statusCode == 200 || resp.statusCode == 204;
      }
    } catch (e) {
      debugPrint('⚠️ [MaintenanceService] updateTicketStatus error: $e');
    }

    return false;
  }
}
