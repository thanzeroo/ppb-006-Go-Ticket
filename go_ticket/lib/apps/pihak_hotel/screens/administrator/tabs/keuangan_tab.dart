import 'package:flutter/material.dart';

import '../../../../../core/theme/hotel_admin_theme.dart';
import '../../../../../models/hotel_admin_model.dart';

/// Tab 4: Buku Kas & Keuangan Administrator
class KeuanganTab extends StatefulWidget {
  final List<TransactionData> transactions;

  const KeuanganTab({super.key, required this.transactions});

  @override
  State<KeuanganTab> createState() => _KeuanganTabState();
}

class _KeuanganTabState extends State<KeuanganTab> {
  int _periodIndex = 0;
  final _periods = ['Hari Ini', '7 Hari', 'Bulan Ini (Okt)', 'Kustom'];

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? cDarkActive : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? cDarkActive : adminCardBorder),
                  ),
                  child: Text(
                    _periods[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),
        // Card 1: Saldo Kas Masuk Bersih (Dark Card)
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
                    style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Okt 2025', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Rp 128.450.000',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Gross Booking', style: TextStyle(fontSize: 9, color: Colors.white60)),
                        SizedBox(height: 2),
                        Text('Rp 142.720.000', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Komisi OTA & Tax', style: TextStyle(fontSize: 9, color: Colors.white60)),
                        SizedBox(height: 2),
                        Text('-Rp 14.270.000', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFFCA5A5))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Mini stats: ADR & RevPAR
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: adminCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.trending_up, size: 14, color: Color(0xFF16A34A)),
                        SizedBox(width: 4),
                        Text('ADR Harian', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Rp 1.025.000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const Text('Average Daily Rate', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: adminCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.bar_chart, size: 14, color: cDarkActive),
                        SizedBox(width: 4),
                        Text('RevPAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Rp 820.000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const Text('Revenue Per Avail. Room', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        // Card 2: Tren Arus Pendapatan with Spline Curve
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: adminCardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Tren Arus Pendapatan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      Text('Komparasi Bruto, Netto, dan Saldo OTA', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: cLight, borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.trending_up, size: 14, color: cDarkActive),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Legend
              Row(
                children: const [
                  LegendDot(color: cDarkActive, label: 'Bruto (Gross)'),
                  SizedBox(width: 10),
                  LegendDot(color: cNormal, label: 'Bersih (Nett)'),
                  SizedBox(width: 10),
                  LegendDot(color: cLightActive, label: 'OTA Fee'),
                ],
              ),
              const SizedBox(height: 12),

              // Spline Curve Chart
              SizedBox(
                height: 120,
                width: double.infinity,
                child: CustomPaint(
                  painter: RevenueChartPainter(
                    tealColor: cDarkActive,
                    cyanColor: cNormal,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('1 Okt', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                  Text('5 Okt', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                  Text('10 Okt', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                  Text('15 Okt', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                  Text('20 Okt', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Card 3: Riwayat Transaksi Terakhir
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: adminCardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mutasi Kas Real-Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  GestureDetector(
                    onTap: () {},
                    child: const Text('Lihat Semua', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cDarkActive)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...widget.transactions.map((tx) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: adminCardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tx.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          Text(tx.amount, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tx.room, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                          Text(tx.code, style: const TextStyle(fontSize: 9, color: cDarkActive, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tx.method, style: const TextStyle(fontSize: 8, color: Color(0xFF475569))),
                          Text(tx.time, style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Card 4: Ekspor Laporan Pendapatan
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: adminCardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: cDarkActive, shape: BoxShape.circle),
                    child: const Icon(Icons.download, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text('Ekspor Laporan Pendapatan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Unduh rekonsiliasi kas masuk untuk audit akuntansi, pajak hotel (PH1), dan rekonsiliasi perbankan.',
                style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 12),
                      label: const Text('Unduh PDF Resmi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cDarkActive,
                        side: const BorderSide(color: cDarkActive),
                        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.table_chart_outlined, size: 12),
                      label: const Text('Unduh CSV / Excel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cDarkActive,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shield_outlined, size: 12, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text(
                'Mode Audit Finansial (Read-Only) • Otorisasi transfer terisolasi',
                style: TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER FOR SPLINE REVENUE CHART
// ─────────────────────────────────────────────────────────────────────────────

class RevenueChartPainter extends CustomPainter {
  final Color tealColor;
  final Color cyanColor;

  RevenueChartPainter({required this.tealColor, required this.cyanColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Data points normalized
    final points = [
      Offset(0, h * 0.75),
      Offset(w * 0.20, h * 0.65),
      Offset(w * 0.40, h * 0.80),
      Offset(w * 0.60, h * 0.55),
      Offset(w * 0.80, h * 0.40),
      Offset(w, h * 0.25),
    ];

    // Net points
    final netPoints = [
      Offset(0, h * 0.82),
      Offset(w * 0.20, h * 0.72),
      Offset(w * 0.40, h * 0.88),
      Offset(w * 0.60, h * 0.62),
      Offset(w * 0.80, h * 0.48),
      Offset(w, h * 0.35),
    ];

    // Gradient fill under the curve
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      fillPath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }
    fillPath.lineTo(w, h);
    fillPath.lineTo(0, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          cyanColor.withValues(alpha: 0.25),
          cyanColor.withValues(alpha: 0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    // Draw Gross Curve (Teal)
    final grossPath = Path();
    grossPath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      grossPath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final grossPaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(grossPath, grossPaint);

    // Draw Net Curve (Cyan)
    final netPath = Path();
    netPath.moveTo(netPoints.first.dx, netPoints.first.dy);
    for (int i = 0; i < netPoints.length - 1; i++) {
      final p0 = netPoints[i];
      final p1 = netPoints[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      netPath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final netPaint = Paint()
      ..color = cyanColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(netPath, netPaint);

    // Draw endpoints circles
    final dotPaint = Paint()..color = Colors.white;
    final dotBorderPaint = Paint()
      ..color = cyanColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final lastPoint = points.last;
    canvas.drawCircle(lastPoint, 4, dotPaint);
    canvas.drawCircle(lastPoint, 4, dotBorderPaint);

    final secondLast = points[points.length - 2];
    canvas.drawCircle(secondLast, 4, dotPaint);
    canvas.drawCircle(secondLast, 4, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
