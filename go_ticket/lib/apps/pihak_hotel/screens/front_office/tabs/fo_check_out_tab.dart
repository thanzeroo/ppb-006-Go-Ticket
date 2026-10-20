import 'package:flutter/material.dart';

/// Tab 4: Check-Out Tamu Front Office
class FoCheckOutTab extends StatefulWidget {
  const FoCheckOutTab({super.key});

  @override
  State<FoCheckOutTab> createState() => _FoCheckOutTabState();
}

class _FoCheckOutTabState extends State<FoCheckOutTab> {
  int _selectedCheckOutRoom = 0; // 0: 104 Sarah, 1: 208 Denny
  bool _cardAccessReturned = true;
  bool _depositRefunded = true;
  String _selectedCleaner = 'Rian - Shift Pagi (Lantai 1, Beban: Rendah)';
  final TextEditingController _cleanerNotesController = TextEditingController(
    text: 'Sprei ganti baru, cek persediaan handuk dan toilet kit.',
  );

  @override
  void dispose() {
    _cleanerNotesController.dispose();
    super.dispose();
  }

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
    return _buildCheckOutTab();
  }

  Widget _buildCheckOutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subheader: LAYANAN RESEPSIONIS • Alur #084
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.room_service_outlined, size: 16, color: Color(0xFF0284C7)),
                  SizedBox(width: 6),
                  Text(
                    'LAYANAN RESEPSIONIS',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0284C7), letterSpacing: 0.8),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('● Alur #084', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Proses Check-out Tamu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pencatatan waktu keluar, rekonsiliasi biaya tambahan, & serah tugas housekeeping.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // Header Pilih Kamar & Tamu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Pilih Kamar & Tamu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              Text('3 Tamu Siap Keluar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
            ],
          ),
          const SizedBox(height: 8),

          // Card Tamu Aktif (104 Ibu Sarah Wilson)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBAE6FD),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('104', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0369A1))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Ibu Sarah Wilson', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCBD5E1).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Deluxe', style: TextStyle(fontSize: 9, color: Color(0xFF475569))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Jadwal: Hari ini 12:00 WIB', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0284C7)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal room selection pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRoomSelectionPill(index: 0, text: 'Kamar 104 (Sarah W.)', isSelected: _selectedCheckOutRoom == 0),
                const SizedBox(width: 8),
                _buildRoomSelectionPill(index: 1, text: 'Kamar 208 (Bpk. Denny)', isSelected: _selectedCheckOutRoom == 1),
                const SizedBox(width: 8),
                _buildRoomSelectionPill(index: 2, text: 'Kamar 310', isSelected: false),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // SECTION 1: Waktu Keluar & Kunci
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0F2FE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF0284C7)),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('1. Waktu Keluar & Kunci', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            Text('Pencatatan aktual fisik tamu', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F4FB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Tepat Waktu', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Waktu keluar aktual box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.key_rounded, size: 18, color: Color(0xFF00758F)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Waktu Keluar Aktual', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                              Text('26 Okt 2025, 11:45 WIB', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text('Ubah', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Checklist 1: Kartu Akses Kamar #104
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _cardAccessReturned,
                        activeColor: const Color(0xFF00C2FF),
                        onChanged: (val) => setState(() => _cardAccessReturned = val ?? false),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Kartu Akses Kamar #104', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            Text('Telah diterima kembali & dicek sensor RFID-nya', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00C2FF), size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Checklist 2: Pengembalian Uang Deposit
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _depositRefunded,
                        activeColor: const Color(0xFF00C2FF),
                        onChanged: (val) => setState(() => _depositRefunded = val ?? false),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Pengembalian Uang Deposit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBAF0FD),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Selesai', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                                ),
                              ],
                            ),
                            const Text('Rp 100.000 telah dikembalikan tunai ke tamu', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      const Icon(Icons.payments_outlined, color: Color(0xFF00758F), size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // SECTION 2: Cleaning Handover
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cleaning_services_outlined, size: 16, color: Color(0xFF0284C7)),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('2. Cleaning', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        Text('Transisi ke operasional tim turn-over', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status Kamar Selanjutnya box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Status Kamar Selanjutnya:', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          Text('Kamar 104', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.circle, color: Color(0xFFD97706), size: 8),
                            SizedBox(width: 5),
                            Text('Perlu Dibersihkan', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Tugaskan Petugas Kebersihan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Tugaskan Petugas Kebersihan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    Text('Tersedia 4 Staf', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCleaner,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      items: [
                        'Rian - Shift Pagi (Lantai 1, Beban: Rendah)',
                        'Budi - Shift Pagi (Lantai 2, Beban: Sedang)',
                        'Doni - Shift Pagi (Lantai 1, Beban: Penuh)',
                      ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _selectedCleaner = val ?? _selectedCleaner),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Catatan Khusus untuk Tim Kebersihan
                const Text('Catatan Khusus untuk Tim Kebersihan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _cleanerNotesController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tulis catatan untuk tim kebersihan...',
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('Maks. 140 karakter', style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Kondisi Awal Kamar 104 Preview Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_size_select_actual_outlined, color: Color(0xFF64748B), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Text('Kondisi Awal Kamar 104', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          SizedBox(width: 4),
                          Icon(Icons.camera_alt_outlined, size: 14, color: Color(0xFF0284C7)),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text('Foto inspeksi pra-inap tersimpan rapi di log', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF7FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Lihat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Checklist info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: Color(0xFF0D9488), size: 16),
                  SizedBox(width: 6),
                  Text('Semua verifikasi checklist lengkap', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                ],
              ),
              Text('Siap Disimpan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
            ],
          ),
          const SizedBox(height: 10),

          // Tombol Konfirmasi Check-out & Ubah Status Kamar
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _showActionSnackbar('Check-out Kamar 104 Selesai! Ditugaskan ke $_selectedCleaner.'),
              icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 18),
              label: const Text(
                'Konfirmasi Check-out & Ubah Status Kamar',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C2FF),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRoomSelectionPill({required int index, required String text, required bool isSelected}) {
    return InkWell(
      onTap: () => setState(() => _selectedCheckOutRoom = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFBAF0FD) : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 13, color: Color(0xFF00758F)),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF006D84) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
