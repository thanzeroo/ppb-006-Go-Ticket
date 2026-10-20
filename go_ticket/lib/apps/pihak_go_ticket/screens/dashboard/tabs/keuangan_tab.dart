import 'package:flutter/material.dart';

/// Tab 1: Laporan Keuangan & Transaksi (Image 4)
class KeuanganTab extends StatefulWidget {
  const KeuanganTab({super.key});

  @override
  State<KeuanganTab> createState() => _KeuanganTabState();
}

class _KeuanganTabState extends State<KeuanganTab> {
  int _selectedPeriod = 1; // 0 = Harian, 1 = Bulanan, 2 = Tahunan

  @override
  Widget build(BuildContext context) {
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
                    'Laporan Keuangan & Transaksi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Rekapitulasi pendapatan kotor, omzet bersih, komisi sistem, dan ekspor laporan resmi.',
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

        // 3. Date Range Picker Bar
        _buildDateRangePickerBar(),
        const SizedBox(height: 14),

        // 4. Hero Card: PENDAPATAN BERSIH (NET REVENUE)
        _buildNetRevenueHeroCard(),
        const SizedBox(height: 12),

        // 5. Two Metric Cards (184 Transaksi Lunas & +18.4% MoM)
        Row(
          children: [
            Expanded(
              child: _buildMiniMetricCard(
                icon: Icons.check_circle_outline_rounded,
                value: '184',
                label: 'Transaksi Lunas',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniMetricCard(
                icon: Icons.trending_up_rounded,
                value: '+18.4%',
                label: 'Pertumbuhan MoM',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 6. Metode Pembayaran Card with multi-segment bar
        _buildPaymentMethodsCard(),
        const SizedBox(height: 18),

        // 7. Transaksi Pembookingan List
        _buildRecentTransactionsSection(),
        const SizedBox(height: 18),

        // 8. Ekspor & Cetak Berkas Card
        _buildExportReportCard(),
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
  // Date Range Picker Bar
  // ---------------------------------------------------------------------------
  Widget _buildDateRangePickerBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 16,
              color: Color(0xFF0096B4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'RENTANG TANGGAL',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '01 Okt 2025 – 26 Okt 2025',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.tune_rounded,
            color: Color(0xFF64748B),
            size: 18,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Hero Card: PENDAPATAN BERSIH
  // ---------------------------------------------------------------------------
  Widget _buildNetRevenueHeroCard() {
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
          // Top row: LIVE AUDIT & Shield
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E5FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE AUDIT PERIODE AKTIF',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE0F7FA),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF00E5FF),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          const Text(
            'PENDAPATAN BERSIH (NET REVENUE)',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB2EBF2),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Big Amount
          const Text(
            'Rp 136.240.000',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle info
          Row(
            children: const [
              Icon(Icons.info_outline_rounded, color: Color(0xFF80DEEA), size: 13),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Bersih setelah potongan diskon voucher & fee operasional',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFFB2EBF2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
                  children: const [
                    Text(
                      'Total Pendapatan Kotor',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFFB2EBF2),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Rp 148.520.000',
                      style: TextStyle(
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
                  children: const [
                    Text(
                      'Rata-rata ADR / Booking',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFFB2EBF2),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Rp 807.170',
                      style: TextStyle(
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
  // Metode Pembayaran Card
  // ---------------------------------------------------------------------------
  Widget _buildPaymentMethodsCard() {
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
                children: const [
                  Icon(Icons.pie_chart_outline_rounded,
                      size: 18, color: Color(0xFF0096B4)),
                  SizedBox(width: 8),
                  Text(
                    'Metode Pembayaran',
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
                child: const Text(
                  'Oktober 2025',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Multi-Segment Bar (54% Teal, 32% Cyan, 14% Slate)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: const [
                  Expanded(
                    flex: 54,
                    child: ColoredBox(color: Color(0xFF006678)),
                  ),
                  SizedBox(width: 2),
                  Expanded(
                    flex: 32,
                    child: ColoredBox(color: Color(0xFF38BDF8)),
                  ),
                  SizedBox(width: 2),
                  Expanded(
                    flex: 14,
                    child: ColoredBox(color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Breakdown List
          _buildPaymentBreakdownRow(
            color: const Color(0xFF006678),
            label: 'QRIS & E-Wallet',
            share: '54% transaksi',
            amount: 'Rp 80.200.000',
          ),
          const SizedBox(height: 10),
          _buildPaymentBreakdownRow(
            color: const Color(0xFF38BDF8),
            label: 'Virtual Account Bank',
            share: '32% transaksi',
            amount: 'Rp 47.520.000',
          ),
          const SizedBox(height: 10),
          _buildPaymentBreakdownRow(
            color: const Color(0xFF94A3B8),
            label: 'Kartu Kredit / Debit',
            share: '14% transaksi',
            amount: 'Rp 20.800.000',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdownRow({
    required Color color,
    required String label,
    required String share,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    share,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Transaksi Pembookingan
  // ---------------------------------------------------------------------------
  Widget _buildRecentTransactionsSection() {
    final transactions = [
      {
        'id': '#TRX-99214',
        'badge': 'Lunas (BCA VA)',
        'room': 'Executive Suite',
        'guest': 'Maya Anggraini',
        'date': '26 Okt 2025 • 14:22 WIB',
        'amount': 'Rp 2.450.000',
      },
      {
        'id': '#TRX-99215',
        'badge': 'Lunas (QRIS)',
        'room': 'Deluxe Ocean View',
        'guest': 'Dimas Raditya',
        'date': '26 Okt 2025 • 11:05 WIB',
        'amount': 'Rp 850.000',
      },
      {
        'id': '#TRX-99210',
        'badge': 'Lunas (Mandiri)',
        'room': 'The Grand Amora',
        'guest': 'Aditya Pratama',
        'date': '24 Okt 2025 • 09:40 WIB',
        'amount': 'Rp 1.700.000',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transaksi Pembookingan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menampilkan seluruh riwayat transaksi...')),
                );
              },
              child: const Text(
                'Lihat Semua',
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
        ...transactions.map((tx) => _buildTransactionCard(tx)),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, String> tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Code & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tx['id']!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tx['badge']!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF007A94),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Room & Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tx['room']!,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                tx['amount']!,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF006678),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Guest & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tx['guest']!,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
              Row(
                children: [
                  Text(
                    tx['date']!,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Ekspor & Cetak Berkas Card
  // ---------------------------------------------------------------------------
  Widget _buildExportReportCard() {
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
          Row(
            children: const [
              Icon(Icons.print_outlined, color: Color(0xFF0096B4), size: 19),
              SizedBox(width: 8),
              Text(
                'Ekspor & Cetak Berkas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Laporan dilengkapi stempel digital resmi, tanda tangan QR verifikasi, dan nomor registrasi audit platform Go Ticket.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Button 1: Unduh Laporan PDF Resmi
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mengunduh Laporan Keuangan PDF Resmi...')),
                );
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 17, color: Colors.white),
              label: const Text(
                'Unduh Laporan PDF Resmi',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C2FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Button 2: Ekspor Format CSV / Excel
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mengekspor data transaksi ke file Excel/CSV...')),
                );
              },
              icon: const Icon(Icons.table_chart_outlined,
                  size: 17, color: Color(0xFF007A94)),
              label: const Text(
                'Ekspor Format CSV / Excel',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF007A94),
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFE0F7FA),
                side: const BorderSide(color: Color(0xFFBAE6FD)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
