// =============================================================================
// FILE: lib/apps/hotel_partner/screens/front_office/verify_booking_screen.dart
// RESPONSIBILITY: Halaman verifikasi pembayaran booking oleh Staff FO.
// Staff memeriksa bukti transfer/pembayaran dari Customer dan mengubah
// status booking dari 'pendingVerification' menjadi 'confirmed'.
// Menampilkan:
// - Detail booking lengkap
// - Bukti pembayaran customer (jika ada foto upload)
// - Tombol konfirmasi atau tolak pembayaran
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

/// Halaman verifikasi pembayaran booking oleh Staff FO.
class VerifyBookingScreen extends StatefulWidget {
  final dynamic arguments;

  const VerifyBookingScreen({super.key, this.arguments});

  @override
  State<VerifyBookingScreen> createState() => _VerifyBookingScreenState();
}

class _VerifyBookingScreenState extends State<VerifyBookingScreen> {
  bool _isVerifying = false;
  bool _isRejecting = false;

  Future<void> _confirmPayment() async {
    setState(() => _isVerifying = true);
    // TODO: Integrasikan dengan BookingRepository.verifyPayment()
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isVerifying = false);
    _showSuccessDialog('Pembayaran berhasil dikonfirmasi!',
        'Status booking diubah menjadi Dikonfirmasi.');
  }

  Future<void> _rejectPayment() async {
    setState(() => _isRejecting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isRejecting = false);
    Navigator.pop(context);
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 56),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke dashboard
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Verifikasi Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pending_actions_rounded,
                      size: 16, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Text('Menunggu Verifikasi',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.warning)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Detail booking
          _buildSection('Detail Booking', [
            _buildRow('Kode Booking', 'GT-20261005-001'),
            _buildRow('Nama Tamu', 'John Doe'),
            _buildRow('No. HP', '08123456789'),
            _buildRow('Hotel', 'Grand Hotel Example'),
            _buildRow('Kamar', 'Standard Room (No. 101)'),
            _buildRow('Check-in', '05 Oktober 2026'),
            _buildRow('Check-out', '08 Oktober 2026'),
            _buildRow('Durasi', '3 Malam'),
            _buildRow('Jumlah Tamu', '2 Tamu'),
          ]),
          const SizedBox(height: 16),

          // Detail pembayaran
          _buildSection('Detail Pembayaran', [
            _buildRow('Metode', 'BCA Virtual Account'),
            _buildRow('Total', 'Rp 1.050.000', isHighlight: true),
            _buildRow('Status Bayar', 'Sudah Dibayar'),
          ]),
          const SizedBox(height: 16),

          // Bukti pembayaran
          _buildSection('Bukti Pembayaran', [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined,
                        size: 48, color: AppColors.grey400),
                    SizedBox(height: 8),
                    Text('Foto Bukti Transfer'),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),

          // Tombol aksi
          GoTicketButton(
            label: 'Konfirmasi Pembayaran',
            onPressed: _isVerifying ? null : _confirmPayment,
            isLoading: _isVerifying,
            backgroundColor: AppColors.success,
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 10),
          GoTicketOutlinedButton(
            label: 'Tolak / Minta Bukti Ulang',
            onPressed: _isRejecting ? null : _rejectPayment,
            isLoading: _isRejecting,
            borderColor: AppColors.error,
            foregroundColor: AppColors.error,
            icon: Icons.cancel_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
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
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value,
              style: isHighlight
                  ? AppTextStyles.titleMedium
                      .copyWith(color: AppColors.primary)
                  : AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}
