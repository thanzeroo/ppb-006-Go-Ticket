// =============================================================================
// FILE: lib/apps/super_admin/screens/transaction_monitoring/transaction_list_screen.dart
// RESPONSIBILITY: Halaman monitoring semua transaksi di seluruh platform
// Go Ticket. Super Admin dapat melihat dan memfilter transaksi:
// - Semua booking di seluruh hotel
// - Filter berdasarkan status, tanggal, hotel
// - Cari berdasarkan kode booking / nama tamu
// - Export laporan (CSV / PDF)
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_text_field.dart';

/// Halaman monitoring transaksi platform untuk Super Admin.
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  final List<String> _filters = [
    'Semua', 'Dikonfirmasi', 'Pending', 'Check-in', 'Check-out', 'Dibatalkan'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Monitoring Transaksi'),
        actions: [
          // Export button
          TextButton.icon(
            onPressed: () {
              // TODO: Implementasi export CSV/PDF
            },
            icon: const Icon(Icons.download_outlined),
            label: const Text('Export'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GoTicketTextField(
                  hint: 'Cari kode booking atau nama tamu...',
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedFilter = filter),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondaryLight,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 20, // TODO: Paginasi dari API
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _buildTransactionRow(index),
      ),
    );
  }

  Widget _buildTransactionRow(int index) {
    final statuses = [
      'confirmed', 'checkedIn', 'checkedOut', 'cancelled', 'pending'
    ];
    final status = statuses[index % statuses.length];
    final amounts = [350, 550, 900, 350, 700];
    final nights = [2, 3, 1, 2, 4];

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'confirmed':
        statusColor = AppColors.statusConfirmed;
        statusLabel = 'Dikonfirmasi';
        statusIcon = Icons.check_circle_outlined;
        break;
      case 'checkedIn':
        statusColor = AppColors.statusCheckedIn;
        statusLabel = 'Check-in';
        statusIcon = Icons.login_outlined;
        break;
      case 'checkedOut':
        statusColor = AppColors.statusCheckedOut;
        statusLabel = 'Selesai';
        statusIcon = Icons.logout_outlined;
        break;
      case 'cancelled':
        statusColor = AppColors.statusCancelled;
        statusLabel = 'Dibatalkan';
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = AppColors.statusPending;
        statusLabel = 'Pending';
        statusIcon = Icons.pending_outlined;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 18),
          ),
          const SizedBox(width: 12),

          // Booking info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GT-202610${(index + 1).toString().padLeft(2, '0')}-001',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary)),
                Text('Tamu ${index + 1} • Hotel Mitra ${(index % 5) + 1}',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),

          // Jumlah
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.toRupiah(
                    amounts[index % amounts.length] * 1000 *
                        nights[index % nights.length]),
                style: AppTextStyles.labelSmall,
              ),
              Text(statusLabel,
                  style: AppTextStyles.caption
                      .copyWith(color: statusColor)),
            ],
          ),
        ],
      ),
    );
  }
}
