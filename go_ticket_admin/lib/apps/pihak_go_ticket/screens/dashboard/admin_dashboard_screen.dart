import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar yang konsisten di semua tab
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
  // TOP APP BAR (Konsisten: Logo + Super Admin di kiri, Tombol Keluar di kanan)
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
          // Logo & Super Admin Kiri
          _buildLeftBranding(),

          // Aksi Kanan (Hanya icon logout tanpa teks)
          _buildRightActions(),
        ],
      ),
    );
  }

  Widget _buildLeftBranding() {
    return Row(
      children: [
        _buildLogoIcon(),
        const SizedBox(width: 10),
        const Text(
          'Super Admin',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
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
    return InkWell(
      onTap: _handleLogout,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: const Icon(
          Icons.logout_rounded,
          size: 18,
          color: Color(0xFFDC2626),
        ),
      ),
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
