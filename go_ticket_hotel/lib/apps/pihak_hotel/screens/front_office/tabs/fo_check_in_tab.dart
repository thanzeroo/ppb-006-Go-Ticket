import 'package:flutter/material.dart';

import 'package:go_ticket_hotel/core/widgets/app_pagination_bar.dart';
import '../../../../../core/models/booking_model.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/booking_service.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../services/hotel_operations_store.dart';

/// Tab 3: Check-In Tamu Front Office
/// Menampilkan:
/// 1. Pencarian & Pemindai Barcode Kamera E-Tiket untuk Tamu Baru Tiba.
/// 2. Daftar Tamu yang Sedang Check-In (Menginap).
/// 3. Fitur Atur Perpanjang Hotel dengan Biaya Tambahan (tanpa reservasi dari awal).
/// 4. Fitur Check-out Lebih Awal dari tanggal yang dipilih.
/// 5. Fitur Keluar Paksa Tamu jika terjadi pelanggaran aturan hotel.
class FoCheckInTab extends StatefulWidget {
  const FoCheckInTab({super.key});

  @override
  State<FoCheckInTab> createState() => _FoCheckInTabState();
}

class _FoCheckInTabState extends State<FoCheckInTab> {
  final TextEditingController _checkInSearchController = TextEditingController();
  List<BookingModel> _checkedInGuests = [];
  bool _isLoading = true;
  String _searchQuery = '';
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
    _checkInSearchController.dispose();
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final hotelId = AuthService.instance.currentUser?.managedHotelId ?? '1';
    try {
      final list = await BookingService.instance.getHotelBookings(hotelId);
      if (mounted) {
        setState(() {
          _checkedInGuests = list.where((b) => b.status == BookingStatus.checkedIn).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _checkedInGuests = [];
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

  /// -------------------------------------------------------------------------
  /// 1. MODAL ATUR PERPANJANGAN HOTEL DENGAN BIAYA TAMBAHAN
  /// -------------------------------------------------------------------------
  void _showExtendStayModal(BookingModel booking) {
    int extraNights = 1;
    final pricePerNight = booking.totalNights > 0
        ? (booking.totalAmount / booking.totalNights).round()
        : 500000;
    String paymentMethod = 'Tunai di Resepsionis';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final currentCheckout = booking.checkOutDate;
          final newCheckout = currentCheckout.add(Duration(days: extraNights));
          final additionalCost = pricePerNight * extraNights;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F4FB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.more_time_rounded,
                                color: Color(0xFF0284C7), size: 22),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Perpanjang Masa Menginap',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Tanpa perlu input data dari awal',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Info Tamu & Kamar Saat Ini
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.customerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kamar: ${booking.roomTypeName} (${booking.bookingCode})',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        ),
                        Text(
                          'Check-Out Semula: ${currentCheckout.day}/${currentCheckout.month}/${currentCheckout.year}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Counter Input Tambah Malam
                  const Text(
                    'Tambah Berapa Malam?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_rounded, color: Color(0xFF0F172A)),
                              onPressed: extraNights > 1
                                  ? () => setModalState(() => extraNights--)
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$extraNights Malam',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_rounded, color: Color(0xFF0F172A)),
                              onPressed: () => setModalState(() => extraNights++),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Check-Out Baru:',
                                style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                            Text(
                              '${newCheckout.day}/${newCheckout.month}/${newCheckout.year}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rincian Biaya Tambahan
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tarif Kamar ($extraNights x ${CurrencyFormatter.toRupiah(pricePerNight)})',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF166534)),
                            ),
                            Text(
                              CurrencyFormatter.toRupiah(additionalCost),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16, color: Color(0xFF86EFAC)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Biaya Tambahan',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF14532D),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.toRupiah(additionalCost),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metode Pembayaran Tambahan
                  const Text(
                    'Metode Pembayaran Biaya Tambahan',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    items: const [
                      DropdownMenuItem(
                        value: 'Tunai di Resepsionis',
                        child: Text('Tunai di Resepsionis (Front Desk)'),
                      ),
                      DropdownMenuItem(
                        value: 'QRIS / E-Wallet',
                        child: Text('QRIS / Dompet Digital'),
                      ),
                      DropdownMenuItem(
                        value: 'Kartu Debit / Kredit',
                        child: Text('Kartu Debit / Kredit EDC'),
                      ),
                    ],
                    onChanged: (val) => setModalState(() => paymentMethod = val ?? paymentMethod),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Konfirmasi
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        HotelOperationsStore.instance.extendStay(
                          bookingId: booking.id,
                          additionalNights: extraNights,
                          additionalCost: additionalCost,
                        );
                        Navigator.pop(ctx);
                        _showActionSnackbar(
                          'Masa menginap ${booking.customerName} berhasil diperpanjang $extraNights malam! Total biaya tambahan ${CurrencyFormatter.toRupiah(additionalCost)}.',
                        );
                        _loadData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007A87),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Konfirmasi Perpanjangan Menginap',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// -------------------------------------------------------------------------
  /// 2. MODAL CHECK-OUT LEBIH AWAL
  /// -------------------------------------------------------------------------
  void _showEarlyCheckoutModal(BookingModel booking) {
    String reason = 'Urusan pekerjaan selesai lebih awal';
    final reasonController = TextEditingController(text: reason);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F4FB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.departure_board_rounded,
                                color: Color(0xFF0284C7), size: 22),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Check-out Lebih Awal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Sebelum batas akhir tanggal reservasi',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  Text(
                    'Tamu: ${booking.customerName}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'Kamar: ${booking.roomTypeName} • Tanggal Rencana: ${booking.checkOutDate.day}/${booking.checkOutDate.month}/${booking.checkOutDate.year}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Alasan Check-out Lebih Awal',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan alasan tamu check-out lebih awal...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildPresetChip('Pekerjaan selesai cepat', reasonController),
                      _buildPresetChip('Perubahan tiket pesawat', reasonController),
                      _buildPresetChip('Keperluan keluarga mendesak', reasonController),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.cleaning_services, size: 18, color: Color(0xFFD97706)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Setelah proses ini, kamar akan otomatis diteruskan ke tim Kebersihan (Maintenance) untuk disanitasi.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        final roomNum = booking.roomTypeName.contains('10') ? '102' : '204';
                        final floorNum = roomNum.startsWith('2') ? 2 : 1;
                        final currentStaff = AuthService.instance.currentUser?.fullName ?? 'Staf FO';

                        HotelOperationsStore.instance.processCheckout(
                          bookingId: booking.id,
                          bookingCode: booking.bookingCode,
                          guestName: booking.customerName,
                          guestPhone: booking.customerPhone,
                          roomNumber: roomNum,
                          floorNumber: floorNum,
                          roomTypeName: booking.roomTypeName,
                          checkInDate: booking.checkInDate,
                          scheduledCheckOutDate: booking.checkOutDate,
                          type: CheckoutType.early,
                          noteOrReason: reasonController.text.trim(),
                          processedBy: currentStaff,
                        );

                        Navigator.pop(ctx);
                        _showActionSnackbar(
                          'Check-out lebih awal ${booking.customerName} selesai. Kamar diteruskan ke tim kebersihan.',
                        );
                        _loadData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Konfirmasi Check-out Lebih Awal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// -------------------------------------------------------------------------
  /// 3. MODAL KELUAR PAKSA TAMU (PELANGGARAN ATURAN HOTEL)
  /// -------------------------------------------------------------------------
  void _showForcedExpulsionModal(BookingModel booking) {
    String selectedViolation = 'Merokok di kamar ber-AC bebas asap rokok';
    final penaltyController = TextEditingController(text: '500000');

    final notesController = TextEditingController();
    final violationPresets = [
      'Merokok di kamar ber-AC bebas asap rokok',
      'Kebisingan ekstrem / mengganggu ketenangan tamu lain',
      'Kerusakan fasilitas properti kamar secara sengaja',
      'Membawa barang/hewan terlarang ke dalam kamar',
      'Pelanggaran hukum / norma kesusilaan',
      'Menolak menyelesaikan pembayaran tagihan hotel',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.gavel_rounded,
                                color: Color(0xFFDC2626), size: 22),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tindakan Keluar Paksa',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                              Text(
                                'Penegakan aturan & pelanggaran berat tamu',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Data Tamu
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tamu yang Dikeluarkan: ${booking.customerName}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        Text(
                          'Kode Booking: ${booking.bookingCode} • ${booking.roomTypeName}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF7F1D1D)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Pilih Kategori Pelanggaran *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedViolation,
                    isExpanded: true,
                    items: violationPresets
                        .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v, style: const TextStyle(fontSize: 12)),
                            ))
                        .toList(),
                    onChanged: (val) => setModalState(() => selectedViolation = val ?? selectedViolation),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Catatan / Kronologi Kejadian *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Jelaskan ringkas detail pelanggaran yang terjadi...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Denda Pelanggaran / Biaya Ganti Rugi (Rp)',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: penaltyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      hintText: '500000',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        final roomNum = booking.roomTypeName.contains('10') ? '102' : '305';
                        final floorNum = roomNum.startsWith('3') ? 3 : 1;
                        final currentStaff = AuthService.instance.currentUser?.fullName ?? 'Staf FO';
                        final penalty = int.tryParse(penaltyController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

                        final fullNote = 'Pelanggaran: $selectedViolation. '
                            '${notesController.text.trim()}';

                        HotelOperationsStore.instance.processCheckout(
                          bookingId: booking.id,
                          bookingCode: booking.bookingCode,
                          guestName: booking.customerName,
                          guestPhone: booking.customerPhone,
                          roomNumber: roomNum,
                          floorNumber: floorNum,
                          roomTypeName: booking.roomTypeName,
                          checkInDate: booking.checkInDate,
                          scheduledCheckOutDate: booking.checkOutDate,
                          type: CheckoutType.forcedExpulsion,
                          noteOrReason: fullNote,
                          penaltyAmount: penalty,
                          processedBy: currentStaff,
                        );

                        Navigator.pop(ctx);
                        _showActionSnackbar(
                          'Tamu ${booking.customerName} berhasil dikeluarkan paksa. Tercatat di histori check-out & kamar masuk antrean pembersihan.',
                        );
                        _loadData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Keluarkan Paksa & Blokir Akses', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetChip(String text, TextEditingController controller) {
    return InkWell(
      onTap: () => controller.text = text,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCheckedIn = _checkedInGuests.where((b) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return b.customerName.toLowerCase().contains(q) ||
          b.bookingCode.toLowerCase().contains(q) ||
          b.roomTypeName.toLowerCase().contains(q);
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _checkInSearchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 12.5),
                decoration: const InputDecoration(
                  hintText: 'Cari Tamu Sedang Menginap / Kode Booking / Kamar',
                  hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: Icon(Icons.search_rounded, size: 19, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section: Tamu yang Sedang Menginap (Checked-In Guests)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hotel_rounded, size: 18, color: Color(0xFF0F172A)),
                    const SizedBox(width: 8),
                    Text(
                      'Tamu yang Sedang Menginap (${_checkedInGuests.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Aktif On-Premise',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredCheckedIn.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.bed_outlined, size: 44, color: Color(0xFF94A3B8)),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada tamu yang aktif menginap',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gunakan scanner kamera di atas untuk memproses check-in tamu yang baru tiba.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              )
            else ...[
              Builder(
                builder: (ctx) {
                  final total = filteredCheckedIn.length;
                  final maxPage = (total / 10).ceil();
                  final safePage = _currentPage.clamp(1, maxPage > 0 ? maxPage : 1);
                  final pagedGuests = paginateList(filteredCheckedIn, safePage, pageSize: 10);

                  return Column(
                    children: [
                      for (final b in pagedGuests) ...[
                        _buildCheckedInGuestCard(b),
                        const SizedBox(height: 14),
                      ],
                      AppPaginationBar(
                        currentPage: safePage,
                        totalItems: total,
                        pageSize: 10,
                        itemLabel: 'tamu menginap',
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

  Widget _buildCheckedInGuestCard(BookingModel b) {
    final store = HotelOperationsStore.instance;
    final extendedNights = store.getExtendedNights(b.id);
    final additionalCost = store.getAdditionalCost(b.id);

    final currentCheckout = b.checkOutDate.add(Duration(days: extendedNights));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
            decoration: const BoxDecoration(
              color: Color(0xFF00758F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.bookingCode,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    Text(
                      b.roomTypeName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.key, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Checked-In',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      b.customerName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    if (b.customerPhone != null)
                      Text(
                        b.customerPhone!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.date_range_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      'Check-in: ${b.checkInDate.day}/${b.checkInDate.month}/${b.checkInDate.year}  →  Check-out: ${currentCheckout.day}/${currentCheckout.month}/${currentCheckout.year}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                    ),
                  ],
                ),

                if (extendedNights > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.more_time, size: 14, color: Color(0xFF16A34A)),
                        const SizedBox(width: 6),
                        Text(
                          'Perpanjangan: +$extendedNights Malam (Biaya Tambahan: ${CurrencyFormatter.toRupiah(additionalCost)})',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // 3 Aksi Utama: 1. Atur Perpanjang, 2. Check-out Lebih Awal, 3. Keluar Paksa
                Row(
                  children: [
                    // 1. Atur Perpanjang Hotel
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () => _showExtendStayModal(b),
                        icon: const Icon(Icons.more_time_rounded, size: 15),
                        label: const Text('Atur Perpanjang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007A87),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // 2. Check-out Lebih Awal
                    Expanded(
                      flex: 3,
                      child: OutlinedButton.icon(
                        onPressed: () => _showEarlyCheckoutModal(b),
                        icon: const Icon(Icons.logout_rounded, size: 14, color: Color(0xFF0284C7)),
                        label: const Text('Check-out Awal', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFBAE6FD)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // 3. Keluar Paksa (Pelanggaran)
                    OutlinedButton(
                      onPressed: () => _showForcedExpulsionModal(b),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        backgroundColor: const Color(0xFFFEF2F2),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.gavel_rounded, size: 14, color: Color(0xFFDC2626)),
                          SizedBox(width: 4),
                          Text('Keluar Paksa', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                        ],
                      ),
                    ),
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
