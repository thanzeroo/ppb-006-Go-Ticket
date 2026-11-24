import 'package:flutter/material.dart';

import '../../../../../core/models/hotel_model.dart';
import '../../../../../core/services/hotel_service.dart';
import '../../../../../core/services/super_admin_service.dart';
import '../../../../../core/utils/currency_formatter.dart';

/// Tab 0: HQ Command Center (Dashboard Nasional & Ekosistem Mitra)
/// Sesuai dengan data real-time database Supabase.
class DashboardTab extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const DashboardTab({super.key, this.onNavigateTab});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  // Filter: 0 = Hari Ini, 1 = Minggu Ini, 2 = Bulan Ini, 3 = Tahun Ini, 4 = Custom
  int _selectedPeriodIndex = 2; // Default: Bulan Ini
  final List<String> _periodOptions = [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
  ];
  int _selectedYear = DateTime.now().year;
  DateTimeRange? _customDateRange;

  Map<String, dynamic> _stats = {};
  List<HotelModel> _hotels = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final s = await SuperAdminService.instance.getPlatformStats();
      final h = await HotelService.instance.getHotels();
      if (mounted) {
        setState(() {
          _stats = s;
          _hotels = h;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _stats = {};
          _hotels = [];
        });
      }
    }
  }

  List<Map<String, dynamic>> get _rawBookings {
    return (_stats['bookingsList'] as List<Map<String, dynamic>>?) ?? [];
  }

  /// Memfilter booking sesuai filter yang dipilih
  List<Map<String, dynamic>> get _filteredBookings {
    final now = DateTime.now();
    return _rawBookings.where((b) {
      final dateStr = (b['tgl_booking'] ?? b['created_at'])?.toString();
      if (dateStr == null || dateStr.isEmpty) return true;
      final d = DateTime.tryParse(dateStr);
      if (d == null) return true;

      if (_selectedPeriodIndex == 0) {
        // Hari Ini
        return d.year == now.year && d.month == now.month && d.day == now.day;
      } else if (_selectedPeriodIndex == 1) {
        // Minggu Ini (7 hari terakhir)
        return now.difference(d).inDays <= 7 && now.difference(d).inDays >= 0;
      } else if (_selectedPeriodIndex == 2) {
        // Bulan Ini
        return d.year == now.year && d.month == now.month;
      } else if (_selectedPeriodIndex == 3) {
        // Tahun Ini (Per Tahun)
        return d.year == _selectedYear;
      } else if (_selectedPeriodIndex == 4 && _customDateRange != null) {
        // Custom Range
        return d.isAfter(_customDateRange!.start.subtract(const Duration(seconds: 1))) &&
            d.isBefore(_customDateRange!.end.add(const Duration(days: 1)));
      }
      return true;
    }).toList();
  }

  double get _filteredRevenue {
    double rev = 0;
    for (final b in _filteredBookings) {
      if (b['status_booking'] == 'confirmed' || b['status_booking'] == 'completed') {
        rev += (b['total_harga'] as num?)?.toDouble() ?? 0;
      }
    }
    return rev;
  }

  /// Data 7 bar hari untuk Tren Booking (nyata dari database jika ada)
  List<int> get _weeklyBookingCounts {
    final now = DateTime.now();
    final counts = List.filled(7, 0);
    for (final b in _rawBookings) {
      final dateStr = (b['tgl_booking'] ?? b['created_at'])?.toString();
      if (dateStr == null || dateStr.isEmpty) continue;
      final d = DateTime.tryParse(dateStr);
      if (d == null) continue;
      final diff = now.difference(d).inDays;
      if (diff >= 0 && diff < 7) {
        // 0 = 6 hari lalu, 6 = hari ini
        final index = 6 - diff;
        counts[index]++;
      }
    }
    return counts;
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007A94),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedPeriodIndex = 4;
      });
    }
  }

  Future<void> _pickYearFilter() async {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (i) => currentYear - i);
    final chosen = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text(
          'Pilih Tahun',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: years.map((y) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, y),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$y', style: const TextStyle(fontSize: 14)),
                  if (y == _selectedYear && _selectedPeriodIndex == 3)
                    const Icon(Icons.check, size: 18, color: Color(0xFF007A94)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (chosen != null) {
      setState(() {
        _selectedYear = chosen;
        _selectedPeriodIndex = 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 1. Title & Subtitle
        const Text(
          'HQ Command Center',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pemantauan real-time metrik bisnis nasional & ekosistem mitra',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 14),

        // 2. Time Filter Chips (Horizontal)
        _buildPeriodFilters(),
        const SizedBox(height: 14),

        // 3. Key Metrics Grid (Pendapatan Kotor, Komisi, Mitra Hotel, Tamu)
        _buildMetricsGrid(),
        const SizedBox(height: 16),

        // 4. National Booking Volume Trend Card (Data Nyata dari Database)
        _buildBookingTrendCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Period Filter Chips + Filter Per Tahun & Custom
  // ---------------------------------------------------------------------------
  Widget _buildPeriodFilters() {
    String currentLabel = '';
    if (_selectedPeriodIndex < _periodOptions.length) {
      currentLabel = _periodOptions[_selectedPeriodIndex];
    } else if (_selectedPeriodIndex == 3) {
      currentLabel = 'Tahun $_selectedYear';
    } else if (_selectedPeriodIndex == 4) {
      if (_customDateRange != null) {
        currentLabel =
            '${_customDateRange!.start.day}/${_customDateRange!.start.month} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}';
      } else {
        currentLabel = 'Kustom';
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 3 filter utama: Hari Ini, Minggu Ini, Bulan Ini
          ...List.generate(_periodOptions.length, (index) {
            final isSelected = _selectedPeriodIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedPeriodIndex = index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFCFFAFE) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF67E8F9)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    _periodOptions[index],
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF0891B2)
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            );
          }),

          // Tombol Filter Per Tahun
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: _pickYearFilter,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _selectedPeriodIndex == 3 ? const Color(0xFFCFFAFE) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedPeriodIndex == 3
                        ? const Color(0xFF67E8F9)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: _selectedPeriodIndex == 3
                          ? const Color(0xFF0891B2)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _selectedPeriodIndex == 3 ? 'Tahun $_selectedYear' : 'Per Tahun',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: _selectedPeriodIndex == 3 ? FontWeight.w800 : FontWeight.w500,
                        color: _selectedPeriodIndex == 3
                            ? const Color(0xFF0891B2)
                            : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: _selectedPeriodIndex == 3
                          ? const Color(0xFF0891B2)
                          : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tombol Filter Kustom
          InkWell(
            onTap: _pickCustomDateRange,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _selectedPeriodIndex == 4 ? const Color(0xFFCFFAFE) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedPeriodIndex == 4
                      ? const Color(0xFF67E8F9)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 13,
                    color: _selectedPeriodIndex == 4
                        ? const Color(0xFF0891B2)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _selectedPeriodIndex == 4 ? currentLabel : 'Kustom',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: _selectedPeriodIndex == 4 ? FontWeight.w800 : FontWeight.w500,
                      color: _selectedPeriodIndex == 4
                          ? const Color(0xFF0891B2)
                          : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Key Metrics 2x2 Grid (Pendapatan Kotor, Komisi, Mitra Hotel, Tamu)
  // ---------------------------------------------------------------------------
  Widget _buildMetricsGrid() {
    final filteredRev = _filteredRevenue;
    final totalHotelsCount = _hotels.length;
    final totalUsers = (_stats['totalUsers'] as num?)?.toInt() ?? 0;

    final gmvStr = CurrencyFormatter.toRupiah(filteredRev.round());
    final komisiStr = CurrencyFormatter.toRupiah((filteredRev * 0.1).round());

    String badgePeriodText = '';
    if (_selectedPeriodIndex < _periodOptions.length) {
      badgePeriodText = _periodOptions[_selectedPeriodIndex];
    } else if (_selectedPeriodIndex == 3) {
      badgePeriodText = 'Tahun $_selectedYear';
    } else {
      badgePeriodText = 'Kustom';
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Pendapatan Kotor',
                value: gmvStr,
                icon: Icons.account_balance_wallet_outlined,
                badgeText: badgePeriodText,
                badgeBg: const Color(0xFFDCFCE7),
                badgeFg: const Color(0xFF15803D),
                subText: 'Realtime DB',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Komisi',
                value: komisiStr,
                icon: Icons.receipt_long_outlined,
                badgeText: 'Komisi 10%',
                badgeBg: const Color(0xFFCFFAFE),
                badgeFg: const Color(0xFF0891B2),
                subText: 'Tercatat',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Mitra Hotel',
                value: '$totalHotelsCount',
                unit: 'Unit',
                icon: Icons.apartment_rounded,
                subText: 'Nasional',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Tamu Terdaftar',
                value: '$totalUsers',
                unit: 'User',
                icon: Icons.people_outline_rounded,
                subText: 'Akun Pengguna',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    String? unit,
    required IconData icon,
    String? badgeText,
    Color? badgeBg,
    Color? badgeFg,
    String? subText,
    Widget? customSub,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: const Color(0xFF0096B4)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          if (customSub != null)
            customSub
          else
            Row(
              children: [
                if (badgeText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg ?? const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: badgeFg ?? const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                if (subText != null)
                  Expanded(
                    child: Text(
                      subText,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. National Booking Volume Trend Card
  // ---------------------------------------------------------------------------
  Widget _buildBookingTrendCard() {
    final counts = _weeklyBookingCounts;
    final totalWeekly = counts.fold<int>(0, (sum, item) => sum + item);
    final now = DateTime.now();

    // Hari 7 hari terakhir: 6 hari lalu s/d hari ini
    const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final labels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return dayNames[d.weekday - 1];
    });

    int maxCount = 0;
    int maxIdx = 6;
    for (int i = 0; i < counts.length; i++) {
      if (counts[i] >= maxCount) {
        maxCount = counts[i];
        maxIdx = i;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tren Volume Booking Nasional',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '7 Hari Terakhir • Total: $totalWeekly booking tercatat',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFFAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Live DB',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0891B2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Custom Painted Chart with Columns & Smooth Line + Tooltip
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _BookingTrendPainter(
                counts: counts,
                labels: labels,
                peakIndex: maxIdx,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 10),

          // Day labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              return _DayLabel(
                label: labels[i],
                isHighlight: i == maxIdx,
              );
            }),
          ),
          const SizedBox(height: 14),

          // Booking Harian Tertinggi Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0096B4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Volume Harian Tertinggi',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                Text(
                  '$maxCount Tiket (${labels[maxIdx]})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Day label for Trend Chart
// -----------------------------------------------------------------------------
class _DayLabel extends StatelessWidget {
  final String label;
  final bool isHighlight;

  const _DayLabel({required this.label, required this.isHighlight});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w600,
        color: isHighlight ? const Color(0xFF0284C7) : const Color(0xFF64748B),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Custom Chart Painter for Booking Trend (Data Asli dari Database)
// -----------------------------------------------------------------------------
class _BookingTrendPainter extends CustomPainter {
  final List<int> counts;
  final List<String> labels;
  final int peakIndex;

  _BookingTrendPainter({
    required this.counts,
    required this.labels,
    required this.peakIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final count = counts.length;
    final columnWidth = 22.0;
    final spacing = (size.width - (count * columnWidth)) / (count - 1);

    int maxCount = 0;
    for (final c in counts) {
      if (c > maxCount) maxCount = c;
    }
    final divisor = maxCount > 0 ? maxCount : 1;

    final linePoints = <Offset>[];

    for (int i = 0; i < count; i++) {
      final left = i * (columnWidth + spacing);
      final normalized = maxCount > 0 ? (counts[i] / divisor) : 0.08;
      // Berikan tinggi minimal 8px agar tetap kelihatan bar walau 0
      final height = (normalized * (size.height - 40)).clamp(8.0, size.height - 30);
      final top = size.height - height;
      final isPeak = i == peakIndex && counts[i] > 0;

      // Draw vertical bar with rounded top
      final barPaint = Paint()
        ..color = isPeak
            ? const Color(0xFF67E8F9)
            : const Color(0xFFE0F2FE);

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, columnWidth, height),
        const Radius.circular(6),
      );
      canvas.drawRRect(rrect, barPaint);

      // Record point for smooth spline line
      final centerX = left + (columnWidth / 2);
      linePoints.add(Offset(centerX, top));
    }

    // Draw smooth curve line over the bars
    if (linePoints.isNotEmpty) {
      final path = Path();
      path.moveTo(linePoints.first.dx, linePoints.first.dy);

      for (int i = 0; i < linePoints.length - 1; i++) {
        final p0 = linePoints[i];
        final p1 = linePoints[i + 1];
        final controlX = (p0.dx + p1.dx) / 2;
        path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      }

      final linePaint = Paint()
        ..color = const Color(0xFF007A94)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, linePaint);

      // Draw peak point dot and tooltip above peak point
      if (peakIndex >= 0 && peakIndex < linePoints.length && counts[peakIndex] > 0) {
        final peakPoint = linePoints[peakIndex];
        final dotPaint = Paint()..color = const Color(0xFF00C2FF);
        canvas.drawCircle(peakPoint, 4, dotPaint);

        final whiteDotPaint = Paint()..color = Colors.white;
        canvas.drawCircle(peakPoint, 2, whiteDotPaint);

        // Draw tooltip box above peak point
        final tipText = '${labels[peakIndex]}: ${counts[peakIndex]}';
        final textSpan = TextSpan(
          text: tipText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        final tooltipWidth = textPainter.width + 16;
        final tooltipRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(peakPoint.dx, peakPoint.dy - 16),
            width: tooltipWidth,
            height: 20,
          ),
          const Radius.circular(10),
        );
        final tooltipBg = Paint()..color = const Color(0xFF0F172A);
        canvas.drawRRect(tooltipRect, tooltipBg);

        textPainter.paint(
          canvas,
          Offset(
            peakPoint.dx - (textPainter.width / 2),
            peakPoint.dy - 16 - (textPainter.height / 2),
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
