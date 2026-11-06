import 'package:flutter/material.dart';

import '../../../../../core/models/hotel_admin_model.dart';
import '../../../../../core/theme/hotel_admin_theme.dart';

/// Tab 4: Buku Kas & Keuangan Administrator (data dinamis dari BookingService).
class KeuanganTab extends StatefulWidget {
  final List<TransactionData> transactions;

  const KeuanganTab({super.key, required this.transactions});

  @override
  State<KeuanganTab> createState() => _KeuanganTabState();
}

class _KeuanganTabState extends State<KeuanganTab> {
  int _periodIndex = 0;
  final _periods = ['Semua', '7 Hari', 'Bulan Ini', 'Kustom'];

  // ── Hitung total dari amount string '+Rp x.xxx.xxx' ─────────────────────
  double get _grossTotal {
    double total = 0;
    for (final tx in widget.transactions) {
      final raw = tx.amount
          .replaceAll(RegExp(r'[^0-9]'), '');
      total += double.tryParse(raw) ?? 0;
    }
    return total;
  }

  double get _netTotal => _grossTotal * 0.9; // 90% setelah komisi 10%
  double get _commission => _grossTotal * 0.1;

  String _fmt(double v) {
    if (v >= 1000000) {
      return 'Rp ${(v / 1000000).toStringAsFixed(1)} Jt';
    }
    if (v >= 1000) {
      return 'Rp ${(v / 1000).toStringAsFixed(0)} Rb';
    }
    return 'Rp ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final gross = _grossTotal;
    final net = _netTotal;
    final commission = _commission;
    final txCount = widget.transactions.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title
        const Text(
          'Buku Kas & Arus Pendapatan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        // Period Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_periods.length, (i) {
              final sel = _periodIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _periodIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? cDarkActive : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? cDarkActive : adminCardBorder),
                  ),
                  child: Text(
                    _periods[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color:
                          sel ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),

        // ── Card 1: Saldo Kas Nett (dark gradient) ─────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [cDarkActive, cDarker],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: cDarkActive.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saldo Kas Masuk Bersih (Nett)',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      txCount == 0 ? 'Kosong' : '$txCount Booking',
                      style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                net == 0 ? '–' : _fmt(net),
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gross Booking',
                            style: TextStyle(
                                fontSize: 9, color: Colors.white60)),
                        const SizedBox(height: 2),
                        Text(
                          gross == 0 ? '–' : _fmt(gross),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Komisi Go Ticket (10%)',
                            style: TextStyle(
                                fontSize: 9, color: Colors.white60)),
                        const SizedBox(height: 2),
                        Text(
                          commission == 0 ? '–' : '- ${_fmt(commission)}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Daftar Transaksi ───────────────────────────────────────────────
        if (txCount == 0)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: adminCardBorder),
            ),
            child: const Column(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 48, color: Color(0xFFCBD5E1)),
                SizedBox(height: 10),
                Text('Belum Ada Transaksi',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B))),
                SizedBox(height: 4),
                Text('Transaksi akan muncul setelah ada booking masuk',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: adminCardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                for (final tx in widget.transactions) ...[
                  _buildTxRow(tx),
                  if (tx != widget.transactions.last)
                    const Divider(height: 16),
                ],
              ],
            ),
          ),

        const SizedBox(height: 12),

        // Footer Banner
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined,
                  size: 12, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text(
                'Mode Audit Finansial (Read-Only) • Otorisasi transfer terisolasi',
                style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTxRow(TransactionData tx) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: cLight, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.receipt_outlined,
              size: 18, color: cDarkActive),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tx.name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
              Text('${tx.room} • ${tx.time}',
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF64748B))),
              Text(tx.code,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cDarkActive)),
            ],
          ),
        ),
        Text(
          tx.amount,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF16A34A)),
        ),
      ],
    );
  }
}
