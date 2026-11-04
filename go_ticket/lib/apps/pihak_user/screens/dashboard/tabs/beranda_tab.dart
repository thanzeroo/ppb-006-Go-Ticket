import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_ticket/core/models/booking_args.dart';
import 'package:go_ticket/core/models/hotel_model.dart';
import 'package:go_ticket/core/services/auth_service.dart';
import 'package:go_ticket/core/services/customer_data_service.dart';
import 'package:go_ticket/core/services/hotel_service.dart';
import 'package:go_ticket/core/utils/currency_formatter.dart';
import 'package:go_ticket/core/widgets/user_avatar.dart';
import '../../../router/customer_router.dart';
import '../customer_dashboard_screen.dart';

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  int _selectedCategoryIndex = 0;
  final Set<String> _savedHotelIds = {};

  @override
  void initState() {
    super.initState();
    _loadSavedHotels();
  }

  Future<void> _loadSavedHotels() async {
    final list = await CustomerDataService.instance.getSavedHotels();
    if (mounted) {
      setState(() {
        _savedHotelIds.clear();
        for (final h in list) {
          final id = h['id']?.toString() ?? h['name']?.toString() ?? '';
          if (id.isNotEmpty) _savedHotelIds.add(id);
        }
      });
    }
  }

  Future<void> _toggleSave(Map<String, dynamic> hotel) async {
    final id = hotel['id']?.toString() ?? hotel['name']?.toString() ?? '';
    final isSaved = await CustomerDataService.instance.toggleSavedHotel(hotel);
    if (mounted) {
      setState(() {
        if (isSaved) {
          _savedHotelIds.add(id);
        } else {
          _savedHotelIds.remove(id);
        }
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSaved
              ? '${hotel['name']} disimpan ke favorit'
              : '${hotel['name']} dihapus dari favorit'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final firstName = (user != null && user.fullName.trim().isNotEmpty)
        ? user.fullName.trim().split(' ').first
        : 'Aditya';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user, firstName),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchCard(),
                  const SizedBox(height: 16),
                  _buildPromoCard(),
                  const SizedBox(height: 24),
                  _buildKategoriSection(),
                  const SizedBox(height: 24),
                  _buildRekomendasiSection(),
                  const SizedBox(height: 24),
                  _buildWhyGoTicket(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(dynamic user, String firstName) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE0F4FB),
            Color(0xFFEBF8FD),
            Color(0xFFF8FAFC),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Logo & Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B4D8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'GO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'GoTicket',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  UserAvatar(
                    name: user?.fullName ?? 'Aditya Pratama',
                    radius: 19,
                    onTap: () => CustomerDashboardScreen.tabNotifier.value = 3,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Badge Pill: Eksplorasi Staycation Pilihan
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Eksplorasi Staycation Pilihan',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4338CA),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Greeting Title
              Text(
                'Halo, $firstName!',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mau liburan atau staycation nyaman ke mana hari ini?',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEARCH CARD
  // ---------------------------------------------------------------------------
  Widget _buildSearchCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tujuan atau Properti
          InkWell(
            onTap: () => CustomerDashboardScreen.tabNotifier.value = 1,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Color(0xFF0077B6), size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tujuan atau Properti',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Bali, Indonesia',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Tanggal & Tamu Row
          Row(
            children: [
              // Tanggal
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Color(0xFF0077B6), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '24 - 26 Okt',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Tamu & Kamar
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline,
                          color: Color(0xFF0077B6), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tamu & Kamar',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '2 Tamu, 1 Kamar',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Button Cari Penginapan Sekarang
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => CustomerDashboardScreen.tabNotifier.value = 1,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4D8),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              icon: const Icon(Icons.search, color: Colors.white, size: 20),
              label: Text(
                'Cari Penginapan Sekarang',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PROMO CARD
  // ---------------------------------------------------------------------------
  Widget _buildPromoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0077B6), Color(0xFF0096C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0077B6).withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Weekend Escape
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'WEEKEND ESCAPE',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Diskon 35% Spesial\nWeekend',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Eksplorasi villa privat dan resor mewah impian Anda.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.confirmation_number_outlined,
                    color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kode Promo Spesial:',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'STAYHEMAT',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: 'STAYHEMAT'));
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kode promo STAYHEMAT berhasil disalin!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0077B6),
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.copy, size: 14),
                label: Text(
                  'Salin Kode',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KATEGORI PILIHAN
  // ---------------------------------------------------------------------------
  Widget _buildKategoriSection() {
    final categories = [
      {'icon': Icons.hotel_outlined, 'label': 'Hotel Bintang 5'},
      {'icon': Icons.home_outlined, 'label': 'Villa Tropis'},
      {'icon': Icons.beach_access_outlined, 'label': 'Resor Pantai'},
      {'icon': Icons.apartment_outlined, 'label': 'Hotel Kota'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kategori Pilihan',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            TextButton(
              onPressed: () => CustomerDashboardScreen.tabNotifier.value = 1,
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF0077B6),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(categories.length, (idx) {
              final cat = categories[idx];
              final isSelected = idx == _selectedCategoryIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedCategoryIndex = idx);
                    CustomerDashboardScreen.tabNotifier.value = 1;
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFC8F0FA)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00B4D8)
                            : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 16,
                          color: isSelected
                              ? const Color(0xFF0077B6)
                              : const Color(0xFF475569),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF0077B6)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // REKOMENDASI TERPOPULER
  // ---------------------------------------------------------------------------
  Widget _buildRekomendasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasi Terpopuler',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dipilih khusus dengan skor ulasan tertinggi',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => CustomerDashboardScreen.tabNotifier.value = 1,
              child: Text(
                'Semua (42)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF0077B6),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<HotelModel>>(
          future: HotelService.instance.getFeaturedHotels(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('Tidak ada hotel rekomendasi saat ini.'),
                ),
              );
            }

            return Column(
              children: list.map((h) => _buildHotelCard(h)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHotelCard(HotelModel h) {
    final hotelMap = {
      'id': h.id,
      'name': h.name,
      'location': '${h.city} • ${h.address}',
      'city': h.city,
      'rating': h.rating.toStringAsFixed(1),
      'reviews': '${h.reviewCount}',
      'badge': 'Bintang ${h.starRating}',
      'price': CurrencyFormatter.toRupiah(h.pricePerNight),
      'pricePerNight': h.pricePerNight,
      'features': h.amenities,
      'imageUrl': h.thumbnailUrl ??
          (h.photoUrls.isNotEmpty ? h.photoUrls.first : ''),
    };

    final isFavorite = _savedHotelIds.contains(h.id) ||
        _savedHotelIds.contains(h.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel Image & Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  h.thumbnailUrl ??
                      (h.photoUrls.isNotEmpty ? h.photoUrls.first : ''),
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 190,
                    color: const Color(0xFFE2E8F0),
                    child: const Icon(Icons.hotel, size: 48, color: Colors.grey),
                  ),
                ),
              ),
              // Top-left ratings & star badges
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFF59E0B), size: 14),
                          const SizedBox(width: 3),
                          Text(
                            h.rating.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF0F172A),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            ' (${h.reviewCount})',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0077B6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Bintang ${h.starRating}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Favorite button
              Positioned(
                top: 12,
                right: 12,
                child: InkWell(
                  onTap: () => _toggleSave(hotelMap),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF475569),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Hotel Info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: Color(0xFF0077B6), size: 14),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        h.shortDescription ?? '${h.city} • 400m dari pantai',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  h.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                // Amenities Row
                Row(
                  children: [
                    _buildAmenityChip(Icons.wifi, 'WiFi Cepat'),
                    const SizedBox(width: 8),
                    _buildAmenityChip(Icons.pool, 'Infinity Pool'),
                    const SizedBox(width: 8),
                    _buildAmenityChip(Icons.restaurant, 'Sarapan Gratis'),
                  ],
                ),
                const SizedBox(height: 14),
                // Bottom row: Price & Pesan Cepat button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mulai dari',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              CurrencyFormatter.toRupiah(h.pricePerNight),
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0077B6),
                              ),
                            ),
                            Text(
                              ' /malam',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final args = BookingArgs.fromHotel(hotelMap);
                        Navigator.pushNamed(
                          context,
                          CustomerRouter.hotelDetail,
                          arguments: args,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        elevation: 0,
                      ),
                      child: Text(
                        'Pesan Cepat',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
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

  Widget _buildAmenityChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: const Color(0xFF0077B6)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KENAPA MEMILIH GO TICKET?
  // ---------------------------------------------------------------------------
  Widget _buildWhyGoTicket() {
    final reasons = [
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Jaminan Harga Terbaik',
        'desc': 'Harga transparan tanpa biaya tersembunyi saat Anda check-out.',
      },
      {
        'icon': Icons.qr_code_scanner,
        'title': 'Check-in Instan QR',
        'desc':
            'Tanpa antre di lobi resepsionis, cukup pindai kode dari ponsel Anda.',
      },
      {
        'icon': Icons.event_repeat_outlined,
        'title': 'Pembatalan Fleksibel',
        'desc':
            'Rencana mendadak berubah? Pembatalan mudah dengan jaminan refund cepat.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kenapa Memilih Go Ticket?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        ...reasons.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8F0FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      r['icon'] as IconData,
                      color: const Color(0xFF0077B6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['title'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          r['desc'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
