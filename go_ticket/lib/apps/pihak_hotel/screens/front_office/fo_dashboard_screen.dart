import 'package:flutter/material.dart';

/// Dashboard Front Office — menampilkan ringkasan aktivitas hari ini.
class FoDashboardScreen extends StatelessWidget {
  const FoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Front Office'),
        backgroundColor: const Color(0xFF0D3B55),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStatRow(),
          const SizedBox(height: 20),
          _buildSectionTitle('Menu Utama'),
          const SizedBox(height: 12),
          _buildMenuGrid(context),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    final stats = [
      {'label': 'Check-In Hari Ini', 'value': '12', 'icon': Icons.login},
      {'label': 'Check-Out', 'value': '8', 'icon': Icons.logout},
      {'label': 'Kamar Tersedia', 'value': '24', 'icon': Icons.bed},
    ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: s != stats.last ? 10 : 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(s['icon'] as IconData,
                    color: const Color(0xFF0D3B55), size: 20),
                const SizedBox(height: 6),
                Text(
                  s['value'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0D3B55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final menus = [
      {'label': 'Scan QR Check-In', 'icon': Icons.qr_code_scanner},
      {'label': 'Verifikasi Booking', 'icon': Icons.verified_outlined},
      {'label': 'Proses Check-Out', 'icon': Icons.exit_to_app_rounded},
      {'label': 'Daftar Tamu', 'icon': Icons.people_outline},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: menus.map((m) {
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showPlaceholder(context, m['label'] as String),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(m['icon'] as IconData,
                      color: const Color(0xFF0D3B55), size: 28),
                  const SizedBox(height: 8),
                  Text(
                    m['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showPlaceholder(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name — coming soon')),
    );
  }
}
