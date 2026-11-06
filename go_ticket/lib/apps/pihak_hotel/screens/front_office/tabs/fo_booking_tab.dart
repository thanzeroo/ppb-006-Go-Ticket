import 'package:flutter/material.dart';

import '../../../../core/models/booking_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/booking_service.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Tab 2: Booking / Verifikasi Reservasi Front Office (100% Dinamis dari Database)
class FoBookingTab extends StatefulWidget {
  const FoBookingTab({super.key});

  @override
  State<FoBookingTab> createState() => _FoBookingTabState();
}

class _FoBookingTabState extends State<FoBookingTab> {
  int _bookingFilterIndex = 0; // 0: Semua, 1: Menunggu Verifikasi, 2: Disetujui
  final TextEditingController _searchBookingController = TextEditingController();
  String _searchQuery = '';
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final hotelId = AuthService.instance.currentUser?.managedHotelId ?? '1';
    try {
      final list = await BookingService.instance.getHotelBookings(hotelId);
      if (mounted) {
        setState(() {
          _bookings = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _bookings = [];
          _isLoading = false;
        });
      }
    }
  }

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

  Future<void> _verify(String id, String code) async {
    final ok = await BookingService.instance.verifyPayment(id);
    if (ok) {
      _showActionSnackbar('Booking $code Berhasil Disetujui! E-Tiket Terbit.');
      _loadBookings();
    }
  }

  Future<void> _reject(String id, String code) async {
    final ok = await BookingService.instance.cancelBooking(id);
    if (ok) {
      _showActionSnackbar('Booking $code telah dibatalkan/ditolak.');
      _loadBookings();
    }
  }

  List<BookingModel> get _filteredBookings {
    final q = _searchQuery.trim().toLowerCase();
    return _bookings.where((b) {
      if (_bookingFilterIndex == 1) {
        return b.status == BookingStatus.pendingVerification ||
            b.status == BookingStatus.pendingPayment;
      }
      if (_bookingFilterIndex == 2) {
        return b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.checkedIn;
      }
      return true;
    }).where((b) {
      if (q.isEmpty) return true;
      return b.bookingCode.toLowerCase().contains(q) ||
          b.customerName.toLowerCase().contains(q) ||
          (b.customerPhone?.toLowerCase().contains(q) ?? false) ||
          b.roomTypeName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _bookings
        .where((b) =>
            b.status == BookingStatus.pendingVerification ||
            b.status == BookingStatus.pendingPayment)
        .length;

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                  Icon(Icons.verified_user_rounded,
                      color: Color(0xFF0284C7), size: 18),
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

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterPill(
                      title: 'Semua Booking',
                      count: _bookings.length,
                      index: 0),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                      title: 'Menunggu Verifikasi',
                      badgeCount: pendingCount,
                      index: 1),
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
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 12.5),
                decoration: const InputDecoration(
                  hintText: 'Cari ID Booking / Nama Tamu / No HP',
                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 19, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 14),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredBookings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: Color(0xFF94A3B8)),
                      SizedBox(height: 12),
                      Text(
                        'Tidak ada antrean reservasi saat ini',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Reservasi baru dari tamu akan langsung muncul di sini',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (final b in _filteredBookings) ...[
                _buildDynamicBookingCard(b),
                const SizedBox(height: 14),
              ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String title,
    int? count,
    int? badgeCount,
    required int index,
  }) {
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
              count != null ? '$title ($count)' : title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
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

  Widget _buildDynamicBookingCard(BookingModel b) {
    final isPending = b.status == BookingStatus.pendingVerification ||
        b.status == BookingStatus.pendingPayment;
    final isConfirmed = b.status == BookingStatus.confirmed ||
        b.status == BookingStatus.checkedIn;
    final isCancelled = b.status == BookingStatus.cancelled ||
        b.status == BookingStatus.expired;

    Color badgeBg = const Color(0xFFFEF3C7);
    Color badgeFg = const Color(0xFFD97706);
    if (isConfirmed) {
      badgeBg = const Color(0xFFCCFBEF);
      badgeFg = const Color(0xFF0D9488);
    } else if (isCancelled) {
      badgeBg = const Color(0xFFFEE2E2);
      badgeFg = const Color(0xFFDC2626);
    }

    final priceStr = CurrencyFormatter.toRupiah(b.totalAmount);
    final dates =
        '${b.checkInDate.day}/${b.checkInDate.month} – ${b.checkOutDate.day}/${b.checkOutDate.month}/${b.checkOutDate.year}';

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
                  Text(
                    b.bookingCode,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00758F)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      b.status.displayName,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeFg),
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
                child: const Icon(Icons.account_balance_outlined,
                    size: 18, color: Color(0xFF0284C7)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Metode: ${b.paymentMethod ?? 'Online'} • $dates',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          // Guest info
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xFFBAF0FD),
                child: Text(
                  b.customerName.isNotEmpty
                      ? b.customerName.substring(0, 1).toUpperCase()
                      : 'T',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00758F)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.customerName,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${b.roomTypeName} (${b.totalNights} Malam • ${b.guestCount} Tamu)',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    priceStr,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A)),
                  ),
                  Text(
                    b.isPaid ? 'Lunas' : 'Menunggu',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: b.isPaid
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () => _reject(b.id, b.bookingCode),
                      icon: const Icon(Icons.cancel_outlined,
                          color: Color(0xFFDC2626), size: 15),
                      label: const Text('Tolak',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () => _verify(b.id, b.bookingCode),
                      icon: const Icon(Icons.verified_outlined,
                          color: Colors.white, size: 16),
                      label: const Text('Setujui & E-Tiket',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C2FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
