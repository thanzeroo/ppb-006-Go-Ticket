import 'package:flutter/material.dart';

import 'add_room_type_screen.dart';
import 'add_staff_screen.dart';
import 'edit_room_type_screen.dart';
import 'edit_staff_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class _RoomTypeData {
  final String badge;
  final String? secondaryBadge;
  final String name;
  final String sub;
  final int totalUnit;
  final int terjual;
  final int occupancy;
  final String weekdayPrice;
  final String weekendPrice;
  final String weekendNote;
  final List<String> amenities;
  final int photoCount;
  final Color imageGradientStart;
  final Color imageGradientEnd;

  const _RoomTypeData({
    required this.badge,
    this.secondaryBadge,
    required this.name,
    required this.sub,
    required this.totalUnit,
    required this.terjual,
    required this.occupancy,
    required this.weekdayPrice,
    required this.weekendPrice,
    required this.weekendNote,
    required this.amenities,
    required this.photoCount,
    required this.imageGradientStart,
    required this.imageGradientEnd,
  });
}

class _StaffData {
  final String name;
  final String id;
  final String role;
  final String statusLabel;
  final Color statusBg;
  final Color statusFg;
  final Color onlineDotColor;
  final List<String> akses;
  final String wa;

  const _StaffData({
    required this.name,
    required this.id,
    required this.role,
    required this.statusLabel,
    required this.statusBg,
    required this.statusFg,
    required this.onlineDotColor,
    required this.akses,
    required this.wa,
  });
}

class _TransactionData {
  final String name;
  final String amount;
  final String room;
  final String code;
  final String method;
  final String time;

  const _TransactionData({
    required this.name,
    required this.amount,
    required this.room,
    required this.code,
    required this.method,
    required this.time,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ExecutiveDashboardScreen extends StatefulWidget {
  const ExecutiveDashboardScreen({super.key});

  @override
  State<ExecutiveDashboardScreen> createState() =>
      _ExecutiveDashboardScreenState();
}

class _ExecutiveDashboardScreenState extends State<ExecutiveDashboardScreen> {
  // Tab index: 0 = Dashboard, 1 = Kamar & Tarif, 2 = Staf & Tim, 3 = Keuangan
  int _selectedTab = 0;

  static const Color _darkTeal = Color(0xFF005B60);
  static const Color _cyanPrimary = Color(0xFF00C4D4);
  static const Color _bg = Color(0xFFF8FAFC);

  final List<_RoomTypeData> _rooms = const [
    _RoomTypeData(
      badge: 'Suite Room',
      name: 'Standard Twin Suite',
      sub: '2 Tamu • 32 m² • Twin Beds • Garden View',
      totalUnit: 20,
      terjual: 16,
      occupancy: 80,
      weekdayPrice: 'Rp 550.000',
      weekendPrice: 'Rp 680.000',
      weekendNote: 'Standar Weekend',
      amenities: ['Garden View', 'Rain Shower', 'Air Conditioner'],
      photoCount: 6,
      imageGradientStart: Color(0xFF334155),
      imageGradientEnd: Color(0xFF1E293B),
    ),
    _RoomTypeData(
      badge: 'Deluxe Series',
      secondaryBadge: '↗ Surge +20%',
      name: 'Deluxe Ocean View',
      sub: '2 Tamu • 38 m² • King Bed • Balkon Pantai',
      totalUnit: 15,
      terjual: 12,
      occupancy: 80,
      weekdayPrice: 'Rp 850.000',
      weekendPrice: 'Rp 1.100.000',
      weekendNote: 'Surge AI Aktif',
      amenities: ['Bathtub', 'Sea View', 'Smart TV', 'Wifi 100Mbps'],
      photoCount: 8,
      imageGradientStart: Color(0xFF1E3A8A),
      imageGradientEnd: Color(0xFF0F172A),
    ),
    _RoomTypeData(
      badge: 'Villa Signature',
      secondaryBadge: '✔ Best Seller',
      name: 'Executive Royal Pool Villa',
      sub: '4 Tamu • 110 m² • 2 King Beds • Private Pool',
      totalUnit: 10,
      terjual: 8,
      occupancy: 80,
      weekdayPrice: 'Rp 2.450.000',
      weekendPrice: 'Rp 2.950.000',
      weekendNote: 'Tarif Dinamis',
      amenities: ['Private Pool', '24h Butler', 'Espresso Bar'],
      photoCount: 12,
      imageGradientStart: Color(0xFF064E3B),
      imageGradientEnd: Color(0xFF022C22),
    ),
  ];

  final List<_StaffData> _staff = const [
    _StaffData(
      name: 'Ni Made Anggreni, S.Tr.Par',
      id: '#STF-2024-004',
      role: 'Front Office Lead / Senior',
      statusLabel: 'Aktif Bertugas',
      statusBg: Color(0xFFE0F2FE),
      statusFg: Color(0xFF0284C7),
      onlineDotColor: Color(0xFF16A34A),
      akses: ['Verifikasi Booking', 'RFID Smart Lock', 'Otorisasi Refund'],
      wa: '+62 813-3982-1140',
    ),
    _StaffData(
      name: 'Budi Santoso',
      id: '#HK-2011',
      role: 'Housekeeping Supervisor (S...)',
      statusLabel: 'Aktif Bertugas',
      statusBg: Color(0xFFE0F2FE),
      statusFg: Color(0xFF0284C7),
      onlineDotColor: Color(0xFF16A34A),
      akses: ['Checklist Kebersihan', 'Logistik Gudang', 'Lapor Kerusakan'],
      wa: '+62 813-8822-9901',
    ),
    _StaffData(
      name: 'Hendra Wijaya',
      id: '#TK-3004',
      role: 'Senior Maintenance Technic',
      statusLabel: 'On-Site (#204)',
      statusBg: Color(0xFFE0F2FE),
      statusFg: Color(0xFF0284C7),
      onlineDotColor: Color(0xFF0284C7),
      akses: ['Tiket Kerusakan', 'Status Kamar OOO'],
      wa: '+62 812-3333-4444',
    ),
    _StaffData(
      name: 'Siti Nurhaliza',
      id: '#FO-1052',
      role: 'Night Audit Front Office',
      statusLabel: 'Terjadwal 23:00',
      statusBg: Color(0xFFF1F5F9),
      statusFg: Color(0xFF64748B),
      onlineDotColor: Color(0xFF94A3B8),
      akses: ['Tutup Buku Kasir EOD', 'Check-in Malam'],
      wa: '+62 821-9999-0000',
    ),
  ];

  final List<_TransactionData> _transactions = const [
    _TransactionData(
      name: 'Bpk. Hendra Kusuma',
      amount: '+Rp 8.700.000',
      room: 'Executive Ocean Panorama Suite • 3 Malam',
      code: '#BK-2025-8821',
      method: 'QRIS Go Ticket Instant',
      time: 'Hari ini, 11:20 WITA',
    ),
    _TransactionData(
      name: 'Ibu Natasha Wibowo',
      amount: '+Rp 4.350.000',
      room: 'Grand Deluxe Pool View • 2 Malam',
      code: '#BK-2025-8819',
      method: 'BCA Virtual Account',
      time: 'Hari ini, 09:14 WITA',
    ),
    _TransactionData(
      name: 'Mr. Alexander Smith',
      amount: '+Rp 2.900.000',
      room: 'Royal Garden Villa • 1 Malam (+ Spa Package)',
      code: '#BK-2025-8804',
      method: 'Kartu Kredit (Visa International)',
      time: 'Kemarin, 19:40 WITA',
    ),
    _TransactionData(
      name: 'Bpk. Kevin Pratama',
      amount: '+Rp 1.450.000',
      room: 'Deluxe King Room • Front Desk Walk-In',
      code: '#BK-2025-8790',
      method: 'EDC Mandiri Terminal 01',
      time: 'Kemarin, 14:15 WITA',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 4 Tabs in exact order matching reference image:
    // 1. Dashboard, 2. Kamar & Tarif, 3. Staf & Tim, 4. Keuangan
    final tabs = [
      (Icons.bar_chart_rounded, 'Dashboard'),
      (Icons.bed_outlined, 'Kamar & Tarif'),
      (Icons.badge_outlined, 'Staf & Tim'),
      (Icons.account_balance_wallet_outlined, 'Keuangan'),
    ];

    final tabViews = [
      _DashboardView(darkTeal: _darkTeal, cyan: _cyanPrimary),
      _KamarTarifView(rooms: _rooms, darkTeal: _darkTeal, cyan: _cyanPrimary),
      _StafTimView(staff: _staff, darkTeal: _darkTeal, cyan: _cyanPrimary),
      _KeuanganView(transactions: _transactions, darkTeal: _darkTeal, cyan: _cyanPrimary),
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopAppBar(),

            // Content
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: tabViews,
              ),
            ),

            // Bottom Navigation Bar
            _buildBottomNav(tabs),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (Navigator.canPop(context)) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: _darkTeal,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'GO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Go Ticket Administrator',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _darkTeal,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(List<(IconData, String)> tabs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final sel = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tabs[i].$1,
                      color: sel ? _darkTeal : const Color(0xFF94A3B8),
                      size: 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tabs[i].$2,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                        color: sel ? _darkTeal : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 1 – DASHBOARD ADMINISTRATOR
// ═══════════════════════════════════════════════════════════════

class _DashboardView extends StatefulWidget {
  final Color darkTeal;
  final Color cyan;

  const _DashboardView({required this.darkTeal, required this.cyan});

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
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
        // Title
        const Text(
          'Dashbord Administrator',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFFBAE6FD) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? const Color(0xFF7DD3FC) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sel) ...[
                        const Icon(Icons.circle, size: 6, color: Color(0xFF0369A1)),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        _periods[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                          color: sel ? const Color(0xFF0369A1) : const Color(0xFF64748B),
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
            const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
            const SizedBox(width: 6),
            const Text(
              '18 Okt – 24 Okt 2025',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.sync, size: 13, color: widget.darkTeal),
                const SizedBox(width: 4),
                Text(
                  'Sinkron OTA otomatis',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: widget.darkTeal),
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
                  const Text('Total Pendapatan Kotor', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.account_balance_outlined, size: 16, color: widget.darkTeal),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Rp 124.850.000',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_upward, size: 9, color: Color(0xFF16A34A)),
                        SizedBox(width: 2),
                        Text('+14.2% vs bln lalu', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Target tercapai 92%', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
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
                    Text('Rata-Rata Okupansi', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    SizedBox(height: 2),
                    Text('84%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    SizedBox(height: 2),
                    Text('RevPAR: Rp 920.000', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                    Text('ADR: Rp 1.150.000', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                  ],
                ),
              ),
              // Gauge
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 65,
                    height: 65,
                    child: CircularProgressIndicator(
                      value: 0.84,
                      strokeWidth: 6,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: widget.darkTeal,
                    ),
                  ),
                  Icon(Icons.hotel, color: widget.darkTeal, size: 20),
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
                        const Text('Kamar Terjual', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFF0FDFE), borderRadius: BorderRadius.circular(4)),
                          child: Icon(Icons.key, size: 12, color: widget.darkTeal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('142', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const Text('Nights', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    const Text('Dari 45 total inventaris unit', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
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
                        const Text('Kepuasan Tamu', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.star, size: 12, color: Color(0xFFD97706)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('4.9', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const Text('/ 5.0', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    const Text('1.280 ulasan terverifikasi', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Tren Okupansi & Penjualan Mingguan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      SizedBox(height: 2),
                      Text('Kinerja harian vs target batas (85%)', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                    ],
                  ),
                  const Icon(Icons.more_vert, size: 16, color: Color(0xFF94A3B8)),
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
                        ? widget.darkTeal
                        : isCyan
                            ? widget.cyan
                            : const Color(0xFFBFDBFE);

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(b['label'] as String, style: const TextStyle(fontSize: 8, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Container(
                            height: 80 * val,
                            width: 28,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            b['day'] as String,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
                              color: isBold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _LegendDot(color: Color(0xFF005B60), label: 'Kamar (75%)'),
                  SizedBox(width: 12),
                  _LegendDot(color: Color(0xFF00C4D4), label: 'F&B & Bar (15%)'),
                  SizedBox(width: 12),
                  _LegendDot(color: Color(0xFFE2E8F0), label: 'Ekstra (10%)'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Card 4: Syarat & Ketentuan Hotel
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.darkTeal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_outlined, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Syarat & Ketentuan Hotel',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Kebijakan', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text('Ketentuan operasional & kebijakan tamu', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: const Icon(Icons.chevron_right, size: 14, color: Color(0xFF0284C7)),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 2 – KELOLA MASTER KAMAR & TARIF
// ═══════════════════════════════════════════════════════════════

class _KamarTarifView extends StatefulWidget {
  final List<_RoomTypeData> rooms;
  final Color darkTeal;
  final Color cyan;

  const _KamarTarifView({
    required this.rooms,
    required this.darkTeal,
    required this.cyan,
  });

  @override
  State<_KamarTarifView> createState() => _KamarTarifViewState();
}

class _KamarTarifViewState extends State<_KamarTarifView> {
  int _categoryIndex = 0;
  final _categories = ['Semua Kamar (45)', 'Ocean View (15)', 'Private Villa (10)'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title
        const Text(
          'Kelola Master Kamar & Tarif',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        // Bright Cyan Pill Button: + Tambah Tipe Kamar Baru
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddRoomTypeScreen()),
            );
          },
          icon: const Icon(Icons.add_circle_outline, size: 16),
          label: const Text(
            '+ Tambah Tipe Kamar Baru',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.cyan,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
        ),

        const SizedBox(height: 12),
        // Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_categories.length, (i) {
              final sel = _categoryIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _categoryIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? widget.darkTeal : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _categories[i],
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

        const SizedBox(height: 16),
        // Room Cards
        ...widget.rooms.map((r) => _buildRoomCard(r)),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRoomCard(_RoomTypeData room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Image Header
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [room.imageGradientStart, room.imageGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        room.badge,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: widget.darkTeal),
                      ),
                    ),
                    if (room.secondaryBadge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.darkTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          room.secondaryBadge!,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      room.sub,
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quota Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.hotel, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text('${room.totalUnit} Unit Total', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                      ],
                    ),
                    Text(
                      '${room.terjual} Terjual (${room.occupancy}% Okupansi)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: widget.darkTeal),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: room.occupancy / 100.0,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation(widget.darkTeal),
                  ),
                ),

                const SizedBox(height: 12),
                // Price Section
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Weekday (Sen – Kam)', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                            const SizedBox(height: 2),
                            Text(room.weekdayPrice, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                            const Text('per malam', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Weekend (Jum – Min)', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                            const SizedBox(height: 2),
                            Text(room.weekendPrice, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: widget.darkTeal)),
                            Text(room.weekendNote, style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                // Amenities Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: room.amenities.map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(a, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),
                // 2 Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.photo_library_outlined, size: 14),
                        label: Text('Galeri Foto (${room.photoCount})'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0FDFE),
                          foregroundColor: const Color(0xFF0369A1),
                          side: const BorderSide(color: Color(0xFFBAE6FD)),
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditRoomTypeScreen(
                                roomName: room.name,
                                category: room.badge,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text('Edit Kamar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.darkTeal,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          padding: const EdgeInsets.symmetric(vertical: 9),
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
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 3 – MANAJEMEN STAF & HAK AKSES
// ═══════════════════════════════════════════════════════════════

class _StafTimView extends StatefulWidget {
  final List<_StaffData> staff;
  final Color darkTeal;
  final Color cyan;

  const _StafTimView({
    required this.staff,
    required this.darkTeal,
    required this.cyan,
  });

  @override
  State<_StafTimView> createState() => _StafTimViewState();
}

class _StafTimViewState extends State<_StafTimView> {
  int _deptIndex = 0;
  final _depts = ['Semua (18)', 'Front Office (6)', 'Housekeeping (8)'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title
        const Text(
          'Manajemen Staf & Hak Akses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        // Bright Cyan Pill Button: + Tambah Karyawan Baru
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddStaffScreen()),
            );
          },
          icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
          label: const Text(
            '+ Tambah Karyawan Baru',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.cyan,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 8),

        // Ekspor Jadwal Shift
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_outlined, size: 14),
          label: const Text('Ekspor Jadwal Shift (PDF/Excel)'),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFF1F5F9),
            foregroundColor: const Color(0xFF334155),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            minimumSize: const Size.fromHeight(42),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),

        const SizedBox(height: 16),
        // Status Roster Hari Ini
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.calendar_month_outlined, size: 14, color: Color(0xFF0F172A)),
                SizedBox(width: 6),
                Text('Status Roster Hari Ini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
              child: const Text('Live Sync', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 2 Shift Status Cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('07:00 – 15:00', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                        Spacer(),
                        Icon(Icons.circle, size: 6, color: Color(0xFF00C4D4)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text('6 Karyawan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const Text('Shift Pagi (Active Now)', style: TextStyle(fontSize: 9, color: Color(0xFF0284C7), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('15:00 – 23:00', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                        Spacer(),
                        Icon(Icons.access_time, size: 10, color: Color(0xFF94A3B8)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text('5 Karyawan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const Text('Shift Siang (Terjadwal)', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),
        // Department Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_depts.length, (i) {
              final sel = _deptIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _deptIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? widget.darkTeal : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? widget.darkTeal : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    _depts[i],
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
        // Staff List
        ...widget.staff.map((s) => _buildStaffCard(s)),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStaffCard(_StaffData s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFCCFBF1),
                    child: Text(
                      s.name[0],
                      style: TextStyle(fontWeight: FontWeight.w900, color: widget.darkTeal, fontSize: 16),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.onlineDotColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          s.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                          child: Text(s.id, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(s.role, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: s.statusBg, borderRadius: BorderRadius.circular(10)),
                child: Text(s.statusLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: s.statusFg)),
              ),
            ],
          ),

          const SizedBox(height: 10),
          // Otorisasi Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('OTORISASI & HAK AKSES:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: s.akses.map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text('✔ $a', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 12, color: Color(0xFF22C55E)),
              const SizedBox(width: 4),
              Text('WhatsApp: ${s.wa}', style: const TextStyle(fontSize: 10, color: Color(0xFF475569))),
            ],
          ),

          const SizedBox(height: 10),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditStaffScreen(
                          staffName: s.name,
                          staffId: s.id,
                          initialRole: s.role,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 12),
                  label: const Text('Atur Shift'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditStaffScreen(
                          staffName: s.name,
                          staffId: s.id,
                          initialRole: s.role,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shield_outlined, size: 12),
                  label: const Text('Kelola Akses'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0FDFE),
                    foregroundColor: const Color(0xFF0369A1),
                    side: const BorderSide(color: Color(0xFFBAE6FD)),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 4 – BUKU KAS & KEUANGAN
// ═══════════════════════════════════════════════════════════════

class _KeuanganView extends StatefulWidget {
  final List<_TransactionData> transactions;
  final Color darkTeal;
  final Color cyan;

  const _KeuanganView({
    required this.transactions,
    required this.darkTeal,
    required this.cyan,
  });

  @override
  State<_KeuanganView> createState() => _KeuanganViewState();
}

class _KeuanganViewState extends State<_KeuanganView> {
  int _periodMode = 0; // 0 = Per Bulan, 1 = Per Tahun
  int _monthPillIndex = 0; // 0 = Bulan Ini (Okt)
  final _monthPills = ['Bulan Ini (Okt)', 'Q1 2025', 'Q2 2025', 'Q3 2025'];

  int _kasFilterIndex = 0;
  final _kasFilters = ['Semua Masuk', 'Sukses Settled', 'Booking Masuk Hari Ini'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            children: [
              const Icon(Icons.sync_alt, size: 16, color: Color(0xFF0284C7)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('EXECUTIVE LEDGER • Real-Time Sync', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                    Text('GM & Owner Dashboard • Read-Only', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(4)),
                child: const Text('Audit Locked', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Filter Switcher Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _periodMode = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _periodMode == 0 ? widget.darkTeal : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Per Bulan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _periodMode == 0 ? Colors.white : const Color(0xFF475569))),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _periodMode = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _periodMode == 1 ? widget.darkTeal : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Per Tahun', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _periodMode == 1 ? Colors.white : const Color(0xFF475569))),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.calendar_today, size: 12, color: Color(0xFF64748B)),
                  SizedBox(width: 4),
                  Text('2025 (YTD)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        // Month pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_monthPills.length, (i) {
              final sel = _monthPillIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _monthPillIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFFBAE6FD) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? const Color(0xFF7DD3FC) : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    _monthPills[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: sel ? const Color(0xFF0369A1) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),
        // Card 1: TOTAL PENDAPATAN MASUK (GROSS INFLOW) -> GORGEOUS DEEP TEAL GRADIENT CARD
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF004D54), Color(0xFF00666E), Color(0xFF007A87)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF004D54).withValues(alpha: 0.3),
                blurRadius: 12,
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
                  Row(
                    children: const [
                      Icon(Icons.account_balance, size: 16, color: Colors.white70),
                      SizedBox(width: 6),
                      Text(
                        'TOTAL PENDAPATAN MASUK (GROSS INFLOW)',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.cyan,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '+16.8% YoY',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF00383D)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Rp 1.485.200.000',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
              ),
              const SizedBox(height: 2),
              const Text(
                'Akumulasi penerimaan bruto per 24 Oktober 2025',
                style: TextStyle(fontSize: 9, color: Colors.white60),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Colors.white24),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nett Settlement Hotel', style: TextStyle(fontSize: 9, color: Colors.white70)),
                        SizedBox(height: 2),
                        Text('Rp 1.336.680.000', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Potongan Komisi OTA', style: TextStyle(fontSize: 9, color: Colors.white70)),
                        SizedBox(height: 2),
                        Text('Rp 148.520.000', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFBAE6FD))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Row 2 Cards: 10 Bulan & 48 Kamar
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: const Color(0xFFF0FDFE), borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.calendar_month, size: 12, color: Color(0xFF0284C7)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(4)),
                          child: const Text('10 Bulan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('Rata-rata Pendapatan', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                    const SizedBox(height: 1),
                    const Text('Rp 148,5 Jt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const Text('/ bulan berjalan', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
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
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: const Color(0xFFF0FDFE), borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.hotel, size: 12, color: Color(0xFF0284C7)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(4)),
                          child: const Text('48 Kamar', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('RevPAR Rata-rata', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                    const SizedBox(height: 1),
                    const Text('Rp 820.000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
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
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    decoration: BoxDecoration(color: const Color(0xFFF0FDFE), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.trending_up, size: 14, color: Color(0xFF0284C7)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Legend
              Row(
                children: const [
                  _LegendDot(color: Color(0xFF005B60), label: 'Bruto (Gross)'),
                  SizedBox(width: 10),
                  _LegendDot(color: Color(0xFF00C4D4), label: 'Bersih (Nett)'),
                  SizedBox(width: 10),
                  _LegendDot(color: Color(0xFFBAE6FD), label: 'OTA Fee'),
                ],
              ),
              const SizedBox(height: 12),

              // Smooth Curved Spline Area Chart
              SizedBox(
                height: 110,
                width: double.infinity,
                child: CustomPaint(
                  painter: _RevenueChartPainter(
                    tealColor: widget.darkTeal,
                    cyanColor: widget.cyan,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Jan', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                  Text('Mar', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                  Text('Mei', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                  Text('Jul', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                  Text('Sep', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                  Text('Okt (Kini)', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF005B60))),
                ],
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                    child: const Text('Tumbuh +16.8% dari 2024', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(4)),
                    child: const Text('YTD 2025 →', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('2023: Rp 1.12 M • 2024: Rp 1.27 M', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Card 3: Buku Kas Uang Masuk
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Buku Kas Uang Masuk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(width: 6),
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
                  const Spacer(),
                  const Icon(Icons.receipt_long_outlined, size: 16, color: Color(0xFF64748B)),
                ],
              ),
              const Text('Log transaksi dana masuk otomatis', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
              const SizedBox(height: 10),

              // Filter pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_kasFilters.length, (i) {
                    final sel = _kasFilterIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _kasFilterIndex = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: sel ? widget.darkTeal : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: sel ? widget.darkTeal : const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          _kasFilters[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 12),
              // Transaction list
              ...widget.transactions.map((tx) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Uang Masuk (+)', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                          ),
                          Text(tx.amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tx.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          Text(tx.code, style: const TextStyle(fontSize: 9, color: Color(0xFF0284C7), fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(tx.room, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
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
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: widget.darkTeal, shape: BoxShape.circle),
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
                        foregroundColor: widget.darkTeal,
                        side: BorderSide(color: widget.darkTeal),
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
                        backgroundColor: widget.darkTeal,
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

class _RevenueChartPainter extends CustomPainter {
  final Color tealColor;
  final Color cyanColor;

  _RevenueChartPainter({required this.tealColor, required this.cyanColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Data points normalized (0 to 1)
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
