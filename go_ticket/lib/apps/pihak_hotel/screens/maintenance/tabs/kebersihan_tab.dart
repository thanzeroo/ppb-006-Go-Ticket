import 'package:flutter/material.dart';

import '../../../../../core/models/maintenance_ticket_model.dart';
import '../../../../../core/services/maintenance_service.dart';
import '../../../services/hotel_operations_store.dart';
import '../widgets/form_cek_kebersihan_sheet.dart';
import '../widgets/lapor_kerusakan_sheet.dart';

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

  List<MaintenanceTicketModel> _tickets = [];
  bool _isLoading = false;

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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await MaintenanceService.instance.getTickets(
        category: TicketCategory.cleaning,
      );
      if (mounted) {
        setState(() {
          _tickets = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
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
    final allQueue = store.cleaningQueue;
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
            // Subheader
            Row(
              children: const [
                Icon(Icons.cleaning_services_rounded, size: 15, color: Color(0xFF0284C7)),
                SizedBox(width: 6),
                Text(
                  'DIVISI HOUSEKEEPING & SANITASI',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0284C7),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Papan Kebersihan Kamar Hotel',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Daftar kamar yang baru saja check-out lengkap beserta informasi lantai untuk segera dibersihkan & disanitasi.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),

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
            else
              for (final task in filteredList) ...[
                _buildCleaningTaskCard(task),
                const SizedBox(height: 12),
              ],

            const SizedBox(height: 16),

            // Tombol + Lapor Kerusakan Fasilitas (jika ditemukan kerusakan saat bersih-bersih)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => showLaporKerusakanModal(context),
                icon: const Icon(Icons.build_circle_outlined, color: Colors.white, size: 18),
                label: const Text(
                  '+ Lapor Temuan Kerusakan Kamar',
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
