import 'package:flutter/material.dart';

import '../../../../../core/theme/hotel_admin_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 – DASHBOARD ADMINISTRATOR
// ─────────────────────────────────────────────────────────────────────────────

class AdministratorDashboardTab extends StatefulWidget {
  const AdministratorDashboardTab({super.key});

  @override
  State<AdministratorDashboardTab> createState() =>
      _AdministratorDashboardTabState();
}

class _AdministratorDashboardTabState
    extends State<AdministratorDashboardTab> {
  int _periodIndex = 1; // 7 Hari Terakhir
  final _periods = ['Hari Ini', '7 Hari Terakhir', 'Bulan Ini', 'Kuartal Q4'];

  final _weeklyBars = const [
    {'day': 'Sen', 'val': 0.78, 'label': '78%'},
    {'day': 'Sel', 'val': 0.82, 'label': '82%'},
    {'day': 'Rab', 'val': 0.80, 'label': '80%'},
    {'day': 'Kam', 'val': 0.85, 'label': '85%'},
    {'day': 'Jum', 'val': 0.94, 'label': '94%', 'cyan': true},
    {'day': 'Sab', 'val': 0.96, 'label': '96%', 'teal': true, 'bold': true},
    {'day': 'Min', 'val': 0.88, 'label': '88%'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Dashboard Administrator',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        // Period filter pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_periods.length, (i) {
              final sel = _periodIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _periodIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? cLightActive : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? cNormal : adminCardBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sel) ...[
                        const Icon(Icons.circle, size: 6, color: cDarkActive),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        _periods[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              sel ? FontWeight.w800 : FontWeight.w600,
                          color: sel
                              ? cDarkActive
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 12),
        // Date range row
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 13, color: Color(0xFF64748B)),
            const SizedBox(width: 6),
            const Text(
              '18 Okt – 24 Okt 2025',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155)),
            ),
            const Spacer(),
            const Row(
              children: [
                Icon(Icons.sync, size: 13, color: cDarkActive),
                SizedBox(width: 4),
                Text(
                  'Sinkron OTA otomatis',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: cDarkActive),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),
        // Card 1: Total Pendapatan Kotor
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pendapatan Kotor',
                      style:
                          TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.account_balance_outlined,
                        size: 16, color: cDarkActive),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Rp 124.850.000',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_upward,
                            size: 9, color: Color(0xFF16A34A)),
                        SizedBox(width: 2),
                        Text('+14.2% vs bln lalu',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF16A34A))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Target tercapai 92%',
                      style: TextStyle(
                          fontSize: 10, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Card 2: Rata-Rata Okupansi
        _buildCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Rata-Rata Okupansi',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF64748B))),
                    SizedBox(height: 2),
                    Text('84%',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    SizedBox(height: 2),
                    Text('RevPAR: Rp 920.000',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF475569))),
                    Text('ADR: Rp 1.150.000',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF475569))),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: const [
                  SizedBox(
                    width: 65,
                    height: 65,
                    child: CircularProgressIndicator(
                      value: 0.84,
                      strokeWidth: 6,
                      backgroundColor: Color(0xFFE2E8F0),
                      color: cDarkActive,
                    ),
                  ),
                  Icon(Icons.hotel, color: cDarkActive, size: 20),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Row 2 Cards: Kamar Terjual & Kepuasan Tamu
        Row(
          children: [
            Expanded(
              child: _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kamar Terjual',
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFF64748B))),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: cLight,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.key,
                              size: 12, color: cDarkActive),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('142',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const Text('Nights',
                        style: TextStyle(
                            fontSize: 9, color: Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    const Text('Dari 45 total inventaris unit',
                        style: TextStyle(
                            fontSize: 8, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kepuasan Tamu',
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFF64748B))),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.star,
                              size: 12, color: Color(0xFFD97706)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('4.9',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const Text('/ 5.0',
                        style: TextStyle(
                            fontSize: 9, color: Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    const Text('1.280 ulasan terverifikasi',
                        style: TextStyle(
                            fontSize: 8, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        // Card 3: Tren Okupansi & Penjualan Mingguan
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tren Okupansi & Penjualan Mingguan',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 2),
                      Text('Kinerja harian vs target batas (85%)',
                          style: TextStyle(
                              fontSize: 9, color: Color(0xFF64748B))),
                    ],
                  ),
                  const Icon(Icons.more_vert,
                      size: 16, color: Color(0xFF94A3B8)),
                ],
              ),
              const SizedBox(height: 16),

              // Bar Chart
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _weeklyBars.map((b) {
                    final isCyan = b['cyan'] == true;
                    final isTeal = b['teal'] == true;
                    final isBold = b['bold'] == true;
                    final val = b['val'] as double;
                    final barColor = isTeal
                        ? cDarkActive
                        : isCyan
                            ? cNormal
                            : const Color(0xFFBFDBFE);

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(b['label'] as String,
                              style: const TextStyle(
                                  fontSize: 8, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Container(
                            height: 80 * val,
                            width: 28,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            b['day'] as String,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isBold
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isBold
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  LegendDot(color: cDarkActive, label: 'Kamar (75%)'),
                  SizedBox(width: 12),
                  LegendDot(color: cNormal, label: 'F&B & Bar (15%)'),
                  SizedBox(width: 12),
                  LegendDot(
                      color: Color(0xFFE2E8F0), label: 'Ekstra (10%)'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Card 4: Info Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cLightActive),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: cDarkActive, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Data diperbarui otomatis setiap 30 detik via OTA sync.',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cDarker),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
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
      child: child,
    );
  }
}
