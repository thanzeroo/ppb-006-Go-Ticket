import 'package:flutter/material.dart';
import '../../../../pihak_user/screens/auth/terms_and_policy_screen.dart';
import '../../../../../core/models/maintenance_ticket_model.dart';
import '../../../../../core/services/maintenance_service.dart';

/// Tab 1: Maintenance & Housekeeping Overview Dashboard
/// 100% dinamis dari Supabase – tidak ada data mockup.
class MaintenanceOverviewTab extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const MaintenanceOverviewTab({super.key, this.onNavigateTab});

  @override
  State<MaintenanceOverviewTab> createState() => _MaintenanceOverviewTabState();
}

class _MaintenanceOverviewTabState extends State<MaintenanceOverviewTab> {
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
      final data = await MaintenanceService.instance.getTickets();
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

  @override
  Widget build(BuildContext context) {
    return _buildDashboardTab();
  }

  Widget _buildDashboardTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C2FF)));
    }

    final openTickets = _tickets.where((t) => t.status == MaintenanceStatus.open).toList();
    final inProgressTickets = _tickets.where((t) => t.status == MaintenanceStatus.inProgress).toList();
    final resolvedTickets = _tickets.where((t) => t.status == MaintenanceStatus.resolved || t.status == MaintenanceStatus.closed).toList();

    // Ambil tiket paling urgent/prioritas untuk banner atas
    MaintenanceTicketModel? urgentTicket;
    if (inProgressTickets.isNotEmpty) {
      urgentTicket = inProgressTickets.first;
    } else if (openTickets.isNotEmpty) {
      urgentTicket = openTickets.first;
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Prioritas Mendesak (dari database)
            if (urgentTicket != null) ...[
              _buildUrgentBanner(urgentTicket),
              const SizedBox(height: 20),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0FFF4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_outline_rounded, color: Color(0xFF059669), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tidak ada tiket mendesak saat ini. Semua operasional berjalan normal.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Header Metrik Operasional Hari Ini
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Metrik Operasional',
                  style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                Text('Live DB', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
            const SizedBox(height: 12),

            // 2x2 Grid Metrik (Dinamis)
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.build_circle_outlined,
                    iconColor: const Color(0xFFDC2626),
                    iconBg: const Color(0xFFFEE2E2),
                    hasDot: openTickets.isNotEmpty,
                    number: '${openTickets.length}',
                    unit: 'Tiket',
                    title: 'Tiket Terbuka',
                    subtitle: openTickets.isEmpty ? 'Tidak ada tiket' : '${openTickets.length} belum ditangani',
                    subtitleColor: openTickets.isEmpty ? const Color(0xFF64748B) : const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.hourglass_top_rounded,
                    iconColor: const Color(0xFFD97706),
                    iconBg: const Color(0xFFFEF3C7),
                    badgeText: inProgressTickets.isNotEmpty ? 'Proses' : null,
                    badgeBg: const Color(0xFFFEF3C7),
                    badgeTextColor: const Color(0xFFB45309),
                    number: '${inProgressTickets.length}',
                    unit: 'Tiket',
                    title: 'Sedang Dikerjakan',
                    subtitle: inProgressTickets.isEmpty ? 'Tidak ada' : '${inProgressTickets.length} sedang proses',
                    subtitleColor: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.verified_outlined,
                    iconColor: const Color(0xFF059669),
                    iconBg: const Color(0xFFD1FAE5),
                    badgeText: resolvedTickets.isNotEmpty ? 'Selesai' : null,
                    badgeBg: const Color(0xFFD1FAE5),
                    badgeTextColor: const Color(0xFF059669),
                    number: '${resolvedTickets.length}',
                    unit: 'Tiket',
                    title: 'Tiket Selesai',
                    subtitle: resolvedTickets.isEmpty ? 'Belum ada' : 'Sudah diselesaikan',
                    subtitleColor: const Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.assessment_outlined,
                    iconColor: const Color(0xFF0284C7),
                    iconBg: const Color(0xFFE0F2FE),
                    number: '${_tickets.length}',
                    unit: 'Total',
                    title: 'Semua Tiket',
                    subtitle: 'Dari database',
                    subtitleColor: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Header Monitor Tiket Terkini
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Monitor Tiket Terkini', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Live', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                    ),
                  ],
                ),
                Text(
                  'Total ${_tickets.length}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0284C7)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List tiket atau empty state
            if (_tickets.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                alignment: Alignment.center,
                child: Column(
                  children: const [
                    Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 48),
                    SizedBox(height: 10),
                    Text('Tidak ada tiket maintenance.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                    SizedBox(height: 4),
                    Text('Semua unit berjalan normal.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
              )
            else
              ..._tickets.take(5).map((t) => _buildTicketCard(t)),

            const SizedBox(height: 18),

            // Tautan Syarat & Ketentuan
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TermsAndPolicyScreen()),
                  );
                },
                child: const Text(
                  'Syarat & Ketentuan (Terms & Policies)',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0284C7),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Banner Prioritas Mendesak (Dinamis dari DB)
  // ---------------------------------------------------------------------------
  Widget _buildUrgentBanner(MaintenanceTicketModel ticket) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ticket.priority.displayName.toUpperCase(),
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ticket.status.displayName,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ticket.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    if (ticket.roomNumber != null)
                      Text(
                        'Kamar #${ticket.roomNumber}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF0284C7)),
                  const SizedBox(width: 4),
                  Text(
                    'Pelapor: ${ticket.reportedByName}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              InkWell(
                onTap: () => widget.onNavigateTab?.call(1),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00667C),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      Text('Periksa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, color: Colors.white, size: 15),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card Tiket (Dinamis)
  // ---------------------------------------------------------------------------
  Widget _buildTicketCard(MaintenanceTicketModel t) {
    final statusBg = t.status == MaintenanceStatus.open
        ? const Color(0xFFFEE2E2)
        : t.status == MaintenanceStatus.inProgress
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFD1FAE5);
    final statusFg = t.status == MaintenanceStatus.open
        ? const Color(0xFFDC2626)
        : t.status == MaintenanceStatus.inProgress
            ? const Color(0xFFB45309)
            : const Color(0xFF059669);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    t.roomNumber != null ? 'Kamar #${t.roomNumber}' : 'ID #${t.id}',
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t.status.displayName,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusFg),
                    ),
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
                child: const Icon(Icons.build_outlined, color: Color(0xFF64748B), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(t.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(
            '${t.category} • Pelapor: ${t.reportedByName}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag_outlined, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    t.priority.displayName,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => widget.onNavigateTab?.call(2),
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                label: const Text('Detail', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00667C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    bool hasDot = false,
    String? badgeText,
    Color? badgeBg,
    Color? badgeTextColor,
    required String number,
    required String unit,
    required String title,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              if (hasDot) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                ),
              ] else if (badgeText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
