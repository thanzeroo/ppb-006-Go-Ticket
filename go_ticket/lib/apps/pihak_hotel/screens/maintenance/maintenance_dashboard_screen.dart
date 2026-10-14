import 'package:flutter/material.dart';

/// Dashboard Maintenance — daftar tugas dan tiket perawatan.
class MaintenanceDashboardScreen extends StatelessWidget {
  const MaintenanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {'room': '201', 'task': 'Pergantian Linen', 'status': 'Pending'},
      {'room': '305', 'task': 'Perbaikan AC', 'status': 'Dalam Pengerjaan'},
      {'room': '112', 'task': 'Pembersihan Kamar Mandi', 'status': 'Selesai'},
      {'room': '408', 'task': 'Lampu Rusak', 'status': 'Pending'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Maintenance'),
        backgroundColor: const Color(0xFF065F46),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buat tiket — coming soon')),
        ),
        backgroundColor: const Color(0xFF065F46),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat Tiket',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Daftar Tugas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 14),
          ...tasks.map((t) => _buildTaskCard(t)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, String> task) {
    final statusColor = switch (task['status']) {
      'Selesai' => const Color(0xFF059669),
      'Dalam Pengerjaan' => const Color(0xFFD97706),
      _ => const Color(0xFF64748B),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF065F46).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.build_circle_outlined,
                color: Color(0xFF065F46), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kamar ${task['room']} — ${task['task']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task['status']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }
}
