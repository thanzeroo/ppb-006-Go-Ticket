import 'package:flutter/material.dart';

import '../../../../core/models/booking_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/booking_service.dart';

/// Tab 4: Check-Out Tamu Front Office (100% Dinamis dari Database)
class FoCheckOutTab extends StatefulWidget {
  const FoCheckOutTab({super.key});

  @override
  State<FoCheckOutTab> createState() => _FoCheckOutTabState();
}

class _FoCheckOutTabState extends State<FoCheckOutTab> {
  List<BookingModel> _activeGuests = [];
  bool _isLoading = true;
  BookingModel? _selectedGuest;

  @override
  void initState() {
    super.initState();
    _loadActiveGuests();
  }

  Future<void> _loadActiveGuests() async {
    setState(() => _isLoading = true);
    final hotelId = AuthService.instance.currentUser?.managedHotelId ?? '1';
    try {
      final list = await BookingService.instance
          .getHotelBookings(hotelId, status: BookingStatus.checkedIn);
      if (mounted) {
        setState(() {
          _activeGuests = list;
          _selectedGuest = list.isNotEmpty ? list.first : null;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _activeGuests = [];
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

  Future<void> _processCheckOut(BookingModel b) async {
    setState(() => _isLoading = true);
    final ok = await BookingService.instance.checkOutGuest(b.id);
    if (mounted) {
      if (ok) {
        _showActionSnackbar(
            'Check-out tamu ${b.customerName} selesai. Status kamar diubah ke Dirty.');
        _loadActiveGuests();
      } else {
        setState(() => _isLoading = false);
        _showActionSnackbar('Gagal memproses check-out.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadActiveGuests,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subheader
            Row(
              children: const [
                Icon(Icons.meeting_room_outlined,
                    size: 15, color: Color(0xFF0284C7)),
                SizedBox(width: 6),
                Text(
                  'TERMINAL CHECK-OUT',
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
              'Proses Check-out Tamu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pengembalian deposit, kartu smart RFID, dan delegasi pembersihan kamar.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_activeGuests.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.check_circle_outline,
                          size: 48, color: Color(0xFF94A3B8)),
                      SizedBox(height: 12),
                      Text(
                        'Tidak ada tamu yang aktif menginap',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Daftar tamu yang telah check-in akan muncul di sini',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Text(
                'Tamu Sedang Menginap (${_activeGuests.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              for (final g in _activeGuests) ...[
                _buildGuestItem(g),
                const SizedBox(height: 10),
              ],
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestItem(BookingModel b) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                b.customerName,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A)),
              ),
              Text(
                'ID: ${b.bookingCode}',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0284C7)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${b.roomTypeName} • Check-in: ${b.checkInDate.day}/${b.checkInDate.month} s/d ${b.checkOutDate.day}/${b.checkOutDate.month}/${b.checkOutDate.year}',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: () => _processCheckOut(b),
              icon: const Icon(Icons.logout_rounded,
                  color: Colors.white, size: 16),
              label: const Text(
                'Proses Check-out Tamu',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C2FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
