// =============================================================================
// FILE: lib/apps/super_admin/screens/payout_management/payout_approval_screen.dart
// RESPONSIBILITY: Halaman persetujuan payout mitra hotel oleh Super Admin.
// Super Admin memeriksa dan memproses pengajuan payout:
// - Melihat daftar payout pending
// - Review detail pengajuan (jumlah, rekening, periode)
// - Approve (proses transfer) atau Reject dengan alasan
// - Upload bukti transfer setelah selesai
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

/// Halaman persetujuan payout hotel mitra untuk Super Admin.
class PayoutApprovalScreen extends StatefulWidget {
  const PayoutApprovalScreen({super.key});

  @override
  State<PayoutApprovalScreen> createState() => _PayoutApprovalScreenState();
}

class _PayoutApprovalScreenState extends State<PayoutApprovalScreen>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Manajemen Payout'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending (7)'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingPayouts(),
          _buildPayoutHistory(),
        ],
      ),
    );
  }

  Widget _buildPendingPayouts() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildPendingCard(index),
    );
  }

  Widget _buildPendingCard(int index) {
    final amounts = [
      15000000, 38000000, 8500000, 22000000,
      42000000, 11000000, 19500000
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warningLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header hotel + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hotel Mitra ${index + 1}',
                      style: AppTextStyles.titleSmall),
                  Text('Diajukan: 01 Oktober 2026',
                      style: AppTextStyles.caption),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pending_outlined,
                        size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text('Pending',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.warning)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.grey100, height: 20),

          // Detail payout
          _buildPayoutInfo('Jumlah', CurrencyFormatter.toRupiah(amounts[index]),
              isHighlight: true),
          _buildPayoutInfo('Bank', 'BCA'),
          _buildPayoutInfo('No. Rekening', '1234567890'),
          _buildPayoutInfo('Atas Nama', 'PT Hotel Mitra ${index + 1}'),
          _buildPayoutInfo('Periode', '01 Sep - 30 Sep 2026'),

          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GoTicketButton(
                  label: 'Approve & Transfer',
                  onPressed: () => _showApproveDialog(context, index),
                  height: 40,
                  backgroundColor: AppColors.success,
                  icon: Icons.check_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GoTicketOutlinedButton(
                  label: 'Reject',
                  onPressed: () => _showRejectDialog(context, index),
                  height: 40,
                  borderColor: AppColors.error,
                  foregroundColor: AppColors.error,
                  icon: Icons.close_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutInfo(String label, String value,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value,
              style: isHighlight
                  ? AppTextStyles.titleMedium.copyWith(color: AppColors.primary)
                  : AppTextStyles.labelMedium),
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context, int index) {
    final txIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Proses Transfer'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Konfirmasi transfer payout ke Hotel Mitra ${index + 1}.',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
            GoTicketTextField(
              label: 'ID Transaksi Transfer (Nomor Referensi Bank)',
              hint: 'Contoh: TRF20261005001',
              controller: txIdController,
              prefixIcon: Icons.numbers_rounded,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          GoTicketButton(
            label: 'Konfirmasi Transfer',
            onPressed: () {
              // TODO: Integrasikan dengan PayoutRepository.processPayout()
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payout berhasil diproses!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            width: 180,
            height: 40,
            backgroundColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, int index) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Payout'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GoTicketTextField(
              label: 'Alasan Penolakan',
              hint: 'Jelaskan alasan penolakan...',
              controller: reasonController,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Integrasikan dengan PayoutRepository.rejectPayout()
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Tolak Payout'),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutHistory() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final isCompleted = index % 3 != 1;
        final amounts = [15, 38, 8, 22, 42, 11, 19, 30, 25, 17];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCompleted ? AppColors.success : AppColors.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hotel Mitra ${index + 1}',
                        style: AppTextStyles.titleSmall),
                    Text(
                        CurrencyFormatter.toRupiah(amounts[index] * 1000000),
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Text(
                isCompleted ? 'Selesai' : 'Ditolak',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isCompleted ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
