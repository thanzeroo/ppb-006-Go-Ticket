// =============================================================================
// FILE: lib/apps/hotel_partner/screens/admin_hotel/financial_payout_screen.dart
// RESPONSIBILITY: Halaman laporan keuangan dan pengajuan payout untuk
// Admin Hotel. Menampilkan:
// - Ringkasan pendapatan periode tertentu
// - Tabel breakdown booking → pendapatan bruto → komisi → neto
// - Riwayat payout sebelumnya
// - Form pengajuan payout baru ke Go Ticket
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

/// Halaman laporan keuangan dan payout mitra hotel.
class FinancialPayoutScreen extends StatefulWidget {
  const FinancialPayoutScreen({super.key});

  @override
  State<FinancialPayoutScreen> createState() => _FinancialPayoutScreenState();
}

class _FinancialPayoutScreenState extends State<FinancialPayoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRequestPayoutDialog() {
    final bankNameCtrl = TextEditingController();
    final accountNameCtrl = TextEditingController();
    final accountNumberCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajukan Payout'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info saldo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.success),
                    const SizedBox(width: 8),
                    Text('Saldo tersedia: Rp 38.000.000',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.success)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GoTicketTextField(
                label: 'Jumlah Payout (Rp)',
                hint: 'Minimal Rp 100.000',
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.payments_outlined,
              ),
              const SizedBox(height: 12),
              GoTicketTextField(
                label: 'Nama Bank',
                hint: 'BCA / Mandiri / BRI / BNI',
                controller: bankNameCtrl,
                prefixIcon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 12),
              GoTicketTextField(
                label: 'Nama Pemilik Rekening',
                hint: 'Sesuai buku tabungan',
                controller: accountNameCtrl,
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              GoTicketTextField(
                label: 'Nomor Rekening',
                hint: '1234567890',
                controller: accountNumberCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.credit_card_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          GoTicketButton(
            label: 'Ajukan',
            onPressed: () {
              // TODO: Integrasikan dengan PayoutRepository.requestPayout()
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengajuan payout berhasil dikirim!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            width: 100,
            height: 40,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Laporan Keuangan & Payout'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Laporan Keuangan'),
            Tab(text: 'Riwayat Payout'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFinancialTab(),
          _buildPayoutHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRequestPayoutDialog,
        icon: const Icon(Icons.request_quote_outlined),
        label: const Text('Ajukan Payout'),
        backgroundColor: AppColors.success,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildFinancialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Saldo tersedia
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saldo Tersedia',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.white.withValues(alpha: 0.8))),
                Text(CurrencyFormatter.toRupiah(38000000),
                    style: AppTextStyles.displaySmall
                        .copyWith(color: AppColors.white)),
                const SizedBox(height: 8),
                Text('Bulan Oktober 2026',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Breakdown keuangan
          _buildFinancialCard('Ringkasan Oktober 2026', [
            _buildFinancialRow('Total Booking', '45'),
            _buildFinancialRow('Pendapatan Bruto',
                CurrencyFormatter.toRupiah(42000000)),
            _buildFinancialRow('Komisi Platform (10%)',
                '- ${CurrencyFormatter.toRupiah(4200000)}',
                color: AppColors.error),
            _buildFinancialRow('Sudah di-Payout',
                '- ${CurrencyFormatter.toRupiah(0)}',
                color: AppColors.grey500),
            _buildFinancialRow('Saldo Bersih',
                CurrencyFormatter.toRupiah(37800000),
                isBold: true, color: AppColors.primary),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildPayoutHistoryTab() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildPayoutHistoryCard(index),
    );
  }

  Widget _buildPayoutHistoryCard(int index) {
    final statuses = ['completed', 'pending', 'completed'];
    final amounts = [15000000, 20000000, 12000000];
    final dates = ['01 Sep 2026', '01 Okt 2026', '01 Agu 2026'];
    final status = statuses[index];
    final isCompleted = status == 'completed';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isCompleted ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.pending_outlined,
              color: isCompleted ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(CurrencyFormatter.toRupiah(amounts[index]),
                    style: AppTextStyles.titleMedium),
                Text('Tanggal: ${dates[index]}',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.successLight : AppColors.warningLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isCompleted ? 'Diterima' : 'Pending',
              style: AppTextStyles.labelSmall.copyWith(
                color: isCompleted ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(String title, List<Widget> rows) {
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
          const Divider(color: AppColors.grey100, height: 20),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value,
      {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value,
              style: isBold
                  ? AppTextStyles.titleMedium.copyWith(color: color)
                  : AppTextStyles.labelMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}
