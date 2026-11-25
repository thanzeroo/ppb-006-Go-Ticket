import 'package:flutter/material.dart';

import 'package:go_ticket_hotel/core/widgets/app_pagination_bar.dart';
import '../../../../../core/models/booking_model.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/booking_service.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../services/hotel_operations_store.dart';

/// Tab 4: Check-Out Tamu Front Office
/// Menampilkan:
/// 1. Histori check-out lengkap:
///    - Tamu durasi check-in habis tanpa perpanjangan (Normal).
///    - Tamu yang check-out lebih cepat / awal.
///    - Tamu yang dikeluarkan paksa karena pelanggaran.
/// 2. Antrean Tamu yang durasinya habis hari ini untuk diproses check-out.
class FoCheckOutTab extends StatefulWidget {
  const FoCheckOutTab({super.key});

  @override
  State<FoCheckOutTab> createState() => _FoCheckOutTabState();
}

class _FoCheckOutTabState extends State<FoCheckOutTab> {
  // 0: Semua Histori, 1: Normal Selesai, 2: Check-out Lebih Awal, 3: Dikeluarkan Paksa
  int _filterIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<BookingModel> _activeGuests = [];
  List<BookingModel> _checkedOutDb = [];
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
    HotelOperationsStore.instance.addListener(_onStoreUpdated);
  }

  @override
  void dispose() {
    HotelOperationsStore.instance.removeListener(_onStoreUpdated);
    _searchController.dispose();
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final hotelId = AuthService.instance.currentUser?.managedHotelId ?? '1';
    try {
      final results = await Future.wait([
        BookingService.instance
            .getHotelBookings(hotelId, status: BookingStatus.checkedIn),
        BookingService.instance
            .getHotelBookings(hotelId, status: BookingStatus.checkedOut),
      ]);
      if (mounted) {
        setState(() {
          _activeGuests = results[0];
          _checkedOutDb = results[1];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _activeGuests = [];
          _checkedOutDb = [];
          _isLoading = false;
        });
      }
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

  /// Proses Check-Out Normal untuk tamu yang durasinya habis tanpa perpanjangan
  Future<void> _processNormalCheckout(BookingModel b) async {
    final store = HotelOperationsStore.instance;
    final currentStaff = AuthService.instance.currentUser?.fullName ?? 'Staf FO';
    final roomNum = b.roomTypeName.contains('10') ? '102' : '201';
    final floorNum = roomNum.startsWith('2') ? 2 : 1;

    try {
      await BookingService.instance.checkOutGuest(b.id);
    } catch (_) {}

    store.processCheckout(
      bookingId: b.id,
      bookingCode: b.bookingCode,
      guestName: b.customerName,
      guestPhone: b.customerPhone,
      roomNumber: roomNum,
      floorNumber: floorNum,
      roomTypeName: b.roomTypeName,
      checkInDate: b.checkInDate,
      scheduledCheckOutDate: b.checkOutDate,
      type: CheckoutType.normal,
      processedBy: currentStaff,
    );

    _showActionSnackbar(
      'Check-out tamu ${b.customerName} selesai. Kamar #$roomNum (Lt. $floorNum) masuk antrean pembersihan.',
    );
    _loadData();
  }

  List<CheckoutRecord> get _allRealHistory {
    final storeHistory = HotelOperationsStore.instance.checkoutHistory;
    final seenBookingIds = storeHistory.map((e) => e.bookingId).toSet();
    final combined = <CheckoutRecord>[...storeHistory];

    for (final b in _checkedOutDb) {
      if (!seenBookingIds.contains(b.id)) {
        combined.add(CheckoutRecord(
          id: 'db-${b.id}',
          bookingId: b.id,
          bookingCode: b.bookingCode,
          guestName: b.customerName,
          guestPhone: b.customerPhone,
          roomNumber: b.roomTypeName,
          floorNumber: 1,
          roomTypeName: b.roomTypeName,
          checkInDate: b.checkInDate,
          scheduledCheckOutDate: b.checkOutDate,
          actualCheckOutDate: b.checkOutDate,
          type: CheckoutType.normal,
          processedBy: 'Front Office',
        ));
      }
    }
    return combined;
  }

  List<CheckoutRecord> get _filteredHistory {
    final list = _allRealHistory;
    final q = _searchQuery.trim().toLowerCase();

    return list.where((rec) {
      if (_filterIndex == 1) return rec.type == CheckoutType.normal;
      if (_filterIndex == 2) return rec.type == CheckoutType.early;
      if (_filterIndex == 3) return rec.type == CheckoutType.forcedExpulsion;
      return true;
    }).where((rec) {
      if (q.isEmpty) return true;
      return rec.guestName.toLowerCase().contains(q) ||
          rec.bookingCode.toLowerCase().contains(q) ||
          rec.roomNumber.toLowerCase().contains(q) ||
          rec.roomTypeName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final store = HotelOperationsStore.instance;
    final allHistory = _allRealHistory;
    final normalCount = allHistory.where((r) => r.type == CheckoutType.normal).length;
    final earlyCount = allHistory.where((r) => r.type == CheckoutType.early).length;
    final forcedCount = allHistory.where((r) => r.type == CheckoutType.forcedExpulsion).length;

    // Tamu yang durasinya habis atau mendekati hari ini
    final dueTodayGuests = _activeGuests.where((b) {
      final ext = store.getExtendedNights(b.id);
      final finalOut = b.checkOutDate.add(Duration(days: ext));
      final now = DateTime.now();
      return finalOut.year == now.year &&
          finalOut.month == now.month &&
          finalOut.day <= now.day;
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Antrean Tamu yang Durasinya Habis Hari Ini (Belum Perpanjangan)
            if (dueTodayGuests.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_off_outlined, color: Color(0xFFB45309), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Masa Menginap Habis Hari Ini (${dueTodayGuests.length} Tamu)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tamu di bawah ini durasinya habis hari ini dan tidak mengajukan perpanjangan:',
                      style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                    ),
                    const SizedBox(height: 10),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB45309)),
                          ),
                        ),
                      )
                    else if (dueTodayGuests.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Tidak ada tamu yang habis masa menginap hari ini.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF78350F), fontStyle: FontStyle.italic),
                        ),
                      )
                    else
                      Column(
                        children: dueTodayGuests.map((g) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    g.customerName,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    '${g.bookingCode} • ${g.roomTypeName}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () => _processNormalCheckout(g),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF007A87),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: const Size(60, 30),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Check-Out', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Filter Tabs Histori
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildHistoryFilterPill(title: 'Semua Histori', count: allHistory.length, index: 0),
                  const SizedBox(width: 8),
                  _buildHistoryFilterPill(title: 'Normal Selesai', count: normalCount, index: 1),
                  const SizedBox(width: 8),
                  _buildHistoryFilterPill(title: 'Check-out Lebih Awal', count: earlyCount, index: 2),
                  const SizedBox(width: 8),
                  _buildHistoryFilterPill(title: 'Dikeluarkan Paksa', count: forcedCount, index: 3),
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
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 12.5),
                decoration: const InputDecoration(
                  hintText: 'Cari Nama Tamu / No Kamar / Kode Booking',
                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: Icon(Icons.search_rounded, size: 19, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daftar Kartu Histori Check-Out
            if (_filteredHistory.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  children: const [
                    Icon(Icons.history_toggle_off_rounded, size: 44, color: Color(0xFF94A3B8)),
                    SizedBox(height: 10),
                    Text(
                      'Tidak ada histori check-out untuk filter ini',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              )
            else ...[
              Builder(
                builder: (ctx) {
                  final total = _filteredHistory.length;
                  final maxPage = (total / 10).ceil();
                  final safePage = _currentPage.clamp(1, maxPage > 0 ? maxPage : 1);
                  final pagedHistory = paginateList(_filteredHistory, safePage, pageSize: 10);

                  return Column(
                    children: [
                      for (final rec in pagedHistory) ...[
                        _buildHistoryRecordCard(rec),
                        const SizedBox(height: 12),
                      ],
                      AppPaginationBar(
                        currentPage: safePage,
                        totalItems: total,
                        pageSize: 10,
                        itemLabel: 'histori check-out',
                        primaryColor: const Color(0xFF007A87),
                        onPageChanged: (newPage) => setState(() => _currentPage = newPage),
                      ),
                    ],
                  );
                },
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryFilterPill({required String title, required int count, required int index}) {
    final isSelected = _filterIndex == index;
    return InkWell(
      onTap: () => setState(() => _filterIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007A87) : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$title ($count)',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryRecordCard(CheckoutRecord rec) {
    final Color badgeBg;
    final Color badgeFg;
    final IconData badgeIcon;

    switch (rec.type) {
      case CheckoutType.normal:
        badgeBg = const Color(0xFFDCFCE7);
        badgeFg = const Color(0xFF15803D);
        badgeIcon = Icons.check_circle_outline;
        break;
      case CheckoutType.early:
        badgeBg = const Color(0xFFE0F2FE);
        badgeFg = const Color(0xFF0369A1);
        badgeIcon = Icons.fast_forward_rounded;
        break;
      case CheckoutType.forcedExpulsion:
        badgeBg = const Color(0xFFFEE2E2);
        badgeFg = const Color(0xFFDC2626);
        badgeIcon = Icons.gavel_rounded;
        break;
    }

    final out = rec.actualCheckOutDate;
    final timeStr =
        '${out.day}/${out.month}/${out.year} • ${out.hour.toString().padLeft(2, '0')}:${out.minute.toString().padLeft(2, '0')} WIB';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rec.type == CheckoutType.forcedExpulsion
              ? const Color(0xFFFECACA)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.meeting_room_rounded, size: 16, color: Color(0xFF0284C7)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kamar #${rec.roomNumber} (Lt. ${rec.floorNumber})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 12, color: badgeFg),
                      const SizedBox(width: 4),
                      Text(
                        rec.typeLabel,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeFg),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rec.guestName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                Text(
                  rec.bookingCode,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Text(
              rec.roomTypeName,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  'Waktu Keluar: $timeStr',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),

            if (rec.noteOrReason != null && rec.noteOrReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Catatan: ${rec.noteOrReason!}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF334155), fontStyle: FontStyle.italic),
                ),
              ),
            ],

            if (rec.penaltyAmount != null && rec.penaltyAmount! > 0) ...[
              const SizedBox(height: 6),
              Text(
                'Denda / Biaya Pelanggaran: ${CurrencyFormatter.toRupiah(rec.penaltyAmount!)}',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
              ),
            ],

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Petugas: ${rec.processedBy}',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                ),
                Row(
                  children: const [
                    Icon(Icons.cleaning_services, size: 12, color: Color(0xFF0284C7)),
                    SizedBox(width: 4),
                    Text(
                      'Diteruskan ke Housekeeping',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
