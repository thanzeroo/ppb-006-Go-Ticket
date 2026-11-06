import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_ticket/core/models/booking_model.dart';
import 'package:go_ticket/core/services/auth_service.dart';
import 'package:go_ticket/core/services/booking_service.dart';
import 'package:go_ticket/core/utils/currency_formatter.dart';
import 'package:go_ticket/core/widgets/user_avatar.dart';
import '../../../router/customer_router.dart';
import '../customer_dashboard_screen.dart';
import 'saved_hotel_screen.dart';

/// Tab Pesanan: Riwayat Tiket & Pesanan (Murni dari Database Supabase)
class PesananTab extends StatefulWidget {
  const PesananTab({super.key});

  /// 0 = Pemesanan, 1 = Saved Hotel
  static final ValueNotifier<int> subTabNotifier = ValueNotifier<int>(0);

  @override
  State<PesananTab> createState() => _PesananTabState();
}

class _PesananTabState extends State<PesananTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final PageController _subPageController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    _subPageController =
        PageController(initialPage: PesananTab.subTabNotifier.value);
    PesananTab.subTabNotifier.addListener(_onSubTabChanged);
  }

  void _onSubTabChanged() {
    if (!mounted) return;
    final target = PesananTab.subTabNotifier.value;
    if (_subPageController.hasClients &&
        _subPageController.page?.round() != target) {
      _subPageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    PesananTab.subTabNotifier.removeListener(_onSubTabChanged);
    _subPageController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  bool _matchesBookingQuery(Iterable<String> fields) {
    final query = _searchQuery.trim().toLowerCase();
    return query.isEmpty ||
        fields.any((field) => field.toLowerCase().contains(query));
  }

  static String _monthShort(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return (m >= 1 && m <= 12) ? months[m - 1] : '';
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _subPageController,
      onPageChanged: (page) {
        if (PesananTab.subTabNotifier.value != page) {
          PesananTab.subTabNotifier.value = page;
        }
      },
      children: [
        _buildPemesananView(),
        SavedHotelScreen(
          onSwitchToPemesanan: () {
            _subPageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN PEMESANAN VIEW
  // ---------------------------------------------------------------------------
  Widget _buildPemesananView() {
    return FutureBuilder<List<BookingModel>>(
      future: BookingService.instance.getMyBookings(),
      builder: (context, snapshot) {
        final allBookings = snapshot.data ?? [];
        final countActive = allBookings
            .where((b) =>
                b.status == BookingStatus.confirmed ||
                b.status == BookingStatus.checkedIn ||
                b.status == BookingStatus.pendingPayment)
            .length;
        final countCompleted = allBookings
            .where((b) => b.status == BookingStatus.checkedOut)
            .length;
        final countCancelled = allBookings
            .where((b) =>
                b.status == BookingStatus.cancelled ||
                b.status == BookingStatus.expired)
            .length;
        final countAll = allBookings.length;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Column(
            children: [
              _buildHeader(),
              _buildTabBar(
                countAll: countAll,
                countActive: countActive,
                countCompleted: countCompleted,
                countCancelled: countCancelled,
              ),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrderList(allBookings, filterStatus: null),
                          _buildOrderList(allBookings, filterStatus: 'active'),
                          _buildOrderList(allBookings, filterStatus: 'selesai'),
                          _buildOrderList(allBookings, filterStatus: 'dibatalkan'),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 28,
                        errorBuilder: (_, __, ___) => Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B4D8),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'GO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'GoTicket',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF111827),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pemesanan',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF111827),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.notifications_none_outlined,
                          color: Color(0xFF111827), size: 22),
                      const SizedBox(width: 12),
                      UserAvatar(
                        name: AuthService.instance.currentUser?.fullName,
                        radius: 17,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Pesanan / Saved Hotel tabs
              Row(
                children: [
                  _buildTopTab('Pemesanan', 0),
                  const SizedBox(width: 8),
                  _buildTopTab('Saved Hotel', 1),
                ],
              ),
              const SizedBox(height: 12),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search,
                        color: Color(0xFF9CA3AF), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText:
                              'Cari nama hotel, kota, atau ID booking...',
                          hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF9CA3AF), fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          suffixIcon: _searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Hapus pencarian',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  icon: const Icon(Icons.close, size: 18),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Label Pesanan Saya
              Row(
                children: [
                  const Icon(Icons.receipt_long,
                      color: Color(0xFF00B4D8), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Pesanan Saya',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopTab(String label, int index) {
    final isSelected = PesananTab.subTabNotifier.value == index;
    return GestureDetector(
      onTap: () {
        if (PesananTab.subTabNotifier.value == index) return;
        PesananTab.subTabNotifier.value = index;
        if (index == 0) return;
        _subPageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFF00B4D8) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF00B4D8) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB BAR DENGAN JUMLAH RIIL DARI DATABASE
  // ---------------------------------------------------------------------------
  Widget _buildTabBar({
    required int countAll,
    required int countActive,
    required int countCompleted,
    required int countCancelled,
  }) {
    final tabs = [
      'Semua ($countAll)',
      'Aktif ($countActive)',
      'Selesai ($countCompleted)',
      'Dibatalkan ($countCancelled)',
    ];

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            labelColor: const Color(0xFF00B4D8),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF00B4D8),
            labelStyle:
                GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LIST PESANAN RIIL DARI DATABASE
  // ---------------------------------------------------------------------------
  Widget _buildOrderList(
    List<BookingModel> allBookings, {
    String? filterStatus,
  }) {
    final filtered = allBookings.where((b) {
      if (filterStatus == 'active') {
        return b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.checkedIn ||
            b.status == BookingStatus.pendingPayment;
      }
      if (filterStatus == 'selesai') {
        return b.status == BookingStatus.checkedOut;
      }
      if (filterStatus == 'dibatalkan') {
        return b.status == BookingStatus.cancelled ||
            b.status == BookingStatus.expired;
      }
      return true;
    }).where((b) {
      return _matchesBookingQuery([
        b.bookingCode,
        b.hotelName,
        b.hotelAddress ?? '',
        b.roomTypeName,
        b.status.displayName,
      ]);
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyOrdersState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: filtered.length + 1, // +1 untuk bantuan card
      itemBuilder: (context, index) {
        if (index == filtered.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            child: _buildBantuanCard(),
          );
        }
        final b = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildBookingCard(b),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // CARD PESANAN 100% DINAMIS DARI MODEL
  // ---------------------------------------------------------------------------
  Widget _buildBookingCard(BookingModel b) {
    final isCancelled = b.status == BookingStatus.cancelled ||
        b.status == BookingStatus.expired;
    final isCompleted = b.status == BookingStatus.checkedOut;
    final dates =
        '${b.checkInDate.day} ${_monthShort(b.checkInDate.month)} – ${b.checkOutDate.day} ${_monthShort(b.checkOutDate.month)} ${b.checkOutDate.year}';
    final priceStr = CurrencyFormatter.toRupiah(b.totalAmount);
    final paymentMethodStr = b.paymentMethod ?? 'QRIS';

    Color headerBg = const Color(0xFFE0F7FA);
    Color statusColor = const Color(0xFF0096C7);
    Color dotColor = const Color(0xFF00B4D8);

    if (isCompleted) {
      headerBg = const Color(0xFFF3F4F6);
      statusColor = const Color(0xFF6B7280);
      dotColor = const Color(0xFF9CA3AF);
    } else if (isCancelled) {
      headerBg = const Color(0xFFFEE2E2);
      statusColor = const Color(0xFFEF4444);
      dotColor = const Color(0xFFEF4444);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCancelled
              ? const Color(0xFFEF4444).withOpacity(0.3)
              : const Color(0xFF00B4D8).withOpacity(0.4),
        ),
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
          // Header Status & ID
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      b.status.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: b.bookingCode));
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ID ${b.bookingCode} berhasil disalin!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'ID: ${b.bookingCode}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: const Color(0xFF6B7280)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy_outlined,
                          size: 14, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        b.hotelImageUrl ?? '',
                        width: 80,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 70,
                          color: const Color(0xFFE5E7EB),
                          child: const Icon(Icons.hotel, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.hotelAddress ?? 'Indonesia',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            b.hotelName,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${b.roomTypeName} (${b.totalRooms} Kamar • ${b.nights} Malam)',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF6B7280)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 12, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 4),
                              Text(
                                dates,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFE5E7EB)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF6B7280)),
                    ),
                    Row(
                      children: [
                        Text(
                          priceStr,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isCancelled
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isCancelled
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFF86EFAC),
                            ),
                          ),
                          child: Text(
                            isCancelled
                                ? 'Dibatalkan'
                                : '✓ Lunas ($paymentMethodStr)',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isCancelled
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF16A34A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Action Buttons
                if (!isCancelled && !isCompleted) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        CustomerRouter.eTicket,
                        arguments: b,
                      ),
                      icon: const Icon(Icons.qr_code, size: 16),
                      label: Text(
                        'Lihat E-Tiket & QR',
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
                ] else if (isCompleted) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            CustomerRouter.postCheckoutReview,
                            arguments: b,
                          ),
                          icon: const Icon(Icons.star_border,
                              color: Color(0xFFF59E0B), size: 14),
                          label: Text(
                            'Beri Ulasan',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: const Color(0xFFF59E0B)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFF59E0B)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              CustomerDashboardScreen.tabNotifier.value = 1,
                          icon: const Icon(Icons.refresh,
                              color: Color(0xFF00B4D8), size: 14),
                          label: Text(
                            'Pesan Lagi',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: const Color(0xFF00B4D8)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00B4D8)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Pesanan telah dibatalkan.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE (Ketika Belum Ada Data di Database)
  // ---------------------------------------------------------------------------
  Widget _buildEmptyOrdersState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFC8F0FA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF0077B6),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Pesanan',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Anda belum memiliki pesanan hotel aktif maupun riwayat pemesanan. Mulai jelajahi dan booking hotel impian Anda sekarang!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => CustomerDashboardScreen.tabNotifier.value = 1,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4D8),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 0,
              ),
              child: Text(
                'Cari Penginapan Sekarang',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BANTUAN CARD
  // ---------------------------------------------------------------------------
  Widget _buildBantuanCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B4D8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.headset_mic,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Butuh Bantuan Reservasi?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0096C7),
                        ),
                      ),
                      Text(
                        'Mengalami kendala check-in di hotel atau perubahan jadwal darurat? Concierge kami siap 24/7.',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: const Color(0xFF374151)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Membuka WhatsApp resmi Go Ticket…'))),
                    icon: const Icon(Icons.chat, size: 14),
                    label: Text(
                      'WhatsApp 24 Jam',
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Pusat Bantuan segera hadir'))),
                    icon: const Icon(Icons.support,
                        color: Color(0xFF00B4D8), size: 14),
                    label: Text(
                      'Pusat Bantuan',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF00B4D8),
                          fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00B4D8)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
