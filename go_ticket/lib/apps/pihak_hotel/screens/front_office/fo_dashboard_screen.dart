import 'package:flutter/material.dart';
import '../../../pihak_user/screens/auth/terms_and_policy_screen.dart';

/// Dashboard Front Office (Staf Depan) Hotel
/// Berisi 4 Tab Utama:
/// 1. Dashboard (Ringkasan Operasional, Scanner, Aksi Cepat)
/// 2. Booking (Verifikasi Reservasi Tamu, Filter, Slip Transfer, Tindakan)
/// 3. Check In (Proses Check-in Tamu, Pencarian, Detail Kamar & Tamu, Serah Kunci)
/// 4. Check Out (Proses Check-out Tamu, Waktu Keluar, Checklist RFID/Deposit, Cleaning Handover)
class FoDashboardScreen extends StatefulWidget {
  const FoDashboardScreen({super.key});

  @override
  State<FoDashboardScreen> createState() => _FoDashboardScreenState();
}

class _FoDashboardScreenState extends State<FoDashboardScreen> {
  int _currentTabIndex = 0;

  // State untuk Tab Booking
  int _bookingFilterIndex = 1; // 0: Semua, 1: Menunggu Verifikasi (4), 2: Disetujui
  final TextEditingController _searchBookingController = TextEditingController();

  // State untuk Tab Check-In
  final TextEditingController _checkInSearchController = TextEditingController(text: '#STP-882910-ID');

  // State untuk Tab Check-Out
  int _selectedCheckOutRoom = 0; // 0: 104 Sarah, 1: 208 Denny
  bool _cardAccessReturned = true;
  bool _depositRefunded = true;
  String _selectedCleaner = 'Rian - Shift Pagi (Lantai 1, Beban: Rendah)';
  final TextEditingController _cleanerNotesController = TextEditingController(
    text: 'Sprei ganti baru, cek persediaan handuk dan toilet kit.',
  );

  @override
  void dispose() {
    _searchBookingController.dispose();
    _checkInSearchController.dispose();
    _cleanerNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar
            _buildTopAppBar(),

            // Body Sesuai Tab yang Aktif
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  _buildDashboardTab(),
                  _buildBookingTab(),
                  _buildCheckInTab(),
                  _buildCheckOutTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ===========================================================================
  // TOP APP BAR
  // ===========================================================================
  Widget _buildTopAppBar() {
    String titleText = 'Dashboard';
    if (_currentTabIndex == 1) titleText = 'Check In'; // Foto tab 2
    if (_currentTabIndex == 2) titleText = 'Check In';
    if (_currentTabIndex == 3) titleText = 'Check Out';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Badge Staf Ops
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFF00B4D8),
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F4FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Staf Ops',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),

          // Role & Shift info + Profile Avatar
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Text(
                    'Shift Pagi',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Stack(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFF475569),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'M',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C2FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: DASHBOARD (Foto 1)
  // ===========================================================================
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card Profile User: Muhammad Farchan
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF334155),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'M',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C2FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'Muhammad Farchan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.verified,
                            color: Color(0xFF0284C7),
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Front Office & Resepsionis',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00C2FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Shift Pagi • Aktif',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Notification Bell with Badge
                Stack(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        size: 20,
                        color: Color(0xFF334155),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card Utama Scanner QR E-Tiket (Cyan Gradient)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFBAF0FD), Color(0xFFE4F8FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF9AE5FA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 13,
                            color: Color(0xFF00758F),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Aksi Utama Petugas',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF00758F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.crop_free_rounded,
                        color: Color(0xFF00758F),
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pemindai Cepat QR E-Tiket',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Validasi instan voucher reservasi, e-tiket, serta bukti booking tamu dengan sekali pindai.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      _showActionSnackbar('Membuka Kamera Pemindai QR E-Tiket...');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C2FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Buka Scanner Kamera',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Header Ringkasan Operasional
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Ringkasan Operasional',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'HARI INI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0284C7),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2x2 Grid Ringkasan Operasional
          Row(
            children: [
              // Card 1: Okupansi Kamar
              Expanded(
                child: _buildSummaryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Okupansi Kamar',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                          Icon(Icons.bed_outlined, size: 16, color: Color(0xFF0284C7)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Circular 82%
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00C2FF), width: 3),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '82%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '41 /50',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Kamar terisi',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.82,
                          backgroundColor: Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Card 2: Check-In
              Expanded(
                child: _buildSummaryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Check-In',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                          Icon(Icons.login_rounded, size: 16, color: Color(0xFF0284C7)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: const [
                          Text(
                            '8',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Tamu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '3 Menunggu • 5 Selesai',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00C2FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            '3 tamu tiba siang',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Card 3: Check-Out
              Expanded(
                child: _buildSummaryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Check-Out',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                          Icon(Icons.logout_rounded, size: 16, color: Color(0xFF0284C7)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: const [
                          Text(
                            '5',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Kamar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '2 Perlu Bersih • 3 Beres',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            '2 menunggu turn',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Card 4: Verifikasi
              Expanded(
                child: _buildSummaryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Verifikasi',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                          Icon(Icons.assignment_late_outlined, size: 16, color: Color(0xFFDC2626)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: const [
                          Text(
                            '3',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Pending',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Pengajuan baru tiket',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDC2626),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Perlu disetujui',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Aksi Cepat Petugas
          const Text(
            'Aksi Cepat Petugas',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          // 2x2 Grid Aksi Cepat
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.qr_code_2_rounded,
                  iconBg: const Color(0xFFBAF0FD),
                  iconColor: const Color(0xFF00758F),
                  title: 'Scan QR Tike',
                  subtitle: 'Validasi Tamu',
                  onTap: () => setState(() => _currentTabIndex = 2), // ke check-in
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.hotel_rounded,
                  iconBg: const Color(0xFFBAF0FD),
                  iconColor: const Color(0xFF00758F),
                  title: 'Cek Status Kam',
                  subtitle: 'Grid Kamar 1–50',
                  onTap: () => _showActionSnackbar('Membuka Grid Status Kamar 1-50...'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.badge_outlined,
                  iconBg: const Color(0xFFEDE9FE),
                  iconColor: const Color(0xFF6D28D9),
                  title: 'Daftar Tamu',
                  subtitle: 'Tamu Menginap',
                  onTap: () => setState(() => _currentTabIndex = 1), // ke booking
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.support_agent_rounded,
                  iconBg: const Color(0xFFCCFBEF),
                  iconColor: const Color(0xFF0D9488),
                  title: 'Housekeeping',
                  subtitle: 'Hubungi Tim Ops',
                  onTap: () => setState(() => _currentTabIndex = 3), // ke checkout/cleaning
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Tautan Syarat & Ketentuan (Terms & Policies)
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TermsAndPolicyScreen()),
                );
              },
              child: const Text(
                'Syarat & Ketentuan (Terms & Policies)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0284C7),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 2: BOOKING / VERIFIKASI RESERVASI (Foto 4)
  // ===========================================================================
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

  // ===========================================================================
  // TAB 3: CHECK IN (Foto 2)
  // ===========================================================================
  Widget _buildCheckInTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subheader: KONTER RESEPSIONIS
          Row(
            children: const [
              Icon(Icons.vpn_key_outlined, size: 15, color: Color(0xFF0284C7)),
              SizedBox(width: 6),
              Text(
                'KONTER RESEPSIONIS',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0284C7),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Proses Check-in Tamu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Validasi identitas, scan e-tiket, dan alokasikan kunci kamar secara instan.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // Search Field & Tombol Cari
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _checkInSearchController,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Cari ID Booking / No. Tiket',
                      hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showActionSnackbar('Mencari data booking ${_checkInSearchController.text}...'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00667C),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Row(
                    children: const [
                      Text('Cari', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pindai QR E-Tiket Langsung Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE4F8FE), Color(0xFFD3F5FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4EE3FE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded, size: 30, color: Color(0xFF006277)),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C2FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pindai QR E-Tiket Langsung',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Arahkan kamera ke layar ponsel tamu',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF00758F),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF00758F), size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Big Card: Kamar Terpilih - Deluxe Ocean View
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Kamar dengan Overlay Tag
                Stack(
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF334155), Color(0xFF0F172A)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        image: const DecorationImage(
                          image: AssetImage('assets/logo_hotel.png'),
                          fit: BoxFit.cover,
                          opacity: 0.15,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Badge E-Tiket Valid
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.verified_outlined, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'E-Tiket Valid & Terkonfirmasi Lunas',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Detail Kamar Title & No
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'KAMAR TERPILIH',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white70,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    Text(
                                      'Deluxe Ocean View',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'No. 101',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Lantai 1 • King Bed',
                                      style: TextStyle(fontSize: 10, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Guest Info Card
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDBEAFE),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text('AP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Bpk. Aditya Pratama', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                                Text('NIK: 3174xxxxxxxx • +62 812-3456-7890', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '#STP-\n882910-ID',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Check-in & Check-out row
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: const [
                                  Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF0284C7)),
                                  SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Check-In', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                                      Text('24 Okt 2025 (14:00)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 26, color: const Color(0xFFCBD5E1)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Row(
                                children: const [
                                  Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF0284C7)),
                                  SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Check-Out (2 Malam)', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
                                      Text('26 Okt 2025 (12:00)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Permintaan Khusus Tamu
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5FD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.room_service_outlined, size: 14, color: Color(0xFF0284C7)),
                                SizedBox(width: 6),
                                Text(
                                  'PERMINTAAN KHUSUS TAMU',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0284C7),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildSpecialRequestPill(icon: Icons.smoke_free_rounded, text: 'Bebas Rokok'),
                                _buildSpecialRequestPill(icon: Icons.apartment_rounded, text: 'Lantai Tinggi'),
                                _buildSpecialRequestPill(icon: Icons.wb_twilight_rounded, text: 'Sunset View'),
                              ],
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
          const SizedBox(height: 18),

          // Tombol Selesaikan Check-in & Serahkan Kunci
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _showActionSnackbar('Check-in Selesai! Kunci kamar No. 101 telah diserahkan.'),
              icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              label: const Text(
                'Selesaikan Check-in & Serahkan Kunci',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
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

  Widget _buildSpecialRequestPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF008DA5)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 4: CHECK OUT (Foto 3)
  // ===========================================================================
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

  // ===========================================================================
  // BOTTOM NAVIGATION BAR (Foto 1, 2, 3, 4)
  // ===========================================================================
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00758F),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number_rounded),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room_outlined),
            activeIcon: Icon(Icons.meeting_room_rounded),
            label: 'Check In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.door_sliding_outlined),
            activeIcon: Icon(Icons.door_sliding_rounded),
            label: 'Check Out',
          ),
        ],
      ),
    );
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
}
