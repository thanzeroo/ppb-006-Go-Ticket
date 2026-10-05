// =============================================================================
// FILE: lib/apps/hotel_partner/screens/front_office/checkout_process_screen.dart
// RESPONSIBILITY: Halaman proses check-out tamu oleh Staff FO.
// Staff memeriksa kondisi kamar sebelum checkout:
// - Apakah ada kerusakan fasilitas?
// - Apakah ada penggunaan minibar / layanan tambahan?
// Setelah checkout dikonfirmasi:
// - Status booking → 'checkedOut'
// - Status kamar → 'Dirty' (perlu dibersihkan)
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

/// Halaman proses check-out tamu oleh Staff FO.
class CheckoutProcessScreen extends StatefulWidget {
  final dynamic arguments;

  const CheckoutProcessScreen({super.key, this.arguments});

  @override
  State<CheckoutProcessScreen> createState() => _CheckoutProcessScreenState();
}

class _CheckoutProcessScreenState extends State<CheckoutProcessScreen> {
  bool _hasDamage = false;
  bool _hasMinibarUsage = false;
  bool _isProcessing = false;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    setState(() => _isProcessing = true);
    // TODO: Integrasikan dengan BookingRepository.processCheckout()
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _showCheckoutSuccess();
  }

  void _showCheckoutSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout_rounded,
                color: AppColors.warning, size: 56),
            const SizedBox(height: 16),
            Text('Check-out Berhasil!', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            const Text('Kamar 101 sekarang berstatus "Perlu Dibersihkan".',
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Proses Check-out')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info tamu
          _buildGuestInfo(),
          const SizedBox(height: 16),

          // Pemeriksaan kondisi kamar
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.grey200),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pemeriksaan Kamar', style: AppTextStyles.titleMedium),
                const SizedBox(height: 16),

                // Cek kerusakan
                SwitchListTile(
                  value: _hasDamage,
                  onChanged: (v) => setState(() => _hasDamage = v),
                  title: Text('Ada Kerusakan Fasilitas',
                      style: AppTextStyles.labelMedium),
                  subtitle: Text('Aktifkan jika ditemukan kerusakan',
                      style: AppTextStyles.bodySmall),
                  activeColor: AppColors.error,
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(color: AppColors.grey200),

                // Cek minibar
                SwitchListTile(
                  value: _hasMinibarUsage,
                  onChanged: (v) => setState(() => _hasMinibarUsage = v),
                  title: Text('Ada Penggunaan Minibar/Layanan Tambahan',
                      style: AppTextStyles.labelMedium),
                  subtitle: Text('Aktifkan jika ada tagihan tambahan',
                      style: AppTextStyles.bodySmall),
                  activeColor: AppColors.warning,
                  contentPadding: EdgeInsets.zero,
                ),

                // Catatan checkout
                const SizedBox(height: 12),
                GoTicketTextField(
                  label: 'Catatan (opsional)',
                  hint: 'Deskripsi kerusakan atau penggunaan minibar...',
                  controller: _notesController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notifikasi ke Maintenance
          if (_hasDamage || _hasMinibarUsage)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Laporan akan dikirim ke Tim Maintenance secara otomatis.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          GoTicketButton(
            label: 'Konfirmasi Check-out',
            onPressed: _isProcessing ? null : _processCheckout,
            isLoading: _isProcessing,
            icon: Icons.logout_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestInfo() {
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
          Text('Informasi Tamu', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          _buildRow('Nama', 'Ahmad Santoso'),
          _buildRow('Kamar', 'Deluxe Room - No. 201'),
          _buildRow('Check-in', '03 Oktober 2026'),
          _buildRow('Check-out', '05 Oktober 2026 (Hari ini)'),
          _buildRow('Durasi', '2 Malam'),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
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
}
