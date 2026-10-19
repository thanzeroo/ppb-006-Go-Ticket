import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS (local, presentational only)
// ─────────────────────────────────────────────────────────────────────────────

class _RoomType {
  final String badge;
  final String name;
  final String sub;
  final int totalUnit;
  final int terjual;
  final int occupancy;
  final String weekdayPrice;
  final String weekendPrice;
  final String weekendNote;
  final bool isSurge;
  final bool isBestSeller;
  final List<String> amenities;
  final int photoCount;

  const _RoomType({
    required this.badge,
    required this.name,
    required this.sub,
    required this.totalUnit,
    required this.terjual,
    required this.occupancy,
    required this.weekdayPrice,
    required this.weekendPrice,
    required this.weekendNote,
    this.isSurge = false,
    this.isBestSeller = false,
    required this.amenities,
    required this.photoCount,
  });
}

class _StaffMember {
  final String name;
  final String id;
  final String role;
  final String statusLabel;
  final Color statusColor;
  final List<String> akses;
  final String wa;

  const _StaffMember({
    required this.name,
    required this.id,
    required this.role,
    required this.statusLabel,
    required this.statusColor,
    required this.akses,
    required this.wa,
  });
}

class _TxItem {
  final String label;
  final String guestName;
  final String roomDesc;
  final String code;
  final String method;
  final String time;
  final String amount;

  const _TxItem({
    required this.label,
    required this.guestName,
    required this.roomDesc,
    required this.code,
    required this.method,
    required this.time,
    required this.amount,
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
  int _selectedTab = 0;

  static const Color _teal = Color(0xFF0D6B6B);
  static const Color _bg = Color(0xFFF3F6FA);

  final List<_RoomType> _rooms = const [
    _RoomType(
      badge: 'Suite Room',
      name: 'Standard Twin Suite',
      sub: '2 Tamu • 37 m² • Twin Beds • Garden View',
      totalUnit: 20, terjual: 16, occupancy: 80,
      weekdayPrice: 'Rp 550.000',
      weekendPrice: 'Rp 680.000',
      weekendNote: 'Standar Weekend',
      amenities: ['Garden View', 'Rain Shower', 'Air Conditioner'],
      photoCount: 6,
    ),
    _RoomType(
      badge: 'Deluxe Series',
      name: 'Deluxe Ocean View',
      sub: '2 Tamu • 38 m² • King Bed • Balkon Pantai',
      totalUnit: 15, terjual: 12, occupancy: 80,
      weekdayPrice: 'Rp 850.000',
      weekendPrice: 'Rp 1.100.000',
      weekendNote: 'Surge AI Aktif',
      isSurge: true,
      amenities: ['Bathtub', 'Sea View', 'Smart TV', 'Wifi 100Mbps'],
      photoCount: 8,
    ),
    _RoomType(
      badge: 'Villa Signature',
      name: 'Executive Royal Pool Villa',
      sub: '4 Tamu • 110 m² • 2 King Beds • Private Pool',
      totalUnit: 10, terjual: 8, occupancy: 80,
      weekdayPrice: 'Rp 2.450.000',
      weekendPrice: 'Rp 2.950.000',
      weekendNote: 'Tarif Dinamis',
      isBestSeller: true,
      amenities: ['Private Pool', '24h Butler', 'Espresso Bar'],
      photoCount: 12,
    ),
  ];

  final List<_StaffMember> _staff = const [
    _StaffMember(
      name: 'Budi Santoso', id: '#HK-2011',
      role: 'Housekeeping Supervisor (S...',
      statusLabel: 'Aktif Bertugas',
      statusColor: Color(0xFF0D9B9B),
      akses: ['Checklist Kebersihan', 'Logistik Gudang', 'Lapor Kerusakan'],
      wa: '+62 813-8822-9901',
    ),
    _StaffMember(
      name: 'Hendra Wijaya', id: '#TK-3004',
      role: 'Senior Maintenance Technic',
      statusLabel: 'On-Site (#204)',
      statusColor: Color(0xFF2563EB),
      akses: ['Tiket Kerusakan', 'Status Kamar OOO'],
      wa: '+62 812-3333-4444',
    ),
    _StaffMember(
      name: 'Siti Nurhaliza', id: '#FO-1052',
      role: 'Night Audit Front Office',
      statusLabel: 'Terjadwal 23:00',
      statusColor: Color(0xFF9CA3AF),
      akses: ['Tutup Buku Kasir EOD', 'Check-in Malam'],
      wa: '+62 821-9999-0000',
    ),
  ];

  final List<_TxItem> _transactions = const [
    _TxItem(
      label: 'Uang Masuk (+)',
      guestName: 'Bpk. Hendra Kusuma',
      roomDesc: 'Executive Ocean Panorama Suite • 3 Malam',
      code: '#BK-2025-8821',
      method: 'QR/IS Go Ticket Instant',
      time: 'Hari ini, 10:20 WIB',
      amount: '+Rp 8.700.000',
    ),
    _TxItem(
      label: 'Uang Masuk (+)',
      guestName: 'Ibu Natasha Wibowo',
      roomDesc: 'Grand Deluxe Pool View • 2 Malam',
      code: '#BK-2023-9019',
      method: 'BCA Virtual Account',
      time: 'Hari ini, 09:14 WIB',
      amount: '+Rp 4.350.000',
    ),
    _TxItem(
      label: 'Uang Masuk (+)',
      guestName: 'Mr. Alexander Smith',
      roomDesc: 'Royal Garden Villa • 1 Malam (+ Spa Package)',
      code: '#BK-2023-9086',
      method: 'Kartu Kredit Visa (International)',
      time: 'Kemarin, Fr:40 WIB',
      amount: '+Rp 2.900.000',
    ),
    _TxItem(
      label: 'Uang Masuk (+)',
      guestName: 'Bpk. Kevin Pratama',
      roomDesc: 'Deluxe King Room • Front Desk Walk-In',
      code: '#BK-2025-9730',
      method: 'FDC Mandiri Terminal 01',
      time: 'Kemarin, 14:15 WIB',
      amount: '+Rp 1.450.000',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Icons.bar_chart_rounded, 'Dashboard'),
      (Icons.bed_outlined, 'Kamar & Tarif'),
      (Icons.receipt_long_outlined, 'Keuangan'),
      (Icons.group_outlined, 'Staf & Tim'),
    ];

    final tabViews = [
      _DashboardTabView(teal: _teal),
      _KamarTarifTabView(rooms: _rooms, teal: _teal),
      _KeuanganTabView(transactions: _transactions, teal: _teal),
      _StafTimTabView(staff: _staff, teal: _teal),
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: _teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('GO',
                        style: TextStyle(color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Go Ticket Administrator',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B))),
                  ),
                  CircleAvatar(radius: 18, backgroundColor: _teal,
                    child: const Icon(Icons.person, color: Colors.white, size: 18)),
                ],
              ),
            ),
            Expanded(child: IndexedStack(index: _selectedTab, children: tabViews)),
            // Bottom nav
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final sel = _selectedTab == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = i),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tabs[i].$1,
                              color: sel ? _teal : const Color(0xFF94A3B8),
                              size: 22),
                            const SizedBox(height: 3),
                            Text(tabs[i].$2,
                              style: TextStyle(fontSize: 10,
                                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                color: sel ? _teal : const Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 1 – DASHBOARD
// ═══════════════════════════════════════════════════════════════

class _DashboardTabView extends StatefulWidget {
  final Color teal;
  const _DashboardTabView({required this.teal});
  @override
  State<_DashboardTabView> createState() => _DashboardTabViewState();
}

class _DashboardTabViewState extends State<_DashboardTabView> {
  int _periodIndex = 1;
  final _periods = ['Hari Ini', '7 Hari Terakhir', 'Bulan Ini', 'Kuartal Q4'];
  final _chartData = const [
    {'day': 'Sen', 'val': 0.78},
    {'day': 'Sel', 'val': 0.82},
    {'day': 'Rab', 'val': 0.80},
    {'day': 'Kam', 'val': 0.85},
    {'day': 'Jum', 'val': 0.94, 'hl': true},
    {'day': 'Sab', 'val': 0.96, 'bold': true},
    {'day': 'Min', 'val': 0.88},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Dashbord Administrator',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B))),
        const SizedBox(height: 14),
        // Period pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: List.generate(_periods.length, (i) {
            final sel = _periodIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _periodIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? widget.teal : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? widget.teal : const Color(0xFFE2E8F0)),
                ),
                child: Text(_periods[i],
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : const Color(0xFF64748B))),
              ),
            );
          })),
        ),
        const SizedBox(height: 12),
        // Date range
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(Icons.calendar_today_outlined, size: 14, color: widget.teal),
            const SizedBox(width: 6),
            const Text('18 Okt – 24 Okt 2025',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: Color(0xFF334155))),
            const Spacer(),
            Icon(Icons.sync, size: 14, color: widget.teal),
            const SizedBox(width: 4),
            Text('Sinkron OTA otomatis',
              style: TextStyle(fontSize: 11, color: widget.teal, fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(height: 12),
        // Revenue card
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Total Pendapatan Kotor',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
            Icon(Icons.account_balance_outlined, size: 18, color: widget.teal),
          ]),
          const SizedBox(height: 6),
          const Text('Rp 124.850.000',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6)),
              child: const Text('↑ +14.2% vs bln lalu',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: Color(0xFF16A34A))),
            ),
            const SizedBox(width: 10),
            const Text('Target tercapai 92%',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ]),
        ])),
        const SizedBox(height: 12),
        // Occupancy card
        _Card(child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Rata-Rata Okupansi',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 4),
            const Text('84%',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            const Text('RevPAR: Rp 920.000',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
            const Text('ADR: Rp 1.150.000',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
          ])),
          _OccupancyRing(percent: 0.84, teal: widget.teal),
        ])),
        const SizedBox(height: 12),
        // 2-col stats
        Row(children: [
          Expanded(child: _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(child: Text('Kamar Terjual',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                Icon(Icons.key_outlined, size: 16, color: widget.teal),
              ]),
              const SizedBox(height: 6),
              const Text('142', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
              const Text('Nights', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const Text('Dari 45 total inventaris unit',
                style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ]))),
          const SizedBox(width: 12),
          Expanded(child: _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(children: [
                Expanded(child: Text('Kepuasan Tamu',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                Icon(Icons.star, size: 16, color: Color(0xFFFBBF24)),
              ]),
              SizedBox(height: 6),
              Text('4.9', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
              Text('/ 5.0', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              Text('1.280 ulasan terverifikasi',
                style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ]))),
        ]),
        const SizedBox(height: 12),
        // Chart card
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tren Okupansi & Penjualan\nMingguan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B))),
              SizedBox(height: 2),
              Text('Kinerja harian vs target batas (85%)',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ])),
            Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
          ]),
          const SizedBox(height: 16),
          SizedBox(height: 120, child: _BarChart(data: _chartData, teal: widget.teal)),
          const SizedBox(height: 14),
          Row(children: [
            _dot(const Color(0xFF0D6B6B), 'Kamar (75%)'),
            const SizedBox(width: 12),
            _dot(const Color(0xFF22D3EE), 'F&B & Bar (15%)'),
            const SizedBox(width: 12),
            _dot(const Color(0xFFE2E8F0), 'Ekstra (10%)'),
          ]),
        ])),
        const SizedBox(height: 12),
        // Syarat & Ketentuan
        _Card(child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: widget.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.article_outlined, color: widget.teal, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Syarat & Ketentuan Hotel',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B))),
              const SizedBox(width: 8),
              _Chip(label: 'Kebijakan', bg: const Color(0xFFDCFCE7),
                  fg: const Color(0xFF16A34A)),
            ]),
            const Text('Ketentuan operasional & kebijakan tamu',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ])),
          const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        ])),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _dot(Color c, String l) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(l, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
  ]);
}

// ═══════════════════════════════════════════════════════════════
// TAB 2 – KAMAR & TARIF
// ═══════════════════════════════════════════════════════════════

class _KamarTarifTabView extends StatefulWidget {
  final List<_RoomType> rooms;
  final Color teal;
  const _KamarTarifTabView({required this.rooms, required this.teal});
  @override
  State<_KamarTarifTabView> createState() => _KamarTarifTabViewState();
}

class _KamarTarifTabViewState extends State<_KamarTarifTabView> {
  int _filterIdx = 0;
  final _filters = ['Semua Kamar (45)', 'Ocean View (15)', 'Private Villa (1)'];
  final _gradients = const [
    [Color(0xFF16A34A), Color(0xFF065F46)],
    [Color(0xFF0369A1), Color(0xFF0D6B6B)],
    [Color(0xFF7C3AED), Color(0xFF4F46E5)],
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Kelola Master Kamar & Tarif',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B))),
        const SizedBox(height: 14),
        _PrimaryBtn(icon: Icons.add_circle_outline,
            label: '+ Tambah Tipe Kamar Baru', color: widget.teal, onTap: () {}),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: List.generate(_filters.length, (i) {
            final sel = _filterIdx == i;
            return GestureDetector(
              onTap: () => setState(() => _filterIdx = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? widget.teal : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? widget.teal : const Color(0xFFE2E8F0)),
                ),
                child: Text(_filters[i],
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : const Color(0xFF64748B))),
              ),
            );
          })),
        ),
        const SizedBox(height: 16),
        ...widget.rooms.asMap().entries.map((e) => _RoomCard(
          room: e.value, teal: widget.teal,
          gradient: _gradients[e.key % _gradients.length],
        )),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _RoomCard extends StatelessWidget {
  final _RoomType room;
  final Color teal;
  final List<Color> gradient;
  const _RoomCard({required this.room, required this.teal, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10, offset: const Offset(0, 3))]),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          Container(
            height: 160, width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient,
                  begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: const Center(child: Icon(Icons.bed, size: 52, color: Colors.white30)),
          ),
          Positioned(top: 10, left: 10,
            child: _Chip(label: room.badge, bg: Colors.black54, fg: Colors.white)),
          if (room.isBestSeller)
            Positioned(top: 10, right: 10,
              child: _Chip(label: 'Best Seller',
                  bg: const Color(0xFFFBBF24), fg: const Color(0xFF7C2D12))),
          if (room.isSurge)
            Positioned(top: 10, right: 10,
              child: _Chip(label: '↑ Surge +20%',
                  bg: const Color(0xFF16A34A), fg: Colors.white)),
          Positioned(bottom: 10, left: 10, right: 10,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(room.name, style: const TextStyle(color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black54)])),
              Text(room.sub, style: const TextStyle(color: Colors.white70, fontSize: 10,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black38)])),
            ])),
        ]),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.bed_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text('${room.totalUnit} Unit Total',
                style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
              const SizedBox(width: 10),
              _Chip(
                label: '${room.terjual} Terjual (${room.occupancy}% Okupansi)',
                bg: teal.withValues(alpha: 0.1), fg: teal),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: room.occupancy / 100,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation(
                    Color.lerp(const Color(0xFF22D3EE), const Color(0xFF0D6B6B), 0.5)!),
                minHeight: 6)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Weekday (Sen – Kam)',
                  style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                const SizedBox(height: 2),
                Text(room.weekdayPrice,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                      color: Color(0xFF334155))),
                const Text('per malam', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ])),
              Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Weekend (Jum – Min)',
                  style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                const SizedBox(height: 2),
                Text(room.weekendPrice,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                    color: room.isSurge ? const Color(0xFF16A34A) : const Color(0xFF334155))),
                Text(room.weekendNote,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ])),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 6, runSpacing: 6,
              children: room.amenities.map((a) =>
                  _Chip(label: a, bg: const Color(0xFFF1F5F9), fg: const Color(0xFF475569))
              ).toList()),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.photo_library_outlined, size: 14),
                label: Text('Galeri Foto (${room.photoCount})'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  padding: const EdgeInsets.symmetric(vertical: 10)))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Edit Kamar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6B6B),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 3 – KEUANGAN
// ═══════════════════════════════════════════════════════════════

class _KeuanganTabView extends StatefulWidget {
  final List<_TxItem> transactions;
  final Color teal;
  const _KeuanganTabView({required this.transactions, required this.teal});
  @override
  State<_KeuanganTabView> createState() => _KeuanganTabViewState();
}

class _KeuanganTabViewState extends State<_KeuanganTabView> {
  int _periodIdx = 0;
  int _kasIdx = 0;
  final _bruto = const [0.3, 0.45, 0.5, 0.6, 0.55, 0.75, 0.65, 0.8, 0.72, 0.88];
  final _netto = const [0.25, 0.38, 0.42, 0.52, 0.48, 0.65, 0.57, 0.70, 0.62, 0.76];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: widget.teal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Text('EXECUTIVE LEDGER',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                  color: widget.teal, letterSpacing: 0.8)),
            const SizedBox(width: 10),
            const Text('Real-Time Sync',
              style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6)),
              child: const Text('Audit Locked',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                    color: Color(0xFFDC2626)))),
          ])),
        const SizedBox(height: 12),
        // Period toggle
        Row(children: [
          ...[('Per Bulan', 0), ('Per Tahun', 1)].map((t) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _periodIdx = t.$2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _periodIdx == t.$2 ? widget.teal : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _periodIdx == t.$2 ? widget.teal : const Color(0xFFE2E8F0))),
                child: Text(t.$1,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: _periodIdx == t.$2 ? Colors.white : const Color(0xFF64748B))),
              ),
            ),
          )),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const Row(children: [
              Text('2025 (YTD)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF94A3B8)),
            ])),
        ]),
        const SizedBox(height: 10),
        // Quarter pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: ['Bulan Ini (Okt)', 'Q1 2025', 'Q2 2025', 'Q3 2025']
              .asMap().entries.map((e) => Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: e.key == 0 ? widget.teal : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: e.key == 0 ? widget.teal : const Color(0xFFE2E8F0))),
            child: Text(e.value,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: e.key == 0 ? Colors.white : const Color(0xFF64748B))),
          )).toList())),
        const SizedBox(height: 14),
        // Revenue summary
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.account_balance_outlined, size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            const Expanded(child: Text('TOTAL PENDAPATAN MASUK (GROSS)',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B), letterSpacing: 0.5))),
            _Chip(label: '↑ 16.8%', bg: const Color(0xFFDCFCE7), fg: const Color(0xFF16A34A)),
          ]),
          const SizedBox(height: 4),
          const Text('Akumulasi penerimaan bruto per 24 Oktober 2025',
            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          const SizedBox(height: 10),
          const Text('Rp 1.485.200.000',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Nett Settlement Hotel',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              SizedBox(height: 2),
              Text('Rp 1.336.680.000',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            ])),
            Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Potongan Komisi OTA',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              SizedBox(height: 2),
              Text('Rp 148.520.000',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626))),
            ])),
          ]),
        ])),
        const SizedBox(height: 12),
        // Stats 2-col
        Row(children: [
          Expanded(child: _Card(padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF64748B)),
              SizedBox(height: 4),
              Text('10 Bulan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
              Text('Rata-rata Pendapatan\nRp 148.5 Jt / bulan berjalan',
                style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ]))),
          const SizedBox(width: 10),
          Expanded(child: _Card(padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Icon(Icons.bed_outlined, size: 16, color: Color(0xFF64748B)),
              SizedBox(height: 4),
              Text('48 Kamar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
              Text('RevPAR Rata-rata\nRp 820.000\nRevenue Per Avail. Room',
                style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ]))),
        ]),
        const SizedBox(height: 12),
        // Trend chart
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Tren Arus Pendapatan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B)))),
            const Icon(Icons.trending_up, size: 16, color: Color(0xFF16A34A)),
          ]),
          const Text('Komparasi Bruto, Netto, dan Saldo OTA',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          const SizedBox(height: 8),
          Row(children: [
            _lineLegend(const Color(0xFF0D6B6B), 'Bruto (Gross)'),
            const SizedBox(width: 12),
            _lineLegend(const Color(0xFF22D3EE), 'Bersih (Nett)'),
            const SizedBox(width: 12),
            _lineLegend(const Color(0xFFCBD5E1), 'OTA Fee'),
          ]),
          const SizedBox(height: 16),
          SizedBox(height: 110, child: _LineChart(bruto: _bruto, netto: _netto, teal: widget.teal)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Jan', 'Mar', 'Mei', 'Jul', 'Sep', 'Okt (Kl)'].map((m) =>
              Text(m, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)))).toList()),
          const SizedBox(height: 10),
          Row(children: [
            _greenTag('Tumbuh +16.8% dari 2024'),
            const SizedBox(width: 8),
            _greenTag('YTD 2025 →'),
          ]),
          const SizedBox(height: 4),
          const Text('2023: Rp 1.12 M  •  2024: Rp 1.27 M',
            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ])),
        const SizedBox(height: 12),
        // Buku Kas
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Buku Kas Uang Masuk',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B)))),
            Container(width: 8, height: 8,
              decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle)),
          ]),
          const Text('Log transaksi aman • update otomatis',
            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: ['Semua Masuk', 'Sukses Settled', 'Booking Masuk Hari Ini']
                .asMap().entries.map((e) => GestureDetector(
              onTap: () => setState(() => _kasIdx = e.key),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _kasIdx == e.key ? widget.teal : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kasIdx == e.key ? widget.teal : const Color(0xFFE2E8F0))),
                child: Text(e.value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: _kasIdx == e.key ? Colors.white : const Color(0xFF64748B))),
              ),
            )).toList())),
          const SizedBox(height: 12),
          ...widget.transactions.map((t) => _TxRow(tx: t)),
        ])),
        const SizedBox(height: 12),
        // Export
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: widget.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.upload_file_outlined, color: widget.teal, size: 20)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ekspor Laporan Pendapatan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B))),
              SizedBox(height: 2),
              Text('Untuk rekonsiliasi kas masuk ke audit external, termasuk pajak PHR, dan rekonsiliasi OTA diperbankkan.',
                style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 14),
              label: const Text('Unduh PDF Resmi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF475569),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                padding: const EdgeInsets.symmetric(vertical: 10)))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.table_chart_outlined, size: 14),
              label: const Text('Unduh CSV / Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6B6B), foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8)),
            child: const Row(children: [
              Icon(Icons.info_outline, size: 14, color: Color(0xFFD97706)),
              SizedBox(width: 6),
              Expanded(child: Text('Mode Audit Finansial (Read-Only) • Otorisasi transfer terkunci.',
                style: TextStyle(fontSize: 10, color: Color(0xFFD97706)))),
            ])),
        ])),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _lineLegend(Color c, String l) => Row(children: [
    Container(width: 18, height: 2, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(1))),
    const SizedBox(width: 4),
    Text(l, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
  ]);

  Widget _greenTag(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
    child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))));
}

class _TxRow extends StatelessWidget {
  final _TxItem tx;
  const _TxRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _Chip(label: tx.label, bg: const Color(0xFFDCFCE7), fg: const Color(0xFF16A34A)),
          const Spacer(),
          Text(tx.amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
              color: Color(0xFF16A34A))),
        ]),
        const SizedBox(height: 6),
        Text(tx.guestName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B))),
        Text(tx.roomDesc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.qr_code_2, size: 12, color: Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          Text(tx.code, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ]),
        Row(children: [
          const Icon(Icons.payment, size: 12, color: Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          Expanded(child: Text(tx.method, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)))),
          Text(tx.time, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ]),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 4 – STAF & TIM
// ═══════════════════════════════════════════════════════════════

class _StafTimTabView extends StatefulWidget {
  final List<_StaffMember> staff;
  final Color teal;
  const _StafTimTabView({required this.staff, required this.teal});
  @override
  State<_StafTimTabView> createState() => _StafTimTabViewState();
}

class _StafTimTabViewState extends State<_StafTimTabView> {
  int _deptIdx = 0;
  final _depts = ['Semua (18)', 'Front Office (6)', 'Housekeeping (8)'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Manajemen Staf & Hak Akses',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
        const SizedBox(height: 14),
        _PrimaryBtn(icon: Icons.person_add_outlined,
            label: '+ Tambah Karyawan Baru', color: widget.teal, onTap: () {}),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_outlined, size: 16),
          label: const Text('Ekspor Jadwal Shift (PDF/Excel)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF334155),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        const SizedBox(height: 16),
        // Roster header
        Row(children: [
          const Text('Status Roster Hari Ini',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFF0D9B9B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6)),
            child: const Row(children: [
              Icon(Icons.circle, size: 6, color: Color(0xFF0D9B9B)),
              SizedBox(width: 4),
              Text('Live Sync', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: Color(0xFF0D9B9B))),
            ])),
        ]),
        const SizedBox(height: 10),
        // Shift cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _shiftCard('07:00 – 15:00', '6 Karyawan', 'Shift Pagi (Active Now)',
                const Color(0xFF0D9B9B), true),
            const SizedBox(width: 10),
            _shiftCard('15:00 – 23:00', '5 Karyawan', 'Shift Siang (Terjadwal)',
                const Color(0xFF94A3B8), false),
            const SizedBox(width: 10),
            _shiftCard('23:00 – 07:00', '3 Karyawan', 'Shift Malam',
                const Color(0xFF94A3B8), false),
          ])),
        const SizedBox(height: 16),
        // Dept filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: List.generate(_depts.length, (i) {
            final sel = _deptIdx == i;
            return GestureDetector(
              onTap: () => setState(() => _deptIdx = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? widget.teal : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? widget.teal : const Color(0xFFE2E8F0))),
                child: Text(_depts[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : const Color(0xFF64748B))),
              ),
            );
          }))),
        const SizedBox(height: 14),
        ...widget.staff.map((s) => _StaffCard(member: s, teal: widget.teal)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _shiftCard(String time, String count, String label, Color color, bool active) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? color : const Color(0xFFE2E8F0), width: active ? 2 : 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(time, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: active ? color : const Color(0xFF94A3B8))),
        const SizedBox(height: 4),
        if (active)
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle))
        else
          Icon(Icons.access_time, size: 14, color: color),
        const SizedBox(height: 4),
        Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A))),
        Text(label, style: TextStyle(fontSize: 10, color: color)),
      ]),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final _StaffMember member;
  final Color teal;
  const _StaffCard({required this.member, required this.teal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: teal.withValues(alpha: 0.15),
              child: Text(member.name[0],
                style: TextStyle(color: teal, fontWeight: FontWeight.w800, fontSize: 16))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(member.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B))),
                const SizedBox(width: 8),
                Text(member.id, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ]),
              const SizedBox(height: 2),
              Text(member.role, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: member.statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6)),
              child: Text(member.statusLabel, style: TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w700, color: member.statusColor))),
          ]),
          const SizedBox(height: 12),
          Text('OTORISASI & HAK AKSES:',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                color: const Color(0xFF94A3B8), letterSpacing: 0.6)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 4,
            children: member.akses.map((a) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: teal.withValues(alpha: 0.2))),
              child: Text(a, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: teal)))).toList()),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.chat_bubble_outline, size: 13, color: Color(0xFF25D366)),
            const SizedBox(width: 6),
            Text('WhatsApp: ${member.wa}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_today_outlined, size: 14),
              label: const Text('Atur Shift'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF475569),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                padding: const EdgeInsets.symmetric(vertical: 9)))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shield_outlined, size: 14),
              label: const Text('Kelola Akses'),
              style: OutlinedButton.styleFrom(
                foregroundColor: teal, side: BorderSide(color: teal),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                padding: const EdgeInsets.symmetric(vertical: 9)))),
          ]),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTERS & SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════

class _OccupancyRing extends StatelessWidget {
  final double percent;
  final Color teal;
  const _OccupancyRing({required this.percent, required this.teal});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70, height: 70,
      child: CustomPaint(
        painter: _RingPainter(percent: percent, color: teal),
        child: Center(child: Icon(Icons.bed, color: teal, size: 22))));
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;
  const _RingPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = cx - 6;
    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..color = const Color(0xFFE2E8F0) ..style = PaintingStyle.stroke ..strokeWidth = 6);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2, 2 * math.pi * percent, false,
      Paint()..color = color ..style = PaintingStyle.stroke ..strokeWidth = 6
        ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) => true;
}

class _BarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color teal;
  const _BarChart({required this.data, required this.teal});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((d) {
        final val = d['val'] as double;
        final isBold = d['bold'] == true;
        final isHl = d['hl'] == true;
        final color = isBold ? teal : isHl ? const Color(0xFF22D3EE) : const Color(0xFFBFDBFE);
        return Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('${(val * 100).toInt()}%',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
              color: isBold ? teal : const Color(0xFF94A3B8))),
          const SizedBox(height: 3),
          Container(
            height: 90 * val, margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
          const SizedBox(height: 4),
          Text(d['day'] as String, style: TextStyle(fontSize: 9,
            color: isBold ? teal : const Color(0xFF94A3B8),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        ]));
      }).toList());
  }
}

class _LineChart extends StatelessWidget {
  final List<double> bruto;
  final List<double> netto;
  final Color teal;
  const _LineChart({required this.bruto, required this.netto, required this.teal});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LinePainter(bruto: bruto, netto: netto, teal: teal));
  }
}

class _LinePainter extends CustomPainter {
  final List<double> bruto;
  final List<double> netto;
  final Color teal;
  const _LinePainter({required this.bruto, required this.netto, required this.teal});

  void _draw(Canvas canvas, Size size, List<double> data, Color color) {
    if (data.length < 2) return;
    final paint = Paint()..color = color ..style = PaintingStyle.stroke ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final step = size.width / (data.length - 1);
    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final y = size.height - data[i] * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = const Color(0xFFE2E8F0) ..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    _draw(canvas, size, bruto, teal);
    _draw(canvas, size, netto, const Color(0xFF22D3EE));
  }

  @override
  bool shouldRepaint(_LinePainter old) => true;
}

// ── Shared reusable widgets ──

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: padding,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: child);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Chip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)));
  }
}

class _PrimaryBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))));
  }
}
