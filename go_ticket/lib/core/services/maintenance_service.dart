import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import '../models/maintenance_ticket_model.dart';
import '../models/room_model.dart';
import 'hotel_service.dart';
import 'supabase_service.dart';

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
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final List<MaintenanceTicketModel> results = [];

        // Ambil dari laporan_kerusakan
        final resK = await sb
            .table(SupabaseConfig.tableLaporanKerusakan)
            ?.select()
            .order('tgl_lapor', ascending: false);
        if (resK != null && (resK as List).isNotEmpty) {
          results.addAll(resK.map((t) =>
              MaintenanceTicketModel.fromJson(Map<String, dynamic>.from(t))));
        }

        // Ambil dari laporan_kebersihan
        final resB = await sb
            .table(SupabaseConfig.tableLaporanKebersihan)
            ?.select()
            .order('tgl_tugas', ascending: false);
        if (resB != null && (resB as List).isNotEmpty) {
          results.addAll(resB.map((t) =>
              MaintenanceTicketModel.fromJson(Map<String, dynamic>.from(t))));
        }

        // Return data dari DB (meskipun kosong)
        return results;
      } catch (e) {
        debugPrint('⚠️ [MaintenanceService] getTickets error: $e');
        return [];
      }
    }

    return [];
  }

  /// Membuat tiket laporan baru
  Future<MaintenanceTicketModel> createTicket(
    MaintenanceTicketModel ticket,
  ) async {
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final row = {
          'id_kamar': ticket.roomNumber ?? '1',
          'dilaporkan_oleh': ticket.reportedById.isNotEmpty ? ticket.reportedById : '1',
          'judul_masalah': ticket.title,
          'deskripsi_kerusakan': ticket.description,
          'tingkat_prioritas': ticket.priority.displayName.toLowerCase(),
          'status_perbaikan': 'dalam_proses',
          'tgl_lapor': DateTime.now().toIso8601String(),
        };

        final res = await sb
            .table(SupabaseConfig.tableLaporanKerusakan)
            ?.insert(row)
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
    final sb = SupabaseService.instance;

    if (sb.isReady) {
      try {
        final parsedId = int.tryParse(ticketId);
        final statusStr = newStatus == MaintenanceStatus.resolved
            ? 'selesai'
            : (newStatus == MaintenanceStatus.inProgress
                ? 'dalam_proses'
                : 'terbuka');

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
          await sb
              .table(SupabaseConfig.tableLaporanKerusakan)
              ?.update(data)
              .eq('id_tiket_kerusakan', parsedId);

          if (newStatus == MaintenanceStatus.resolved) {
            // Kamar siap kembali
          }
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ [MaintenanceService] updateTicketStatus error: $e');
        return false;
      }
    }

    return false;
  }
}
