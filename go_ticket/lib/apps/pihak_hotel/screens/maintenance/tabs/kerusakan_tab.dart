import 'package:flutter/material.dart';
import '../widgets/lapor_kerusakan_sheet.dart';
import '../../../../../core/models/maintenance_ticket_model.dart';
import '../../../../../core/services/maintenance_service.dart';

/// Tab 3: Tiket Kerusakan & Hub Pemeliharaan Maintenance
/// 100% dinamis dari Supabase – tidak ada data mockup.
class KerusakanTab extends StatefulWidget {
  const KerusakanTab({super.key});

  @override
  State<KerusakanTab> createState() => _KerusakanTabState();
}

class _KerusakanTabState extends State<KerusakanTab> {
  int _ticketFilterIndex = 0; // 0: Semua, 1: Terbuka, 2: Proses, 3: Selesai

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
      // Ambil tiket kerusakan (bukan kebersihan)
      final data = await MaintenanceService.instance.getTickets();
      if (mounted) {
        setState(() {
          // Filter hanya kerusakan (bukan kategori kebersihan)
          _tickets = data.where((t) => t.category != TicketCategory.cleaning).toList();
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
    switch (_ticketFilterIndex) {
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
  int get _resolvedCount => _tickets.where((t) => t.status == MaintenanceStatus.resolved || t.status == MaintenanceStatus.closed).length;

  @override
  Widget build(BuildContext context) {
    return _buildKerusakanTab();
  }

  Widget _buildKerusakanTab() {
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
            // Subheader: LIVE MAINTENANCE HUB
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF00C2FF), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('LIVE MAINTENANCE HUB', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0284C7), letterSpacing: 0.8)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Shift Aktif', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Tiket Kerusakan & Pemeliharaan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.4),
            ),
            const SizedBox(height: 14),

            // 3 Ringkasan Kotak (Dinamis dari DB)
            Row(
              children: [
                Expanded(
                  child: _buildTicketSummaryBox(
                    icon: Icons.build_circle_outlined,
                    number: '$_openCount',
                    label: 'Tiket Terbuka',
                    badgeText: _openCount > 0 ? '${_openCount} Aktif' : null,
                    badgeBg: const Color(0xFFFEE2E2),
                    badgeTextColor: const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTicketSummaryBox(
                    icon: Icons.hourglass_top_rounded,
                    number: '$_inProgressCount',
                    label: 'Proses',
                    hasDot: _inProgressCount > 0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTicketSummaryBox(
                    icon: Icons.verified_outlined,
                    number: '$_resolvedCount',
                    label: 'Selesai',
                    badgeText: 'Total',
                    badgeBg: const Color(0xFFBAF0FD),
                    badgeTextColor: const Color(0xFF00758F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Filter Pills (Dinamis label)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTicketFilterPill(title: 'Semua (${_tickets.length})', index: 0),
                  const SizedBox(width: 8),
                  _buildTicketFilterPill(title: 'Terbuka ($_openCount)', index: 1),
                  const SizedBox(width: 8),
                  _buildTicketFilterPill(title: 'Proses ($_inProgressCount)', index: 2),
                  const SizedBox(width: 8),
                  _buildTicketFilterPill(title: 'Selesai ($_resolvedCount)', index: 3),
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
                    Icon(Icons.build_circle_outlined, size: 48, color: Color(0xFF94A3B8)),
                    SizedBox(height: 10),
                    Text('Tidak ada tiket kerusakan.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                    SizedBox(height: 4),
                    Text('Semua fasilitas berjalan normal.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
              )
            else
              ..._filteredTickets.map((t) => _buildTicketCard(t)),

            const SizedBox(height: 14),

            // Tombol Lapor Kerusakan Baru
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => showLaporKerusakanModal(context),
                icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                label: const Text('+ Lapor Kerusakan Baru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
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

  // ---------------------------------------------------------------------------
  // Card Tiket Kerusakan (Dinamis)
  // ---------------------------------------------------------------------------
  Widget _buildTicketCard(MaintenanceTicketModel t) {
    final isOpen = t.status == MaintenanceStatus.open;
    final isInProgress = t.status == MaintenanceStatus.inProgress;
    final isDone = !isOpen && !isInProgress;

    final priorityColor = t.priority == MaintenancePriority.critical || t.priority == MaintenancePriority.urgent
        ? const Color(0xFFDC2626)
        : t.priority == MaintenancePriority.high
            ? const Color(0xFFD97706)
            : const Color(0xFF6D28D9);
    final priorityBg = t.priority == MaintenancePriority.critical || t.priority == MaintenancePriority.urgent
        ? const Color(0xFFFEE2E2)
        : t.priority == MaintenancePriority.high
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFEDE9FE);

    final statusBg = isDone
        ? const Color(0xFFEEF2FE)
        : isInProgress
            ? const Color(0xFFBAF0FD)
            : const Color(0xFFFEE2E2);
    final statusFg = isDone
        ? const Color(0xFF1E40AF)
        : isInProgress
            ? const Color(0xFF006D84)
            : const Color(0xFFDC2626);
    final statusLabel = isDone ? 'Resolved' : isInProgress ? 'In Progress' : 'Terbuka';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID & badge prioritas & status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    t.roomNumber != null ? '#KMR-${t.roomNumber}' : '#TKT-${t.id}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF00758F)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: priorityBg, borderRadius: BorderRadius.circular(6)),
                    child: Text(t.priority.displayName, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: priorityColor)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isDone) const Icon(Icons.check, color: Color(0xFF1E40AF), size: 10),
                    if (isDone) const SizedBox(width: 3),
                    Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusFg)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Judul
          Text(
            t.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            t.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),

          // Info kamar & pelapor
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (t.roomNumber != null)
                  Row(
                    children: [
                      const Icon(Icons.bed_outlined, size: 14, color: Color(0xFF0284C7)),
                      const SizedBox(width: 6),
                      Text('Kamar #${t.roomNumber} • ${t.category}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                if (t.roomNumber != null) const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text('Pelapor: ${t.reportedByName}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
                if (t.assignedToName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.engineering_outlined, size: 14, color: Color(0xFF00758F)),
                      const SizedBox(width: 6),
                      Text('Dikerjakan: ${t.assignedToName}', style: const TextStyle(fontSize: 11, color: Color(0xFF00758F), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action buttons
          if (!isDone)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () => _showActionSnackbar('Memperbarui status tiket #${t.id}...'),
                      icon: const Icon(Icons.sync_rounded, size: 16, color: Color(0xFF00758F)),
                      label: const Text('Update', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFBAE6FD)),
                        backgroundColor: const Color(0xFFF1F5FD),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final newStatus = isOpen ? MaintenanceStatus.inProgress : MaintenanceStatus.resolved;
                        await MaintenanceService.instance.updateTicketStatus(t.id, newStatus);
                        _loadData();
                      },
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                      label: Text(
                        isOpen ? 'Proses' : 'Selesaikan',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00667C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else if (t.resolutionNotes != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                t.resolutionNotes!,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper widgets
  // ---------------------------------------------------------------------------
  Widget _buildTicketSummaryBox({
    required IconData icon,
    required String number,
    required String label,
    String? badgeText,
    Color? badgeBg,
    Color? badgeTextColor,
    bool hasDot = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF00758F)),
              if (badgeText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(badgeText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeTextColor)),
                ),
              ] else if (hasDot) ...[
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(number, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 1),
          Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildTicketFilterPill({required String title, required int index}) {
    final isSelected = _ticketFilterIndex == index;
    return InkWell(
      onTap: () => setState(() => _ticketFilterIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFBAF0FD) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF9AE5FA) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF006D84) : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
