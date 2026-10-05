// =============================================================================
// FILE: lib/apps/hotel_partner/screens/front_office/qr_scanner_checkin_screen.dart
// RESPONSIBILITY: Halaman scan QR Code E-Tiket tamu untuk proses check-in.
// Staff FO mengarahkan kamera ke QR code yang ditampilkan di HP tamu.
// Setelah scan sukses:
// - Validasi data booking
// - Konfirmasi check-in → status booking 'checkedIn'
// - Status kamar berubah menjadi 'Occupied'
// Menggunakan package mobile_scanner / qr_code_scanner.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

/// Halaman scanner QR untuk proses check-in tamu.
class QrScannerCheckinScreen extends StatefulWidget {
  const QrScannerCheckinScreen({super.key});

  @override
  State<QrScannerCheckinScreen> createState() => _QrScannerCheckinScreenState();
}

class _QrScannerCheckinScreenState extends State<QrScannerCheckinScreen> {
  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  /// Apakah QR sudah berhasil di-scan
  bool _isScanned = false;

  /// Apakah sedang memproses check-in setelah scan
  bool _isProcessing = false;

  /// Data yang dibaca dari QR code
  String? _scannedData;

  /// Apakah lampu flash aktif
  bool _flashOn = false;

  Future<void> _simulateScan() async {
    // Simulasi scan QR — di produksi pakai package mobile_scanner
    setState(() {
      _isScanned = true;
      _scannedData = 'GT-20261005-001';
    });
  }

  Future<void> _processCheckin() async {
    setState(() => _isProcessing = true);
    // TODO: Integrasikan dengan BookingRepository.processCheckin()
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _showCheckinSuccess();
  }

  void _showCheckinSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            Text('Check-in Berhasil!', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text('John Doe berhasil check-in\nke Kamar 101 Standard Room.',
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text('Status kamar diubah ke: Ditempati',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.roomOccupied)),
          ],
        ),
        actions: [
          GoTicketButton(
            label: 'Selesai',
            onPressed: () {
              Navigator.pop(context); // Dialog
              Navigator.pop(context); // Screen
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  void _resetScan() {
    setState(() {
      _isScanned = false;
      _scannedData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
        title: const Text('Scan QR Check-in'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _flashOn = !_flashOn),
            icon: Icon(
              _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: AppColors.white,
            ),
          ),
        ],
      ),
      body: _isScanned ? _buildScanResult() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        // Kamera placeholder — ganti dengan MobileScanner widget
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR frame overlay
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Sudut-sudut frame
                    ..._buildCorners(),

                    // Scanning animation line
                    Center(
                      child: Container(
                        height: 2,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Arahkan kamera ke QR code\npada HP tamu',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Tombol simulasi scan (untuk development)
              GoTicketButton(
                label: 'Simulasi Scan QR',
                onPressed: _simulateScan,
                width: 200,
                backgroundColor: AppColors.primary.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCorners() {
    const color = AppColors.primary;
    const size = 24.0;
    const thickness = 4.0;

    return [
      // Top-left
      Positioned(top: 0, left: 0,
          child: _buildCorner(color, size, thickness, true, true)),
      // Top-right
      Positioned(top: 0, right: 0,
          child: _buildCorner(color, size, thickness, true, false)),
      // Bottom-left
      Positioned(bottom: 0, left: 0,
          child: _buildCorner(color, size, thickness, false, true)),
      // Bottom-right
      Positioned(bottom: 0, right: 0,
          child: _buildCorner(color, size, thickness, false, false)),
    ];
  }

  Widget _buildCorner(Color color, double size, double thickness,
      bool isTop, bool isLeft) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(color, thickness, isTop, isLeft),
      ),
    );
  }

  Widget _buildScanResult() {
    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Icon sukses scan
          const Icon(Icons.qr_code_rounded,
              size: 64, color: AppColors.primary),
          const SizedBox(height: 12),
          Text('QR Code Berhasil Dibaca!',
              style: AppTextStyles.headlineSmall),
          Text(_scannedData ?? '', style: AppTextStyles.priceMedium),
          const SizedBox(height: 24),

          // Detail booking hasil scan
          _buildBookingPreview(),
          const Spacer(),

          // Tombol proses check-in
          GoTicketButton(
            label: 'Konfirmasi Check-in',
            onPressed: _isProcessing ? null : _processCheckin,
            isLoading: _isProcessing,
            backgroundColor: AppColors.success,
            icon: Icons.login_rounded,
          ),
          const SizedBox(height: 12),
          GoTicketOutlinedButton(
            label: 'Scan Ulang',
            onPressed: _resetScan,
            icon: Icons.refresh_rounded,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBookingPreview() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow('Nama Tamu', 'John Doe'),
          _buildInfoRow('Tipe Kamar', 'Standard Room'),
          _buildInfoRow('Nomor Kamar', '101'),
          _buildInfoRow('Check-in', '05 Oktober 2026'),
          _buildInfoRow('Check-out', '08 Oktober 2026'),
          _buildInfoRow('Jumlah Tamu', '2 Tamu'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}

/// Custom painter untuk sudut frame QR scanner
class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool isTop;
  final bool isLeft;

  _CornerPainter(this.color, this.thickness, this.isTop, this.isLeft);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
