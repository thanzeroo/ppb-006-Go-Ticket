import 'package:flutter/material.dart';

import '../../../pihak_user/screens/auth/terms_and_policy_screen.dart';

/// Dashboard Maintenance & Housekeeping Hotel
/// Berisi 3 Tab Utama:
/// 1. Dashboard (Prioritas Mendesak, Metrik Operasional, Monitor Kamar Terkini)
/// 2. Kebersihan (Papan Kebersihan Kamar, Filter Lantai, Status Antrean/Proses/Inspeksi, Checklist Sanitasi & Bukti QC)
/// 3. Kerusakan (Live Maintenance Hub, Tiket Kerusakan & Pemeliharaan, Status Pengerjaan, Tugas Teknisi)
/// Serta Modal / Form: Lapor Kerusakan Fasilitas (#MT-2025-088)
class MaintenanceDashboardScreen extends StatefulWidget {
  const MaintenanceDashboardScreen({super.key});

  @override
  State<MaintenanceDashboardScreen> createState() => _MaintenanceDashboardScreenState();
}

class _MaintenanceDashboardScreenState extends State<MaintenanceDashboardScreen> {
  int _currentTabIndex = 0;

  // State untuk Tab Kebersihan
  int _selectedFloorIndex = 0; // 0: Semua Lantai, 1: Lantai 1, 2: Lantai 2, 3: Lantai 3
  int _selectedStatusFilter = 0; // 0: Antrean (5), 1: Proses (3), 2: Siap Inspeksi (6)
  
  // Checklist kamar #304
  final List<bool> _checklistValues = [true, true, true, false, false, false];

  // State untuk Tab Kerusakan
  int _ticketFilterIndex = 0; // 0: Semua Tiket, 1: Pending (1), 2: In Progress (1)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopAppBar(),

            // Konten Sesuai Tab Aktif
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  _buildDashboardTab(),
                  _buildKebersihanTab(),
                  _buildKerusakanTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ===========================================================================
  // TOP APP BAR
  // ===========================================================================
  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFF00B4D8),
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Go Ticket Maintenance',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'The Grand Amora Resort • ',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C2FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'On-Duty: 6 Staf',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF0A5868),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: DASHBOARD (Foto 2)
  // ===========================================================================
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
                      onTap: () => setState(() => _currentTabIndex = 1),
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
                      onPressed: () => setState(() => _currentTabIndex = 1),
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
  Widget _buildKebersihanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Utama: Papan Kebersihan Kamar
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

          // Status Badges Bar: [● Antrean 5] [● Proses 3] [● Siap Inspeksi 6]
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
                    dotColor: const Color(0xFFDC2626),
                    title: 'Antrean',
                    count: 5,
                    isSelected: _selectedStatusFilter == 0,
                    onTap: () => setState(() => _selectedStatusFilter = 0),
                  ),
                ),
                Expanded(
                  child: _buildStatusFilterPill(
                    dotColor: const Color(0xFF00C2FF),
                    title: 'Proses',
                    count: 3,
                    isSelected: _selectedStatusFilter == 1,
                    onTap: () => setState(() => _selectedStatusFilter = 1),
                  ),
                ),
                Expanded(
                  child: _buildStatusFilterPill(
                    dotColor: const Color(0xFF00758F),
                    title: 'Siap Inspeksi',
                    count: 6,
                    isSelected: _selectedStatusFilter == 2,
                    onTap: () => setState(() => _selectedStatusFilter = 2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 1: Kamar #205 (Dirty / Checkout Baru)
          Container(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Kamar #205',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Dirty / Checkout Baru',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
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
                      child: const Icon(Icons.meeting_room_outlined, color: Color(0xFF0284C7), size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('Standard Suite • Lantai 2', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 14),

                // Petugas & Target Durasi Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFBAE6FD),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text('MW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Petugas', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                            Text('Made Wijaya', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF0284C7)),
                          SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target Durasi', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                              Text('30 Menit • Normal', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Tombol [Ganti] [Buka Checklist & Mulai]
                Row(
                  children: [
                    SizedBox(
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: () => _showActionSnackbar('Ganti penugasan kamar #205...'),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: Color(0xFF334155)),
                        label: const Text('Ganti', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          backgroundColor: const Color(0xFFF8FAFD),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () => _showActionSnackbar('Membuka checklist & memulai timer kamar #205...'),
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                          label: const Text('Buka Checklist & Mulai', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
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
          ),
          const SizedBox(height: 16),

          // Card 2: Kamar #304 (Sedang Dibersihkan 18:24) & Full Checklist
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kamar #304', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBAF0FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.circle, color: Color(0xFF00758F), size: 6),
                              SizedBox(width: 4),
                              Text('Sedang Dibersihkan (18:24)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006D84))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text('Deluxe Ocean View • Lantai 3', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A5868),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('BS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Progress Bar: 3 dari 6 selesai (50%)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Progres Kebersihan: 3 dari 6 selesai', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    Text('50%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Color(0xFFEEF2FE),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 16),

                // Checklist Sanitasi & Penataan
                const Text(
                  'Checklist Sanitasi & Penataan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),

                // 6 Checklist Items
                _buildChecklistItem(
                  index: 0,
                  title: 'Penggantian Bed Linen, Duvet & Sarung Bantal Baru',
                  subtitle: 'Selesai • Linen Putih Bersih',
                ),
                _buildChecklistItem(
                  index: 1,
                  title: 'Sanitasi Kamar Mandi, Toilet & Handuk Bersih',
                  subtitle: 'Selesai • Disinfeksi Area Basah',
                ),
                _buildChecklistItem(
                  index: 2,
                  title: 'Restock Amenities (Sikat gigi, sabun, sandal)',
                  subtitle: 'Selesai • Kit Kamar Mandi Lengkap',
                ),
                _buildChecklistItem(
                  index: 3,
                  title: 'Dusting Meja, Vacuum Karpet & Pel Lantai',
                  subtitle: 'Sedang proses pembersihan debu balkon',
                ),
                _buildChecklistItem(
                  index: 4,
                  title: 'Restock Minibar & 2 Botol Air Mineral Eco-Glass',
                  subtitle: 'Menunggu verifikasi segel botol',
                ),
                _buildChecklistItem(
                  index: 5,
                  title: 'Pengosongan Tempat Sampah & Cek Remote AC/TV',
                  subtitle: 'Cek baterai remote & sanitize unit',
                ),
                const SizedBox(height: 16),

                // Bukti Kerapian & Quality Control
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Bukti Kerapian & Quality Control', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    Text('1/2 Foto', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    // Foto 1: Ranjang Rapi
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(14),
                          image: const DecorationImage(
                            image: AssetImage('assets/logo_hotel.png'),
                            fit: BoxFit.cover,
                            opacity: 0.15,
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle_outline, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('Ranjang Rapi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Foto 2: Foto Kamar Mandi
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt_outlined, size: 24, color: Color(0xFF00C2FF)),
                            SizedBox(height: 4),
                            Text('Foto Kamar Mandi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tombol Tunda & Selesai & Siap Huni
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton(
                          onPressed: () => _showActionSnackbar('Pembersihan kamar #304 ditunda.'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            backgroundColor: const Color(0xFFF1F5FD),
                          ),
                          child: const Text('Tunda', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () => _showActionSnackbar('Kamar #304 Selesai & Siap Huni!'),
                          icon: const Icon(Icons.verified_outlined, color: Colors.white, size: 16),
                          label: const Text('Selesai & Siap Huni', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C2FF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tombol + Lapor Kerusakan
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _openLaporKerusakanModal(context),
                    icon: const Icon(Icons.build_circle_outlined, color: Colors.white, size: 18),
                    label: const Text('+ Lapor Kerusakan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C2FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
            Text(title, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: const Color(0xFF0F172A))),
            const SizedBox(width: 4),
            Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required int index,
    required String title,
    required String subtitle,
  }) {
    final isChecked = _checklistValues[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isChecked,
            activeColor: const Color(0xFF00C2FF),
            onChanged: (val) {
              setState(() {
                _checklistValues[index] = val ?? false;
              });
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isChecked ? const Color(0xFF334155) : const Color(0xFF0F172A),
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3: KERUSAKAN (Foto 3)
  // ===========================================================================
  Widget _buildKerusakanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subheader: LIVE MAINTENANCE HUB • Shift Pagi
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
                child: const Text('Shift Pagi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tiket Kerusakan & Pemeliharaan',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.4),
          ),
          const SizedBox(height: 14),

          // 3 Ringkasan Kotak: [Tiket Aktif] [Sparepart] [Selesai]
          Row(
            children: [
              Expanded(
                child: _buildTicketSummaryBox(
                  icon: Icons.build_circle_outlined,
                  number: '2',
                  label: 'Tiket Aktif',
                  badgeText: '1 Urgent',
                  badgeBg: const Color(0xFFFEE2E2),
                  badgeTextColor: const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTicketSummaryBox(
                  icon: Icons.inventory_2_outlined,
                  number: '1',
                  label: 'Sparepart',
                  hasDot: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTicketSummaryBox(
                  icon: Icons.verified_outlined,
                  number: '14',
                  label: 'Selesai',
                  badgeText: 'Minggu ini',
                  badgeBg: const Color(0xFFBAF0FD),
                  badgeTextColor: const Color(0xFF00758F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Filter Pills: [Semua Tiket] [Pending (1)] [In Progress (1)]
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTicketFilterPill(title: 'Semua Tiket', index: 0),
                const SizedBox(width: 8),
                _buildTicketFilterPill(title: 'Pending (1)', index: 1),
                const SizedBox(width: 8),
                _buildTicketFilterPill(title: 'In Progress (1)', index: 2),
                const SizedBox(width: 8),
                _buildTicketFilterPill(title: 'Resolved', index: 3),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // TIKET 1: #MT-402 (AC Kurang Dingin - In Progress)
          Container(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('#MT-402', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF00758F))),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Darurat / Tamu In-House', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBAF0FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.circle, color: Color(0xFF00758F), size: 6),
                          SizedBox(width: 4),
                          Text('In Progress', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006D84))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'AC Kurang Dingin (Suhu 27°C)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),

                // Lokasi Kamar & Tamu Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.bed_outlined, size: 14, color: Color(0xFF0284C7)),
                          SizedBox(width: 6),
                          Text('Kamar #204 — Deluxe Ocean View', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 6),
                          Text('Tamu in-house: Ir. Gunawan (Check-out tgl 16)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 6),
                          Text('Dilaporkan 08:15 WIB • Durasi: 45 mnt berjalan', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Info Teknisi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.engineering_outlined, size: 18, color: Color(0xFF00758F)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Hendra Wijaya (Teknisi Senior)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          SizedBox(height: 2),
                          Text(
                            'Status pengerjaan: Penggantian kapasitor 35uF & pengisian freon R32 di unit outdoor balkon.',
                            style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Buttons: [Update Status] [Selesaikan Tiket]
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () => _showActionSnackbar('Memperbarui status pengerjaan tiket #MT-402...'),
                          icon: const Icon(Icons.sync_rounded, size: 16, color: Color(0xFF00758F)),
                          label: const Text('Update Status', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
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
                          onPressed: () => _showActionSnackbar('Tiket #MT-402 Selesai & Ditutup!'),
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                          label: const Text('Selesaikan Tiket', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00667C),
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
          ),
          const SizedBox(height: 16),

          // TIKET 2: #MT-405 (Lampu Spot Balkon Berkedip & Mati)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                        const Text('#MT-405', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF475569))),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Urgensi Sedang', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF6D28D9))),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F4FB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Menunggu Sparepart', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lampu Spot Balkon Berkedip & Mati',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.bed_outlined, size: 14, color: Color(0xFF0284C7)),
                          SizedBox(width: 6),
                          Text('Kamar #310 — Standard Twin', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Driver LED 12V konslet kena uap embun laut. Menunggu restok gudang logistik.',
                              style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Teknisi: Belum Ditugaskan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                    Text('09:40 WIB', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _showActionSnackbar('Membuka penugasan teknisi untuk tiket #MT-405...'),
                    icon: const Icon(Icons.person_add_alt_outlined, color: Color(0xFF00758F), size: 17),
                    label: const Text('Tugaskan Teknisi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBAF0FD),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // TIKET 3: #MT-398 (Keran Shower Bocor - Resolved)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                        const Text('#MT-398', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Rendah', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check, color: Color(0xFF1E40AF), size: 12),
                          SizedBox(width: 4),
                          Text('Resolved', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keran Shower Bocor / ...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Kamar #102 • Suite Garden', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    Text('Selesai: Kemarin 16:30', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Dikerjakan oleh Teknisi Hendra. Penggantian rubber seal valve selesai dan telah dites tekanan air.',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

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

  // ===========================================================================
  // BOTTOM NAVIGATION BAR (Foto 1, 2, 3)
  // ===========================================================================
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00758F),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cleaning_services_outlined),
            activeIcon: Icon(Icons.cleaning_services_rounded),
            label: 'Kebersihan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build_rounded),
            label: 'Kerusakan',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FORM / MODAL LAPOR KERUSAKAN FASILITAS (Foto 4)
  // ===========================================================================
  void _openLaporKerusakanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.94,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header Lapor Kerusakan Fasilitas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    Image.asset(
                      'assets/logo.png',
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.confirmation_number_outlined, color: Color(0xFF00B4D8)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Lapor Kerusakan Fasilitas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          Text('The Grand Amora Resort & Spa', style: TextStyle(fontSize: 10.5, color: Color(0xFF0284C7))),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: Color(0xFF0A5868), shape: BoxShape.circle),
                      child: const Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge: #MT-2025-088 • Drafting
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFD),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Text('TIKET MAINTENANCE BARU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                    SizedBox(width: 6),
                                    Text('#MT-2025-088', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('● Drafting', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(Icons.engineering_outlined, size: 13, color: Color(0xFF0284C7)),
                                SizedBox(width: 4),
                                Text('Modul Engineering • Pelapor: Front Office Staff (Dewi)', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Step 1: Lokasi & Titik Kerusakan
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: const Text('1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                                ),
                                const SizedBox(width: 8),
                                const Text('Lokasi & Titik Kerusakan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('Nomor Kamar • Blok Villa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                                Text('Live PMS Sync', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Kamar #304 - Deluxe Ocean View (Lt. 3)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                  Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0284C7)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Step 4: Detail Keluhan Kerusakan
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: const Text('4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                                ),
                                const SizedBox(width: 8),
                                const Text('Detail Keluhan Kerusakan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('Judul Singkat Masalah', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('AC Menetes Air & Kurang Dingin (Suhu Tertahan di ...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                            ),
                            const SizedBox(height: 12),

                            const Text('Deskripsi Rinci Masalah • Temuan Front Office', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Tamu mengeluhkan ada tetesan air dari indoor unit AC mengalir ke meja samping ranjang, terdengar suara desis freon, filter kotor.',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.35),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // SOP Penanganan Khusus Tamu In-Room
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(Icons.notifications_active_outlined, size: 16, color: Color(0xFF0284C7)),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('SOP Penanganan Khusus Tamu In-Room', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                                        SizedBox(height: 2),
                                        Text(
                                          'Tamu sedang berada di dalam kamar. Wajib ketuk pintu sopan sesuai SOP perhotelan & bawa matras alas pelindung lantai.',
                                          style: TextStyle(fontSize: 10, color: Color(0xFF475569), height: 1.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Step 5: Lampiran Foto Lapangan (2 dari 3 Foto Terlampir)
                      Container(
                        padding: const EdgeInsets.all(14),
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
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
                                      alignment: Alignment.center,
                                      child: const Text('5', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Lampiran Foto Lapangan', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                                  ],
                                ),
                                const Text('2 dari 3 Foto\nTerlampir', textAlign: TextAlign.right, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                // Foto 1: Unit Indoor AC
                                Expanded(
                                  child: Container(
                                    height: 88,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF334155),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                                            child: const Icon(Icons.close, size: 13, color: Colors.white),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 6,
                                          left: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(4)),
                                            child: const Text('Unit Indoor AC', style: TextStyle(fontSize: 8.5, color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Foto 2: Rembesan Lantai
                                Expanded(
                                  child: Container(
                                    height: 88,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF475569),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                                            child: const Icon(Icons.close, size: 13, color: Colors.white),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 6,
                                          left: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(4)),
                                            child: const Text('Rembesan Lantai', style: TextStyle(fontSize: 8.5, color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Foto 3: Ambil Foto ke-3
                                Expanded(
                                  child: Container(
                                    height: 88,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.camera_alt_outlined, color: Color(0xFF00C2FF), size: 22),
                                        SizedBox(height: 3),
                                        Text('Ambil Foto ke-3', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Tombol Buka Kamera Ponsel Ops
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: OutlinedButton.icon(
                                onPressed: () => _showActionSnackbar('Membuka Kamera Ponsel Ops...'),
                                icon: const Icon(Icons.camera_alt_outlined, size: 16, color: Color(0xFF00758F)),
                                label: const Text('Buka Kamera Ponsel Ops', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFBAE6FD)),
                                  backgroundColor: const Color(0xFFF1F5FD),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar: [Batal / Reset] [Terbitkan • Kirim >]
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEEF2FE),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          child: const Text('Batal / Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showActionSnackbar('Tiket #MT-2025-088 Berhasil Diterbitkan ke Tim Engineering!');
                          },
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                          label: const Text('Terbitkan • Kirim', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C2FF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
}
