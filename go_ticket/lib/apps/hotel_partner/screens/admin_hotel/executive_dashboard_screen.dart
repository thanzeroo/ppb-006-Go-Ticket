// =============================================================================
// FILE: lib/apps/hotel_partner/screens/admin_hotel/executive_dashboard_screen.dart
// RESPONSIBILITY: Dashboard eksekutif untuk Admin Hotel (Manager/Owner).
// Menampilkan grafik dan metrik bisnis hotel secara real-time:
// - Tingkat okupansi hari ini dan trend mingguan
// - Total pendapatan bulan ini vs bulan lalu
// - Grafik booking harian (bar chart)
// - Status kamar overview (pie/donut chart)
// - Shortcut ke menu manajemen
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../router/hotel_router.dart';

/// Dashboard eksekutif Admin Hotel Go Ticket.
class ExecutiveDashboardScreen extends StatefulWidget {
  const ExecutiveDashboardScreen({super.key});

  @override
  State<ExecutiveDashboardScreen> createState() =>
      _ExecutiveDashboardScreenState();
}

class _ExecutiveDashboardScreenState extends State<ExecutiveDashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildDashboardTab(),
          _buildBookingsTab(),
          _buildRoomsTab(),
          _buildMoreTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room_outlined),
            activeIcon: Icon(Icons.meeting_room_rounded),
            label: 'Kamar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_rounded),
            label: 'Lainnya',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DASHBOARD TAB
  // ---------------------------------------------------------------------------

  Widget _buildDashboardTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 120,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient),
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Grand Hotel Example',
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: AppColors.white)),
                  Text('Senin, 05 Oktober 2026',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.white),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // KPI Cards
              _buildKpiGrid(),
              const SizedBox(height: 20),

              // Grafik Booking Mingguan (Placeholder)
              _buildChartCard(),
              const SizedBox(height: 20),

              // Status Kamar
              _buildRoomStatusCard(),
              const SizedBox(height: 20),

              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiGrid() {
    final kpis = [
      _KpiItem('Okupansi', '78%', Icons.hotel_outlined,
          AppColors.primary, '+5%'),
      _KpiItem('Pendapatan\nBulan Ini', 'Rp 42jt', Icons.payments_outlined,
          AppColors.success, '+12%'),
      _KpiItem('Booking\nHari Ini', '12', Icons.book_online_outlined,
          AppColors.info, '+3'),
      _KpiItem('Penilaian\nRata-rata', '4.8 ⭐', Icons.star_outline_rounded,
          AppColors.warning, '0'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) => _buildKpiCard(kpis[index]),
    );
  }

  Widget _buildKpiCard(_KpiItem kpi) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(kpi.icon, color: kpi.color, size: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(kpi.change,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.success)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(kpi.value,
                  style: AppTextStyles.headlineSmall.copyWith(color: kpi.color)),
              Text(kpi.label,
                  style: AppTextStyles.caption, maxLines: 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking 7 Hari Terakhir',
              style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [5, 8, 12, 7, 15, 10, 12].asMap().entries.map((e) {
                final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                final maxVal = 15.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(e.value.toString(), style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: (e.value / maxVal) * 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.7 + (e.value / maxVal) * 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(days[e.key], style: AppTextStyles.caption),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomStatusCard() {
    final statuses = [
      ('Tersedia', 15, AppColors.roomAvailable),
      ('Ditempati', 20, AppColors.roomOccupied),
      ('Kotor', 5, AppColors.roomDirty),
      ('Maintenance', 2, AppColors.roomMaintenance),
    ];
    final total = statuses.fold(0, (sum, s) => sum + s.$2);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Kamar (Total: $total)', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          // Progress bar kamar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 20,
              child: Row(
                children: statuses.map((s) {
                  return Expanded(
                    flex: s.$2,
                    child: Container(color: s.$3),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: statuses.map((s) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                          color: s.$3, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('${s.$1}: ${s.$2}', style: AppTextStyles.caption),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      ('Kelola Karyawan', Icons.people_outline_rounded,
          HotelRouter.employeeManagement),
      ('Harga Kamar', Icons.price_change_outlined, HotelRouter.roomPricing),
      ('Laporan Keuangan', Icons.account_balance_outlined,
          HotelRouter.financialPayout),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Akses Cepat', style: AppTextStyles.titleMedium),
        const SizedBox(height: 10),
        Row(
          children: actions.map((a) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, a.$3),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      children: [
                        Icon(a.$2, color: AppColors.primary, size: 24),
                        const SizedBox(height: 6),
                        Text(a.$1,
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                            maxLines: 2),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // OTHER TABS — Placeholder
  // ---------------------------------------------------------------------------

  Widget _buildBookingsTab() => const Center(child: Text('Daftar Booking Hotel'));
  Widget _buildRoomsTab() => const Center(child: Text('Manajemen Kamar'));
  Widget _buildMoreTab() => Column(
    children: [
      const SizedBox(height: 20),
      ListTile(
        leading: const Icon(Icons.people_outline_rounded),
        title: const Text('Manajemen Karyawan'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.pushNamed(context, HotelRouter.employeeManagement),
      ),
      ListTile(
        leading: const Icon(Icons.price_change_outlined),
        title: const Text('Harga & Diskon Kamar'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.pushNamed(context, HotelRouter.roomPricing),
      ),
      ListTile(
        leading: const Icon(Icons.account_balance_wallet_outlined),
        title: const Text('Laporan & Payout'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.pushNamed(context, HotelRouter.financialPayout),
      ),
    ],
  );
}

class _KpiItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String change;

  const _KpiItem(this.label, this.value, this.icon, this.color, this.change);
}
