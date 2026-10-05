// =============================================================================
// FILE: lib/apps/super_admin/screens/dashboard/super_admin_dashboard_screen.dart
// RESPONSIBILITY: Dashboard utama Super Admin — overview seluruh platform
// Go Ticket. Menampilkan:
// - KPI Platform: Total hotel, total user, GMV (Gross Merchandise Value)
// - Grafik pertumbuhan booking mingguan/bulanan
// - Daftar payout pending yang perlu diproses
// - Alert/notifikasi sistem
// - Navigation sidebar (web-style)
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../super_admin/router/super_admin_router.dart';

/// Dashboard Super Admin Platform Go Ticket.
class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState
    extends State<SuperAdminDashboardScreen> {
  int _selectedNavIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard_rounded),
    _NavItem('Hotel Mitra', Icons.hotel_outlined, Icons.hotel_rounded),
    _NavItem('Transaksi', Icons.receipt_long_outlined,
        Icons.receipt_long_rounded),
    _NavItem('Payout', Icons.payments_outlined, Icons.payments_rounded),
    _NavItem('Pengaturan', Icons.settings_outlined, Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.grey950,
      body: isWide
          ? Row(
              children: [
                // Sidebar navigasi (web mode)
                _buildSidebar(),

                // Konten utama
                Expanded(child: _buildContent()),
              ],
            )
          : _buildContent(), // Mobile: tanpa sidebar
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedNavIndex,
              onDestinationSelected: (i) =>
                  setState(() => _selectedNavIndex = i),
              destinations: _navItems
                  .map((n) => NavigationDestination(
                      icon: Icon(n.icon),
                      selectedIcon: Icon(n.activeIcon),
                      label: n.label))
                  .toList(),
            ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220,
      color: AppColors.grey900,
      child: Column(
        children: [
          // Logo
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings_rounded,
                    color: AppColors.primary, size: 28),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Go Ticket',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.white)),
                    Text('Super Admin',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.grey800),
          const SizedBox(height: 8),

          // Nav items
          ..._navItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isSelected = _selectedNavIndex == i;
            return ListTile(
              leading: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected ? AppColors.primary : AppColors.grey400,
                size: 20,
              ),
              title: Text(
                item.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.grey400,
                ),
              ),
              selected: isSelected,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              onTap: () => setState(() => _selectedNavIndex = i),
            );
          }),

          const Spacer(),
          const Divider(color: AppColors.grey800),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout_rounded,
                color: AppColors.error, size: 20),
            title: Text('Logout',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.error)),
            onTap: () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedNavIndex) {
      case 0: return _buildDashboardContent();
      case 1: return _buildHotelManagementContent();
      case 2: return _buildTransactionContent();
      case 3: return _buildPayoutContent();
      default: return _buildDashboardContent();
    }
  }

  // ---------------------------------------------------------------------------
  // DASHBOARD CONTENT
  // ---------------------------------------------------------------------------

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Platform Dashboard',
                  style: AppTextStyles.headlineMedium),
              Text('Senin, 05 Oktober 2026',
                  style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 20),

          // KPI Grid
          _buildKpiGrid(),
          const SizedBox(height: 24),

          // Payout pending alerts
          _buildPendingPayoutsAlert(),
          const SizedBox(height: 24),

          // Platform chart (placeholder)
          _buildPlatformChart(),
        ],
      ),
    );
  }

  Widget _buildKpiGrid() {
    final kpis = [
      ('Hotel Aktif', '128', Icons.hotel_rounded, AppColors.primary),
      ('Total User', '4.521', Icons.people_rounded, AppColors.info),
      ('GMV Bulan Ini', CurrencyFormatter.toRupiah(1250000000),
          Icons.trending_up_rounded, AppColors.success),
      ('Payout Pending', '7', Icons.pending_actions_rounded, AppColors.warning),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.0,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        final kpi = kpis[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.grey900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey800),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kpi.$4.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(kpi.$3, color: kpi.$4, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(kpi.$2,
                        style: AppTextStyles.headlineMedium
                            .copyWith(color: AppColors.white)),
                    Text(kpi.$1,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.grey400)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingPayoutsAlert() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.pending_actions_rounded,
              color: AppColors.warning, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('7 Payout Menunggu Persetujuan',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.warning)),
                Text('Segera proses untuk menjaga kepercayaan mitra hotel.',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedNavIndex = 3),
            child: const Text('Lihat'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformChart() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey800),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking Platform — 7 Hari Terakhir',
              style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  [45, 62, 78, 55, 90, 104, 87].asMap().entries.map((e) {
                final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                final maxVal = 104.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(e.value.toString(),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.grey400)),
                    const SizedBox(height: 6),
                    Container(
                      width: 36,
                      height: (e.value / maxVal) * 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.5),
                            AppColors.primary,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(days[e.key],
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.grey400)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OTHER SECTIONS — Navigasi ke screen terpisah
  // ---------------------------------------------------------------------------

  Widget _buildHotelManagementContent() {
    return const Center(child: Text('Hotel List Screen — navigate via router'));
  }

  Widget _buildTransactionContent() {
    return const Center(child: Text('Transaction Monitoring — navigate via router'));
  }

  Widget _buildPayoutContent() {
    return const Center(child: Text('Payout Approval — navigate via router'));
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem(this.label, this.icon, this.activeIcon);
}
