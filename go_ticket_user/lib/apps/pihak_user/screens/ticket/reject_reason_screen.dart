import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_ticket_user/core/models/booking_args.dart';
import 'package:go_ticket_user/core/models/booking_model.dart';
import 'package:go_ticket_user/core/services/booking_service.dart';
import 'package:go_ticket_user/core/utils/currency_formatter.dart';
import 'package:go_ticket_user/core/widgets/gt_ui.dart';
import '../../services/user_booking_storage.dart';

/// Halaman Form Alasan Reject Pesanan untuk User / Tamu.
/// Menampilkan ringkasan pesanan terkonfirmasi, pilihan checkbox alasan reject,
/// opsi alasan lain (input manual teks), validasi, serta konfirmasi submit pembatalan.
class RejectReasonScreen extends StatefulWidget {
  final dynamic arguments;
  const RejectReasonScreen({super.key, this.arguments});

  @override
  State<RejectReasonScreen> createState() => _RejectReasonScreenState();
}

class _RejectReasonScreenState extends State<RejectReasonScreen> {
  BookingModel? _booking;
  BookingArgs? _args;

  final TextEditingController _customReasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _reasonOptions = const [
    'Perubahan jadwal atau tanggal perjalanan',
    'Menemukan akomodasi atau promo lain',
    'Kendala transportasi / rute menuju penginapan',
    'Kondisi darurat medis atau urusan keluarga mendesak',
    'Tipe kamar atau fasilitas tidak sesuai kebutuhan',
    'Alasan Lainnya',
  ];

  final Set<String> _selectedReasons = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _parseArguments();
  }

  void _parseArguments() {
    final a = widget.arguments;
    if (a is BookingModel) {
      _booking = a;
    } else if (a is Map) {
      if (a['booking'] is BookingModel) {
        _booking = a['booking'] as BookingModel;
      } else if (a['args'] != null) {
        _args = BookingArgs.fromHotel(a['args']);
      } else {
        try {
          _booking = BookingModel.fromJson(Map<String, dynamic>.from(a));
        } catch (_) {
          _args = BookingArgs.fromHotel(a);
        }
      }
    } else if (a is BookingArgs) {
      _args = a;
    }
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  String get _hotelName =>
      _booking?.hotelName ?? _args?.hotelName ?? 'Penginapan Go Ticket';
  String get _roomName =>
      _booking?.roomTypeName ?? _args?.roomName ?? 'Kamar Hotel';
  String get _bookingCode => _booking?.bookingCode ?? 'GT-BOOKING';
  int get _totalAmount => _booking?.totalAmount ?? _args?.total ?? 0;

  void _toggleReason(String reason) {
    setState(() {
      if (_selectedReasons.contains(reason)) {
        _selectedReasons.remove(reason);
      } else {
        _selectedReasons.add(reason);
      }
    });
  }

  bool get _hasCustomReasonSelected =>
      _selectedReasons.contains('Alasan Lainnya');

  Future<void> _submitReject() async {
    if (_selectedReasons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal salah satu alasan reject pesanan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_hasCustomReasonSelected &&
        _customReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tuliskan alasan spesifik Anda pada kolom yang disediakan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tampilkan dialog konfirmasi pembatalan
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Konfirmasi Reject', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin me-reject / membatalkan pesanan ini? '
          'Status pesanan Anda akan diubah menjadi Dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: GT.muted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, Reject Pesanan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    // Kumpulkan seluruh alasan
    final reasonsList = _selectedReasons.toList();
    if (_hasCustomReasonSelected) {
      reasonsList.remove('Alasan Lainnya');
      reasonsList.add('Lainnya: ${_customReasonController.text.trim()}');
    }
    final fullReason = reasonsList.join('; ');

    try {
      final idOrCode = _booking?.id ?? _bookingCode;
      await UserBookingStorage.instance.cancelBooking(
        idOrCode,
        reason: fullReason,
        fallbackBooking: _booking,
      );

      // Sinkronkan ke BookingService jika ada
      try {
        await BookingService.instance.cancelBooking(idOrCode);
      } catch (_) {}

      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses pembatalan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GT.bg,
      appBar: const GTAppBar(title: 'Form Alasan Reject'),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              _buildBookingCard(),
              const SizedBox(height: 16),
              _buildInstructionNotice(),
              const SizedBox(height: 16),
              _buildCheckboxList(),
              if (_hasCustomReasonSelected) ...[
                const SizedBox(height: 14),
                _buildCustomTextField(),
              ],
              const SizedBox(height: 24),
              _buildNoticeWarning(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBookingCard() {
    return GTCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Kode: $_bookingCode',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 12, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Text(
                      'Dikonfirmasi',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _hotelName,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: GT.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _roomName,
            style: GoogleFonts.inter(fontSize: 13, color: GT.muted),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran:',
                style: GoogleFonts.inter(fontSize: 12, color: GT.muted),
              ),
              Text(
                CurrencyFormatter.toRupiah(_totalAmount),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: GT.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: GT.teal, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Silakan pilih alasan Anda me-reject / membatalkan pesanan terkonfirmasi ini. '
              'Masukan Anda sangat penting untuk evaluasi hotel.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF334155),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Alasan Reject (Bisa Lebih Dari Satu):',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: GT.ink,
          ),
        ),
        const SizedBox(height: 10),
        for (final opt in _reasonOptions) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedReasons.contains(opt)
                    ? GT.teal
                    : const Color(0xFFE2E8F0),
                width: _selectedReasons.contains(opt) ? 1.5 : 1,
              ),
            ),
            child: CheckboxListTile(
              value: _selectedReasons.contains(opt),
              onChanged: (_) => _toggleReason(opt),
              title: Text(
                opt,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: _selectedReasons.contains(opt)
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: _selectedReasons.contains(opt) ? GT.ink : const Color(0xFF475569),
                ),
              ),
              activeColor: GT.teal,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCustomTextField() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GT.teal, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.edit_note, color: GT.teal, size: 18),
              SizedBox(width: 6),
              Text(
                'Ketik Alasan Lainnya Secara Manual:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: GT.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _customReasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tuliskan alasan spesifik Anda membatalkan pesanan ini...',
              hintStyle: GoogleFonts.inter(fontSize: 12, color: GT.muted),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: GT.teal, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
            style: GoogleFonts.inter(fontSize: 13, color: GT.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Perhatian: Me-reject pesanan ini akan membatalkan reservasi dan e-tiket kamar hotel Anda. '
              'Tindakan ini tidak dapat dibatalkan kembali.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF991B1B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Kirim & Reject Pesanan',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
