import 'package:flutter/material.dart';

import '../../../../core/models/booking_model.dart';
import '../../../../core/services/booking_service.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Tab 3: Check-In Tamu Front Office (100% Dinamis dari Database)
class FoCheckInTab extends StatefulWidget {
  const FoCheckInTab({super.key});

  @override
  State<FoCheckInTab> createState() => _FoCheckInTabState();
}

class _FoCheckInTabState extends State<FoCheckInTab> {
  final TextEditingController _checkInSearchController =
      TextEditingController();
  BookingModel? _activeBooking;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _checkInSearchController.dispose();
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

  Future<void> _searchBooking() async {
    final query = _checkInSearchController.text.trim();
    if (query.isEmpty) {
      _showActionSnackbar('Masukkan ID Booking atau Kode E-Tiket');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _activeBooking = null;
    });

    try {
      final b = await BookingService.instance.getBookingById(query);
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (b != null) {
            _activeBooking = b;
          } else {
            _errorMessage = 'Booking dengan kode "$query" tidak ditemukan di database.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data booking dari server: $e';
        });
      }
    }
  }

  Future<void> _processCheckIn() async {
    if (_activeBooking == null) return;
    setState(() => _isLoading = true);

    try {
      final ok = await BookingService.instance.checkInGuest(_activeBooking!.id);
      if (mounted) {
        setState(() => _isLoading = false);
        if (ok) {
          _showActionSnackbar(
              'Tamu ${_activeBooking!.customerName} berhasil Check-In! Kunci dialokasikan.');
          _searchBooking();
        } else {
          _showActionSnackbar('Gagal melakukan check-in.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showActionSnackbar('Terjadi kesalahan saat check-in: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subheader
          Row(
            children: const [
              Icon(Icons.vpn_key_outlined, size: 15, color: Color(0xFF0284C7)),
              SizedBox(width: 6),
              Text(
                'KONTER RESEPSIONIS',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0284C7),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Proses Check-in Tamu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Validasi identitas, scan e-tiket, dan alokasikan kunci kamar secara instan.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // Search Field & Tombol Cari
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search_rounded,
                    size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _checkInSearchController,
                    onSubmitted: (_) => _searchBooking(),
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Cari ID Booking / No. Tiket',
                      hintStyle:
                          TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _searchBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00667C),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  child: Row(
                    children: const [
                      Text('Cari',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFDC2626)),
                    ),
                  ),
                ],
              ),
            )
          else if (_activeBooking != null)
            _buildBookingCard(_activeBooking!)
          else
            // Empty placeholder prompting search
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: const [
                  Icon(Icons.qr_code_scanner_rounded,
                      size: 48, color: Color(0xFF94A3B8)),
                  SizedBox(height: 12),
                  Text(
                    'Siap Memproses Check-in',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Masukkan Kode Booking tamu atau scan E-Tiket untuk melihat rincian reservasi dan memproses check-in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel b) {
    final priceStr = CurrencyFormatter.toRupiah(b.totalAmount);
    final dates =
        '${b.checkInDate.day}/${b.checkInDate.month}/${b.checkInDate.year} – ${b.checkOutDate.day}/${b.checkOutDate.month}/${b.checkOutDate.year}';
    final isAlreadyCheckedIn = b.status == BookingStatus.checkedIn;
    final isCheckedOut = b.status == BookingStatus.checkedOut;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF00758F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${b.bookingCode}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70),
                    ),
                    Text(
                      b.roomTypeName,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    b.status.displayName,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
                _buildRow('Nama Tamu', b.customerName),
                _buildRow('Nomor Telepon', b.customerPhone ?? '-'),
                _buildRow('Jadwal Menginap', dates),
                _buildRow('Durasi', '${b.totalNights} Malam • ${b.guestCount} Tamu'),
                _buildRow('Total Tagihan', priceStr),
                _buildRow('Status Pembayaran', b.isPaid ? 'Lunas' : 'Belum Lunas'),
                const SizedBox(height: 16),
                if (!isAlreadyCheckedIn && !isCheckedOut)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _processCheckIn,
                      icon: const Icon(Icons.key_rounded,
                          color: Colors.white, size: 18),
                      label: const Text(
                        'Konfirmasi Check-In Tamu',
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C2FF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isAlreadyCheckedIn
                          ? 'Tamu sudah berada di kamar (Check-in selesai).'
                          : 'Tamu sudah check-out.',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(value,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
