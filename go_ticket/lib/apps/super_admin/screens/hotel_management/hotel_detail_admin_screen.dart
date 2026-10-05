// =============================================================================
// FILE: lib/apps/super_admin/screens/hotel_management/hotel_detail_admin_screen.dart
// RESPONSIBILITY: Halaman detail hotel dari perspektif Super Admin.
// Menampilkan informasi lengkap hotel mitra:
// - Profil dan data hotel
// - Statistik performa hotel (booking, rating, pendapatan)
// - Riwayat payout dan komisi yang sudah dibayar
// - Tombol aksi: Approve, Suspend, Ubah Komisi
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';

/// Halaman detail hotel mitra untuk Super Admin.
class HotelDetailAdminScreen extends StatelessWidget {
  final dynamic arguments;

  const HotelDetailAdminScreen({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Detail Hotel Mitra'),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'suspend', child: Text('🚫 Suspend Hotel')),
              PopupMenuItem(value: 'commission', child: Text('💰 Ubah Komisi')),
            ],
            onSelected: (v) {
              if (v == 'suspend') _showSuspendDialog(context);
              if (v == 'commission') _showCommissionDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel profile header
            _buildHotelHeader(),
            const SizedBox(height: 16),

            // Status dan komisi
            _buildStatusCard(),
            const SizedBox(height: 16),

            // Statistik performa
            _buildPerformanceStats(),
            const SizedBox(height: 16),

            // Info pendaftaran
            _buildRegistrationInfo(),
            const SizedBox(height: 16),

            // Aksi Super Admin
            _buildAdminActions(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.hotel_rounded,
                color: AppColors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grand Hotel Example',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.white)),
                Text('Bintang 4 • Jakarta Pusat',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 6),
                Text('ID: HTL-001 | Terdaftar: Jan 2025',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status Platform', style: AppTextStyles.bodySmall),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text('Aktif', style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.success)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Komisi Platform', style: AppTextStyles.bodySmall),
                Text('10%', style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rating', style: AppTextStyles.bodySmall),
                Text('⭐ 4.8', style: AppTextStyles.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats() {
    final stats = [
      ('Total Booking', '245'),
      ('Total Pendapatan', CurrencyFormatter.toRupiah(312000000)),
      ('Komisi Diterima', CurrencyFormatter.toRupiah(31200000)),
      ('Payout Tersalurkan', CurrencyFormatter.toRupiah(280000000)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistik Performa', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ...stats.map((s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.$1, style: AppTextStyles.bodySmall),
                Text(s.$2, style: AppTextStyles.labelMedium),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRegistrationInfo() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Pendaftaran', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          _buildInfoRow('Nama PIC', 'Budi Santoso'),
          _buildInfoRow('Email Bisnis', 'manager@grandhotelexample.com'),
          _buildInfoRow('No. HP PIC', '08123456789'),
          _buildInfoRow('Nama Bank', 'BCA'),
          _buildInfoRow('No. Rekening', '1234567890'),
          _buildInfoRow('Atas Nama', 'PT Grand Hotel Indonesia'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Column(
      children: [
        GoTicketButton(
          label: 'Suspend Hotel',
          onPressed: () => _showSuspendDialog(context),
          backgroundColor: AppColors.error,
          icon: Icons.block_rounded,
        ),
        const SizedBox(height: 10),
        GoTicketOutlinedButton(
          label: 'Ubah Persentase Komisi',
          onPressed: () => _showCommissionDialog(context),
          icon: Icons.percent_rounded,
        ),
      ],
    );
  }

  void _showSuspendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Suspend Hotel?'),
        content: const Text(
            'Hotel ini akan dinonaktifkan dari platform. '
            'Customer tidak dapat memesan hingga hotel diaktifkan kembali.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showCommissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ubah Komisi'),
        content: const TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Persentase Komisi (%)',
            hintText: 'Masukkan 5-20',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Simpan')),
        ],
      ),
    );
  }
}
