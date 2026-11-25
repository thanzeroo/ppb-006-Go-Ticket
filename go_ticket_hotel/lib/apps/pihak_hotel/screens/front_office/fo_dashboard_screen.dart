import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/tiko_chat_bubble.dart';
import '../auth/staff_login_screen.dart';
import 'tabs/fo_booking_tab.dart';
import 'tabs/fo_check_in_tab.dart';
import 'tabs/fo_check_out_tab.dart';
import 'tabs/fo_dashboard_tab.dart';

/// Dashboard Front Office (Staf Depan) Hotel
/// Terbagi menjadi 4 Modul / Tab:
/// 1. FoDashboardTab: Ringkasan Operasional, Scanner E-Tiket, Aksi Cepat
/// 2. FoBookingTab: Verifikasi Reservasi Tamu, Filter, Slip Transfer
/// 3. FoCheckInTab: Proses Check-in Tamu, Pencarian, Serah Kunci RFID
/// 4. FoCheckOutTab: Proses Check-out Tamu, Waktu Keluar, Checklist Deposit & Handover
class FoDashboardScreen extends StatefulWidget {
  const FoDashboardScreen({super.key});

  @override
  State<FoDashboardScreen> createState() => _FoDashboardScreenState();
}

class _FoDashboardScreenState extends State<FoDashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8FAFD),
          body: SafeArea(
            child: Column(
              children: [
                // Header Top Bar
                _buildTopAppBar(),

                // Body Sesuai Tab yang Aktif
                Expanded(
                  child: IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      FoDashboardTab(
                        onNavigateTab: (index) {
                          setState(() => _currentTabIndex = index);
                        },
                      ),
                      const FoBookingTab(),
                      const FoCheckInTab(),
                      const FoCheckOutTab(),
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

  Future<void> _handleLogout() async {
    try {
      await AuthService.instance.logout();
    } catch (e) {
      debugPrint('⚠️ [Logout error]: $e');
    }
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berhasil keluar. Silakan login kembali.'),
        backgroundColor: Color(0xFF007A87),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ===========================================================================
  // TOP APP BAR
  // ===========================================================================
  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Logo & Tag Front Office
          Image.asset(
            'assets/logo.png',
            height: 30,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.confirmation_number_outlined,
              color: Color(0xFF00B4D8),
              size: 26,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F4FB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: const Text(
              'Front Office',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF00758F),
              ),
            ),
          ),
          const Spacer(),
          // Tombol Logout Merah (Hanya Icon)
          Tooltip(
            message: 'Keluar',
            child: InkWell(
              onTap: _handleLogout,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM NAVIGATION BAR
  // ===========================================================================
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00758F),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle:
            const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
        unselectedLabelStyle:
            const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number_rounded),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room_outlined),
            activeIcon: Icon(Icons.meeting_room_rounded),
            label: 'Check In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.door_sliding_outlined),
            activeIcon: Icon(Icons.door_sliding_rounded),
            label: 'Check Out',
          ),
        ],
      ),
    );
  }
}
