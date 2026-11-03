
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_ticket/core/services/hotel_service.dart';
import '../../../router/customer_router.dart';
import '../customer_dashboard_screen.dart';

/// Tab Cari: menampilkan daftar hotel dan hasil pencarian.
class CariTab extends StatefulWidget {
  const CariTab({super.key});

  @override
  State<CariTab> createState() => _CariTabState();
}

class _CariTabState extends State<CariTab> {
  final TextEditingController _searchController = TextEditingController();

  String _sort = 'Terpopuler';
  String _keyword = '';

  Map<String, dynamic>? _searchFilter;

  List<Map<String, dynamic>> _hotels = [];

  bool _isLoading = false;

  static final List<Map<String, dynamic>> _baseHotels = [
    {
      'name': 'The Grand Amora Resort & Spa',
      'location': 'Petittenget, Seminyak',
      'type': 'Resor • ⭐ 5',
      'rating': '4.9',
      'reviews': '428 ulasan',
      'distance': '190m ke Pantai',
      'originalPrice': 'Rp 1.900.000',
      'discountedPrice': 'Rp 850.000',
      'discount': 'Hemat 29%',
      'features': ['Kolam Infinity', 'Spa Mewah', 'Bebas Batal'],
      'tag': 'Paling Diminati',
      'tagColor': Color(0xFF00B4D8),
      'isFavorite': false,
      'isFree': true,
      'imageUrl':
          'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=400',
      'badgeText': null,
    },
    {
      'name': 'Kayumanis Private Villa',
      'location': 'Kayu Aya, Seminyak',
      'type': null,
      'rating': '4.8',
      'reviews': '120 ulasan',
      'distance': '1 Unit Tersisa',
      'originalPrice': null,
      'discountedPrice': 'Rp 1.650.000',
      'discount': null,
      'features': ['Private Pool', 'Floating Breakfast'],
      'extras': ['Butler 24 Jam'],
      'tag': 'Private Villa',
      'tagColor': Color(0xFF7C3AED),
      'isFavorite': false,
      'isFree': false,
      'imageUrl':
          'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400',
      'badgeText': 'Bintang 5',
    },
    {
      'name': 'Seminyak Beach Breeze Hotel',
      'location': 'Double Six, Seminyak',
      'type': null,
      'rating': '4.7',
      'reviews': '89 ulasan',
      'distance': 'Dekat Spot Surfing',
      'originalPrice': null,
      'discountedPrice': 'Rp 620.000',
      'discount': null,
      'features': ['Langsung ke Pasir', 'WiFi Kencang'],
      'extras': ['Cafe Tepi Pantai'],
      'tag': 'Akses Pantai',
      'tagColor': Color(0xFF16A34A),
      'isFavorite': false,
      'isFree': false,
      'imageUrl':
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400',
      'badgeText': 'Bintang 4',
    },
  ];

  @override
  void initState() {
    super.initState();

    _searchFilter = CustomerDashboardScreen.searchFilterNotifier.value;

    CustomerDashboardScreen.searchFilterNotifier.addListener(
      _onSearchFilterChanged,
    );

    _fetchHotels();
  }

  @override
  void dispose() {
    CustomerDashboardScreen.searchFilterNotifier.removeListener(
      _onSearchFilterChanged,
    );

    _searchController.dispose();

    super.dispose();
  }

  /// Menerima perubahan filter dari Beranda.
  void _onSearchFilterChanged() {
    if (!mounted) return;

    setState(() {
      _searchFilter = CustomerDashboardScreen.searchFilterNotifier.value;

      _keyword = '';
      _searchController.clear();
    });
  }

  String get _destination {
    return (_searchFilter?['destination'] as String?) ??
        'Seminyak, Bali';
  }

  DateTime? get _checkIn {
    return _searchFilter?['checkIn'] as DateTime?;
  }

  DateTime? get _checkOut {
    return _searchFilter?['checkOut'] as DateTime?;
  }

  int get _guests {
    return (_searchFilter?['guests'] as int?) ?? 2;
  }

  int get _rooms {
    return (_searchFilter?['rooms'] as int?) ?? 1;
  }

  String _formatDateRange() {
    final start = _checkIn;
    final end = _checkOut;

    if (start == null || end == null) {
      return 'Pilih tanggal';
    }

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'Mei', 'Jun', 'Jul', 'Agu',
      'Sep', 'Okt', 'Nov', 'Des',
    ];

    if (start.month == end.month && start.year == end.year) {
      return '${start.day} - ${end.day} ${months[end.month - 1]}';
    }

    return '${start.day} ${months[start.month - 1]} - '
        '${end.day} ${months[end.month - 1]}';
  }

  /// Mengambil data hotel dari HotelService.
  Future<void> _fetchHotels() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final data = await HotelService.instance.getHotels(
        sortBy: _sort,
      );

      if (!mounted) return;

      setState(() {
        _hotels = data.map((h) {
          return {
            'id': h.id,
            'name': h.name,
            'location': '${h.city} • ${h.address}',
            'type': 'Resor • ⭐ ${h.starRating}',
            'rating': h.rating.toStringAsFixed(1),
            'reviews': '${h.reviewCount} ulasan',
            'distance': h.shortDescription ?? '',
            'originalPrice': h.originalPrice != null
                ? 'Rp ${h.originalPrice}'
                : null,
            'discountedPrice': 'Rp ${h.pricePerNight}',
            'discount': h.originalPrice != null ? 'Promo' : null,
            'features': h.amenities,
            'tag': h.isRecommended ? 'Paling Diminati' : null,
            'tagColor': const Color(0xFF00B4D8),
            'isFavorite': false,
            'isFree': false,
            'imageUrl': h.thumbnailUrl ??
                (h.photoUrls.isNotEmpty ? h.photoUrls.first : ''),
            'badgeText': 'Bintang ${h.starRating}',
          };
        }).toList();

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hotels = [
          for (final hotel in _baseHotels) {...hotel},
        ];

        _isLoading = false;
      });
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  /// Mengurutkan hotel.
  Future<void> _showSort() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Urutkan Hotel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              for (final option in const [
                'Terpopuler',
                'Harga Terendah',
                'Harga Tertinggi',
                'Rating Tertinggi',
              ])
                ListTile(
                  title: Text(option),
                  trailing: option == _sort
                      ? const Icon(
                          Icons.check,
                          color: Color(0xFF00B4D8),
                        )
                      : null,
                  onTap: () => Navigator.pop(ctx, option),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected != null && selected != _sort) {
      setState(() => _sort = selected);

      await _fetchHotels();

      _snack('Urutan hotel: $selected');
    }
  }

  /// Filter hotel sederhana.
  void _showFilter() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Penginapan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Gunakan pilihan filter untuk mempersempit pencarian hotel.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _snack('Filter diterapkan.');
                    },
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Pencarian berdasarkan nama hotel atau lokasi.
  List<Map<String, dynamic>> get _filteredHotels {
    var result = List<Map<String, dynamic>>.from(_hotels);

    if (_keyword.trim().isNotEmpty) {
      final keyword = _keyword.toLowerCase().trim();

      result = result.where((hotel) {
        final name = (hotel['name'] ?? '').toString().toLowerCase();
        final location =
            (hotel['location'] ?? '').toString().toLowerCase();

        return name.contains(keyword) ||
            location.contains(keyword);
      }).toList();
    }

    switch (_sort) {
      case 'Harga Terendah':
        result.sort(
          (a, b) => _priceValue(a).compareTo(_priceValue(b)),
        );
        break;

      case 'Harga Tertinggi':
        result.sort(
          (a, b) => _priceValue(b).compareTo(_priceValue(a)),
        );
        break;

      case 'Rating Tertinggi':
        result.sort(
          (a, b) => _ratingValue(b).compareTo(_ratingValue(a)),
        );
        break;
    }

    return result;
  }

  int _priceValue(Map<String, dynamic> hotel) {
    final price = (hotel['discountedPrice'] ?? '')
        .toString()
        .replaceAll(RegExp(r'[^0-9]'), '');

    return int.tryParse(price) ?? 0;
  }

  double _ratingValue(Map<String, dynamic> hotel) {
    return double.tryParse(
          (hotel['rating'] ?? '0').toString(),
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    final hotels = _filteredHotels;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildSearchHeader(),
          _buildFilterBar(),
          _buildResultsInfo(hotels.length),
          Expanded(
            child: _isLoading && _hotels.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : hotels.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          24,
                        ),
                        itemCount: hotels.length,
                        itemBuilder: (context, index) {
                          return _buildHotelCard(hotels[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hotel_outlined,
              size: 55,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            Text(
              'Hotel tidak ditemukan',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Coba gunakan nama hotel atau lokasi lainnya.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 28,
                    errorBuilder: (_, __, ___) {
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B4D8),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'GO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'GoTicket',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF111827),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.notifications_none_outlined,
                    color: Color(0xFF111827),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 17,
                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/100?img=11',
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _keyword = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari nama hotel atau lokasi...',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    if (_keyword.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _keyword = '');
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      'Promo Kilat',
      'Harga',
      '⭐ 4.5+',
      '🏊 Kolam Renang',
    ];

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(
            height: 1,
            color: Color(0xFFE5E7EB),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: filters.map((filter) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () {
                      if (filter == 'Harga') {
                        _showSort();
                      } else {
                        _snack('Filter $filter belum diaktifkan.');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111827),
                      side: const BorderSide(
                        color: Color(0xFFE5E7EB),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      filter,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFE5E7EB),
          ),
          InkWell(
            onTap: _showFilter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF00B4D8),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '$_destination  •  ${_formatDateRange()}  •  '
                      '$_guests Tamu, $_rooms Kamar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.tune,
                    color: Color(0xFF00B4D8),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsInfo(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$count Penginapan ',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  TextSpan(
                    text: 'di $_destination',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: _showSort,
            child: Row(
              children: [
                const Icon(
                  Icons.sort,
                  color: Color(0xFF00B4D8),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _sort,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF00B4D8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel) {
    return GestureDetector(
      onTap: () => _openHotelDetail(hotel),
      child: _buildHotelCardBody(hotel),
    );
  }

  void _openHotelDetail(Map<String, dynamic> hotel) {
    Navigator.pushNamed(
      context,
      CustomerRouter.hotelDetail,
      arguments: hotel,
    );
  }

  Widget _buildHotelCardBody(Map<String, dynamic> hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  (hotel['imageUrl'] ?? '').toString(),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 180,
                      color: const Color(0xFFE5E7EB),
                      child: const Center(
                        child: Icon(
                          Icons.hotel,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (hotel['tag'] != null)
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hotel['tagColor'] as Color? ??
                          const Color(0xFF00B4D8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hotel['tag'].toString(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hotel['isFavorite'] == true
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: hotel['isFavorite'] == true
                        ? Colors.red
                        : const Color(0xFF9CA3AF),
                    size: 18,
                  ),
                ),
              ),
              if (hotel['discount'] != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hotel['discount'].toString(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Color(0xFFFBBC05),
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      hotel['rating'].toString(),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '  (${hotel['reviews'] ?? '0 ulasan'})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    if ((hotel['distance'] ?? '').toString().isNotEmpty)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hotel['distance'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (hotel['badgeText'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF86EFAC),
                        ),
                      ),
                      child: Text(
                        hotel['badgeText'].toString(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF16A34A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Text(
                  hotel['name'].toString(),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF9CA3AF),
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        hotel['location'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: (hotel['features'] as List? ?? [])
                      .map(
                        (feature) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check,
                              size: 12,
                              color: Color(0xFF00B4D8),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              feature.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
                if (hotel['extras'] != null) ...[
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: (hotel['extras'] as List)
                        .map(
                          (extra) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check,
                                size: 12,
                                color: Color(0xFF00B4D8),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                extra.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hotel['originalPrice'] != null)
                            Text(
                              hotel['originalPrice'].toString(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF9CA3AF),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            hotel['discountedPrice'].toString(),
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            hotel['originalPrice'] != null
                                ? '/malam'
                                : 'Harga mulai dari',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          if (hotel['isFree'] == true)
                            Text(
                              '⊘ Bebas Biaya Layanan',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _openHotelDetail(hotel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'Pilih Kamar',
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
}
