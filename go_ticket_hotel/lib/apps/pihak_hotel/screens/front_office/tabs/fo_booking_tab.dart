import 'package:flutter/material.dart';

import 'package:go_ticket_hotel/core/widgets/app_pagination_bar.dart';
import '../../../../../core/models/booking_model.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/booking_service.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../services/hotel_operations_store.dart';
import '../widgets/fo_barcode_scanner_modal.dart';

/// Tab 2: Booking / Verifikasi Reservasi Front Office
/// Menampilkan:
/// 1. Antrean booking tamu yang SUDAH BAYAR tapi E-Tiket belum di-scan/diverifikasi.
/// 2. Menu Disetujui: tamu yang E-Tiket-nya sudah di-scan/diverifikasi (siap/telah check-in).
class FoBookingTab extends StatefulWidget {
  const FoBookingTab({super.key});

  @override
  State<FoBookingTab> createState() => _FoBookingTabState();
}

class _FoBookingTabState extends State<FoBookingTab> {
  // 0: Menunggu Scan E-Tiket (Sudah Bayar), 1: Disetujui (Tiket Terverifikasi), 2: Semua Reservasi
  int _bookingFilterIndex = 0;
  final TextEditingController _searchBookingController = TextEditingController();
  String _searchQuery = '';
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadBookings();
    HotelOperationsStore.instance.addListener(_onStoreUpdated);
  }

  @override
  void dispose() {
    HotelOperationsStore.instance.removeListener(_onStoreUpdated);
    _searchBookingController.dispose();
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
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

  void _showActionSnackbar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFF00758F) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Buka modal scanner kamera untuk reservasi ini
  Future<void> _openCameraScanner([BookingModel? targetBooking]) async {
    final result = await FoBarcodeScannerModal.show(
      context,
      availableBookings: targetBooking != null ? [targetBooking] : _bookings,
    );
    if (result != null) {
      _loadBookings();
    }
  }

  /// Verifikasi manual jika kamera tidak tersedia
  Future<void> _verifyManual(BookingModel b) async {
    try {
      final ok = await BookingService.instance.verifyPayment(b.id);
      if (ok) {
        HotelOperationsStore.instance.verifyETicket(b.id);
        _showActionSnackbar('E-Tiket booking ${b.bookingCode} berhasil diverifikasi & disetujui!');
        _loadBookings();
      }
    } catch (e) {
      _showActionSnackbar('Gagal verifikasi: $e', isSuccess: false);
    }
  }

  List<BookingModel> get _filteredBookings {
    final q = _searchQuery.trim().toLowerCase();
    final store = HotelOperationsStore.instance;

    return _bookings.where((b) {
      final isVerified = store.isETicketVerified(b.id) || b.status == BookingStatus.checkedIn;
      final isPaidAndWaitingScan = (b.isPaid ||
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.pendingVerification) &&
          !isVerified;

      if (_bookingFilterIndex == 0) {
        // Tamu sudah bayar tapi e-tiket belum di-scan/diverifikasi
        return isPaidAndWaitingScan;
      } else if (_bookingFilterIndex == 1) {
        // Menu Disetujui: E-Tiket sudah di-scan / diverifikasi
        return isVerified;
      }
      // Semua
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
    final store = HotelOperationsStore.instance;
    final waitingScanCount = _bookings.where((b) {
      final isVerified = store.isETicketVerified(b.id) || b.status == BookingStatus.checkedIn;
      return (b.isPaid ||
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.pendingVerification) &&
          !isVerified;
    }).length;

    final approvedCount = _bookings.where((b) {
      return store.isETicketVerified(b.id) || b.status == BookingStatus.checkedIn;
    }).length;

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Tabs (Sesuai instruksi: 1. Sudah bayar belum scan, 2. Disetujui/Sudah scan)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterPill(
                    title: 'Menunggu Scan E-Tiket',
                    badgeCount: waitingScanCount,
                    index: 0,
                    subtitle: 'Sudah Bayar',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    title: 'Disetujui',
                    count: approvedCount,
                    index: 1,
                    subtitle: 'Tiket Terverifikasi',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    title: 'Semua Booking',
                    count: _bookings.length,
                    index: 2,
                  ),
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
                  hintText: 'Cari ID Booking / Nama Tamu / No HP / Tipe Kamar',
                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: Icon(Icons.search_rounded, size: 19, color: Color(0xFF94A3B8)),
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
                    children: [
                      Icon(
                        _bookingFilterIndex == 0
                            ? Icons.check_circle_outline
                            : Icons.receipt_long_outlined,
                        size: 48,
                        color: const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _bookingFilterIndex == 0
                            ? 'Tidak ada tiket yang menunggu verifikasi'
                            : (_bookingFilterIndex == 1
                                ? 'Belum ada tiket yang disetujui / diverifikasi'
                                : 'Tidak ada data reservasi ditemukan'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _bookingFilterIndex == 0
                            ? 'Semua reservasi tamu yang sudah bayar telah diverifikasi.'
                            : 'Gunakan tombol Scan Tiket untuk memverifikasi tamu.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Builder(
                builder: (ctx) {
                  final total = _filteredBookings.length;
                  final maxPage = (total / 10).ceil();
                  final safePage = _currentPage.clamp(1, maxPage > 0 ? maxPage : 1);
                  final pagedBookings = paginateList(_filteredBookings, safePage, pageSize: 10);

                  return Column(
                    children: [
                      for (final b in pagedBookings) ...[
                        _buildBookingItemCard(b),
                        const SizedBox(height: 14),
                      ],
                      AppPaginationBar(
                        currentPage: safePage,
                        totalItems: total,
                        pageSize: 10,
                        itemLabel: 'reservasi',
                        primaryColor: const Color(0xFF007A87),
                        onPageChanged: (newPage) => setState(() => _currentPage = newPage),
                      ),
                    ],
                  );
                },
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String title,
    String? subtitle,
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
          color: isSelected ? const Color(0xFF007A87) : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00D1FF) : const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFF003847) : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: isSelected ? Colors.white70 : const Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItemCard(BookingModel b) {
    final store = HotelOperationsStore.instance;
    final isVerified = store.isETicketVerified(b.id) || b.status == BookingStatus.checkedIn;
    final isPaid = b.isPaid || b.status == BookingStatus.confirmed;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isVerified ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isVerified
                  ? const Color(0xFFE0F4FB)
                  : (isPaid ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isVerified
                          ? Icons.check_circle_rounded
                          : (isPaid ? Icons.payment_rounded : Icons.schedule_rounded),
                      size: 16,
                      color: isVerified
                          ? const Color(0xFF00758F)
                          : (isPaid ? const Color(0xFF16A34A) : const Color(0xFFD97706)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      b.bookingCode,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isVerified
                        ? const Color(0xFF007A87)
                        : (isPaid ? const Color(0xFF16A34A) : const Color(0xFFFEF3C7)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isVerified
                        ? 'Disetujui • E-Tiket Valid'
                        : (isPaid ? 'Sudah Bayar • Menunggu Scan' : 'Menunggu Bayar'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: (isVerified || isPaid) ? Colors.white : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Rincian Tamu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        b.customerName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.toRupiah(b.totalAmount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${b.roomTypeName} • ${b.totalNights} Malam',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tanggal: ${b.checkInDate.day}/${b.checkInDate.month}/${b.checkInDate.year} – ${b.checkOutDate.day}/${b.checkOutDate.month}/${b.checkOutDate.year}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                if (b.customerPhone != null && b.customerPhone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('No. HP: ${b.customerPhone}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    if (!isVerified) ...[
                      // Tombol Scan Barcode Kamera Langsung
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: () => _openCameraScanner(b),
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                          label: const Text(
                            'Scan Kamera & Konfirmasi',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C2FF),
                            foregroundColor: const Color(0xFF003847),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tombol Verifikasi Cepat
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: () => _verifyManual(b),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFBAE6FD)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Verifikasi',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF007A87)),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Badge info tiket telah disetujui & check-in
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.verified, size: 16, color: Color(0xFF16A34A)),
                              SizedBox(width: 6),
                              Text(
                                'E-Tiket Tamu Terverifikasi & Disetujui',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
