import 'package:flutter/material.dart';
import '../widgets/lapor_kerusakan_sheet.dart';
import '../../../../../core/models/maintenance_ticket_model.dart';
import '../../../../../core/services/maintenance_service.dart';

/// Tab 2: Papan Kebersihan Kamar & Checklist Housekeeping
/// 100% dinamis dari Supabase – tidak ada data mockup.
class KebersihanTab extends StatefulWidget {
  const KebersihanTab({super.key});

  @override
  State<KebersihanTab> createState() => _KebersihanTabState();
}

class _KebersihanTabState extends State<KebersihanTab> {
  int _selectedFloorIndex = 0;
  int _selectedStatusFilter = 0; // 0: Semua, 1: Terbuka, 2: Proses, 3: Selesai

  List<MaintenanceTicketModel> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Ambil tiket kategori kebersihan
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

  List<MaintenanceTicketModel> get _filteredTickets {
    switch (_selectedStatusFilter) {
      case 1:
        return _tickets.where((t) => t.status == MaintenanceStatus.open).toList();
      case 2:
        return _tickets.where((t) => t.status == MaintenanceStatus.inProgress).toList();
      case 3:
        return _tickets.where((t) => t.status == MaintenanceStatus.resolved || t.status == MaintenanceStatus.closed).toList();
      default:
        return _tickets;
    }
  }

  int get _openCount => _tickets.where((t) => t.status == MaintenanceStatus.open).length;
  int get _inProgressCount => _tickets.where((t) => t.status == MaintenanceStatus.inProgress).length;
  int get _doneCount => _tickets.where((t) => t.status == MaintenanceStatus.resolved || t.status == MaintenanceStatus.closed).length;

  @override
  Widget build(BuildContext context) {
    return _buildKebersihanTab();
  }

  Widget _buildKebersihanTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C2FF)));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Utama
            const Text(
              'Papan Kebersihan Kamar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),

            // Horizontal Filter Lantai (UI static – filter visual)
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

            // Status Filter Bar (Dinamis dari DB)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildStatusFilterPill(dotColor: const Color(0xFF64748B), title: 'Semua', count: _tickets.length, isSelected: _selectedStatusFilter == 0, onTap: () => setState(() => _selectedStatusFilter = 0))),
                  Expanded(child: _buildStatusFilterPill(dotColor: const Color(0xFFDC2626), title: 'Antrean', count: _openCount, isSelected: _selectedStatusFilter == 1, onTap: () => setState(() => _selectedStatusFilter = 1))),
                  Expanded(child: _buildStatusFilterPill(dotColor: const Color(0xFF00C2FF), title: 'Proses', count: _inProgressCount, isSelected: _selectedStatusFilter == 2, onTap: () => setState(() => _selectedStatusFilter = 2))),
                  Expanded(child: _buildStatusFilterPill(dotColor: const Color(0xFF00758F), title: 'Selesai', count: _doneCount, isSelected: _selectedStatusFilter == 3, onTap: () => setState(() => _selectedStatusFilter = 3))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List tiket atau empty state
            if (_filteredTickets.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36),
                alignment: Alignment.center,
                child: Column(
                  children: const [
                    Icon(Icons.cleaning_services_outlined, size: 48, color: Color(0xFF94A3B8)),
                    SizedBox(height: 10),
                    Text('Tidak ada tiket kebersihan.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                    SizedBox(height: 4),
                    Text('Semua kamar bersih & siap huni.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
              )
            else
              ..._filteredTickets.map((t) => _buildTicketCard(t)),

            const SizedBox(height: 16),

            // Tombol + Lapor Kerusakan
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => showLaporKerusakanModal(context),
                icon: const Icon(Icons.build_circle_outlined, color: Colors.white, size: 18),
                label: const Text('+ Lapor Kerusakan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C2FF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(MaintenanceTicketModel t) {
    final isOpen = t.status == MaintenanceStatus.open;
    final isInProgress = t.status == MaintenanceStatus.inProgress;
    final isDone = t.status == MaintenanceStatus.resolved || t.status == MaintenanceStatus.closed;

    final statusColor = isOpen
        ? const Color(0xFFDC2626)
        : isInProgress
            ? const Color(0xFF006D84)
            : const Color(0xFF059669);
    final statusBg = isOpen
        ? const Color(0xFFFEE2E2)
        : isInProgress
            ? const Color(0xFFBAF0FD)
            : const Color(0xFFD1FAE5);
    final statusLabel = isOpen
        ? 'Antrean'
        : isInProgress
            ? 'Sedang Dibersihkan'
            : 'Selesai';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: nomor kamar & status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    t.roomNumber != null ? 'Kamar #${t.roomNumber}' : 'Tiket #${t.id}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cleaning_services_outlined, color: Color(0xFF0284C7), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
          Text(
            'Pelapor: ${t.reportedByName} • ${t.category}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),

          // Prioritas
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 13, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                'Prioritas: ${t.priority.displayName}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tombol aksi
          if (!isDone)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () => _showActionSnackbar('Tiket ${t.roomNumber != null ? '#${t.roomNumber}' : '#${t.id}'} ditunda.'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        backgroundColor: const Color(0xFFF8FAFD),
                      ),
                      child: const Text('Tunda', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final newStatus = isOpen ? MaintenanceStatus.inProgress : MaintenanceStatus.resolved;
                        await MaintenanceService.instance.updateTicketStatus(t.id, newStatus);
                        _loadData();
                      },
                      icon: Icon(isDone ? Icons.verified_outlined : Icons.play_arrow_rounded, color: Colors.white, size: 16),
                      label: Text(
                        isOpen ? 'Mulai Bersihkan' : 'Selesai & Siap Huni',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C2FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
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
          color: isSelected ? const Color(0xFF00667C) : const Color(0xFFF1F5FD),
          borderRadius: BorderRadius.circular(20),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(title, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: const Color(0xFF0F172A))),
            const SizedBox(width: 3),
            Text('$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
