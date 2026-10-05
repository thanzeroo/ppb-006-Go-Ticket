// =============================================================================
// FILE: lib/apps/super_admin/screens/hotel_management/hotel_list_screen.dart
// RESPONSIBILITY: Halaman daftar semua hotel mitra di platform Go Ticket.
// Super Admin dapat melihat dan mengelola status hotel:
// - Filter berdasarkan status: Active, Pending Review, Suspended
// - Cari hotel berdasarkan nama / kota
// - Approve hotel baru
// - Suspend / Reaktivasi hotel
// - Navigasi ke detail hotel
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../router/super_admin_router.dart';

/// Halaman daftar hotel mitra untuk Super Admin.
class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  final List<String> _tabs = ['Semua', 'Aktif', 'Pending', 'Suspended'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Manajemen Hotel Mitra'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GoTicketTextField(
                  hint: 'Cari nama hotel atau kota...',
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                ),
              ),
              // Filter tabs
              TabBar(
                controller: _tabController,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
                isScrollable: true,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((_) => _buildHotelList()).toList(),
      ),
    );
  }

  Widget _buildHotelList() {
    // TODO: Muat dari HotelRepository dengan filter status
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildHotelCard(index),
    );
  }

  Widget _buildHotelCard(int index) {
    final statuses = ['active', 'active', 'pending', 'active', 'suspended',
        'active', 'pending', 'active'];
    final status = statuses[index % statuses.length];

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'active':
        statusColor = AppColors.success;
        statusLabel = 'Aktif';
        break;
      case 'pending':
        statusColor = AppColors.warning;
        statusLabel = 'Pending Review';
        break;
      case 'suspended':
        statusColor = AppColors.error;
        statusLabel = 'Suspended';
        break;
      default:
        statusColor = AppColors.grey400;
        statusLabel = 'Unknown';
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        SuperAdminRouter.hotelDetailAdmin,
        arguments: 'hotel-id-${index + 1}',
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey200),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Foto hotel placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 64,
                height: 64,
                color: AppColors.grey200,
                child: const Icon(Icons.hotel_rounded,
                    size: 30, color: AppColors.grey400),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hotel Example ${index + 1}',
                      style: AppTextStyles.titleSmall),
                  Text('Kota ${['Jakarta', 'Bali', 'Yogyakarta'][index % 3]}',
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(statusLabel,
                            style: AppTextStyles.caption
                                .copyWith(color: statusColor)),
                      ),
                      const SizedBox(width: 8),
                      Text('${18 + index} kamar',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),

            // Menu aksi
            PopupMenuButton<String>(
              onSelected: (action) {
                // TODO: Implementasi aksi (approve/suspend/reaktivasi)
              },
              itemBuilder: (_) => [
                if (status == 'pending')
                  const PopupMenuItem(
                    value: 'approve',
                    child: Text('✅ Approve Hotel'),
                  ),
                if (status == 'active')
                  const PopupMenuItem(
                    value: 'suspend',
                    child: Text('🚫 Suspend Hotel'),
                  ),
                if (status == 'suspended')
                  const PopupMenuItem(
                    value: 'activate',
                    child: Text('🔄 Aktifkan Kembali'),
                  ),
                const PopupMenuItem(
                  value: 'detail',
                  child: Text('📋 Lihat Detail'),
                ),
              ],
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
