import 'package:flutter/material.dart';

/// Tab Pesanan — daftar booking aktif dan riwayat.
class PesananTab extends StatelessWidget {
  const PesananTab({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        'hotel': 'Grand Amora Resort',
        'date': '24 - 26 Okt 2026',
        'status': 'Aktif',
        'code': 'GTK-2024-001',
      },
      {
        'hotel': 'Kuta Beach Hotel',
        'date': '10 - 12 Sep 2026',
        'status': 'Selesai',
        'code': 'GTK-2024-002',
      },
      {
        'hotel': 'Padma Resort Ubud',
        'date': '5 - 7 Agu 2026',
        'status': 'Dibatalkan',
        'code': 'GTK-2024-003',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        backgroundColor: const Color(0xFF00B4D8),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: orders.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 48, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada pesanan',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _buildOrderCard(orders[i]),
            ),
    );
  }

  Widget _buildOrderCard(Map<String, String> order) {
    final statusColor = switch (order['status']) {
      'Aktif' => const Color(0xFF0284C7),
      'Selesai' => const Color(0xFF059669),
      _ => const Color(0xFFDC2626),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['hotel']!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['status']!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                order['date']!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.confirmation_number_outlined,
                  size: 13, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                order['code']!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          if (order['status'] == 'Aktif') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00B4D8),
                  side: const BorderSide(color: Color(0xFF00B4D8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.qr_code, size: 16),
                label: const Text(
                  'Lihat E-Tiket',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
