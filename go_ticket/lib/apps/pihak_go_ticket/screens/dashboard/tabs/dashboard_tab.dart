import 'package:flutter/material.dart';

/// Tab 0: HQ Command Center (Dashboard Nasional & Ekosistem Mitra)
/// Sesuai dengan desain visual pada Gambar 1.
class DashboardTab extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const DashboardTab({super.key, this.onNavigateTab});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int _selectedPeriodIndex = 2; // Default: 'Bulan Ini (MTD)'
  final List<String> _periodOptions = [
    'Hari Ini',
    '7 Hari Terakhir',
    'Bulan Ini (MTD)',
    'Tahun Ini (YTD)',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 1. Live Server Status Pill & Timestamp
        _buildLiveStatusRow(),
        const SizedBox(height: 12),

        // 2. Title & Subtitle
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

        // 3. Time Filter Chips (Horizontal)
        _buildPeriodFilters(),
        const SizedBox(height: 12),

        // 4. Region Dropdown Card
        _buildRegionSelector(),
        const SizedBox(height: 14),

        // 5. Alert Banner Card ("PERHATIAN KEUANGAN")
        _buildFinancialAlertCard(),
        const SizedBox(height: 14),

        // 6. Key Metrics Grid (2x2)
        _buildMetricsGrid(),
        const SizedBox(height: 14),

        // 7. National Booking Volume Trend Card (Interactive/Painter)
        _buildBookingTrendCard(),
        const SizedBox(height: 20),

        // 8. Sebaran Hotel Populer
        _buildPopularHotelsSection(),
        const SizedBox(height: 20),

        // 9. Aksi Cepat Super Admin
        _buildQuickActionsSection(),
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Live Status Row
  // ---------------------------------------------------------------------------
  Widget _buildLiveStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F7FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF00B4D8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Live Server: Normal 99.98%',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0284C7),
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Sinkronisasi: 14:02 WIB',
          style: TextStyle(
            fontSize: 10.5,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Period Filter Chips
  // ---------------------------------------------------------------------------
  Widget _buildPeriodFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_periodOptions.length, (index) {
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
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Region Selector Card
  // ---------------------------------------------------------------------------
  Widget _buildRegionSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: const [
          Icon(Icons.public, color: Color(0xFF0096B4), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Seluruh Indonesia (Nasional)',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 20),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Financial Alert Banner
  // ---------------------------------------------------------------------------
  Widget _buildFinancialAlertCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFFD97706),
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'PERHATIAN KEUANGAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF92400E),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE68A),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Segera',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '18 Antrean Payout Mitra (Rp 1.450.000.000) jatuh tempo verifikasi hari ini.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF78350F),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                // Switch to Keuangan Tab
                widget.onNavigateTab?.call(1);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE047),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Buka Antrean',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF78350F),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: Color(0xFF78350F),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Key Metrics 2x2 Grid
  // ---------------------------------------------------------------------------
  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'GMV Platform',
                value: 'Rp 42,85 M',
                icon: Icons.account_balance_wallet_outlined,
                badgeText: '↗ +18.4%',
                badgeBg: const Color(0xFFDCFCE7),
                badgeFg: const Color(0xFF15803D),
                subText: 'MoM',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Komisi (10%)',
                value: 'Rp 4,28 M',
                icon: Icons.receipt_long_outlined,
                badgeText: '104% Target',
                badgeBg: const Color(0xFFCFFAFE),
                badgeFg: const Color(0xFF0891B2),
                subText: 'Tercapai',
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
                value: '1.420',
                unit: 'Unit',
                icon: Icons.apartment_rounded,
                customSub: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    children: [
                      TextSpan(
                        text: '48 ',
                        style: TextStyle(
                          color: Color(0xFF0284C7),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(text: 'dalam verifikasi'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Tamu Aktif',
                value: '842,1rb',
                icon: Icons.people_outline_rounded,
                subText: '34,2 rb trsk bln ini',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tren Volume Booking Nasional',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '7 Hari Terakhir • Puncak Sabtu (9.420 tiket)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFFAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Live',
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
              painter: _BookingTrendPainter(),
              child: Container(),
            ),
          ),
          const SizedBox(height: 10),

          // Day labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _DayLabel(label: 'Sen', isHighlight: false),
              _DayLabel(label: 'Sel', isHighlight: false),
              _DayLabel(label: 'Rab', isHighlight: false),
              _DayLabel(label: 'Kam', isHighlight: false),
              _DayLabel(label: 'Jum', isHighlight: false),
              _DayLabel(label: 'Sab', isHighlight: true),
              _DayLabel(label: 'Min', isHighlight: false),
            ],
          ),
          const SizedBox(height: 14),

          // Omzet Harian Tertinggi Banner
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
                      'Omzet Harian Tertinggi',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Rp 8,12 M (Sabtu)',
                  style: TextStyle(
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

  // ---------------------------------------------------------------------------
  // 7. Sebaran Hotel Populer
  // ---------------------------------------------------------------------------
  Widget _buildPopularHotelsSection() {
    final list = [
      {
        'title': 'Bali & Nusa Tenggara',
        'count': '480 Hotel Rekanan',
        'occupancy': '88%',
        'image':
            'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=200&auto=format&fit=crop',
        'verified': true,
      },
      {
        'title': 'Jabodetabek Urban',
        'count': '390 Hotel Rekanan',
        'occupancy': '82%',
        'image':
            'https://images.unsplash.com/photo-1555899434-94d1368aa7af?w=200&auto=format&fit=crop',
        'verified': false,
      },
      {
        'title': 'Yogyakarta & Jateng',
        'count': '210 Hotel Rekanan',
        'occupancy': '85%',
        'image':
            'https://images.unsplash.com/photo-1596401057633-54a8fe8ef647?w=200&auto=format&fit=crop',
        'verified': false,
      },
      {
        'title': 'Surabaya & Jatim',
        'count': '180 Hotel Rekanan',
        'occupancy': '79%',
        'image':
            'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=200&auto=format&fit=crop',
        'verified': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Sebaran Hotel Populer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Klaster destinasi dengan okupansi tertinggi',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membuka Peta Okupansi Nasional...')),
                );
              },
              child: const Text(
                'Lihat Peta',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0284C7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...list.map((item) => _buildHotelRegionCard(item)),
      ],
    );
  }

  Widget _buildHotelRegionCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Thumbnail image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item['image'] as String,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: const Color(0xFFE2E8F0),
                child: const Icon(Icons.hotel_rounded, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item['verified'] == true) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF0284C7),
                        size: 15,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item['count'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Occupancy Stat
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item['occupancy'] as String,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D9488),
                ),
              ),
              const Text(
                'Okupansi',
                style: TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. Aksi Cepat Super Admin
  // ---------------------------------------------------------------------------
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat Super Admin',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                label: '+ Buat Promo\nNasional',
                icon: Icons.campaign_rounded,
                bgColor: const Color(0xFF00809A),
                iconColor: Colors.white,
                onTap: () => widget.onNavigateTab?.call(2), // Promo Tab
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                label: 'Audit Legalitas\nMitra',
                icon: Icons.fact_check_rounded,
                bgColor: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0284C7),
                onTap: () => widget.onNavigateTab?.call(3), // Kelola Hotel Tab
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                label: 'Laporan Escrow\nPayout',
                icon: Icons.account_balance_rounded,
                bgColor: const Color(0xFFEEF2FF),
                iconColor: const Color(0xFF4F46E5),
                onTap: () => widget.onNavigateTab?.call(1), // Keuangan Tab
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.25,
              ),
            ),
          ],
        ),
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
// Custom Chart Painter for Booking Trend
// -----------------------------------------------------------------------------
class _BookingTrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 7 columns
    final values = [0.35, 0.45, 0.52, 0.60, 0.70, 0.95, 0.58];
    final count = values.length;
    final columnWidth = 22.0;
    final spacing = (size.width - (count * columnWidth)) / (count - 1);

    final linePoints = <Offset>[];

    for (int i = 0; i < count; i++) {
      final left = i * (columnWidth + spacing);
      final height = values[i] * (size.height - 30);
      final top = size.height - height;
      final isPeak = i == 5; // Sabtu

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

    // Draw peak point dot and tooltip above Saturday (index 5)
    final peakPoint = linePoints[5];
    final dotPaint = Paint()..color = const Color(0xFF00C2FF);
    canvas.drawCircle(peakPoint, 4, dotPaint);

    final whiteDotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(peakPoint, 2, whiteDotPaint);

    // Draw tooltip box above peak point
    final tooltipRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(peakPoint.dx, peakPoint.dy - 16),
        width: 72,
        height: 20,
      ),
      const Radius.circular(10),
    );
    final tooltipBg = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(tooltipRect, tooltipBg);

    // Draw tooltip text "Sabtu: 9.420"
    final textSpan = const TextSpan(
      text: 'Sabtu: 9.420',
      style: TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        peakPoint.dx - (textPainter.width / 2),
        peakPoint.dy - 16 - (textPainter.height / 2),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
