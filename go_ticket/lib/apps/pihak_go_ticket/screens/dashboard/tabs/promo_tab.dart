import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tambah_promo_screen.dart';

/// Tab 2: Manajemen Promo & Diskon (Image 5)
class PromoTab extends StatefulWidget {
  const PromoTab({super.key});

  @override
  State<PromoTab> createState() => _PromoTabState();
}

class _PromoTabState extends State<PromoTab> {
  int _selectedIncentive = 0; // 0 = Diskon %, 1 = Potongan Rp, 2 = Poin Reward
  int _selectedSeason = 0; // 0 = Weekend Staycation, 1 = Musim Liburan, 2 = Hari Libur

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 1. Breadcrumb & Active Count Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'KAMPANYE & PENAWARAN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF007A94),
                letterSpacing: 0.6,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00B4D8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    '2 Aktif',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF007A94),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 2. Title & Subtitle
        const Text(
          'Manajemen Promo & Diskon',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Buat kampanye potongan harga, voucher musiman, dan diskon hari libur.',
          style: TextStyle(
            fontSize: 11.5,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 14),

        // 3. Primary Action Button: + Buat Voucher Promo Baru
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TambahPromoScreen()),
              );
            },
            icon: const Icon(Icons.confirmation_number_outlined, size: 18, color: Colors.white),
            label: const Text(
              '+ Buat Voucher Promo Baru',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C2FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 4. Performance Impact Card ("Dampak Performa Promo")
        _buildPerformanceCard(),
        const SizedBox(height: 16),

        // 5. Preset Kampanye Cepat Section
        _buildQuickPresetsSection(),
        const SizedBox(height: 18),

        // 6. Daftar Voucher Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Daftar Voucher',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: const [
                Icon(Icons.tune_rounded, size: 16, color: Color(0xFF007A94)),
                SizedBox(width: 4),
                Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF007A94),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 7. Voucher Cards List
        _buildVoucherCard1(),
        const SizedBox(height: 14),
        _buildVoucherCard2(),
        const SizedBox(height: 14),
        _buildVoucherCard3(),
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Performance Card
  // ---------------------------------------------------------------------------
  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFBAE6FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Color(0xFF0284C7),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Dampak Performa Promo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCFFAFE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '+34%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0891B2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Meningkatkan reservasi kamar hingga +34% selama akhir pekan dan peak season.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Quick Presets Section
  // ---------------------------------------------------------------------------
  Widget _buildQuickPresetsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
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
            children: const [
              Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 17, color: Color(0xFF0096B4)),
                  SizedBox(width: 6),
                  Text(
                    'Preset Kampanye Cepat',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                'Format Cepat',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tipe Insentif
          const Text(
            'Tipe Insentif',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildPresetChip(
                label: 'Diskon %',
                isSelected: _selectedIncentive == 0,
                onTap: () => setState(() => _selectedIncentive = 0),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                label: 'Potongan Rp',
                isSelected: _selectedIncentive == 1,
                onTap: () => setState(() => _selectedIncentive = 1),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                label: 'Poin Reward',
                isSelected: _selectedIncentive == 2,
                onTap: () => setState(() => _selectedIncentive = 2),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Musim Acuan
          const Text(
            'Musim Acuan',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildPresetChip(
                label: 'Weekend Staycation',
                icon: Icons.hotel_rounded,
                isSelected: _selectedSeason == 0,
                onTap: () => setState(() => _selectedSeason = 0),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                label: 'Musim Liburan',
                icon: Icons.flight_rounded,
                isSelected: _selectedSeason == 1,
                onTap: () => setState(() => _selectedSeason = 1),
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                label: 'Hari Libur',
                icon: Icons.celebration_rounded,
                isSelected: _selectedSeason == 2,
                onTap: () => setState(() => _selectedSeason = 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F2FE) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF7DD3FC) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Voucher Card 1 (Active: STAYHEMAT)
  // ---------------------------------------------------------------------------
  Widget _buildVoucherCard1() {
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
          // Header: Code & Active Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'STAYHEMAT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: 'STAYHEMAT'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kode voucher STAYHEMAT disalin!')),
                      );
                    },
                    child: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFF007A94)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00B4D8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Sedang Aktif',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF007A94),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Diskon 35% Spesial Weekend',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          // Info Box: Kategori & Potongan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Kategori', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    SizedBox(height: 2),
                    Text(
                      'Weekend Staycation',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('Potongan', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    SizedBox(height: 2),
                    Text(
                      '35% (Maks Rp 150rb)',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF007A94)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Sisa Kuota Pemakaian
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.group_outlined, size: 14, color: Color(0xFF64748B)),
                  SizedBox(width: 5),
                  Text(
                    'Sisa Kuota Pemakaian',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Text(
                '75 / 100 (75%)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Progress Bar (75%)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),

          // Valid Date Range & Slot remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                  SizedBox(width: 5),
                  Text(
                    '20 Okt – 31 Okt 2025',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Text(
                'Tersisa 25 Slot',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0284C7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons: Sunting Promo & Hentikan Kupon
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 15, color: Color(0xFF0F172A)),
                    label: const Text(
                      'Sunting Promo',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.cancel_outlined, size: 15, color: Color(0xFFDC2626)),
                    label: const Text(
                      'Hentikan Kupon',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEE2E2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // ---------------------------------------------------------------------------
  // Voucher Card 2 (Scheduled: LIBURANHEMAT25)
  // ---------------------------------------------------------------------------
  Widget _buildVoucherCard2() {
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
                  const Text(
                    'LIBURANHEMAT25',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: 'LIBURANHEMAT25'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kode voucher LIBURANHEMAT25 disalin!')),
                      );
                    },
                    child: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFF007A94)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0284C7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Terjadwal',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Promo Musim Liburan Akhir Tahun',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          // Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Kategori', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    SizedBox(height: 2),
                    Text(
                      'Peak Season Holiday',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('Potongan', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    SizedBox(height: 2),
                    Text(
                      'Rp 200rb (Min 1,5Jt)',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF007A94)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Sisa Kuota (15%)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.group_outlined, size: 14, color: Color(0xFF64748B)),
                  SizedBox(width: 5),
                  Text('Sisa Kuota Pemakaian', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Text('30 / 200 (15%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.15,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),

          // Valid Date Range & Start info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                  SizedBox(width: 5),
                  Text('1 Des 2025 – 5 Jan 2026', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Text('Mulai 40 hari lagi', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons: Sunting Jadwal & Lihat Analitik
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF0F172A)),
                    label: const Text(
                      'Sunting Jadwal',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEF2FE),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.auto_graph_rounded, size: 15, color: Color(0xFF007A94)),
                    label: const Text(
                      'Lihat Analitik',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF007A94)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0F7FA),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // ---------------------------------------------------------------------------
  // Voucher Card 3 (Expired: FLASH50)
  // ---------------------------------------------------------------------------
  Widget _buildVoucherCard3() {
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
                  const Text(
                    'FLASH50',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: 'FLASH50'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kode voucher FLASH50 disalin!')),
                      );
                    },
                    child: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF64748B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Habis / Kedaluwarsa',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Flash Deal 50% Resor Pilihan',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          // Quota full 100%
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF64748B)),
                  SizedBox(width: 5),
                  Text('Kuota Habis Terpakai', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Text('100 / 100 (100%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 1.0,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF94A3B8)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 14),

          // Button: Aktifkan Kembali & Tambah Kuota
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mengaktifkan kembali kupon FLASH50...')),
                );
              },
              icon: const Icon(Icons.sync_rounded, size: 16, color: Color(0xFF007A94)),
              label: const Text(
                'Aktifkan Kembali & Tambah Kuota',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF007A94),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF2FE),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
