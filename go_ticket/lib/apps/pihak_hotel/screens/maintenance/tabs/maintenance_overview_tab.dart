import 'package:flutter/material.dart';
import '../../../../pihak_user/screens/auth/terms_and_policy_screen.dart';

/// Tab 1: Maintenance & Housekeeping Overview Dashboard
class MaintenanceOverviewTab extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const MaintenanceOverviewTab({super.key, this.onNavigateTab});

  @override
  State<MaintenanceOverviewTab> createState() => _MaintenanceOverviewTabState();
}

class _MaintenanceOverviewTabState extends State<MaintenanceOverviewTab> {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Prioritas Mendesak (Kamar #304)
          Container(
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
                                child: const Text(
                                  'PRIORITAS MENDESAK',
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Check-in 14:00 WITA',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                              children: [
                                TextSpan(text: 'Kamar #304 '),
                                TextSpan(
                                  text: '(Deluxe Ocean View)',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'Tamu: Bpk. Aditya Pratama',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Petugas & Est
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF0284C7)),
                        SizedBox(width: 4),
                        Text('Petugas: Budi Santoso', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    Text('Est. 13:45', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.78,
                    backgroundColor: Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status: Sedang Deep Clean (78%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
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
                            Text('Periksa Kamar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
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
          ),
          const SizedBox(height: 20),

          // Header Metrik Operasional Hari Ini
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Metrik Operasional Hari Ini',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              Text('Auto-sync 30d', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 12),

          // 2x2 Grid Metrik
          Row(
            children: [
              // Card 1: Perlu Dibersihkan
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.cleaning_services_outlined,
                  iconColor: const Color(0xFFDC2626),
                  iconBg: const Color(0xFFFEE2E2),
                  hasDot: true,
                  number: '5',
                  unit: 'Unit',
                  title: 'Perlu Dibersihkan',
                  subtitle: '2 Tamu Prioritas Check-in\n14:00',
                  subtitleColor: const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 12),
              // Card 2: Sedang Dikerjakan
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.hourglass_top_rounded,
                  iconColor: const Color(0xFFD97706),
                  iconBg: const Color(0xFFFEF3C7),
                  badgeText: 'Proses',
                  badgeBg: const Color(0xFFFEF3C7),
                  badgeTextColor: const Color(0xFFB45309),
                  number: '3',
                  unit: 'Unit',
                  title: 'Sedang Dikerjakan',
                  subtitle: 'Rata-rata 22 mnt/kamar',
                  subtitleColor: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Card 3: Kamar Siap Huni
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.verified_outlined,
                  iconColor: const Color(0xFF059669),
                  iconBg: const Color(0xFFD1FAE5),
                  badgeText: 'Inspected',
                  badgeBg: const Color(0xFFD1FAE5),
                  badgeTextColor: const Color(0xFF059669),
                  number: '14',
                  unit: 'Unit',
                  title: 'Kamar Siap Huni',
                  subtitle: 'Clean & Siap Check-in',
                  subtitleColor: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 12),
              // Card 4: Stok Logistik Tipis
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.inventory_2_outlined,
                  iconColor: const Color(0xFFE11D48),
                  iconBg: const Color(0xFFFFE4E6),
                  badgeText: 'Restock',
                  badgeBg: const Color(0xFFFFE4E6),
                  badgeTextColor: const Color(0xFFE11D48),
                  number: '2',
                  unit: 'Alert',
                  title: 'Stok Logistik Tipis',
                  subtitle: 'Sprei King (22) & Sabun Cair',
                  subtitleColor: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Header Monitor Kamar Terkini
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Monitor Kamar Terkini', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
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
              const Text('Lihat Semua (22)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
            ],
          ),
          const SizedBox(height: 12),

          // List Kamar Terkini 1: Kamar #205 (Dirty / Check-out)
          Container(
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
                        const Text('Kamar #205', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Dirty / Check-out', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
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
                      child: const Icon(Icons.bed_outlined, color: Color(0xFF64748B), size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('Standard Suite • Check-out 10 mnt lalu', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                        SizedBox(width: 4),
                        Text('Est. Turnaround: 30 menit', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => widget.onNavigateTab?.call(1),
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                      label: const Text('Mulai Bersihkan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
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
          ),
          const SizedBox(height: 12),

          // List Kamar Terkini 2: Kamar #304 (Siap Inspeksi)
          Container(
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
                        const Text('Kamar #304', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Siap Inspeksi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
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
                      child: const Icon(Icons.checklist_rounded, color: Color(0xFF64748B), size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('Deluxe Twin • Selesai oleh Siti R.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.checklist_rtl_rounded, size: 14, color: Color(0xFF059669)),
                        SizedBox(width: 4),
                        Text('Form 12 Titik Sanitasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showActionSnackbar('Membuka Form Inspeksi Kamar #304...'),
                      icon: const Icon(Icons.verified_outlined, color: Colors.white, size: 16),
                      label: const Text('Inspeksi & Approve', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
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
          ),
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

  // ===========================================================================
  // TAB 2: KEBERSIHAN (Foto 1)
  // ===========================================================================

}
