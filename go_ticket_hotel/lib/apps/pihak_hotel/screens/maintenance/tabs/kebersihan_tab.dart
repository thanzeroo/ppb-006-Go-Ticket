import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:go_ticket_hotel/core/widgets/app_pagination_bar.dart';
import '../../../../../core/config/supabase_config.dart';
import '../../../../../core/models/maintenance_ticket_model.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/maintenance_service.dart';
import '../../../services/hotel_operations_store.dart';
import '../widgets/form_cek_kebersihan_sheet.dart';

/// Tab 2: Papan Kebersihan Kamar & Checklist Housekeeping
/// Sesuai instruksi:
/// 1. Jika ada tamu yang sudah check-out, list kamar dan informasi di lantai berapa akan muncul untuk dibersihkan.
/// 2. Form cek kebersihan dengan flow yang simpel & jelas tanpa input foto/gambar.
/// 3. Time log kebersihan otomatis muncul saat petugas mengirimkannya/submit.
class KebersihanTab extends StatefulWidget {
  const KebersihanTab({super.key});

  @override
  State<KebersihanTab> createState() => _KebersihanTabState();
}

class _KebersihanTabState extends State<KebersihanTab> {
  int _selectedFloorIndex = 0; // 0: Semua Lantai, 1: Lantai 1, 2: Lantai 2, 3: Lantai 3
  int _selectedStatusFilter = 0; // 0: Semua, 1: Antrean (Perlu Bersih), 2: Proses, 3: Selesai Siap Huni

  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
    HotelOperationsStore.instance.addListener(_onStoreUpdated);
  }

  @override
  void dispose() {
    HotelOperationsStore.instance.removeListener(_onStoreUpdated);
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  List<CleaningTaskItem> _dbCleaningTasks = [];

  Future<void> _loadData() async {
    try {
      final hotelId = AuthService.instance.currentUser?.managedHotelId ?? '1';
      final svcKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
          ? SupabaseConfig.supabaseServiceRoleKey
          : SupabaseConfig.activeApiKey;

      final results = await Future.wait([
        MaintenanceService.instance.getTickets(category: TicketCategory.cleaning),
        http.get(
          Uri.parse(
              '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableKamar}?id_penginapan=eq.$hotelId&select=*,tipe_kamar(nama_tipe)&order=nomor_kamar.asc'),
          headers: {
            'apikey': svcKey,
            'Authorization': 'Bearer $svcKey',
          },
        ),
      ]);

      final kamarResp = results[1] as http.Response;
      final List<CleaningTaskItem> synced = [];
      if (kamarResp.statusCode == 200) {
        final List<dynamic> rooms = jsonDecode(kamarResp.body);
        for (final r in rooms) {
          final status = (r['status_kamar'] ?? '').toString().toLowerCase();
          // Abaikan kamar yang rusak; fokus pada kamar kotor/proses/bersih
          if (status.contains('rusak') || status.contains('maint')) continue;
          if (status.contains('kotor') ||
              status.contains('dirty') ||
              status.contains('bersih') ||
              status.contains('clean')) {
            final roomNo = (r['nomor_kamar'] ?? r['id_kamar']).toString();
            final floor = int.tryParse((r['lantai'] ?? '1').toString()) ?? 1;
            final tipeMap = r['tipe_kamar'];
            final tipeName = tipeMap is Map
                ? (tipeMap['nama_tipe'] ?? 'Kamar').toString()
                : 'Kamar';
            final isCleaning =
                status.contains('proses') || status.contains('sedang');
            synced.add(CleaningTaskItem(
              id: 'DB-${r['id_kamar']}',
              roomNumber: roomNo,
              floorNumber: floor,
              roomTypeName: tipeName,
              checkoutTime: DateTime.now(),
              checkoutType: CheckoutType.normal,
              isCleaning: isCleaning,
              isCleaned: false,
            ));
          }
        }
      }
      if (mounted) {
        setState(() => _dbCleaningTasks = synced);
      }
    } catch (_) {}
  }

  /// Modal Laporan Kebersihan Kamar (pengganti Lapor Kerusakan di tab Kebersihan)
  void _showLaporanKebersihanModal() {
    final roomCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String statusKebersihan = 'Selesai Dibersihkan (Siap Huni)';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Laporan Kebersihan Kamar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roomCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nomor Kamar *',
                    hintText: 'Masukkan nomor kamar (contoh: 102)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: statusKebersihan,
                  decoration: InputDecoration(
                    labelText: 'Status Kebersihan',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Selesai Dibersihkan (Siap Huni)',
                      child: Text('Selesai Dibersihkan (Siap Huni)',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                    DropdownMenuItem(
                      value: 'Sedang Dibersihkan',
                      child: Text('Sedang Dibersihkan',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                    DropdownMenuItem(
                      value: 'Perlu Pembersihan Ulang',
                      child: Text('Perlu Pembersihan Ulang',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setSheetState(() => statusKebersihan = v);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Catatan Kebersihan & Sanitasi',
                    hintText: 'Masukkan catatan kondisi kebersihan kamar',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final roomNo = roomCtrl.text.trim();
                            if (roomNo.isEmpty) {
                              _showActionSnackbar('Nomor kamar wajib diisi.');
                              return;
                            }
                            setSheetState(() => isSaving = true);
                            try {
                              final svcKey = SupabaseConfig
                                      .supabaseServiceRoleKey.isNotEmpty
                                  ? SupabaseConfig.supabaseServiceRoleKey
                                  : SupabaseConfig.activeApiKey;
                              final hotelId = AuthService
                                      .instance.currentUser?.managedHotelId ??
                                  '1';
                              final staffId =
                                  AuthService.instance.currentUser?.id ??
                                      'MTC';

                              await http.post(
                                Uri.parse(
                                    '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableLaporanKebersihan}'),
                                headers: {
                                  'apikey': svcKey,
                                  'Authorization': 'Bearer $svcKey',
                                  'Content-Type': 'application/json',
                                  'Prefer': 'return=minimal',
                                },
                                body: jsonEncode({
                                  'id_kamar': roomNo,
                                  'id_staf': staffId,
                                  'status_kebersihan': statusKebersihan,
                                  'catatan_sanitasi': notesCtrl.text.trim(),
                                  'tgl_tugas': DateTime.now().toIso8601String(),
                                }),
                              );

                              // Update status kamar jika sudah selesai dibersihkan
                              if (statusKebersihan.contains('Selesai')) {
                                await http.patch(
                                  Uri.parse(
                                      '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableKamar}?id_penginapan=eq.$hotelId&nomor_kamar=eq.$roomNo'),
                                  headers: {
                                    'apikey': svcKey,
                                    'Authorization': 'Bearer $svcKey',
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode({'status_kamar': 'Tersedia'}),
                                );
                              }

                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              _showActionSnackbar(
                                  'Laporan kebersihan Kamar $roomNo berhasil dikirim!');
                              _loadData();
                            } catch (e) {
                              setSheetState(() => isSaving = false);
                              _showActionSnackbar('Gagal mengirim laporan: $e');
                            }
                          },
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.cleaning_services_rounded, size: 18),
                    label: const Text('Kirim Laporan Kebersihan',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00758F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActionSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00758F),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<CleaningTaskItem> get _filteredTasks {
    final store = HotelOperationsStore.instance;
    final seenRooms = store.cleaningQueue.map((e) => e.roomNumber).toSet();
    final allQueue = [
      ...store.cleaningQueue,
      ..._dbCleaningTasks.where((d) => !seenRooms.contains(d.roomNumber)),
    ];
    final allCleaned = store.cleanedHistory;

    List<CleaningTaskItem> combined = [];
    if (_selectedStatusFilter == 0) {
      combined = [...allQueue, ...allCleaned];
    } else if (_selectedStatusFilter == 1) {
      // Perlu dibersihkan
      combined = allQueue.where((t) => !t.isCleaning).toList();
    } else if (_selectedStatusFilter == 2) {
      // Sedang dibersihkan
      combined = allQueue.where((t) => t.isCleaning).toList();
    } else if (_selectedStatusFilter == 3) {
      // Selesai siap huni
      combined = allCleaned;
    }

    if (_selectedFloorIndex > 0) {
      combined = combined.where((t) => t.floorNumber == _selectedFloorIndex).toList();
    }

    return combined;
  }

  @override
  Widget build(BuildContext context) {
    final store = HotelOperationsStore.instance;
    final queue = store.cleaningQueue;
    final cleaned = store.cleanedHistory;

    final openCount = queue.where((t) => !t.isCleaning).length;
    final inProgressCount = queue.where((t) => t.isCleaning).length;
    final doneCount = cleaned.length;
    final totalCount = queue.length + cleaned.length;

    final filteredList = _filteredTasks;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal Filter Lantai
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFloorPill(title: 'Semua Lantai', index: 0),
                  const SizedBox(width: 8),
                  _buildFloorPill(title: 'Lantai 1', index: 1),
                  const SizedBox(width: 8),
                  _buildFloorPill(title: 'Lantai 2', index: 2),
                  const SizedBox(width: 8),
                  _buildFloorPill(title: 'Lantai 3', index: 3),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Status Filter Bar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatusFilterPill(
                      dotColor: const Color(0xFF64748B),
                      title: 'Semua',
                      count: totalCount,
                      isSelected: _selectedStatusFilter == 0,
                      onTap: () => setState(() => _selectedStatusFilter = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildStatusFilterPill(
                      dotColor: const Color(0xFFDC2626),
                      title: 'Perlu Bersih',
                      count: openCount,
                      isSelected: _selectedStatusFilter == 1,
                      onTap: () => setState(() => _selectedStatusFilter = 1),
                    ),
                  ),
                  Expanded(
                    child: _buildStatusFilterPill(
                      dotColor: const Color(0xFF00C2FF),
                      title: 'Proses',
                      count: inProgressCount,
                      isSelected: _selectedStatusFilter == 2,
                      onTap: () => setState(() => _selectedStatusFilter = 2),
                    ),
                  ),
                  Expanded(
                    child: _buildStatusFilterPill(
                      dotColor: const Color(0xFF16A34A),
                      title: 'Siap Huni',
                      count: doneCount,
                      isSelected: _selectedStatusFilter == 3,
                      onTap: () => setState(() => _selectedStatusFilter = 3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List Kamar yang Perlu Dibersihkan
            if (filteredList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.cleaning_services_outlined, size: 48, color: Color(0xFF94A3B8)),
                    SizedBox(height: 10),
                    Text(
                      'Tidak ada kamar dalam antrean ini',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kamar tamu yang selesai check-out di front desk akan otomatis muncul di sini.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else ...[
              Builder(
                builder: (ctx) {
                  final total = filteredList.length;
                  final maxPage = (total / 10).ceil();
                  final safePage = _currentPage.clamp(1, maxPage > 0 ? maxPage : 1);
                  final pagedList = paginateList(filteredList, safePage, pageSize: 10);

                  return Column(
                    children: [
                      for (final task in pagedList) ...[
                        _buildCleaningTaskCard(task),
                        const SizedBox(height: 12),
                      ],
                      AppPaginationBar(
                        currentPage: safePage,
                        totalItems: total,
                        pageSize: 10,
                        itemLabel: 'tugas kebersihan',
                        primaryColor: const Color(0xFF00758F),
                        onPageChanged: (newPage) => setState(() => _currentPage = newPage),
                      ),
                    ],
                  );
                },
              ),
            ],

            const SizedBox(height: 16),

            // Tombol + Laporan Kebersihan Kamar
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _showLaporanKebersihanModal,
                icon: const Icon(Icons.cleaning_services_rounded, color: Colors.white, size: 18),
                label: const Text(
                  '+ Laporan Kebersihan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00758F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorPill({required String title, required int index}) {
    final isSelected = _selectedFloorIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedFloorIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007A87) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF007A87) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterPill({
    required Color dotColor,
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleaningTaskCard(CleaningTaskItem task) {
    final isDone = task.isCleaned;
    final isProcessing = task.isCleaning;

    final statusBg = isDone
        ? const Color(0xFFDCFCE7)
        : (isProcessing ? const Color(0xFFBAF0FD) : const Color(0xFFFEE2E2));
    final statusFg = isDone
        ? const Color(0xFF15803D)
        : (isProcessing ? const Color(0xFF00758F) : const Color(0xFFDC2626));
    final statusLabel = isDone
        ? 'Siap Huni'
        : (isProcessing ? 'Sedang Dibersihkan' : 'Perlu Dibersihkan');

    final outTime =
        '${task.checkoutTime.hour.toString().padLeft(2, '0')}:${task.checkoutTime.minute.toString().padLeft(2, '0')} WIB';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar: Lantai & Nomor Kamar (Sesuai instruksi: informasi di lantai berapa)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007A87),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Lantai ${task.floorNumber}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kamar #${task.roomNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: statusFg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              task.roomTypeName,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.logout_rounded, size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  'Tamu Check-out: $outTime (${task.previousGuestName ?? "Tamu Hotel"})',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),

            if (task.checkoutReason != null && task.checkoutReason!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Info FO: ${task.checkoutReason!}',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                ),
              ),
            ],

            // TIME LOG SUBMIT OTOMATIS (Sesuai instruksi: untuk time log kebersihan otomatis muncul saat submit)
            if (isDone && task.cleanedAt != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_filled_rounded, size: 14, color: Color(0xFF16A34A)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Waktu Submit Selesai: ${task.cleanedAt!.day}/${task.cleanedAt!.month}/${task.cleanedAt!.year} • ${task.cleanedAt!.hour.toString().padLeft(2, '0')}:${task.cleanedAt!.minute.toString().padLeft(2, '0')}:${task.cleanedAt!.second.toString().padLeft(2, '0')} WIB (Oleh: ${task.cleanedBy ?? "Housekeeping"})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Tombol Aksi
            if (!isDone)
              Row(
                children: [
                  if (!isProcessing) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HotelOperationsStore.instance.startCleaning(task.id);
                          _showActionSnackbar('Mulai membersihkan Kamar #${task.roomNumber} (Lt. ${task.floorNumber})');
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: const Text('Mulai Bersihkan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFBAE6FD)),
                          foregroundColor: const Color(0xFF00758F),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    flex: isProcessing ? 1 : 1,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showFormCekKebersihanModal(
                          context,
                          task: task,
                          onFinished: () => setState(() {}),
                        );
                      },
                      icon: const Icon(Icons.checklist_rounded, size: 16),
                      label: const Text(
                        'Form Cek Kebersihan',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Status Sanitasi: Lolos QC (Siap Tamu Baru)', style: TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                  Icon(Icons.verified_rounded, size: 16, color: Color(0xFF16A34A)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
