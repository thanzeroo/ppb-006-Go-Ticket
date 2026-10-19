import 'package:flutter/material.dart';

/// Modal Bottom Sheet: Lapor Kerusakan Fasilitas (#MT-2025-088)
  void showLaporKerusakanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.94,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header Lapor Kerusakan Fasilitas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    Image.asset(
                      'assets/logo.png',
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.confirmation_number_outlined, color: Color(0xFF00B4D8)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Lapor Kerusakan Fasilitas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          Text('The Grand Amora Resort & Spa', style: TextStyle(fontSize: 10.5, color: Color(0xFF0284C7))),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: Color(0xFF0A5868), shape: BoxShape.circle),
                      child: const Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge: #MT-2025-088 • Drafting
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
                              children: [
                                Row(
                                  children: const [
                                    Text('TIKET MAINTENANCE BARU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                    SizedBox(width: 6),
                                    Text('#MT-2025-088', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('● Drafting', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(Icons.engineering_outlined, size: 13, color: Color(0xFF0284C7)),
                                SizedBox(width: 4),
                                Text('Modul Engineering • Pelapor: Front Office Staff (Dewi)', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Step 1: Lokasi & Titik Kerusakan
                      Container(
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
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: const Text('1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                                ),
                                const SizedBox(width: 8),
                                const Text('Lokasi & Titik Kerusakan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('Nomor Kamar • Blok Villa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                                Text('Live PMS Sync', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Kamar #304 - Deluxe Ocean View (Lt. 3)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                  Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0284C7)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Step 4: Detail Keluhan Kerusakan
                      Container(
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
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: const Text('4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                                ),
                                const SizedBox(width: 8),
                                const Text('Detail Keluhan Kerusakan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('Judul Singkat Masalah', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('AC Menetes Air & Kurang Dingin (Suhu Tertahan di ...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                            ),
                            const SizedBox(height: 12),

                            const Text('Deskripsi Rinci Masalah • Temuan Front Office', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Tamu mengeluhkan ada tetesan air dari indoor unit AC mengalir ke meja samping ranjang, terdengar suara desis freon, filter kotor.',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.35),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // SOP Penanganan Khusus Tamu In-Room
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(Icons.notifications_active_outlined, size: 16, color: Color(0xFF0284C7)),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('SOP Penanganan Khusus Tamu In-Room', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                                        SizedBox(height: 2),
                                        Text(
                                          'Tamu sedang berada di dalam kamar. Wajib ketuk pintu sopan sesuai SOP perhotelan & bawa matras alas pelindung lantai.',
                                          style: TextStyle(fontSize: 10, color: Color(0xFF475569), height: 1.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Step 5: Lampiran Foto Lapangan (2 dari 3 Foto Terlampir)
                      Container(
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
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
                                      alignment: Alignment.center,
                                      child: const Text('5', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Lampiran Foto Lapangan', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                                  ],
                                ),
                                const Text('2 dari 3 Foto\nTerlampir', textAlign: TextAlign.right, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                // Foto 1: Unit Indoor AC
                                Expanded(
                                  child: Container(
                                    height: 88,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF334155),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                                            child: const Icon(Icons.close, size: 13, color: Colors.white),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 6,
                                          left: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(4)),
                                            child: const Text('Unit Indoor AC', style: TextStyle(fontSize: 8.5, color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Foto 2: Rembesan Lantai
                                Expanded(
                                  child: Container(
                                    height: 88,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF475569),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                                            child: const Icon(Icons.close, size: 13, color: Colors.white),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 6,
                                          left: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(4)),
                                            child: const Text('Rembesan Lantai', style: TextStyle(fontSize: 8.5, color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Foto 3: Ambil Foto ke-3
                                Expanded(
                                  child: Container(
                                    height: 88,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.camera_alt_outlined, color: Color(0xFF00C2FF), size: 22),
                                        SizedBox(height: 3),
                                        Text('Ambil Foto ke-3', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Tombol Buka Kamera Ponsel Ops
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Membuka Kamera Ponsel Ops...'),
                                      backgroundColor: Color(0xFF00758F),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.camera_alt_outlined, size: 16, color: Color(0xFF00758F)),
                                label: const Text('Buka Kamera Ponsel Ops', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF00758F))),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFBAE6FD)),
                                  backgroundColor: const Color(0xFFF1F5FD),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar: [Batal / Reset] [Terbitkan • Kirim >]
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEEF2FE),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          child: const Text('Batal / Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tiket #MT-2025-088 Berhasil Diterbitkan ke Tim Engineering!'), backgroundColor: Color(0xFF00758F)));
                          },
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                          label: const Text('Terbitkan • Kirim', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
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
              ),
            ],
          ),
        );
      },
    );
  }

