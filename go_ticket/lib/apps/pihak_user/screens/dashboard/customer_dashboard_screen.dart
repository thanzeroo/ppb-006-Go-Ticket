import 'package:flutter/material.dart';

import 'tabs/beranda_tab.dart';
import 'tabs/cari_tab.dart';
import 'tabs/pesanan_tab.dart';
import 'tabs/pengaturan_tab.dart';

/// Dashboard utama User/Customer dengan 4 tab navigasi.
class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  /// Dipakai tab lain untuk pindah tab: `CustomerDashboardScreen.tabNotifier.value = 1;`
  /// (0 Beranda, 1 Cari, 2 Pesanan, 3 Pengaturan)
  static final ValueNotifier<int> tabNotifier = ValueNotifier<int>(0);

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _currentIndex = 0;

<<<<<<< HEAD:go_ticket/lib/apps/user/screens/dashboard/customer_dashboard_screen.dart
  void _onTabChanged() {
    if (mounted) {
      setState(() => _currentIndex = CustomerDashboardScreen.tabNotifier.value);
    }
  }

  @override
  void initState() {
    super.initState();
    CustomerDashboardScreen.tabNotifier.value = 0;
    CustomerDashboardScreen.tabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    CustomerDashboardScreen.tabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  static const List<Widget> _pages = [
=======
  static const List<Widget> _tabs = [
>>>>>>> b22167a638fe5031603dbdfed85d081a7ce2eb77:go_ticket/lib/apps/pihak_user/screens/dashboard/customer_dashboard_screen.dart
    BerandaTab(),
    CariTab(),
    PesananTab(),
    PengaturanTab(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Beranda'),
    _NavItem(icon: Icons.search_outlined, activeIcon: Icons.search, label: 'Cari'),
    _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Pesanan'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final selected = i == _currentIndex;
              return Expanded(
                child: GestureDetector(
<<<<<<< HEAD:go_ticket/lib/apps/user/screens/dashboard/customer_dashboard_screen.dart
                  onTap: () => CustomerDashboardScreen.tabNotifier.value = index,
=======
                  onTap: () => setState(() => _currentIndex = i),
>>>>>>> b22167a638fe5031603dbdfed85d081a7ce2eb77:go_ticket/lib/apps/pihak_user/screens/dashboard/customer_dashboard_screen.dart
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF00B4D8).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected
                              ? const Color(0xFF00B4D8)
                              : const Color(0xFF9CA3AF),
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: selected
                                ? const Color(0xFF00B4D8)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
