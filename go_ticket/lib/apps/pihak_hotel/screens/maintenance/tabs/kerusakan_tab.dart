import 'package:flutter/material.dart';

/// Tab 3: Tiket Kerusakan & Hub Pemeliharaan Maintenance
class KerusakanTab extends StatefulWidget {
  const KerusakanTab({super.key});

  @override
  State<KerusakanTab> createState() => _KerusakanTabState();
}

class _KerusakanTabState extends State<KerusakanTab> {
  int _ticketFilterIndex = 0; // 0: Semua Tiket, 1: Pending (1), 2: In Progress (1)

  void _showActionSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00758F),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildKerusakanTab();
  }

  Widget _buildKerusakanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subheader: LIVE MAINTENANCE HUB • Shift Pagi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF00C2FF), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('LIVE MAINTENANCE HUB', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0284C7), letterSpacing: 0.8)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Shift Pagi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tiket Kerusakan & Pemeliharaan',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.4),
          ),
          const SizedBox(height: 14),

          // 3 Ringkasan Kotak: [Tiket Aktif] [Sparepart] [Selesai]
          Row(
            children: [
              Expanded(
                child: _buildTicketSummaryBox(
                  icon: Icons.build_circle_outlined,
                  number: '2',
                  label: 'Tiket Aktif',
                  badgeText: '1 Urgent',
                  badgeBg: const Color(0xFFFEE2E2),
                  badgeTextColor: const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTicketSummaryBox(
                  icon: Icons.inventory_2_outlined,
                  number: '1',
                  label: 'Sparepart',
                  hasDot: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTicketSummaryBox(
                  icon: Icons.verified_outlined,
                  number: '14',
                  label: 'Selesai',
                  badgeText: 'Minggu ini',
                  badgeBg: const Color(0xFFBAF0FD),
                  badgeTextColor: const Color(0xFF00758F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Filter Pills: [Semua Tiket] [Pending (1)] [In Progress (1)]
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTicketFilterPill(title: 'Semua Tiket', index: 0),
                const SizedBox(width: 8),
                _buildTicketFilterPill(title: 'Pending (1)', index: 1),
                const SizedBox(width: 8),
                _buildTicketFilterPill(title: 'In Progress (1)', index: 2),
                const SizedBox(width: 8),
                _buildTicketFilterPill(title: 'Resolved', index: 3),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // TIKET 1: #MT-402 (AC Kurang Dingin - In Progress)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('#MT-402', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF00758F))),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Darurat / Tamu In-House', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBAF0FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.circle, color: Color(0xFF00758F), size: 6),
                          SizedBox(width: 4),
                          Text('In Progress', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006D84))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'AC Kurang Dingin (Suhu 27°C)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),

                // Lokasi Kamar & Tamu Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.bed_outlined, size: 14, color: Color(0xFF0284C7)),
                          SizedBox(width: 6),
                          Text('Kamar #204 — Deluxe Ocean View', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 6),
                          Text('Tamu in-house: Ir. Gunawan (Check-out tgl 16)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 6),
                          Text('Dilaporkan 08:15 WIB • Durasi: 45 mnt berjalan', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Info Teknisi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.engineering_outlined, size: 18, color: Color(0xFF00758F)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Hendra Wijaya (Teknisi Senior)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          SizedBox(height: 2),
                          Text(
                            'Status pengerjaan: Penggantian kapasitor 35uF & pengisian freon R32 di unit outdoor balkon.',
                            style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Buttons: [Update Status] [Selesaikan Tiket]
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () => _showActionSnackbar('Memperbarui status pengerjaan tiket #MT-402...'),
                          icon: const Icon(Icons.sync_rounded, size: 16, color: Color(0xFF00758F)),
                          label: const Text('Update Status', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFBAE6FD)),
                            backgroundColor: const Color(0xFFF1F5FD),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () => _showActionSnackbar('Tiket #MT-402 Selesai & Ditutup!'),
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                          label: const Text('Selesaikan Tiket', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00667C),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // TIKET 2: #MT-405 (Lampu Spot Balkon Berkedip & Mati)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('#MT-405', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF475569))),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Urgensi Sedang', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF6D28D9))),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F4FB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Menunggu Sparepart', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lampu Spot Balkon Berkedip & Mati',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.bed_outlined, size: 14, color: Color(0xFF0284C7)),
                          SizedBox(width: 6),
                          Text('Kamar #310 — Standard Twin', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Driver LED 12V konslet kena uap embun laut. Menunggu restok gudang logistik.',
                              style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Teknisi: Belum Ditugaskan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                    Text('09:40 WIB', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _showActionSnackbar('Membuka penugasan teknisi untuk tiket #MT-405...'),
                    icon: const Icon(Icons.person_add_alt_outlined, color: Color(0xFF00758F), size: 17),
                    label: const Text('Tugaskan Teknisi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBAF0FD),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // TIKET 3: #MT-398 (Keran Shower Bocor - Resolved)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('#MT-398', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Rendah', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check, color: Color(0xFF1E40AF), size: 12),
                          SizedBox(width: 4),
                          Text('Resolved', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keran Shower Bocor / ...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Kamar #102 • Suite Garden', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    Text('Selesai: Kemarin 16:30', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Dikerjakan oleh Teknisi Hendra. Penggantian rubber seal valve selesai dan telah dites tekanan air.',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTicketSummaryBox({
    required IconData icon,
    required String number,
    required String label,
    String? badgeText,
    Color? badgeBg,
    Color? badgeTextColor,
    bool hasDot = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF00758F)),
              if (badgeText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(badgeText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeTextColor)),
                ),
              ] else if (hasDot) ...[
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(number, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 1),
          Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildTicketFilterPill({required String title, required int index}) {
    final isSelected = _ticketFilterIndex == index;
    return InkWell(
      onTap: () => setState(() => _ticketFilterIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFBAF0FD) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF9AE5FA) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF006D84) : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // BOTTOM NAVIGATION BAR (Foto 1, 2, 3)
  // ===========================================================================

}
