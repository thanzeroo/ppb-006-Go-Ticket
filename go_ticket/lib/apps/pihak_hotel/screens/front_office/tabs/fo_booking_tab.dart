import 'package:flutter/material.dart';

/// Tab 2: Booking / Verifikasi Reservasi Front Office
class FoBookingTab extends StatefulWidget {
  const FoBookingTab({super.key});

  @override
  State<FoBookingTab> createState() => _FoBookingTabState();
}

class _FoBookingTabState extends State<FoBookingTab> {
  int _bookingFilterIndex = 1; // 0: Semua, 1: Menunggu Verifikasi (4), 2: Disetujui
  final TextEditingController _searchBookingController = TextEditingController();

  @override
  void dispose() {
    _searchBookingController.dispose();
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
    return _buildBookingTab();
  }

  Widget _buildBookingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner: Verifikasi Reservasi Tamu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6FD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified_user_rounded, color: Color(0xFF0284C7), size: 18),
                SizedBox(width: 8),
                Text(
                  'Verifikasi Reservasi Tamu',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Filter Tabs: [Semua Booking] [Menunggu Verifikasi (4)] [Disetujui]
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterPill(title: 'Semua Booking', index: 0),
                const SizedBox(width: 8),
                _buildFilterPill(title: 'Menunggu Verifikasi', badgeCount: 4, index: 1),
                const SizedBox(width: 8),
                _buildFilterPill(title: 'Disetujui', index: 2),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search Bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchBookingController,
              style: const TextStyle(fontSize: 12.5),
              decoration: const InputDecoration(
                hintText: 'Cari ID Booking / Nama Tamu / No HP',
                hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                prefixIcon: Icon(Icons.search_rounded, size: 19, color: Color(0xFF94A3B8)),
                suffixIcon: Icon(Icons.tune_rounded, size: 18, color: Color(0xFF0284C7)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Quick Filter chips: [Tipe Kamar: Semua v] [Check-in: Hari Ini x]
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTagChip(label: 'Tipe Kamar: Semua', icon: Icons.bed_outlined, isDropdown: true),
                const SizedBox(width: 8),
                _buildTagChip(label: 'Check-in: Hari Ini', icon: Icons.calendar_today_outlined, hasClear: true),
                const SizedBox(width: 8),
                _buildTagChip(label: '1', icon: Icons.filter_alt_outlined),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Banner: Antrean Verifikasi Mendesak (1 Baru)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFBAF0FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF00758F)),
                    SizedBox(width: 6),
                    Text(
                      'Antrean Verifikasi Mendesak',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF006D84),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '1 Baru',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ITEM 1: #BK-99302 (Prioritas - Transfer BCA)
          _buildBookingItem1(),
          const SizedBox(height: 16),

          // ITEM 2: #BK-99305 (QRIS Instant)
          _buildBookingItem2(),
          const SizedBox(height: 16),

          // ITEM 3: #BK-99280 (Disetujui E-Tiket Terbit)
          _buildBookingItem3(),
          const SizedBox(height: 16),

          // Info Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF7FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Semua reservasi yang disetujui akan otomatis tersinkronisasi ke Room Grid dan mengirimkan tautan Check-In Mandiri ke aplikasi tamu.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.35),
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

  Widget _buildFilterPill({required String title, int? badgeCount, required int index}) {
    final isSelected = _bookingFilterIndex == index;
    return InkWell(
      onTap: () => setState(() => _bookingFilterIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00C2FF) : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 6),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip({
    required String label,
    required IconData icon,
    bool isDropdown = false,
    bool hasClear = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F4FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0284C7)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7)),
          ),
          if (isDropdown) ...[
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF0284C7)),
          ],
          if (hasClear) ...[
            const SizedBox(width: 4),
            const Icon(Icons.close, size: 13, color: Color(0xFF0284C7)),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingItem1() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                    '#BK-99302',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF00758F)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '● Prioritas',
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
                child: const Icon(Icons.account_balance_outlined, size: 18, color: Color(0xFF0284C7)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '🕒 Dibuat 15 menit lalu • Transfer Bank BCA',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          // Guest row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFBAE6FD),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('RP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Bpk. Rian Pratama', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    Text('NIK: 327310089920003', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone_outlined, size: 17, color: Color(0xFF0284C7)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.bed_outlined, size: 14, color: Color(0xFF0284C7)),
              SizedBox(width: 4),
              Text('Deluxe Ocean View', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              Spacer(),
              Text('3 Malam (24 - 27 Okt)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 12),

          // Total Biaya
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('TOTAL BIAYA DP', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  Text('Rp 2.450.000', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F4FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.cloud_done_outlined, size: 14, color: Color(0xFF0284C7)),
                    SizedBox(width: 4),
                    Text('Bukti Bayar Diunggah', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Audit Slip Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.description_outlined, size: 15, color: Color(0xFF0284C7)),
                        SizedBox(width: 6),
                        Text('Audit Slip Transfer Bank', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      ],
                    ),
                    Text('Pratinjau Slip ↗', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF64748B), size: 28),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBAF0FD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Valid Rp 2.450.000', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                          ),
                          const SizedBox(height: 2),
                          const Text('Ref: TRF-BCA-980122941', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          const Text('Penerima: PT Amora Hospitality', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Permintaan Khusus Tamu:', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text('"High floor, non-smoking room, extra towel."', style: TextStyle(fontSize: 11, color: Color(0xFF334155), fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons: [Tolak Booking] [Setujui & E-Tiket]
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () => _showActionSnackbar('Booking #BK-99302 ditolak.'),
                    icon: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 16),
                    label: const Text('Tolak\nBooking', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEE2E2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () => _showActionSnackbar('Booking #BK-99302 Berhasil Disetujui! E-Tiket Terbit.'),
                    icon: const Icon(Icons.verified_outlined, color: Colors.white, size: 17),
                    label: const Text('Setujui & E-Tiket', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
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
        ],
      ),
    );
  }

  Widget _buildBookingItem2() {
    return Container(
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
                  const Text('#BK-99305', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF00758F))),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F4FB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('QRIS Instant', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
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
                child: const Icon(Icons.qr_code_2_rounded, size: 18, color: Color(0xFF0284C7)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text('Dibuat 42 menit lalu', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFBAF0FD),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('AL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Ibu Amanda Lee', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    Text('Royal Pool Villa', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('Rp 4.350.000', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  Text('Lunas QRIS', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.badge_outlined, size: 14, color: Color(0xFFDC2626)),
                  SizedBox(width: 6),
                  Text('Verifikasi Identitas KTP Tamu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Periksa KTP ➔', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem3() {
    return Container(
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
                  const Text('#BK-99280', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF00758F))),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBEF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('✔ Disetujui (E-Tiket Terbit)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
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
                child: const Icon(Icons.confirmation_number_outlined, size: 18, color: Color(0xFF0284C7)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text('Diverifikasi oleh Staf FO Rani • 1 Jam lalu', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('HK', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Hendro Kusuma', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    Text('Standard Twin Room', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('Rp 1.100.000', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  Text('BCA Virtual Acc', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.badge_outlined, size: 14, color: Color(0xFF0284C7)),
                  SizedBox(width: 6),
                  Text('Kode E-Tiket: GT-893021', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('📄 Slip PDF', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
