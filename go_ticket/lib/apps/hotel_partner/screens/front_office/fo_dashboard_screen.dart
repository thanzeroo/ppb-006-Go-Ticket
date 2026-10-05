// =============================================================================
// FILE: lib/apps/hotel_partner/screens/front_office/fo_dashboard_screen.dart
// RESPONSIBILITY: Dashboard utama Staff Front Office (FO). Menampilkan:
// - Ringkasan hari ini: expected arrivals, expected departures
// - Status kamar real-time (grid overview)
// - Daftar tamu yang akan check-in hari ini
// - Daftar tamu yang akan check-out hari ini
// - Akses cepat ke QR Scanner dan verifikasi booking
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../router/hotel_router.dart';

/// Dashboard Staff Front Office Go Ticket.
class FoDashboardScreen extends StatefulWidget {
  const FoDashboardScreen({super.key});

  @override
  State<FoDashboardScreen> createState() => _FoDashboardScreenState();
}

class _FoDashboardScreenState extends State<FoDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Front Office', style: AppTextStyles.titleLarge),
            Text('Grand Hotel Example',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondaryLight)),
          ],
        ),
        actions: [
          // Quick action: QR Scanner
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, HotelRouter.qrScanCheckin),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Scan QR Check-in',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Kedatangan'),
            Tab(text: 'Keberangkatan'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary statistik hari ini
          _buildDailySummaryBar(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildArrivalsList(),
                _buildDeparturesList(),
              ],
            ),
          ),
        ],
      ),

      // FAB: Scan QR
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, HotelRouter.qrScanCheckin),
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Scan Check-in'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildDailySummaryBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildStatCard('Expected Arrivals', '12', AppColors.info,
              Icons.login_rounded),
          const SizedBox(width: 12),
          _buildStatCard('Expected Departures', '8', AppColors.warning,
              Icons.logout_rounded),
          const SizedBox(width: 12),
          _buildStatCard('Menunggu Verifikasi', '3', AppColors.error,
              Icons.pending_actions_rounded),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style:
                    AppTextStyles.headlineSmall.copyWith(color: color)),
            Text(label,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
                maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildArrivalsList() {
    // TODO: Muat data dari BookingRepository.getHotelBookings(status: 'confirmed')
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildArrivalCard(index),
    );
  }

  Widget _buildArrivalCard(int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Avatar inisial tamu
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('JD',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 12),

          // Informasi tamu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('John Doe ${index + 1}',
                    style: AppTextStyles.titleSmall),
                Text('Standard Room • 3 Malam',
                    style: AppTextStyles.bodySmall),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: index == 0
                            ? AppColors.warningLight
                            : AppColors.infoLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        index == 0 ? 'Menunggu Verifikasi' : 'Dikonfirmasi',
                        style: AppTextStyles.caption.copyWith(
                          color: index == 0
                              ? AppColors.warning
                              : AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tombol aksi
          Column(
            children: [
              if (index == 0)
                IconButton(
                  onPressed: () => Navigator.pushNamed(
                      context, HotelRouter.verifyBooking),
                  icon: const Icon(Icons.verified_outlined,
                      color: AppColors.warning),
                  tooltip: 'Verifikasi',
                )
              else
                IconButton(
                  onPressed: () => Navigator.pushNamed(
                      context, HotelRouter.qrScanCheckin),
                  icon: const Icon(Icons.qr_code_scanner_rounded,
                      color: AppColors.info),
                  tooltip: 'Scan Check-in',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeparturesList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildDepartureCard(index),
    );
  }

  Widget _buildDepartureCard(int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('AS',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.warning)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ahmad Santoso ${index + 1}',
                    style: AppTextStyles.titleSmall),
                Text('Deluxe Room • Kamar 201',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, HotelRouter.checkout),
            icon: const Icon(Icons.exit_to_app_rounded,
                color: AppColors.warning),
            tooltip: 'Proses Checkout',
          ),
        ],
      ),
    );
  }
}
