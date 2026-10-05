// =============================================================================
// FILE: lib/apps/hotel_partner/screens/maintenance/maintenance_dashboard_screen.dart
// RESPONSIBILITY: Dashboard utama Staff Maintenance. Menampilkan daftar kamar
// yang membutuhkan perhatian, dikelompokkan berdasarkan status:
// - 'Dirty': Kamar baru checkout, menunggu dibersihkan
// - 'Cleaning': Kamar sedang dalam proses pembersihan
// Staff mengklaim tugas dan mengupdate status progress.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../router/hotel_router.dart';

/// Dashboard Maintenance Staff Go Ticket.
class MaintenanceDashboardScreen extends StatefulWidget {
  const MaintenanceDashboardScreen({super.key});

  @override
  State<MaintenanceDashboardScreen> createState() =>
      _MaintenanceDashboardScreenState();
}

class _MaintenanceDashboardScreenState
    extends State<MaintenanceDashboardScreen>
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
            Text('Maintenance', style: AppTextStyles.titleLarge),
            Text('Grand Hotel Example',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondaryLight)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Perlu Dibersihkan (5)'),
            Tab(text: 'Sedang Bersih (2)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDirtyRoomsList(),
          _buildCleaningRoomsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, HotelRouter.createTicket),
        icon: const Icon(Icons.report_problem_outlined),
        label: const Text('Lapor Kerusakan'),
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildDirtyRoomsList() {
    // TODO: Muat dari RoomRepository.getDirtyRooms()
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildRoomTaskCard(
        roomNumber: '10${index + 1}',
        roomType: index % 2 == 0 ? 'Standard Room' : 'Deluxe Room',
        floor: index < 3 ? 'Lantai 1' : 'Lantai 2',
        status: 'dirty',
        checkoutTime: '${8 + index}.00',
      ),
    );
  }

  Widget _buildCleaningRoomsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildRoomTaskCard(
        roomNumber: '20${index + 1}',
        roomType: 'Suite Room',
        floor: 'Lantai 2',
        status: 'cleaning',
        checkoutTime: '10.00',
      ),
    );
  }

  Widget _buildRoomTaskCard({
    required String roomNumber,
    required String roomType,
    required String floor,
    required String status,
    required String checkoutTime,
  }) {
    final isDirty = status == 'dirty';
    final color = isDirty ? AppColors.roomDirty : AppColors.roomCleaning;
    final statusLabel = isDirty ? 'Perlu Dibersihkan' : 'Sedang Dibersihkan';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDirty ? Icons.cleaning_services_outlined : Icons.hourglass_top_rounded,
                  color: color,
                  size: 22,
                ),
                Text(roomNumber,
                    style: AppTextStyles.labelSmall.copyWith(color: color)),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Info kamar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(roomType, style: AppTextStyles.titleSmall),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(statusLabel,
                          style: AppTextStyles.caption
                              .copyWith(color: color)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text('$floor • Checkout jam $checkoutTime',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),

          // Tombol ambil tugas / update status
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(
              context,
              HotelRouter.cleaningTask,
              arguments: {'roomNumber': roomNumber},
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isDirty ? 'Mulai' : 'Update',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
