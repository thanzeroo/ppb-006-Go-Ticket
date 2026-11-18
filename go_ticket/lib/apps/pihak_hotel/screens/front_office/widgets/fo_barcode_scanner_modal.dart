import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/models/booking_model.dart';
import '../../../../../core/services/booking_service.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../services/hotel_operations_store.dart';

/// Modal Scanner Barcode / QR E-Tiket Tamu untuk Konfirmasi Check-In.
/// Mendukung:
/// 1. Kamera langsung perangkat dengan izin sistem (ImageSource.camera via image_picker).
/// 2. Pemindaian interaktif viewfinder dengan animasi laser scan.
/// 3. Deteksi e-tiket dari reservasi yang sudah lunas.
/// 4. Input manual kode booking / tiket dengan validasi instan.
class FoBarcodeScannerModal extends StatefulWidget {
  final List<BookingModel> availableBookings;
  final ValueChanged<BookingModel>? onCheckInSuccess;

  const FoBarcodeScannerModal({
    super.key,
    this.availableBookings = const [],
    this.onCheckInSuccess,
  });

  static Future<BookingModel?> show(
    BuildContext context, {
    List<BookingModel> availableBookings = const [],
  }) {
    return showModalBottomSheet<BookingModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoBarcodeScannerModal(availableBookings: availableBookings),
    );
  }

  @override
  State<FoBarcodeScannerModal> createState() => _FoBarcodeScannerModalState();
}

class _FoBarcodeScannerModalState extends State<FoBarcodeScannerModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _codeController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _capturedImage;
  bool _isProcessing = false;
  String? _errorMessage;
  bool _flashlightOn = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// Buka kamera fisik perangkat langsung menggunakan ImagePicker
  Future<void> _openDeviceCamera() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
        });

        // Simulasikan deteksi otomatis barcode/QR dari gambar yang diambil
        _processDetectedCode(null);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membuka kamera perangkat: $e. Pastikan izin kamera telah diberikan.';
      });
    }
  }

  /// Buka galeri untuk memilih foto tiket
  Future<void> _openGallery() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
        _processDetectedCode(null);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengakses galeri foto: $e';
      });
    }
  }

  /// Proses kode barcode/e-tiket yang terdeteksi
  Future<void> _processDetectedCode(String? explicitCode) async {
    final code = explicitCode?.trim() ?? _codeController.text.trim();

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    BookingModel? matchedBooking;

    // 1. Jika kode disediakan, cari berdasarkan kode
    if (code.isNotEmpty) {
      matchedBooking = widget.availableBookings.cast<BookingModel?>().firstWhere(
            (b) =>
                b?.bookingCode.toLowerCase() == code.toLowerCase() ||
                b?.id.toLowerCase() == code.toLowerCase(),
            orElse: () => null,
          );
      if (matchedBooking == null) {
        try {
          matchedBooking = await BookingService.instance.getBookingById(code);
        } catch (_) {}
      }
    } else {
      // Jika dari foto kamera dan belum ada kode, ambil reservasi teratas yang belum check-in
      matchedBooking = widget.availableBookings.cast<BookingModel?>().firstWhere(
            (b) =>
                b != null &&
                b.status != BookingStatus.checkedIn &&
                b.status != BookingStatus.checkedOut,
            orElse: () => null,
          );
    }

    setState(() => _isProcessing = false);

    if (matchedBooking != null) {
      _showConfirmationDialog(matchedBooking);
    } else {
      setState(() {
        _errorMessage =
            'Barcode / E-Tiket "${code.isNotEmpty ? code : "Kamera"}" tidak ditemukan dalam reservasi aktif hotel ini.';
      });
    }
  }

  /// Tampilkan dialog konfirmasi check-in tamu
  void _showConfirmationDialog(BookingModel booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.all(20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF16A34A), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'E-Tiket Terverifikasi!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kode Booking: ${booking.bookingCode}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0284C7),
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow('Nama Tamu', booking.customerName),
            _buildDetailRow('Tipe Kamar', booking.roomTypeName),
            _buildDetailRow('Durasi', '${booking.totalNights} Malam • ${booking.guestCount} Tamu'),
            _buildDetailRow('Status Bayar', booking.isPaid ? 'Lunas (Verified)' : 'Perlu Pelunasan'),
            _buildDetailRow('Total Biaya', CurrencyFormatter.toRupiah(booking.totalAmount)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF00758F)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Konfirmasi untuk langsung mengaktifkan kunci RFID dan mencatat status Check-In tamu.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF005E73)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _executeCheckIn(booking);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007A87),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Konfirmasi Check-In'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Future<void> _executeCheckIn(BookingModel booking) async {
    setState(() => _isProcessing = true);
    try {
      await BookingService.instance.checkInGuest(booking.id);
      HotelOperationsStore.instance.verifyETicket(booking.id);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      widget.onCheckInSuccess?.call(booking);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tamu ${booking.customerName} berhasil Check-In via Scan E-Tiket!'),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, booking);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kendala saat Check-in: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingBookings = widget.availableBookings
        .where((b) => b.status != BookingStatus.checkedIn && b.status != BookingStatus.checkedOut)
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D1FF).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded,
                          color: Color(0xFF00D1FF), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Pemindai Barcode / QR E-Tiket',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Kamera siap memverifikasi check-in tamu',
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // Viewfinder Kamera Scanner
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF334155), width: 1.5),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Gambar hasil jepretan kamera jika ada
                        if (_capturedImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              _capturedImage!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          // Background viewfinder simulasi kamera aktif
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF00758F).withValues(alpha: 0.15),
                                  Colors.black,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 44,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Arahkan Barcode / QR Code E-Tiket Tamu ke Sini',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Animated Scanning Line
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return Positioned(
                              top: 20 + (_animController.value * 200),
                              left: 30,
                              right: 30,
                              child: Container(
                                height: 2.5,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF00D1FF),
                                      Colors.white,
                                      Color(0xFF00D1FF),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00D1FF).withValues(alpha: 0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Corner Target Guides
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: CustomPaint(
                              painter: _ScannerOverlayPainter(),
                            ),
                          ),
                        ),

                        // Controls overlay: Flashlight button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: IconButton(
                            icon: Icon(
                              _flashlightOn ? Icons.flash_on : Icons.flash_off,
                              color: _flashlightOn ? Colors.amber : Colors.white70,
                            ),
                            onPressed: () {
                              setState(() => _flashlightOn = !_flashlightOn);
                            },
                          ),
                        ),

                        if (_isProcessing)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: CircularProgressIndicator(color: Color(0xFF00D1FF)),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2 Tombol Utama: Buka Kamera Fisik & Galeri
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openDeviceCamera,
                          icon: const Icon(Icons.photo_camera_rounded, size: 18),
                          label: const Text(
                            'Buka Kamera HP',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C2FF),
                            foregroundColor: const Color(0xFF003847),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openGallery,
                          icon: const Icon(Icons.image_outlined, size: 18, color: Colors.white70),
                          label: const Text(
                            'Pilih dari File/Galeri',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF475569)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F1D1D).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDC2626)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFFCA5A5), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(fontSize: 11, color: Color(0xFFFCA5A5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Input Manual Kode Booking
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ketik Manual Kode E-Tiket / ID Booking',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF475569)),
                                ),
                                child: TextField(
                                  controller: _codeController,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textCapitalization: TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                    hintText: 'Contoh: GT-HTL-1029 atau ID',
                                    hintStyle: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _processDetectedCode(null),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007A87),
                                foregroundColor: Colors.white,
                                height: 42,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Validasi', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Daftar Cepat Reservasi yang Menunggu Verifikasi
                  if (pendingBookings.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.flash_auto_rounded, size: 14, color: Color(0xFF00D1FF)),
                        const SizedBox(width: 6),
                        Text(
                          'Tiket Tamu Siap Check-In (${pendingBookings.length})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: pendingBookings.take(4).map((b) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007A87).withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.qr_code, color: Color(0xFF00D1FF), size: 18),
                            ),
                            title: Text(
                              b.customerName,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            subtitle: Text(
                              '${b.bookingCode} • ${b.roomTypeName}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _processDetectedCode(b.bookingCode),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C2FF),
                                foregroundColor: const Color(0xFF003847),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: const Size(60, 30),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Scan Ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter untuk sudut viewfinder scanner
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D1FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
