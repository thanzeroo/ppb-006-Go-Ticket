// =============================================================================
// FILE: lib/apps/customer/screens/ticket/e_ticket_detail_screen.dart
// RESPONSIBILITY: Halaman E-Tiket digital yang ditunjukkan Customer saat
// Check-in di hotel. Data riil dari database (BookingModel / BookingArgs).
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/booking_args.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

/// Halaman E-Tiket untuk Check-in Customer.
class ETicketDetailScreen extends StatelessWidget {
  final dynamic arguments;

  const ETicketDetailScreen({super.key, this.arguments});

  String get hotelName {
    if (arguments is BookingModel) return (arguments as BookingModel).hotelName;
    if (arguments is BookingArgs) return (arguments as BookingArgs).hotelName;
    if (arguments is Map) return arguments['hotelName']?.toString() ?? 'Hotel';
    return 'Hotel';
  }

  String get hotelLocation {
    if (arguments is BookingModel) {
      return (arguments as BookingModel).hotelAddress ?? 'Indonesia';
    }
    if (arguments is BookingArgs) return (arguments as BookingArgs).location;
    if (arguments is Map) return arguments['location']?.toString() ?? 'Indonesia';
    return 'Indonesia';
  }

  String get guestName {
    if (arguments is BookingModel) {
      final b = arguments as BookingModel;
      return b.customerName.isNotEmpty ? b.customerName : 'Tamu Go Ticket';
    }
    if (arguments is BookingArgs) {
      final b = arguments as BookingArgs;
      return b.guestName.isNotEmpty ? b.guestName : 'Tamu Go Ticket';
    }
    return 'Tamu Go Ticket';
  }

  String get bookingCode {
    if (arguments is BookingModel) return (arguments as BookingModel).bookingCode;
    if (arguments is BookingArgs) {
      return 'GT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    }
    return 'GT-RESERVASI';
  }

  String get roomName {
    if (arguments is BookingModel) return (arguments as BookingModel).roomTypeName;
    if (arguments is BookingArgs) return (arguments as BookingArgs).roomName;
    return 'Standard Room';
  }

  String get dateRange {
    if (arguments is BookingModel) {
      final b = arguments as BookingModel;
      return '${b.checkInDate.day}/${b.checkInDate.month}/${b.checkInDate.year} – ${b.checkOutDate.day}/${b.checkOutDate.month}/${b.checkOutDate.year}';
    }
    if (arguments is BookingArgs) return (arguments as BookingArgs).dateRange;
    return '-';
  }

  String get guestCount {
    if (arguments is BookingModel) {
      final b = arguments as BookingModel;
      return '${b.guestCount} Tamu (${b.totalNights} Malam)';
    }
    if (arguments is BookingArgs) {
      final b = arguments as BookingArgs;
      return '${b.adults} Dewasa${b.children > 0 ? ', ${b.children} Anak' : ''}';
    }
    return '2 Tamu';
  }

  String get qrData {
    if (arguments is BookingModel) {
      final b = arguments as BookingModel;
      return b.qrCodeData ?? '${b.bookingCode}-CHECKIN';
    }
    return '$bookingCode-CHECKIN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('E-Tiket'),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tautan E-Tiket disalin'))),
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('E-Tiket sedang diunduh'))),
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status badge
            _buildStatusBadge(),
            const SizedBox(height: 20),

            // E-Tiket card
            _buildTicketCard(),
            const SizedBox(height: 20),

            // QR Code utama
            _buildQrCodeSection(),
            const SizedBox(height: 20),

            // Instruksi check-in
            _buildCheckinInstructions(),
            const SizedBox(height: 24),

            // Tombol aksi
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.statusConfirmed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.statusConfirmed),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 18, color: AppColors.statusConfirmed),
          const SizedBox(width: 6),
          Text('Booking Dikonfirmasi',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.statusConfirmed)),
        ],
      ),
    );
  }

  Widget _buildTicketCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header tiket — gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.hotel_rounded,
                    color: AppColors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  hotelName,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  hotelLocation,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),

          // Dotted line divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _buildCircleClip(isLeft: true),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        (constraints.constrainWidth() / 8).floor(),
                        (_) => const SizedBox(
                          width: 4,
                          height: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: AppColors.grey300),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                _buildCircleClip(isLeft: false),
              ],
            ),
          ),

          // Detail booking
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                _buildTicketRow(
                  'Nama Tamu',
                  guestName,
                ),
                _buildTicketRow(
                  'Kode Booking',
                  bookingCode,
                ),
                _buildTicketRow(
                  'Tipe Kamar',
                  roomName,
                ),
                _buildTicketRow(
                  'Jadwal Menginap',
                  dateRange,
                ),
                _buildTicketRow(
                  'Jumlah Tamu',
                  guestCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleClip({required bool isLeft}) {
    return Container(
      width: 16,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? Radius.zero : const Radius.circular(16),
          right: isLeft ? const Radius.circular(16) : Radius.zero,
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.labelLarge
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Tunjukkan QR Code ini saat Check-in',
              style: AppTextStyles.titleMedium),
          const SizedBox(height: 6),
          Text('Staff FO akan memindai untuk validasi reservasi',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey300, width: 2),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.qr_code_2_rounded,
                  size: 160,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  bookingCode,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinInstructions() {
    final instructions = [
      'Waktu check-in standar mulai pukul 14:00 waktu setempat.',
      'Siapkan KTP/Paspor asli yang sesuai dengan nama pada tiket.',
      'Deposit dapat diperlukan saat check-in sesuai kebijakan hotel.',
      'Hubungi Front Office jika Anda tiba lebih lambat dari jadwal.',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Petunjuk Check-in',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ...instructions.map((inst) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(inst,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.grey700)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        GoTicketButton(
          label: 'Kembali ke Beranda',
          variant: ButtonVariant.outline,
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ],
    );
  }
}
