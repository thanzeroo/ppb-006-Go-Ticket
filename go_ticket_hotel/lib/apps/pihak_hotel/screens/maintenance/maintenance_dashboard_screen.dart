import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/tiko_chat_bubble.dart';
import '../auth/staff_login_screen.dart';
import 'tabs/kebersihan_tab.dart';
import 'tabs/kerusakan_tab.dart';
import 'tabs/maintenance_overview_tab.dart';

/// Dashboard Maintenance & Housekeeping Hotel
/// Terbagi menjadi 3 Modul / Tab:
/// 1. MaintenanceOverviewTab: Prioritas Mendesak, Metrik Operasional, Monitor Kamar Terkini
/// 2. KebersihanTab: Papan Kebersihan Kamar, Filter Lantai, Checklist Sanitasi QC
/// 3. KerusakanTab: Live Maintenance Hub, Tiket Kerusakan & Pemeliharaan, Status Pengerjaan
/// Serta Modal Bottom Sheet: showLaporKerusakanModal
class MaintenanceDashboardScreen extends StatefulWidget {
  const MaintenanceDashboardScreen({super.key});

  @override
  State<MaintenanceDashboardScreen> createState() =>
      _MaintenanceDashboardScreenState();
}

class _MaintenanceDashboardScreenState
    extends State<MaintenanceDashboardScreen> {
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
                // Top Bar
                _buildTopAppBar(),

                // Konten Sesuai Tab Aktif
                Expanded(
                  child: IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      MaintenanceOverviewTab(
                        onNavigateTab: (index) {
                          setState(() => _currentTabIndex = index);
                        },
                      ),
                      const KebersihanTab(),
                      const KerusakanTab(),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFF00B4D8),
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Go Ticket Maintenance',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'The Grand Amora Resort • ',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C2FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'On-Duty: 6 Staf',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFF0A5868),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              // Tombol Logout Merah
              Tooltip(
                message: 'Keluar / Logout',
                child: InkWell(
                  onTap: _handleLogout,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.logout_rounded,
                            color: Color(0xFFDC2626), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
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
            icon: Icon(Icons.cleaning_services_outlined),
            activeIcon: Icon(Icons.cleaning_services_rounded),
            label: 'Kebersihan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build_rounded),
            label: 'Kerusakan',
          ),
        ],
      ),
    );
  }
}
