import 'package:flutter/material.dart';

/// Dashboard Executive / Admin Hotel — ringkasan keuangan dan manajemen.
class ExecutiveDashboardScreen extends StatelessWidget {
  const ExecutiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      {
        'icon': Icons.people_outline,
        'label': 'Manajemen Staf',
        'desc': 'Kelola data karyawan hotel',
      },
      {
        'icon': Icons.bed_outlined,
        'label': 'Harga Kamar',
        'desc': 'Atur tarif dan ketersediaan kamar',
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Keuangan & Payout',
        'desc': 'Laporan pendapatan dan pencairan',
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Laporan Performa',
        'desc': 'Statistik occupancy dan revenue',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Admin Hotel'),
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Pendapatan Bulan Ini',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  'Rp 84.500.000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '↑ 12% dari bulan lalu',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Menu Manajemen',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ...menus.map(
            (m) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${m['label']} — coming soon')),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            m['icon'] as IconData,
                            color: const Color(0xFF7C3AED),
                            size: 22,
                          ),
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
                                  color: Color(0xFF1E293B),
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
                        const Icon(Icons.chevron_right,
                            color: Color(0xFFCBD5E1)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
