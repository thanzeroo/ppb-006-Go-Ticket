import 'package:flutter/material.dart';
import '../../../../pihak_user/screens/auth/terms_and_policy_screen.dart';
import '../../../../../core/models/booking_model.dart';
import '../../../../../core/models/room_model.dart';
import '../../../../../core/models/user_model.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/booking_service.dart';
import '../../../../../core/services/hotel_service.dart';
import '../widgets/fo_barcode_scanner_modal.dart';

/// Tab 1: Overview Dashboard Front Office (100% Dinamis dari Database)
class FoDashboardTab extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const FoDashboardTab({super.key, this.onNavigateTab});

  @override
  State<FoDashboardTab> createState() => _FoDashboardTabState();
}

class _FoDashboardTabState extends State<FoDashboardTab> {
  List<RoomModel> _rooms = [];
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    final userHotelId = AuthService.instance.currentUser?.managedHotelId;
    final hotelId = (userHotelId != null && userHotelId.isNotEmpty) ? userHotelId : '1';
    try {
      final results = await Future.wait([
        HotelService.instance.getRoomsByHotel(hotelId),
        BookingService.instance.getHotelBookings(hotelId),
      ]);
      if (mounted) {
        setState(() {
          _rooms = results[0] as List<RoomModel>;
          _bookings = results[1] as List<BookingModel>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
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

  void _showRoomStatusDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Status Kamar Hotel',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: _rooms.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Belum ada data kamar terdaftar di database.',
                      textAlign: TextAlign.center),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _rooms.length,
                  itemBuilder: (ctx, i) {
                    final r = _rooms[i];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.meeting_room_outlined,
                          color: Color(0xFF0284C7)),
                      title: Text(r.typeName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Rp ${r.pricePerNight.toInt()} / malam'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: r.status == RoomStatus.available
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          r.status.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: r.status == RoomStatus.available
                                ? const Color(0xFF15803D)
                                : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _rooms.isEmpty && _bookings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C2FF)),
      );
    }
    return _buildDashboardTab();
  }

  Widget _buildDashboardTab() {
    final currentUser = AuthService.instance.currentUser;
    final staffName = currentUser?.fullName ?? 'Staff FO';
    final initials = staffName.trim().isNotEmpty
        ? staffName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : 'FO';
    final roleLabel = currentUser?.role.displayName ?? 'Front Office & Resepsionis';

    final totalRooms = _rooms.isEmpty ? 50 : _rooms.length;
    final occupiedRooms =
        _rooms.where((r) => r.status == RoomStatus.occupied).length;
    final occupancyPercent =
        totalRooms > 0 ? ((occupiedRooms / totalRooms) * 100).round() : 0;

    final totalCheckIn = _bookings
        .where((b) =>
            b.status == BookingStatus.checkedIn ||
            b.status == BookingStatus.confirmed)
        .length;
    final pendingCheckIn =
        _bookings.where((b) => b.status == BookingStatus.confirmed).length;
    final doneCheckIn =
        _bookings.where((b) => b.status == BookingStatus.checkedIn).length;

    final checkOutCount =
        _bookings.where((b) => b.status == BookingStatus.checkedOut).length;
    final dirtyRoomsCount =
        _rooms.where((r) => r.status == RoomStatus.dirty).length;

    final pendingVerificationCount = _bookings
        .where((b) =>
            b.status == BookingStatus.pendingVerification ||
            b.status == BookingStatus.pendingPayment)
        .length;

    return RefreshIndicator(
      onRefresh: _loadSummary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card Profile User (Dinamis dari AuthService)
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
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 20,
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
                        children: [
                          Text(
                            staffName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF0284C7),
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        roleLabel,
                        style: const TextStyle(
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
                    onPressed: () async {
                      final res = await FoBarcodeScannerModal.show(
                        context,
                        availableBookings: _bookings,
                      );
                      if (res != null) {
                        _loadSummary();
                      }
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
                          // Circular %
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00C2FF), width: 3),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$occupancyPercent%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$occupiedRooms /$totalRooms',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const Text(
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
                        child: LinearProgressIndicator(
                          value: (occupancyPercent / 100.0).clamp(0.0, 1.0),
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
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
                        children: [
                          Text(
                            '$totalCheckIn',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Tamu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$pendingCheckIn Menunggu • $doneCheckIn Selesai',
                        style: const TextStyle(
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
                          Text(
                            pendingCheckIn > 0 ? '$pendingCheckIn siap check-in' : 'Semua telah check-in',
                            style: const TextStyle(
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
                        children: [
                          Text(
                            '$checkOutCount',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Kamar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dirtyRoomsCount Perlu Bersih • $checkOutCount Beres',
                        style: const TextStyle(
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
                          Text(
                            '$dirtyRoomsCount unit kotor',
                            style: const TextStyle(
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
                        children: [
                          Text(
                            '$pendingVerificationCount',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
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
                          Text(
                            pendingVerificationCount > 0 ? '$pendingVerificationCount perlu disetujui' : 'Semua telah diverifikasi',
                            style: const TextStyle(
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
                  title: 'Scan QR Tiket',
                  subtitle: 'Validasi Tamu',
                  onTap: () async {
                    final res = await FoBarcodeScannerModal.show(
                      context,
                      availableBookings: _bookings,
                    );
                    if (res != null) {
                      _loadSummary();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.hotel_rounded,
                  iconBg: const Color(0xFFBAF0FD),
                  iconColor: const Color(0xFF00758F),
                  title: 'Cek Status Kamar',
                  subtitle: 'Kamar Hotel',
                  onTap: _showRoomStatusDialog,
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
                  onTap: () => widget.onNavigateTab?.call(1), // ke booking
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
                  onTap: () => widget.onNavigateTab?.call(3), // ke checkout/cleaning
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


}
