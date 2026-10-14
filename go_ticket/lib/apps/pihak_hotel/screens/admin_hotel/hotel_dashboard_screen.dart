import 'package:flutter/material.dart';

import '../auth/staff_login_screen.dart';
import '../front_office/fo_dashboard_screen.dart';
import '../maintenance/maintenance_dashboard_screen.dart';
import '../admin_hotel/executive_dashboard_screen.dart';

/// Dashboard utama pihak hotel — menampilkan pilihan menu per role.
class HotelDashboardScreen extends StatelessWidget {
  const HotelDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      _MenuItem(
        icon: Icons.desk,
        label: 'Front Office',
        subtitle: 'Kelola check-in & check-out tamu',
        color: const Color(0xFF0D3B55),
        destination: const FoDashboardScreen(),
      ),
      _MenuItem(
        icon: Icons.build_circle_outlined,
        label: 'Maintenance',
        subtitle: 'Kelola tiket dan tugas perawatan',
        color: const Color(0xFF065F46),
        destination: const MaintenanceDashboardScreen(),
      ),
      _MenuItem(
        icon: Icons.manage_accounts_outlined,
        label: 'Admin Hotel',
        subtitle: 'Laporan, keuangan & manajemen staf',
        color: const Color(0xFF7C3AED),
        destination: const ExecutiveDashboardScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Pihak Hotel'),
        backgroundColor: const Color(0xFF0D3B55),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
              (_) => false,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Pilih Role',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D3B55),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Akses menu sesuai tugas Anda',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ...menus.map((m) => _buildMenuCard(context, m)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, _MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.destination),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Widget destination;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.destination,
  });
}
