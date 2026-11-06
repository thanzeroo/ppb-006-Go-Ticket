import 'package:flutter/material.dart';

import '../../../../../core/models/booking_model.dart';
import '../../../../../core/models/review_model.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/booking_service.dart';
import '../../../../../core/services/review_service.dart';
import '../../../../../core/theme/hotel_admin_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 – DASHBOARD ADMINISTRATOR (data dinamis dari DB)
// ─────────────────────────────────────────────────────────────────────────────

class AdministratorDashboardTab extends StatefulWidget {
  const AdministratorDashboardTab({super.key});

  @override
  State<AdministratorDashboardTab> createState() =>
      _AdministratorDashboardTabState();
}

class _AdministratorDashboardTabState
    extends State<AdministratorDashboardTab> {
  int _periodIndex = 1;
  final _periods = ['Hari Ini', '7 Hari Terakhir', 'Bulan Ini', 'Semua'];

  bool _loading = true;
  List<BookingModel> _bookings = [];
  List<ReviewModel> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final hotelId =
        AuthService.instance.currentUser?.managedHotelId ?? '';
    final bookings = hotelId.isEmpty
        ? <BookingModel>[]
        : await BookingService.instance.getHotelBookings(hotelId);
    final reviews = hotelId.isEmpty
        ? <ReviewModel>[]
        : await ReviewService.instance.getReviewsByHotel(hotelId);
    if (mounted) {
      setState(() {
        _bookings = bookings;
        _reviews = reviews;
        _loading = false;
      });
    }
  }

  // ── Hitung metrik dari data nyata ─────────────────────────────────────────

  List<BookingModel> get _filtered {
    final now = DateTime.now();
    return _bookings.where((b) {
      switch (_periodIndex) {
        case 0: // Hari Ini
          return b.checkInDate.year == now.year &&
              b.checkInDate.month == now.month &&
              b.checkInDate.day == now.day;
        case 1: // 7 Hari Terakhir
          return b.checkInDate
              .isAfter(now.subtract(const Duration(days: 7)));
        case 2: // Bulan Ini
          return b.checkInDate.year == now.year &&
              b.checkInDate.month == now.month;
        default:
          return true;
      }
    }).toList();
  }

  double get _totalRevenue =>
      _filtered.fold<double>(0, (s, b) => s + (b.totalPrice));

  int get _nightsSold => _filtered.fold<int>(
      0, (s, b) => s + b.checkOutDate.difference(b.checkInDate).inDays);

  double get _avgRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.fold<double>(0, (s, r) => s + r.overallRating) /
        _reviews.length;
  }

  String _fmt(double v) {
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)} Jt';
    if (v >= 1000) return 'Rp ${(v / 1000).toStringAsFixed(0)} Rb';
    return 'Rp ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: cDarkActive));
    }

    final revenue = _totalRevenue;
    final nights = _nightsSold;
    final rating = _avgRating;
    final reviewCount = _reviews.length;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: cDarkActive,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Dashboard Administrator',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),

          // ── Period filter pills ──────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_periods.length, (i) {
                final sel = _periodIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _periodIndex = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? cLightActive : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? cNormal : adminCardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (sel) ...[
                          const Icon(Icons.circle,
                              size: 6, color: cDarkActive),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          _periods[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: sel
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: sel
                                ? cDarkActive
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 14),

          // ── Card 1: Total Pendapatan ─────────────────────────────────────
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pendapatan Kotor',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF64748B))),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                          Icons.account_balance_outlined,
                          size: 16,
                          color: cDarkActive),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  revenue == 0 ? '–' : _fmt(revenue),
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  revenue == 0
                      ? 'Belum ada booking'
                      : '${_filtered.length} booking tercatat',
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Row mini cards ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Malam Terjual',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B))),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: cLight,
                                borderRadius: BorderRadius.circular(4)),
                            child: const Icon(Icons.key,
                                size: 12, color: cDarkActive),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                          nights == 0 ? '–' : '$nights',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const Text('Nights',
                          style: TextStyle(
                              fontSize: 9, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kepuasan Tamu',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B))),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4)),
                            child: const Icon(Icons.star,
                                size: 12, color: Color(0xFFD97706)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                          rating == 0
                              ? '–'
                              : rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const Text('/ 5.0',
                          style: TextStyle(
                              fontSize: 9, color: Color(0xFF64748B))),
                      const SizedBox(height: 2),
                      Text(
                          reviewCount == 0
                              ? 'Belum ada ulasan'
                              : '$reviewCount ulasan terverifikasi',
                          style: const TextStyle(
                              fontSize: 8, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Info Banner ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cLightActive),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: cDarkActive, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tarik ke bawah untuk memperbarui data.',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cDarker),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: adminCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
