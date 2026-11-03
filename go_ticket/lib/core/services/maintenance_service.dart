import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import '../models/maintenance_ticket_model.dart';
import '../models/room_model.dart';
import 'hotel_service.dart';
import 'mock_data.dart';
import 'supabase_service.dart';

/// Service untuk operasional pemeliharaan hotel (Kebersihan & Kerusakan).
class MaintenanceService {
  MaintenanceService._();
  static final MaintenanceService instance = MaintenanceService._();

  /// Mengambil daftar tiket maintenance
  Future<List<MaintenanceTicketModel>> getTickets({
    String? hotelId,
    TicketCategory? category,
    TicketStatus? status,
  }) async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        var q = sb.table(SupabaseConfig.tableMaintenanceTickets)?.select();
        if (hotelId != null) q = q?.eq('hotel_id', hotelId);
        if (category != null) q = q?.eq('category', category.apiValue);
        if (status != null) q = q?.eq('status', status.apiValue);

        final res = await q?.order('created_at', ascending: false);
        if (res != null && (res as List).isNotEmpty) {
          return res
              .map((t) =>
                  MaintenanceTicketModel.fromJson(Map<String, dynamic>.from(t)))
              .toList();
        }
      } catch (e) {
        debugPrint('⚠️ [MaintenanceService] getTickets error: $e');
      }
    }

    // Fallback Mock
    await Future.delayed(const Duration(milliseconds: 250));
    var list = List<MaintenanceTicketModel>.from(MockData.maintenanceTickets);

    if (hotelId != null) {
      list = list.where((t) => t.hotelId == hotelId).toList();
    }
    if (category != null) {
      list = list.where((t) => t.category == category).toList();
    }
    if (status != null) {
      list = list.where((t) => t.status == status).toList();
    }

    return list;
  }

  /// Membuat tiket laporan baru (contoh: Lapor Kerusakan atau Permintaan Kebersihan)
  Future<MaintenanceTicketModel> createTicket(
    MaintenanceTicketModel ticket,
  ) async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final res = await sb
            .table(SupabaseConfig.tableMaintenanceTickets)
            ?.insert(ticket.toJson())
            .select()
            .single();

        if (res != null) {
          return MaintenanceTicketModel.fromJson(
            Map<String, dynamic>.from(res),
          );
        }
      } catch (e) {
        debugPrint('⚠️ [MaintenanceService] createTicket error: $e');
      }
    }

    // Jika kamar rusak, otomatis ubah status kamar ke Maintenance
    if (ticket.category == TicketCategory.repair) {
      await HotelService.instance
          .updateRoomStatus(ticket.roomId, RoomStatus.maintenance);
    }

    MockData.maintenanceTickets.insert(0, ticket);
    return ticket;
  }

  /// Mengubah status pengerjaan tiket
  Future<bool> updateTicketStatus(
    String ticketId,
    TicketStatus newStatus, {
    String? resolutionNotes,
  }) async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final data = <String, dynamic>{
          'status': newStatus.apiValue,
        };
        if (newStatus == TicketStatus.resolved) {
          data['resolved_at'] = DateTime.now().toIso8601String();
          if (resolutionNotes != null) {
            data['resolution_notes'] = resolutionNotes;
          }
        }
        await sb
            .table(SupabaseConfig.tableMaintenanceTickets)
            ?.update(data)
            .eq('id', ticketId);
      } catch (e) {
        debugPrint('⚠️ [MaintenanceService] updateTicketStatus error: $e');
      }
    }

    final idx =
        MockData.maintenanceTickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      final old = MockData.maintenanceTickets[idx];
      MockData.maintenanceTickets[idx] = old.copyWith(
        status: newStatus,
        resolvedAt: newStatus == TicketStatus.resolved ? DateTime.now() : null,
        resolutionNotes: resolutionNotes ?? old.resolutionNotes,
      );

      // Jika tiket selesai (resolved), kembalikan kamar jadi Available
      if (newStatus == TicketStatus.resolved) {
        await HotelService.instance
            .updateRoomStatus(old.roomId, RoomStatus.available);
      }
      return true;
    }
    return false;
  }
}
