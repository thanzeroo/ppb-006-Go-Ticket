import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_ticket_user/core/models/booking_model.dart';
import 'package:go_ticket_user/core/services/auth_service.dart';
import 'package:go_ticket_user/core/services/booking_service.dart';
import 'package:go_ticket_user/core/widgets/user_avatar.dart';
import 'package:go_ticket_user/core/services/hotel_operations_store.dart';
import 'package:go_ticket_user/core/widgets/app_pagination_bar.dart';
import '../../../router/customer_router.dart';
import '../../../services/user_booking_storage.dart';
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
  final Map<String, int> _tabPages = {
    'all': 1,
    'pending': 1,
    'confirmed': 1,
    'selesai': 1,
    'dibatalkan': 1,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    _subPageController =
        PageController(initialPage: PesananTab.subTabNotifier.value);
    PesananTab.subTabNotifier.addListener(_onSubTabChanged);

    try {
      HotelOperationsStore.instance.addListener(_onOperationsUpdated);
    } catch (_) {}
  }

  void _onOperationsUpdated() {
    if (mounted) setState(() {});
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
    try {
      HotelOperationsStore.instance.removeListener(_onOperationsUpdated);
    } catch (_) {}
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

  Future<List<BookingModel>> _fetchBookings() async {
    final remoteList = await BookingService.instance.getMyBookings();
    final localList = await UserBookingStorage.instance.getBookings();

    final Map<String, BookingModel> map = {};
    for (final b in remoteList) {
      final key = b.bookingCode.isNotEmpty ? b.bookingCode : b.id;
      map[key] = b;
    }
    for (final b in localList) {
      final key = b.bookingCode.isNotEmpty ? b.bookingCode : b.id;
      if (map.containsKey(key)) {
        final remote = map[key]!;
        if (remote.status == BookingStatus.checkedIn ||
            remote.status == BookingStatus.checkedOut) {
          map[key] = remote.copyWith(
            roomNumber: b.roomNumber ?? remote.roomNumber,
          );
        } else if (b.status == BookingStatus.cancelled) {
          map[key] = remote.copyWith(
            status: BookingStatus.cancelled,
            roomNumber: b.roomNumber ?? remote.roomNumber,
          );
        } else if (b.status == BookingStatus.pendingVerification) {
          // Status baru payment tetap "Menunggu Konfirmasi" sampai staf hotel scan e-tiket
          bool isVerifiedByStaff = false;
          try {
            isVerifiedByStaff =
                HotelOperationsStore.instance.isETicketVerified(remote.id) ||
                HotelOperationsStore.instance.isETicketVerified(b.id) ||
                HotelOperationsStore.instance.isETicketVerified(remote.bookingCode) ||
                HotelOperationsStore.instance.isETicketVerified(b.bookingCode);
          } catch (_) {}

          if (isVerifiedByStaff) {
            map[key] = remote.copyWith(
              status: BookingStatus.confirmed,
              roomNumber: b.roomNumber ?? remote.roomNumber,
            );
          } else {
            map[key] = remote.copyWith(
              status: BookingStatus.pendingVerification,
              roomNumber: b.roomNumber ?? remote.roomNumber,
            );
          }
        } else {
          map[key] = remote.copyWith(
            status: b.status,
            roomNumber: b.roomNumber ?? remote.roomNumber,
          );
        }
      } else {
        bool isVerifiedByStaff = false;
        try {
          isVerifiedByStaff =
              HotelOperationsStore.instance.isETicketVerified(b.id) ||
              HotelOperationsStore.instance.isETicketVerified(b.bookingCode);
        } catch (_) {}
        if (isVerifiedByStaff && b.status == BookingStatus.pendingVerification) {
          map[key] = b.copyWith(status: BookingStatus.confirmed);
        } else {
          map[key] = b;
        }
      }
    }

    final merged = map.values.toList();
    merged.sort((a, b) {
      final tA = a.paidAt ?? a.createdAt ?? a.checkInDate;
      final tB = b.paidAt ?? b.createdAt ?? b.checkInDate;
      return tB.compareTo(tA);
    });
    return merged;
  }

  // ---------------------------------------------------------------------------
  // MAIN PEMESANAN VIEW
  // ---------------------------------------------------------------------------
  Widget _buildPemesananView() {
    return FutureBuilder<List<BookingModel>>(
      future: _fetchBookings(),
      builder: (context, snapshot) {
        final allBookings = snapshot.data ?? [];
        final countPending = allBookings
            .where((b) =>
                b.status == BookingStatus.pendingVerification ||
                b.status == BookingStatus.pendingPayment)
            .length;
        final countConfirmed = allBookings
            .where((b) =>
                b.status == BookingStatus.confirmed ||
                b.status == BookingStatus.checkedIn)
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
                countPending: countPending,
                countConfirmed: countConfirmed,
                countCompleted: countCompleted,
                countCancelled: countCancelled,
              ),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        color: const Color(0xFF00B4D8),
                        onRefresh: () async {
                          setState(() {});
                        },
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOrderList(allBookings, filterStatus: 'all'),
                            _buildOrderList(allBookings, filterStatus: 'pending'),
                            _buildOrderList(allBookings, filterStatus: 'confirmed'),
                            _buildOrderList(allBookings, filterStatus: 'selesai'),
                            _buildOrderList(allBookings, filterStatus: 'dibatalkan'),
                          ],
                        ),
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
                      UserAvatar(
                        imageUrl: AuthService.instance.currentUser?.avatarUrl,
                        name: AuthService.instance.currentUser?.fullName,
                        radius: 17,
                        onTap: () =>
                            CustomerDashboardScreen.tabNotifier.value = 3,
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
    required int countPending,
    required int countConfirmed,
    required int countCompleted,
    required int countCancelled,
  }) {
    final tabs = [
      'Semua ($countAll)',
      'Menunggu Konfirmasi ($countPending)',
      'Dikonfirmasi ($countConfirmed)',
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
    required String filterStatus,
  }) {
    final filtered = allBookings.where((b) {
      if (filterStatus == 'pending') {
        return b.status == BookingStatus.pendingVerification ||
            b.status == BookingStatus.pendingPayment;
      }
      if (filterStatus == 'confirmed') {
        return b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.checkedIn;
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
        b.roomNumber ?? '',
        b.status.displayName,
      ]);
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyOrdersState();
    }

    final total = filtered.length;
    final curPage = _tabPages[filterStatus] ?? 1;
    final maxPage = (total / 5).ceil();
    final safePage = curPage.clamp(1, maxPage > 0 ? maxPage : 1);
    final pagedBookings = paginateList(filtered, safePage, pageSize: 5);

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: pagedBookings.length + (total > 0 ? 1 : 0) + 1, // items + pagination bar + bantuan card
      itemBuilder: (context, index) {
        if (index < pagedBookings.length) {
          final b = pagedBookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildBookingCard(b),
          );
        } else if (index == pagedBookings.length) {
          return AppPaginationBar(
            currentPage: safePage,
            totalItems: total,
            pageSize: 5,
            itemLabel: 'pesanan',
            primaryColor: const Color(0xFF00B4D8),
            onPageChanged: (newPage) {
              setState(() {
                _tabPages[filterStatus] = newPage;
              });
            },
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            child: _buildBantuanCard(),
          );
        }
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
    final isConfirmed = b.status == BookingStatus.confirmed ||
        b.status == BookingStatus.checkedIn;
    final isPending = b.status == BookingStatus.pendingVerification ||
        b.status == BookingStatus.pendingPayment;

    final dates =
        '${b.checkInDate.day} ${_monthShort(b.checkInDate.month)} – ${b.checkOutDate.day} ${_monthShort(b.checkOutDate.month)} ${b.checkOutDate.year}';

    String statusText = 'Menunggu Konfirmasi';
    Color headerBg = const Color(0xFFFFFBEB);
    Color statusColor = const Color(0xFFD97706);
    Color dotColor = const Color(0xFFD97706);

    if (isCompleted) {
      statusText = 'Selesai';
      headerBg = const Color(0xFFDCFCE7);
      statusColor = const Color(0xFF16A34A);
      dotColor = const Color(0xFF16A34A);
    } else if (isConfirmed) {
      statusText = 'Dikonfirmasi';
      headerBg = const Color(0xFFDBEAFE);
      statusColor = const Color(0xFF2563EB);
      dotColor = const Color(0xFF2563EB);
    } else if (isCancelled) {
      statusText = 'Dibatalkan (Reject)';
      headerBg = const Color(0xFFFEE2E2);
      statusColor = const Color(0xFFEF4444);
      dotColor = const Color(0xFFEF4444);
    }

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          CustomerRouter.reservationDetail,
          arguments: b,
        ).then((_) => setState(() {}));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCancelled
                ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                : const Color(0xFF00B4D8).withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                        statusText,
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
                              '${b.roomTypeName} • Kamar ${b.roomNumber ?? '003'} (${b.totalRooms} Kamar • ${b.nights} Malam)',
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
                  const SizedBox(height: 12),
                  // Action Buttons
                  if (isPending) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              CustomerRouter.reservationDetail,
                              arguments: b,
                            ).then((_) => setState(() {})),
                            icon: const Icon(Icons.receipt_long,
                                size: 15, color: Color(0xFF00B4D8)),
                            label: Text(
                              'Detail Reservasi',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF00B4D8)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF00B4D8)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              CustomerRouter.eTicket,
                              arguments: b,
                            ),
                            icon: const Icon(Icons.qr_code, size: 15),
                            label: Text(
                              'Lihat E-Tiket',
                              style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B4D8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (isConfirmed) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              CustomerRouter.reservationDetail,
                              arguments: b,
                            ).then((_) => setState(() {})),
                            icon: const Icon(Icons.receipt_long,
                                size: 15, color: Color(0xFF00B4D8)),
                            label: Text(
                              'Detail Reservasi',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF00B4D8)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF00B4D8)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              CustomerRouter.eTicket,
                              arguments: b,
                            ),
                            icon: const Icon(Icons.qr_code, size: 15),
                            label: Text(
                              'Lihat E-Tiket & QR',
                              style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B4D8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final res = await Navigator.pushNamed(
                            context,
                            CustomerRouter.rejectReason,
                            arguments: b,
                          );
                          if (res == true && mounted) {
                            setState(() {
                              _tabController.animateTo(4);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pesanan berhasil di-reject / dibatalkan.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.cancel_outlined,
                            size: 15, color: Color(0xFFEF4444)),
                        label: Text(
                          'Reject Pesanan',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          backgroundColor: const Color(0xFFFEF2F2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ] else if (isCompleted) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              CustomerRouter.postCheckoutReview,
                              arguments: b,
                            ).then((_) => setState(() {})),
                            icon: const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 16),
                            label: Text(
                              'Beri Ulasan',
                              style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              CustomerRouter.reservationDetail,
                              arguments: b,
                            ),
                            icon: const Icon(Icons.receipt_long,
                                size: 15, color: Color(0xFF00B4D8)),
                            label: Text(
                              'Detail Reservasi',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF00B4D8),
                                  fontWeight: FontWeight.w700),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF00B4D8)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              CustomerRouter.reservationDetail,
                              arguments: b,
                            ),
                            icon: const Icon(Icons.receipt_long,
                                size: 15, color: Colors.red),
                            label: Text(
                              'Lihat Detail Pembatalan',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
