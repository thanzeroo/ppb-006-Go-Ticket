// =============================================================================
// FILE: lib/apps/customer/screens/ticket/e_ticket_detail_screen.dart
// RESPONSIBILITY: Halaman E-Tiket digital yang ditunjukkan Customer saat
// Check-in di hotel. Menampilkan:
// - QR Code besar yang discan oleh Staff FO
// - Detail booking (nama, hotel, kamar, tanggal)
// - Status booking real-time
// - Tombol download / share tiket
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

/// Halaman E-Tiket untuk Check-in Customer.
class ETicketDetailScreen extends StatelessWidget {
  final dynamic arguments;

  const ETicketDetailScreen({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('E-Tiket'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status badge
            _buildStatusBadge(),
            const SizedBox(height: 20),

            // E-Tiket card
            _buildTicketCard(),
            const SizedBox(height: 20),

            // QR Code utama
            _buildQrCodeSection(),
            const SizedBox(height: 20),

            // Instruksi check-in
            _buildCheckinInstructions(),
            const SizedBox(height: 24),

            // Tombol aksi
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.statusConfirmed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.statusConfirmed),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 18, color: AppColors.statusConfirmed),
          const SizedBox(width: 6),
          Text('Booking Dikonfirmasi',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.statusConfirmed)),
        ],
      ),
    );
  }

  Widget _buildTicketCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header tiket — gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.hotel_rounded,
                    color: AppColors.white, size: 32),
                const SizedBox(height: 8),
                Text('Grand Hotel Example',
                    style: AppTextStyles.headlineSmall
                        .copyWith(color: AppColors.white)),
                Text('Jakarta Pusat, DKI Jakarta',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),

          // Dotted line divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _buildCircleClip(isLeft: true),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        (constraints.constrainWidth() / 8).floor(),
                        (_) => const SizedBox(width: 4, height: 1,
                            child: DecoratedBox(decoration: BoxDecoration(color: AppColors.grey300))),
                      ),
                    );
                  }),
                ),
                _buildCircleClip(isLeft: false),
              ],
            ),
          ),

          // Detail booking
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                _buildTicketRow('Nama Tamu', 'John Doe'),
                _buildTicketRow('Kode Booking', 'GT-20261005-001'),
                _buildTicketRow('Tipe Kamar', 'Standard Room'),
                _buildTicketRow('Check-in', '05 Oktober 2026, 14.00'),
                _buildTicketRow('Check-out', '08 Oktober 2026, 12.00'),
                _buildTicketRow('Jumlah Tamu', '2 Tamu'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleClip({required bool isLeft}) {
    return Transform.translate(
      offset: Offset(isLeft ? -12 : 12, 0),
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }

  Widget _buildQrCodeSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Tunjukkan QR ini saat Check-in',
              style: AppTextStyles.labelMedium),
          const SizedBox(height: 16),

          // QR Code placeholder — ganti dengan QrImageView dari package qr_flutter
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2_rounded,
                      size: 100, color: AppColors.grey800),
                  SizedBox(height: 8),
                  Text('QR Code', style: TextStyle(color: AppColors.grey400)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('GT-20261005-001',
              style: AppTextStyles.titleMedium.copyWith(
                letterSpacing: 2,
                color: AppColors.primary,
              )),
        ],
      ),
    );
  }

  Widget _buildCheckinInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.info),
              const SizedBox(width: 8),
              Text('Panduan Check-in',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.info)),
            ],
          ),
          const SizedBox(height: 10),
          ...[
            'Datang ke hotel pada jam check-in (14.00)',
            'Tunjukkan QR Code di atas kepada Staff Front Office',
            'Staff akan memindai QR untuk verifikasi',
            'Bawa dokumen identitas (KTP/Paspor)',
          ].map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.info)),
                    Expanded(
                      child: Text(step,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info,
                          )),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        GoTicketOutlinedButton(
          label: 'Unduh E-Tiket (PDF)',
          onPressed: () {},
          icon: Icons.picture_as_pdf_outlined,
        ),
        const SizedBox(height: 12),
        GoTicketTextButton(
          label: 'Kembali ke Beranda',
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          icon: Icons.home_outlined,
        ),
      ],
    );
  }
}
