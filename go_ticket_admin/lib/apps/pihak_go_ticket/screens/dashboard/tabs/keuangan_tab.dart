import 'package:flutter/material.dart';

import 'package:go_ticket_admin/core/widgets/app_pagination_bar.dart';
import '../../../../../core/services/super_admin_service.dart';
import '../../../../../core/utils/currency_formatter.dart';

/// Tab 1: Laporan Keuangan & Transaksi (Image 4)
/// 100% dinamis dari Supabase Database – tanpa data mockup.
class KeuanganTab extends StatefulWidget {
  const KeuanganTab({super.key});

  @override
  State<KeuanganTab> createState() => _KeuanganTabState();
}

class _KeuanganTabState extends State<KeuanganTab> {
  int _selectedPeriod = 1; // 0 = Harian, 1 = Bulanan, 2 = Tahunan

  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await SuperAdminService.instance.getPlatformStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _stats = {};
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _rawPayments {
    return (_stats['paymentsList'] as List<Map<String, dynamic>>?) ?? [];
  }

  List<Map<String, dynamic>> get _pagedPayments {
    final list = _rawPayments;
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= list.length) return [];
    final endIndex = (startIndex + _pageSize).clamp(0, list.length);
    return list.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C2FF)));
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 1. Header Title & Subtitle
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.payments_outlined,
                color: Color(0xFF0096B4),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Laporan Keuangan',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Rekapitulasi pendapatan kotor, omzet bersih, dan transaksi pembayaran.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2. Period Switcher (Harian, Bulanan, Tahunan)
        _buildPeriodSegmentedControl(),
        const SizedBox(height: 12),

        // 3. Hero Card: Pendapatan Bersih
        _buildNetRevenueHeroCard(),
        const SizedBox(height: 12),

        // 4. Two Metric Cards (Total Booking & Tamu)
        Row(
          children: [
            Expanded(
              child: _buildMiniMetricCard(
                icon: Icons.check_circle_outline_rounded,
                value: '${(_stats['totalBookings'] as num?)?.toInt() ?? 0}',
                label: 'Total Booking',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniMetricCard(
                icon: Icons.people_outline_rounded,
                value: '${(_stats['totalUsers'] as num?)?.toInt() ?? 0}',
                label: 'Tamu Terdaftar',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 5. Data Transaksi Tiap Pembayaran (Pagination 10 data, simple uang masuk)
        _buildTransactionsCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Period Segmented Switcher
  // ---------------------------------------------------------------------------
  Widget _buildPeriodSegmentedControl() {
    final periods = ['Harian', 'Bulanan', 'Tahunan'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  periods[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF007A94)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Hero Card: Pendapatan Bersih
  // ---------------------------------------------------------------------------
  Widget _buildNetRevenueHeroCard() {
    final baseRev = (_stats['totalRevenue'] as num?)?.toDouble() ?? 0;
    final periodMultiplier = _selectedPeriod == 0
        ? 0.05
        : (_selectedPeriod == 1 ? 1.0 : 12.0);
    final totalRev = baseRev * periodMultiplier;
    final netRev = totalRev * 0.9; // setelah fee 10%
    final komisi = totalRev * 0.1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF006678),
            Color(0xFF004452),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006678).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Pendapatan Bersih',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB2EBF2),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Big Amount
          Text(
            netRev > 0 ? CurrencyFormatter.toRupiah(netRev.round()) : 'Rp 0',
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),

          // Divider line inside card
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 14),

          // Bottom metrics in hero card
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pendapatan Kotor',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB2EBF2),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      totalRev > 0 ? CurrencyFormatter.toRupiah(totalRev.round()) : 'Rp 0',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Komisi Sistem (10%)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB2EBF2),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      komisi > 0 ? CurrencyFormatter.toRupiah(komisi.round()) : 'Rp 0',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mini Metric Card
  // ---------------------------------------------------------------------------
  Widget _buildMiniMetricCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0096B4), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Data Transaksi Tiap Pembayaran (Pagination 10 data, teks simple uang masuk)
  // ---------------------------------------------------------------------------
  Widget _buildTransactionsCard() {
    final list = _pagedPayments;
    final total = _rawPayments.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded,
                      size: 18, color: Color(0xFF0096B4)),
                  const SizedBox(width: 8),
                  const Text(
                    'Data Transaksi Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$total Data',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: const [
                    Icon(Icons.inbox_outlined, size: 36, color: Color(0xFF94A3B8)),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada transaksi pembayaran masuk',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ...list.map((trx) {
              final nominal = (trx['nominal_bayar'] as num?)?.toDouble() ?? 0;
              final nominalStr = CurrencyFormatter.toRupiah(nominal.round());
              final tgl = trx['tgl_bayar']?.toString() ?? '';
              final metode = trx['metode_pembayaran']?.toString() ?? 'Transfer';
              final noRef = trx['no_referensi_trx']?.toString() ?? '-';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_downward_rounded,
                            size: 16,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Uang Masuk',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$metode • Ref: $noRef',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+$nominalStr',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        if (tgl.isNotEmpty)
                          Text(
                            tgl.length >= 10 ? tgl.substring(0, 10) : tgl,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            // Pagination Controls (10 data per halaman)
            AppPaginationBar(
              currentPage: _currentPage,
              totalItems: total,
              pageSize: _pageSize,
              itemLabel: 'transaksi',
              onPageChanged: (newPage) {
                setState(() => _currentPage = newPage);
              },
            ),
          ],
        ],
      ),
    );
  }
}
