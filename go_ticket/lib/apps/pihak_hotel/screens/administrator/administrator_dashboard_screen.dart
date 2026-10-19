import 'package:flutter/material.dart';

import 'models/administrator_models.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/kamar_tarif_tab.dart';
import 'tabs/keuangan_tab.dart';
import 'tabs/staf_tim_tab.dart';
import 'widgets/administrator_theme.dart';

/// Main Dashboard Screen for Administrator Pihak Hotel
/// Consists of 4 Tabs:
/// 1. Dashboard (Overview & Analytics)
/// 2. Kamar & Tarif (Room Inventory & Rates)
/// 3. Staf & Tim (Team Roster & Roles)
/// 4. Keuangan (Financials & Revenue)
class AdministratorDashboardScreen extends StatefulWidget {
  const AdministratorDashboardScreen({super.key});

  @override
  State<AdministratorDashboardScreen> createState() =>
      _AdministratorDashboardScreenState();
}

class _AdministratorDashboardScreenState
    extends State<AdministratorDashboardScreen> {
  // Tab index: 0 = Dashboard, 1 = Kamar & Tarif, 2 = Staf & Tim, 3 = Keuangan
  int _selectedTab = 0;

  final List<RoomTypeData> _rooms = const [
    RoomTypeData(
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
      imageUrl:
          'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&auto=format&fit=crop',
    ),
    RoomTypeData(
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
      imageUrl:
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&auto=format&fit=crop',
    ),
    RoomTypeData(
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
      imageUrl:
          'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800&auto=format&fit=crop',
    ),
  ];

  final List<StaffData> _staff = const [
    StaffData(
      name: 'Ni Made Anggreni, S.Tr.Par',
      id: '#STF-2024-004',
      role: 'Front Office Lead / Senior',
      statusLabel: 'Aktif Bertugas',
      statusBg: cLight,
      statusFg: cDarkActive,
      onlineDotColor: Color(0xFF16A34A),
      akses: ['Verifikasi Booking', 'RFID Smart Lock', 'Otorisasi Refund'],
      wa: '+62 813-3982-1140',
      avatarUrl:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=300&auto=format&fit=crop',
    ),
    StaffData(
      name: 'Budi Santoso',
      id: '#HK-2011',
      role: 'Housekeeping Supervisor (S...)',
      statusLabel: 'Aktif Bertugas',
      statusBg: cLight,
      statusFg: cDarkActive,
      onlineDotColor: Color(0xFF16A34A),
      akses: ['Checklist Kebersihan', 'Logistik Gudang', 'Lapor Kerusakan'],
      wa: '+62 813-8822-9901',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&auto=format&fit=crop',
    ),
    StaffData(
      name: 'Hendra Wijaya',
      id: '#TK-3004',
      role: 'Senior Maintenance Technic',
      statusLabel: 'On-Site (#204)',
      statusBg: cLight,
      statusFg: cDarkActive,
      onlineDotColor: cNormal,
      akses: ['Tiket Kerusakan', 'Status Kamar OOO'],
      wa: '+62 812-3333-4444',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&auto=format&fit=crop',
    ),
    StaffData(
      name: 'Siti Nurhaliza',
      id: '#FO-1052',
      role: 'Night Audit Front Office',
      statusLabel: 'Terjadwal 23:00',
      statusBg: Color(0xFFF1F5F9),
      statusFg: Color(0xFF64748B),
      onlineDotColor: Color(0xFF94A3B8),
      akses: ['Tutup Buku Kasir EOD', 'Check-in Malam'],
      wa: '+62 821-9999-0000',
      avatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&auto=format&fit=crop',
    ),
  ];

  final List<TransactionData> _transactions = const [
    TransactionData(
      name: 'Bpk. Hendra Kusuma',
      amount: '+Rp 8.700.000',
      room: 'Executive Ocean Panorama Suite • 3 Malam',
      code: '#BK-2025-8821',
      method: 'QRIS Go Ticket Instant',
      time: 'Hari ini, 11:20 WITA',
    ),
    TransactionData(
      name: 'Ibu Natasha Wibowo',
      amount: '+Rp 4.350.000',
      room: 'Grand Deluxe Pool View • 2 Malam',
      code: '#BK-2025-8819',
      method: 'BCA Virtual Account',
      time: 'Hari ini, 09:14 WITA',
    ),
    TransactionData(
      name: 'Mr. Alexander Smith',
      amount: '+Rp 2.900.000',
      room: 'Royal Garden Villa • 1 Malam (+ Spa Package)',
      code: '#BK-2025-8804',
      method: 'Kartu Kredit (Visa International)',
      time: 'Kemarin, 19:40 WITA',
    ),
    TransactionData(
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
    final tabs = [
      (Icons.bar_chart_rounded, 'Dashboard'),
      (Icons.bed_outlined, 'Kamar & Tarif'),
      (Icons.badge_outlined, 'Staf & Tim'),
      (Icons.account_balance_wallet_outlined, 'Keuangan'),
    ];

    final tabViews = [
      const AdministratorDashboardTab(),
      KamarTarifTab(rooms: _rooms),
      StafTimTab(staff: _staff),
      KeuanganTab(transactions: _transactions),
    ];

    return Scaffold(
      backgroundColor: adminBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with official Logo
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
          // Logo & Title
          Image.asset(
            'assets/logo.png',
            height: 30,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: cDarkActive,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('GT',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'The Grand Amora Resort',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Administrator • Live System',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Notification & Profile
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                size: 20, color: Color(0xFF475569)),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 10),
          ClipOval(
            child: buildNetworkImage(
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop',
              width: 32,
              height: 32,
              placeholder: const CircleAvatar(
                radius: 16,
                backgroundColor: cDarkActive,
                child: Text('AD',
                    style: TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(List<(IconData, String)> tabs) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: adminCardBorder)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final sel = _selectedTab == i;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _selectedTab = i),
            child: SizedBox(
              width: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tabs[i].$1,
                    size: 20,
                    color: sel ? cDarkActive : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tabs[i].$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                      color: sel ? cDarkActive : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
