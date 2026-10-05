// =============================================================================
// FILE: lib/apps/customer/screens/hotel_detail/room_selection_screen.dart
// RESPONSIBILITY: Halaman pemilihan kamar setelah Customer memilih hotel.
// Menampilkan:
// - Summary tanggal check-in / check-out (bisa diedit)
// - Daftar tipe kamar yang tersedia (dengan filter tersedia/tidak)
// - Detail tiap kamar: foto, fasilitas, kapasitas, harga
// - Tombol pilih kamar (navigasi ke kalender jika tanggal belum dipilih)
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../router/customer_router.dart';

/// Halaman pemilihan kamar hotel untuk Customer.
class RoomSelectionScreen extends StatefulWidget {
  final dynamic arguments;

  const RoomSelectionScreen({super.key, this.arguments});

  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  // TODO: Muat daftar kamar dari RoomRepository berdasarkan hotelId & tanggal

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pilih Kamar'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary tanggal & tamu yang dipilih
          _buildDateSummaryBar(),

          // Daftar kamar
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildRoomList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSummaryBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, CustomerRouter.calendar),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('05 Okt - 08 Okt 2026 • 3 malam',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.primary)),
                    Text('2 Tamu',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined,
                  size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomList() {
    // TODO: Ganti dengan data dari RoomRepository
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Placeholder 3 tipe kamar
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildRoomCard(index),
    );
  }

  Widget _buildRoomCard(int index) {
    final types = ['Standard Room', 'Deluxe Room', 'Suite Room'];
    final prices = ['Rp 350.000', 'Rp 550.000', 'Rp 900.000'];
    final capacities = ['2 Tamu', '2 Tamu', '4 Tamu'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto kamar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 140,
              color: AppColors.grey200,
              child: Center(
                child: Icon(Icons.bed_rounded, size: 48, color: AppColors.grey400),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(types[index], style: AppTextStyles.titleMedium),
                    if (index == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Terlaris',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.success)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Spesifikasi kamar
                Row(
                  children: [
                    _buildRoomSpec(Icons.people_outline_rounded, capacities[index]),
                    const SizedBox(width: 12),
                    _buildRoomSpec(Icons.king_bed_outlined, '1 King Bed'),
                    const SizedBox(width: 12),
                    _buildRoomSpec(Icons.square_foot_outlined, '28 m²'),
                  ],
                ),
                const SizedBox(height: 10),

                // Fasilitas singkat
                Wrap(
                  spacing: 6,
                  children: ['WiFi', 'AC', 'TV', 'Shower'].map((f) => Chip(
                    label: Text(f),
                    labelStyle: AppTextStyles.caption,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
                const SizedBox(height: 12),

                // Harga dan tombol pilih
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prices[index], style: AppTextStyles.priceMedium),
                        Text('per malam', style: AppTextStyles.caption),
                      ],
                    ),
                    GoTicketButton(
                      label: 'Pilih',
                      onPressed: () => Navigator.pushNamed(
                          context, CustomerRouter.guestDetail),
                      width: 100,
                      height: 40,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomSpec(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey400),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
