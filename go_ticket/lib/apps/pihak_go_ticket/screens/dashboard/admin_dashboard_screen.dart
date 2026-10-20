import 'package:flutter/material.dart';

import 'tabs/dashboard_tab.dart';
import 'tabs/kelola_hotel_tab.dart';
import 'tabs/keuangan_tab.dart';
import 'tabs/promo_tab.dart';
import 'tabs/user_tab.dart';

/// Screen Shell Utama untuk Pihak Go Ticket (Super Admin).
/// Mengontrol 5 Tab via Bottom Navigation Bar:
/// 0. Dashboard (HQ Command Center)
/// 1. Keuangan (Laporan Keuangan & Transaksi)
/// 2. Promo (Manajemen Promo & Diskon)
/// 3. Kelola Hotel (Kelola Hotel & Properti)
/// 4. User (Direktori Pengguna & Staf)
class AdminDashboardScreen extends StatefulWidget {
  final int initialTab;

  const AdminDashboardScreen({super.key, this.initialTab = 0});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTab;
  }

  void _onSelectTab(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar yang beradaptasi sesuai Tab yang aktif
            _buildTopAppBar(),

            // IndexedStack untuk perpindahan tab yang cepat dan mulus
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  DashboardTab(onNavigateTab: _onSelectTab),
                  const KeuanganTab(),
                  const PromoTab(),
                  const KelolaHotelTab(),
                  const UserTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ===========================================================================
  // TOP APP BAR (Sesuai Masing-masing Gambar)
  // ===========================================================================
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Branding Kiri
          _buildLeftBranding(),

          // Aksi Kanan (Status Online / Bell Notifikasi + Profile Avatar)
          _buildRightActions(),
        ],
      ),
    );
  }

  Widget _buildLeftBranding() {
    switch (_currentTabIndex) {
      case 1: // Keuangan (Image 4)
        return Row(
          children: [
            _buildLogoIcon(),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Go Ticket',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCFFAFE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'SUPER ADMIN',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0891B2),
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Keuangan Laporan',
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        );

      case 2: // Promo (Image 5)
        return Row(
          children: [
            _buildLogoIcon(),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Go Ticket',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCFFAFE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'SUPER ADMIN',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0891B2),
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Promo Vouchers',
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        );

      case 3: // Kelola Hotel (Image 2)
        return Row(
          children: [
            _buildLogoIcon(),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'GO TICKET ADMIN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF007A94),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'More Hotel Kamar',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        );

      case 0: // Dashboard (Image 1)
      case 4: // User (Image 3)
      default:
        return Row(
          children: [
            _buildLogoIcon(),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Go Ticket',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'ADMIN PANEL',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF007A94),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildLogoIcon() {
    return Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.confirmation_number_rounded,
          color: Color(0xFF00B4D8),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRightActions() {
    // Pada tab 1, 2, 3 ada ikon bell notifikasi
    final showBell = _currentTabIndex == 1 || _currentTabIndex == 2 || _currentTabIndex == 3;

    return Row(
      children: [
        if (showBell) ...[
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada notifikasi baru.')),
              );
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
                if (_currentTabIndex == 1) // Notif dot merah di Keuangan
                  Positioned(
                    top: -1,
                    right: 0,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C2FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 10),
        ] else ...[
          // Badge: Admin Ops ONLINE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      'Admin Ops',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'ONLINE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF10B981),
                        letterSpacing: 0.4,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],

        // User Avatar Circle
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF006678),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BOTTOM NAVIGATION BAR (5 Tabs)
  // ===========================================================================
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: _onSelectTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF007A94),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded, size: 20),
            activeIcon: Icon(Icons.grid_view_rounded, size: 20),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined, size: 20),
            activeIcon: Icon(Icons.account_balance_wallet_rounded, size: 20),
            label: 'Keuangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined, size: 20),
            activeIcon: Icon(Icons.local_offer_rounded, size: 20),
            label: 'Promo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work_outlined, size: 20),
            activeIcon: Icon(Icons.home_work_rounded, size: 20),
            label: 'Kelola Hotel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded, size: 20),
            activeIcon: Icon(Icons.person_rounded, size: 20),
            label: 'User',
          ),
        ],
      ),
    );
  }
}
