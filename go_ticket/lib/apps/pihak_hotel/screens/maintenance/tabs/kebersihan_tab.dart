import 'package:flutter/material.dart';
import '../widgets/lapor_kerusakan_sheet.dart';

/// Tab 2: Papan Kebersihan Kamar & Checklist Housekeeping
class KebersihanTab extends StatefulWidget {
  const KebersihanTab({super.key});

  @override
  State<KebersihanTab> createState() => _KebersihanTabState();
}

class _KebersihanTabState extends State<KebersihanTab> {
  int _selectedFloorIndex = 0; // 0: Semua Lantai, 1: Lantai 1, 2: Lantai 2, 3: Lantai 3
  int _selectedStatusFilter = 0; // 0: Antrean (5), 1: Proses (3), 2: Siap Inspeksi (6)
  
  // Checklist kamar #304
  final List<bool> _checklistValues = [true, true, true, false, false, false];

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
    return _buildKebersihanTab();
  }

  Widget _buildKebersihanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Utama: Papan Kebersihan Kamar
          const Text(
            'Papan Kebersihan Kamar',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Filter Lantai
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFloorPill(title: 'Semua Lantai', index: 0),
                const SizedBox(width: 8),
                _buildFloorPill(title: 'Lantai 1', index: 1),
                const SizedBox(width: 8),
                _buildFloorPill(title: 'Lantai 2', index: 2),
                const SizedBox(width: 8),
                _buildFloorPill(title: 'Lantai 3', index: 3),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Status Badges Bar: [● Antrean 5] [● Proses 3] [● Siap Inspeksi 6]
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatusFilterPill(
                    dotColor: const Color(0xFFDC2626),
                    title: 'Antrean',
                    count: 5,
                    isSelected: _selectedStatusFilter == 0,
                    onTap: () => setState(() => _selectedStatusFilter = 0),
                  ),
                ),
                Expanded(
                  child: _buildStatusFilterPill(
                    dotColor: const Color(0xFF00C2FF),
                    title: 'Proses',
                    count: 3,
                    isSelected: _selectedStatusFilter == 1,
                    onTap: () => setState(() => _selectedStatusFilter = 1),
                  ),
                ),
                Expanded(
                  child: _buildStatusFilterPill(
                    dotColor: const Color(0xFF00758F),
                    title: 'Siap Inspeksi',
                    count: 6,
                    isSelected: _selectedStatusFilter == 2,
                    onTap: () => setState(() => _selectedStatusFilter = 2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 1: Kamar #205 (Dirty / Checkout Baru)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
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
                        const Text(
                          'Kamar #205',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Dirty / Checkout Baru',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.meeting_room_outlined, color: Color(0xFF0284C7), size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('Standard Suite • Lantai 2', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 14),

                // Petugas & Target Durasi Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFBAE6FD),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text('MW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Petugas', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                            Text('Made Wijaya', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF0284C7)),
                          SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target Durasi', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                              Text('30 Menit • Normal', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Tombol [Ganti] [Buka Checklist & Mulai]
                Row(
                  children: [
                    SizedBox(
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: () => _showActionSnackbar('Ganti penugasan kamar #205...'),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: Color(0xFF334155)),
                        label: const Text('Ganti', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          backgroundColor: const Color(0xFFF8FAFD),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () => _showActionSnackbar('Membuka checklist & memulai timer kamar #205...'),
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                          label: const Text('Buka Checklist & Mulai', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C2FF),
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

          // Card 2: Kamar #304 (Sedang Dibersihkan 18:24) & Full Checklist
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kamar #304', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBAF0FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.circle, color: Color(0xFF00758F), size: 6),
                              SizedBox(width: 4),
                              Text('Sedang Dibersihkan (18:24)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006D84))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text('Deluxe Ocean View • Lantai 3', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A5868),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('BS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Progress Bar: 3 dari 6 selesai (50%)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Progres Kebersihan: 3 dari 6 selesai', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    Text('50%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Color(0xFFEEF2FE),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 16),

                // Checklist Sanitasi & Penataan
                const Text(
                  'Checklist Sanitasi & Penataan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),

                // 6 Checklist Items
                _buildChecklistItem(
                  index: 0,
                  title: 'Penggantian Bed Linen, Duvet & Sarung Bantal Baru',
                  subtitle: 'Selesai • Linen Putih Bersih',
                ),
                _buildChecklistItem(
                  index: 1,
                  title: 'Sanitasi Kamar Mandi, Toilet & Handuk Bersih',
                  subtitle: 'Selesai • Disinfeksi Area Basah',
                ),
                _buildChecklistItem(
                  index: 2,
                  title: 'Restock Amenities (Sikat gigi, sabun, sandal)',
                  subtitle: 'Selesai • Kit Kamar Mandi Lengkap',
                ),
                _buildChecklistItem(
                  index: 3,
                  title: 'Dusting Meja, Vacuum Karpet & Pel Lantai',
                  subtitle: 'Sedang proses pembersihan debu balkon',
                ),
                _buildChecklistItem(
                  index: 4,
                  title: 'Restock Minibar & 2 Botol Air Mineral Eco-Glass',
                  subtitle: 'Menunggu verifikasi segel botol',
                ),
                _buildChecklistItem(
                  index: 5,
                  title: 'Pengosongan Tempat Sampah & Cek Remote AC/TV',
                  subtitle: 'Cek baterai remote & sanitize unit',
                ),
                const SizedBox(height: 16),

                // Bukti Kerapian & Quality Control
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Bukti Kerapian & Quality Control', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    Text('1/2 Foto', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    // Foto 1: Ranjang Rapi
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(14),
                          image: const DecorationImage(
                            image: AssetImage('assets/logo_hotel.png'),
                            fit: BoxFit.cover,
                            opacity: 0.15,
                          ),
                        ),
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle_outline, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('Ranjang Rapi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Foto 2: Foto Kamar Mandi
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt_outlined, size: 24, color: Color(0xFF00C2FF)),
                            SizedBox(height: 4),
                            Text('Foto Kamar Mandi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tombol Tunda & Selesai & Siap Huni
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton(
                          onPressed: () => _showActionSnackbar('Pembersihan kamar #304 ditunda.'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            backgroundColor: const Color(0xFFF1F5FD),
                          ),
                          child: const Text('Tunda', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () => _showActionSnackbar('Kamar #304 Selesai & Siap Huni!'),
                          icon: const Icon(Icons.verified_outlined, color: Colors.white, size: 16),
                          label: const Text('Selesai & Siap Huni', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C2FF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tombol + Lapor Kerusakan
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => showLaporKerusakanModal(context),
                    icon: const Icon(Icons.build_circle_outlined, color: Colors.white, size: 18),
                    label: const Text('+ Lapor Kerusakan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C2FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
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

  Widget _buildFloorPill({required String title, required int index}) {
    final isSelected = _selectedFloorIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedFloorIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00667C) : const Color(0xFFF1F5FD),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterPill({
    required Color dotColor,
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(title, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: const Color(0xFF0F172A))),
            const SizedBox(width: 4),
            Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required int index,
    required String title,
    required String subtitle,
  }) {
    final isChecked = _checklistValues[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isChecked,
            activeColor: const Color(0xFF00C2FF),
            onChanged: (val) {
              setState(() {
                _checklistValues[index] = val ?? false;
              });
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isChecked ? const Color(0xFF334155) : const Color(0xFF0F172A),
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3: KERUSAKAN (Foto 3)
  // ===========================================================================

}
