// =============================================================================
// FILE: lib/apps/customer/screens/hotel_detail/hotel_detail_screen.dart
// RESPONSIBILITY: Halaman detail hotel yang dipilih Customer.
// Menampilkan:
// - Galeri foto hotel (header dengan carousel)
// - Informasi hotel: nama, rating, lokasi, deskripsi
// - Daftar fasilitas / amenities
// - Tombol navigasi ke halaman pilih kamar
// - Review tamu sebelumnya
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../router/customer_router.dart';

/// Halaman detail hotel Go Ticket untuk Customer.
class HotelDetailScreen extends StatefulWidget {
  /// Argumen dari navigator — bisa berupa HotelModel atau String hotelId
  final dynamic arguments;

  const HotelDetailScreen({super.key, this.arguments});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  bool _isLoading = false;
  bool _isFavorite = false;
  int _currentImageIndex = 0;

  // TODO: Muat data hotel dari HotelRepository berdasarkan arguments

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Header — Galeri foto dan AppBar
          _buildSliverAppBar(),

          // Konten detail hotel
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHotelInfo(),
                const Divider(color: AppColors.grey200, height: 1),
                _buildAmenities(),
                const Divider(color: AppColors.grey200, height: 1),
                _buildDescription(),
                const Divider(color: AppColors.grey200, height: 1),
                _buildReviewsSummary(),
                const SizedBox(height: 100), // Padding bottom untuk sticky button
              ],
            ),
          ),
        ],
      ),

      // Sticky bottom bar — Harga + tombol pesan
      bottomNavigationBar: _buildStickyBookButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.white,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.grey900),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => setState(() => _isFavorite = !_isFavorite),
          icon: Icon(
            _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: _isFavorite ? AppColors.error : AppColors.grey900,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share_outlined, color: AppColors.grey900),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Gambar hotel placeholder
            Container(
              color: AppColors.grey200,
              child: const Center(
                child: Icon(Icons.hotel_rounded, size: 80, color: AppColors.grey400),
              ),
            ),
            // Indicator gambar
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '1/5',
                  style: AppTextStyles.caption.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bintang dan badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text('4.8 (245 ulasan)',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.warning,
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Bintang 4',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Nama hotel
          Text('Grand Hotel Example', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 6),

          // Lokasi
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.grey400),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Jl. Contoh No. 1, Jakarta Pusat, DKI Jakarta',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Check-in & Check-out time
          Row(
            children: [
              _buildTimeChip(Icons.login_rounded, 'Check-in: 14.00'),
              const SizedBox(width: 12),
              _buildTimeChip(Icons.logout_rounded, 'Check-out: 12.00'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey400),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildAmenities() {
    final amenities = ['WiFi Gratis', 'Kolam Renang', 'Parkir', 'AC', 'Restoran', 'Gym'];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fasilitas Hotel', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(a, style: AppTextStyles.labelSmall),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tentang Hotel', style: AppTextStyles.titleMedium),
          const SizedBox(height: 10),
          Text(
            'Grand Hotel Example adalah hotel bintang 4 yang terletak di jantung kota Jakarta. '
            'Menawarkan kenyamanan premium dengan fasilitas lengkap dan pelayanan terbaik '
            'untuk perjalanan bisnis maupun liburan keluarga Anda.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSummary() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ulasan Tamu', style: AppTextStyles.titleMedium),
              TextButton(
                onPressed: () {},
                child: Text('Lihat Semua',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Placeholder review list — akan diisi dengan ReviewModel',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildStickyBookButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mulai dari', style: AppTextStyles.caption),
                Text('Rp 350.000', style: AppTextStyles.priceMedium),
                Text('per malam', style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GoTicketButton(
              label: 'Pilih Kamar',
              onPressed: () =>
                  Navigator.pushNamed(context, CustomerRouter.roomSelection),
              icon: Icons.bed_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
