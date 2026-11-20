import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/tiko_chat_bubble.dart';
import '../auth/admin_login_screen.dart';
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
    return Stack(
      children: [
        Scaffold(
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
        ),
        const TikoChatBubble(),
      ],
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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Keluar Akun',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari sesi Super Admin Go Ticket?',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await AuthService.instance.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildRightActions() {
    return Row(
      children: [
        // Logout button
        InkWell(
          onTap: _handleLogout,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.logout_rounded, size: 14, color: Color(0xFFDC2626)),
                SizedBox(width: 4),
                Text(
                  'Keluar',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
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
