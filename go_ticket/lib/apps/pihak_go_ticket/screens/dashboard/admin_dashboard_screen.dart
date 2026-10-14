import 'package:flutter/material.dart';

import '../auth/admin_login_screen.dart';

/// Dashboard utama Pihak Go Ticket.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      {
        'icon': Icons.hotel_outlined,
        'label': 'Manajemen Hotel',
        'desc': 'Daftar & kelola hotel mitra',
        'color': const Color(0xFF0369A1),
      },
      {
        'icon': Icons.receipt_long_outlined,
        'label': 'Monitoring Transaksi',
        'desc': 'Pantau booking & transaksi platform',
        'color': const Color(0xFF059669),
      },
      {
        'icon': Icons.account_balance_outlined,
        'label': 'Persetujuan Payout',
        'desc': 'Approve pencairan dana hotel',
        'color': const Color(0xFFD97706),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Pihak Go Ticket'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
              (_) => false,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Stats summary
          Row(
            children: [
              _buildStatCard('Total Hotel Mitra', '128', Icons.hotel),
              const SizedBox(width: 12),
              _buildStatCard('Transaksi Hari Ini', '342', Icons.receipt),
              const SizedBox(width: 12),
              _buildStatCard('Pending Payout', '7', Icons.pending_actions),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Menu Pengelolaan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...menus.map((m) => _buildMenuCard(context, m)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00B4D8), size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, Map<String, dynamic> m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${m['label']} — coming soon')),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (m['color'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(m['icon'] as IconData,
                      color: m['color'] as Color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m['label'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m['desc'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF334155)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
