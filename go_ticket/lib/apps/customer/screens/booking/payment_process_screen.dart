// =============================================================================
// FILE: lib/apps/customer/screens/booking/payment_process_screen.dart
// RESPONSIBILITY: Halaman proses pembayaran booking hotel. Menampilkan:
// - Ringkasan pesanan dan total yang harus dibayar
// - Pilihan metode pembayaran (Transfer Bank, VA, E-Wallet, QRIS)
// - Countdown timer batas waktu pembayaran
// - Instruksi pembayaran setelah metode dipilih
// - Status polling setelah pembayaran (menunggu konfirmasi)
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../ticket/e_ticket_detail_screen.dart';

/// Halaman proses pembayaran Go Ticket.
class PaymentProcessScreen extends StatefulWidget {
  final dynamic arguments;

  const PaymentProcessScreen({super.key, this.arguments});

  @override
  State<PaymentProcessScreen> createState() => _PaymentProcessScreenState();
}

class _PaymentProcessScreenState extends State<PaymentProcessScreen> {
  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  /// Metode pembayaran yang dipilih
  String? _selectedMethod;

  /// Apakah sedang memproses pembayaran
  bool _isProcessing = false;

  /// Apakah instruksi pembayaran sudah ditampilkan
  bool _showInstructions = false;

  // Countdown timer — 15 menit
  int _countdown = 15 * 60;

  final List<_PaymentMethod> _paymentMethods = const [
    _PaymentMethod(
        id: 'bca_va',
        name: 'BCA Virtual Account',
        category: 'Transfer Bank / VA',
        icon: Icons.account_balance_outlined),
    _PaymentMethod(
        id: 'mandiri_va',
        name: 'Mandiri Virtual Account',
        category: 'Transfer Bank / VA',
        icon: Icons.account_balance_outlined),
    _PaymentMethod(
        id: 'gopay',
        name: 'GoPay',
        category: 'E-Wallet',
        icon: Icons.account_balance_wallet_outlined),
    _PaymentMethod(
        id: 'ovo',
        name: 'OVO',
        category: 'E-Wallet',
        icon: Icons.account_balance_wallet_outlined),
    _PaymentMethod(
        id: 'dana',
        name: 'DANA',
        category: 'E-Wallet',
        icon: Icons.account_balance_wallet_outlined),
    _PaymentMethod(
        id: 'qris',
        name: 'QRIS',
        category: 'QRIS',
        icon: Icons.qr_code_rounded),
  ];

  void _selectMethod(String methodId) {
    setState(() {
      _selectedMethod = methodId;
      _showInstructions = false;
    });
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == null) return;

    setState(() => _isProcessing = true);

    // TODO: Integrasikan dengan BookingRepository.initiatePayment()
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _showInstructions = true;
    });
  }

  void _navigateToTicket() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ETicketDetailScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pembayaran'),
        automaticallyImplyLeading: !_showInstructions,
      ),
      body: _showInstructions ? _buildPaymentInstructions() : _buildMethodSelector(),
      bottomNavigationBar: _showInstructions
          ? null
          : _buildPayButton(),
    );
  }

  Widget _buildMethodSelector() {
    final grouped = <String, List<_PaymentMethod>>{};
    for (final m in _paymentMethods) {
      grouped.putIfAbsent(m.category, () => []).add(m);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Ringkasan harga
        _buildOrderSummary(),
        const SizedBox(height: 16),

        // Pilih metode bayar
        Text('Pilih Metode Pembayaran', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),

        ...grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(entry.key,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondaryLight)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  children: entry.value.map((method) {
                    final isSelected = _selectedMethod == method.id;
                    return ListTile(
                      onTap: () => _selectMethod(method.id),
                      leading: Icon(method.icon,
                          color: isSelected ? AppColors.primary : AppColors.grey500),
                      title: Text(method.name, style: AppTextStyles.labelMedium),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.primary)
                          : const Icon(Icons.radio_button_unchecked,
                              color: AppColors.grey300),
                      tileColor: isSelected
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : null,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Pembayaran',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.white.withValues(alpha: 0.8))),
          Text('Rp 950.000',
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.white)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Hotel Example — Standard',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.white.withValues(alpha: 0.8))),
              Text('3 Malam',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      color: AppColors.white,
      child: GoTicketButton(
        label: _selectedMethod != null ? 'Bayar Sekarang' : 'Pilih Metode Dulu',
        onPressed: _selectedMethod != null ? _processPayment : null,
        isLoading: _isProcessing,
      ),
    );
  }

  Widget _buildPaymentInstructions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Status ikon sukses
          const Icon(Icons.access_time_rounded,
              size: 64, color: AppColors.warning),
          const SizedBox(height: 16),
          Text('Menunggu Pembayaran', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Selesaikan pembayaran sebelum batas waktu habis',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Countdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('Batas Waktu Pembayaran', style: AppTextStyles.labelSmall),
                const SizedBox(height: 8),
                Text('14:59', style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.warning,
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Nomor VA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nomor Virtual Account', style: AppTextStyles.labelSmall),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1234 5678 9012 3456',
                        style: AppTextStyles.headlineMedium),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.copy_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),

          // Tombol cek status / sudah bayar
          GoTicketButton(
            label: 'Saya Sudah Membayar',
            onPressed: _navigateToTicket,
            icon: Icons.check_circle_outline_rounded,
          ),
        ],
      ),
    );
  }
}

/// Data class untuk metode pembayaran
class _PaymentMethod {
  final String id;
  final String name;
  final String category;
  final IconData icon;

  const _PaymentMethod({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
  });
}
