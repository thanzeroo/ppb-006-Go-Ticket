// =============================================================================
// FILE: lib/apps/customer/screens/dashboard/customer_dashboard_screen.dart
// RESPONSIBILITY: Halaman utama Customer App — Dashboard pencarian dan
// rekomendasi hotel. Menampilkan:
// - Search bar untuk mencari hotel berdasarkan kota / nama
// - Filter cepat (kategori: Budget, Bintang 4+, dll.)
// - Banner promo / featured deals
// - Rekomendasi hotel berdasarkan lokasi / popularitas
// - Riwayat pencarian terakhir
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../router/customer_router.dart';

/// Dashboard utama Customer App Go Ticket.
/// Menampilkan pencarian, promo, dan rekomendasi hotel.
class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  /// Index tab bottom navigation yang aktif
  int _currentNavIndex = 0;

  /// Apakah sedang memuat data hotel
  final bool _isLoadingHotels = false;

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildSearchTab();
      case 2:
        return _buildBookingsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  // ---------------------------------------------------------------------------
  // HOME TAB — Rekomendasi dan hotel populer
  // ---------------------------------------------------------------------------

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        // App bar dengan search field
        SliverAppBar(
          expandedHeight: 180,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeaderBanner(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, CustomerRouter.hotelDetail),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: AppColors.grey400, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Cari hotel, kota, atau destinasi...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Konten utama
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Quick filter chips
              _buildQuickFilters(),
              const SizedBox(height: 24),

              // Section: Promo banner
              _buildSectionHeader('Promo Spesial 🔥', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildPromoBanner(),
              const SizedBox(height: 24),

              // Section: Hotel Populer
              _buildSectionHeader('Hotel Populer', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildHotelGrid(),
              const SizedBox(height: 24),

              // Section: Destinasi Pilihan
              _buildSectionHeader('Destinasi Pilihan', onSeeAll: () {}),
              const SizedBox(height: 12),
              _buildDestinationList(),
              const SizedBox(height: 80), // Bottom nav padding
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, Selamat Datang 👋',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    'Go Ticket',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    final filters = ['Semua', 'Hotel Bintang 4+', 'Budget', 'Kolam Renang', 'Sarapan'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return FilterChip(
            label: Text(filters[index]),
            selected: isSelected,
            onSelected: (_) {},
            backgroundColor: AppColors.grey100,
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
            labelStyle: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text('Lihat Semua',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.primary)),
          ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: AppColors.secondaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Hemat 30% Weekend Ini!',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                    )),
                const SizedBox(height: 4),
                Text('Gunakan kode: WEEKEND30',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    )),
              ],
            ),
          ),
          const Icon(Icons.local_offer_rounded,
              size: 48, color: AppColors.white),
        ],
      ),
    );
  }

  Widget _buildHotelGrid() {
    if (_isLoadingHotels) {
      return const SizedBox(
        height: 200,
        child: GoTicketLoadingIndicator(message: 'Memuat hotel...'),
      );
    }

    // TODO: Ganti dengan data dari HotelRepository
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: 4, // Placeholder 4 card
      itemBuilder: (context, index) => _buildHotelCard(index),
    );
  }

  Widget _buildHotelCard(int index) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, CustomerRouter.hotelDetail),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar hotel placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 120,
                color: AppColors.grey200,
                child: const Center(
                  child: Icon(Icons.hotel_rounded,
                      size: 40, color: AppColors.grey400),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hotel Example ${index + 1}',
                      style: AppTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.grey400),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text('Jakarta',
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Rp 350.000',
                      style: AppTextStyles.priceSmall),
                  Text('per malam',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationList() {
    final destinations = ['Jakarta', 'Bali', 'Yogyakarta', 'Bandung', 'Surabaya'];
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: destinations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_city_rounded,
                      color: AppColors.primary, size: 24),
                  const SizedBox(height: 6),
                  Text(destinations[index],
                      style: AppTextStyles.labelSmall,
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OTHER TABS — Placeholder
  // ---------------------------------------------------------------------------

  Widget _buildSearchTab() {
    return const Center(child: Text('Halaman Pencarian'));
  }

  Widget _buildBookingsTab() {
    return const Center(child: Text('Riwayat Booking'));
  }

  Widget _buildProfileTab() {
    return const Center(child: Text('Profil Saya'));
  }

  // ---------------------------------------------------------------------------
  // BOTTOM NAV BAR
  // ---------------------------------------------------------------------------

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: (index) => setState(() => _currentNavIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search_rounded),
          label: 'Cari',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}
