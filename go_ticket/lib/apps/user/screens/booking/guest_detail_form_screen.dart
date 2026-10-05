// =============================================================================
// FILE: lib/apps/customer/screens/booking/guest_detail_form_screen.dart
// RESPONSIBILITY: Form data diri tamu saat proses booking. Menampilkan:
// - Summary booking (hotel, kamar, tanggal, harga)
// - Form data tamu: nama, nomor HP, email
// - Jumlah tamu (validasi tidak melebihi kapasitas kamar)
// - Field permintaan khusus (special request)
// - Input kode promo / voucher
// - Tombol lanjut ke pembayaran
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../router/customer_router.dart';

/// Form data diri tamu untuk proses booking hotel.
class GuestDetailFormScreen extends StatefulWidget {
  final dynamic arguments;

  const GuestDetailFormScreen({super.key, this.arguments});

  @override
  State<GuestDetailFormScreen> createState() => _GuestDetailFormScreenState();
}

class _GuestDetailFormScreenState extends State<GuestDetailFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _specialRequestController = TextEditingController();
  final _promoCodeController = TextEditingController();

  int _guestCount = 1;
  bool _isPromoApplied = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _specialRequestController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  void _incrementGuest() {
    if (_guestCount < 4) setState(() => _guestCount++);
  }

  void _decrementGuest() {
    if (_guestCount > 1) setState(() => _guestCount--);
  }

  Future<void> _applyPromoCode() async {
    // TODO: Validasi promo code ke API
    if (_promoCodeController.text.isNotEmpty) {
      setState(() => _isPromoApplied = true);
    }
  }

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pushNamed(context, CustomerRouter.payment, arguments: {
      'guestName': _nameController.text,
      'guestPhone': _phoneController.text,
      'guestEmail': _emailController.text,
      'guestCount': _guestCount,
      'specialRequest': _specialRequestController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Detail Tamu')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ringkasan booking
            _buildBookingSummaryCard(),
            const SizedBox(height: 16),

            // Form data tamu
            _buildSectionCard(
              title: 'Data Pemesan',
              child: Column(
                children: [
                  GoTicketTextField(
                    label: 'Nama Lengkap',
                    hint: 'Sesuai KTP / Paspor',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) =>
                        v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  GoTicketTextField(
                    label: 'Nomor HP',
                    hint: '08123456789',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        v!.isEmpty ? 'Nomor HP tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  GoTicketTextField(
                    label: 'Email (Opsional)',
                    hint: 'contoh@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Jumlah tamu
            _buildSectionCard(
              title: 'Jumlah Tamu',
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tamu Dewasa', style: AppTextStyles.labelMedium),
                        Text('Maks. 4 tamu per kamar',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _decrementGuest,
                        icon: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.remove, size: 18),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          _guestCount.toString(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: _incrementGuest,
                        icon: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              size: 18, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Permintaan khusus
            _buildSectionCard(
              title: 'Permintaan Khusus (Opsional)',
              child: GoTicketTextField(
                hint: 'Contoh: Kamar di lantai atas, tempat tidur ekstra, dll.',
                controller: _specialRequestController,
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 16),

            // Kode promo
            _buildSectionCard(
              title: 'Kode Promo / Voucher',
              child: Row(
                children: [
                  Expanded(
                    child: GoTicketTextField(
                      hint: 'Masukkan kode promo',
                      controller: _promoCodeController,
                      prefixIcon: Icons.local_offer_outlined,
                      suffix: _isPromoApplied
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 20)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GoTicketButton(
                    label: 'Pakai',
                    onPressed: _applyPromoCode,
                    width: 80,
                    height: 48,
                    backgroundColor: _isPromoApplied
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ringkasan harga
            _buildPriceSummaryCard(),
            const SizedBox(height: 24),

            // Tombol lanjut
            GoTicketButton(
              label: 'Lanjut ke Pembayaran',
              onPressed: _isLoading ? null : _proceedToPayment,
              isLoading: _isLoading,
              icon: Icons.arrow_forward_rounded,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard() {
    return _buildSectionCard(
      title: 'Ringkasan Pesanan',
      child: Column(
        children: [
          _buildSummaryRow('Hotel', 'Grand Hotel Example'),
          _buildSummaryRow('Kamar', 'Standard Room'),
          _buildSummaryRow('Check-in', '05 Oktober 2026'),
          _buildSummaryRow('Check-out', '08 Oktober 2026'),
          _buildSummaryRow('Durasi', '3 Malam'),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryCard() {
    return _buildSectionCard(
      title: 'Rincian Harga',
      child: Column(
        children: [
          _buildSummaryRow('Harga kamar (3 malam)', 'Rp 1.050.000'),
          if (_isPromoApplied)
            _buildSummaryRow('Diskon Promo', '- Rp 100.000',
                valueColor: AppColors.success),
          const Divider(color: AppColors.grey200, height: 20),
          _buildSummaryRow('Total', 'Rp 950.000', isBold: true),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            value,
            style: isBold
                ? AppTextStyles.titleMedium.copyWith(color: AppColors.primary)
                : AppTextStyles.labelMedium.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
