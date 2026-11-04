import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_ticket/core/services/auth_service.dart';
import 'package:go_ticket/core/services/hotel_service.dart';
import 'package:go_ticket/core/utils/currency_formatter.dart';
import 'package:go_ticket/core/widgets/user_avatar.dart';
import '../../../router/customer_router.dart';

class _CariFilters {
  const _CariFilters({
    this.promotionsOnly = false,
    this.rating45Plus = false,
    this.poolOnly = false,
    this.maxPrice = 5000000,
  });

  final bool promotionsOnly;
  final bool rating45Plus;
  final bool poolOnly;
  final double maxPrice;
}

/// Tab Cari: Halaman hasil pencarian hotel seperti screenshot
class CariTab extends StatefulWidget {
  const CariTab({super.key});

  @override
  State<CariTab> createState() => _CariTabState();
}

class _CariTabState extends State<CariTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _CariFilters _filters = const _CariFilters();

  static final List<Map<String, dynamic>> _baseHotels = [
    {
      'name': 'The Grand Amora Resort & Spa',
      'location': 'Petittenget, Seminyak',
      'type': 'Resor • ⭐ 5',
      'rating': '4.9',
      'reviews': '428 ulasan',
      'distance': '190m ke Pantai',
      'originalPrice': 'Rp 1.200.000',
      'discountedPrice': 'Rp 850.000',
      'discount': 'Hemat 29%',
      'features': ['Kolam Infinity', 'Spa Mewah', 'Bebas Batal'],
      'tag': 'Paling Diminati',
      'tagColor': Color(0xFF00B4D8),
      'isFavorite': true,
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

  List<Map<String, dynamic>> _hotels = [];
  bool _isLoading = false;
  String _sort = 'Terpopuler';

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _visibleHotels {
    final query = _searchQuery.trim().toLowerCase();
    final hotels = _hotels.where((hotel) {
      final searchableText = [
        hotel['name'],
        hotel['location'],
        hotel['type'],
        ...(hotel['features'] as List<String>),
        ...((hotel['extras'] as List<String>?) ?? const <String>[]),
      ].whereType<String>().join(' ').toLowerCase();
      final price =
          CurrencyFormatter.parseToInt(hotel['discountedPrice'] as String);
      final originalPrice = hotel['originalPrice'] == null
          ? null
          : CurrencyFormatter.parseToInt(hotel['originalPrice'] as String);
      final rating = double.tryParse(hotel['rating'] as String) ?? 0;
      final amenities = [
        ...(hotel['features'] as List<String>),
        ...((hotel['extras'] as List<String>?) ?? const <String>[]),
      ].join(' ').toLowerCase();
      return (query.isEmpty || searchableText.contains(query)) &&
          price <= _filters.maxPrice &&
          (!_filters.promotionsOnly ||
              (originalPrice != null && originalPrice > price)) &&
          (!_filters.rating45Plus || rating >= 4.5) &&
          (!_filters.poolOnly ||
              amenities.contains('kolam') ||
              amenities.contains('pool'));
    }).toList();

    switch (_sort) {
      case 'Harga Terendah':
        hotels.sort(
          (a, b) => CurrencyFormatter.parseToInt(
            a['discountedPrice'] as String,
          ).compareTo(
            CurrencyFormatter.parseToInt(b['discountedPrice'] as String),
          ),
        );
      case 'Harga Tertinggi':
        hotels.sort(
          (a, b) => CurrencyFormatter.parseToInt(
            b['discountedPrice'] as String,
          ).compareTo(
            CurrencyFormatter.parseToInt(a['discountedPrice'] as String),
          ),
        );
      case 'Rating Tertinggi':
        hotels.sort(
          (a, b) => (double.tryParse(b['rating'] as String) ?? 0).compareTo(
            double.tryParse(a['rating'] as String) ?? 0,
          ),
        );
      default:
        hotels.sort(
          (a, b) => (double.tryParse(b['rating'] as String) ?? 0).compareTo(
            double.tryParse(a['rating'] as String) ?? 0,
          ),
        );
    }
    return hotels;
  }

  Future<void> _fetchHotels() async {
    setState(() => _isLoading = true);
    try {
      final data = await HotelService.instance.getHotels(sortBy: _sort);
      if (mounted) {
        final promoIndex = data.indexWhere(
          (hotel) =>
              hotel.originalPrice != null &&
              hotel.originalPrice! > hotel.pricePerNight,
        );
        setState(() {
          _hotels = data.asMap().entries.map((entry) {
            final h = entry.value;
            final originalPrice =
                entry.key == promoIndex ? h.originalPrice : null;
            final discountPercent = originalPrice == null
                ? null
                : ((originalPrice - h.pricePerNight) * 100 / originalPrice)
                    .round();
            return {
              'id': h.id,
              'name': h.name,
              'location': '${h.city} • ${h.address}',
              'type': 'Resor • ⭐ ${h.starRating}',
              'rating': h.rating.toStringAsFixed(1),
              'reviews': '${h.reviewCount} ulasan',
              'distance': h.shortDescription ?? '',
              'originalPrice': originalPrice == null
                  ? null
                  : CurrencyFormatter.toRupiah(originalPrice),
              'discountedPrice': CurrencyFormatter.toRupiah(h.pricePerNight),
              'discount':
                  discountPercent == null ? null : 'Hemat $discountPercent%',
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
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hotels = [
            for (final h in _baseHotels) {...h, 'isFavorite': false}
          ];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showSort() async {
    final v = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Urutkan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          for (final o in const [
            'Terpopuler',
            'Harga Terendah',
            'Harga Tertinggi',
            'Rating Tertinggi'
          ])
            ListTile(
              title: Text(o),
              trailing: o == _sort
                  ? const Icon(Icons.check, color: Color(0xFF00B4D8))
                  : null,
              onTap: () => Navigator.pop(ctx, o),
            ),
        ]),
      ),
    );
    if (v != null) {
      setState(() => _sort = v);
    }
  }

  Future<void> _showFilter() async {
    var promotionsOnly = _filters.promotionsOnly;
    var rating45Plus = _filters.rating45Plus;
    var poolOnly = _filters.poolOnly;
    var maxPrice = _filters.maxPrice;
    final result = await showModalBottomSheet<_CariFilters>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Penginapan',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setSheetState(() {
                        promotionsOnly = false;
                        rating45Plus = false;
                        poolOnly = false;
                        maxPrice = 5000000;
                      }),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Promo saja'),
                  value: promotionsOnly,
                  activeThumbColor: const Color(0xFF00B4D8),
                  onChanged: (value) =>
                      setSheetState(() => promotionsOnly = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Rating 4.5 ke atas'),
                  value: rating45Plus,
                  activeThumbColor: const Color(0xFF00B4D8),
                  onChanged: (value) =>
                      setSheetState(() => rating45Plus = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ada kolam renang'),
                  value: poolOnly,
                  activeThumbColor: const Color(0xFF00B4D8),
                  onChanged: (value) => setSheetState(() => poolOnly = value),
                ),
                Text(
                  'Harga maksimum ${CurrencyFormatter.toRupiah(maxPrice.round())}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: maxPrice,
                  min: 100000,
                  max: 5000000,
                  divisions: 49,
                  label: CurrencyFormatter.toRupiah(maxPrice.round()),
                  activeColor: const Color(0xFF00B4D8),
                  onChanged: (value) =>
                      setSheetState(() => maxPrice = value),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(
                      sheetContext,
                      _CariFilters(
                        promotionsOnly: promotionsOnly,
                        rating45Plus: rating45Plus,
                        poolOnly: poolOnly,
                        maxPrice: maxPrice,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Terapkan Filter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _filters = result);
    }
  }

  void _toggleFilter(String filter) {
    setState(() {
      switch (filter) {
        case 'Promo Kilat':
          _filters = _CariFilters(
            promotionsOnly: !_filters.promotionsOnly,
            rating45Plus: _filters.rating45Plus,
            poolOnly: _filters.poolOnly,
            maxPrice: _filters.maxPrice,
          );
        case '⭐ 4.5+':
          _filters = _CariFilters(
            promotionsOnly: _filters.promotionsOnly,
            rating45Plus: !_filters.rating45Plus,
            poolOnly: _filters.poolOnly,
            maxPrice: _filters.maxPrice,
          );
        case '🏊 Kolam Renang':
          _filters = _CariFilters(
            promotionsOnly: _filters.promotionsOnly,
            rating45Plus: _filters.rating45Plus,
            poolOnly: !_filters.poolOnly,
            maxPrice: _filters.maxPrice,
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleHotels = _visibleHotels;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchHeader(),
              _buildFilterBar(),
              _buildResultsInfo(),
              Expanded(
                child: _isLoading && _hotels.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : visibleHotels.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Penginapan tidak ditemukan. Ubah kata pencarian atau filter.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                            itemCount: visibleHotels.length,
                            itemBuilder: (context, index) {
                              return _buildHotelCard(visibleHotels[index]);
                            },
                          ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: _buildBottomButtons(),
            ),
          ),
        ],
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
                  Image.asset('assets/logo.png', height: 28,
                      errorBuilder: (_, __, ___) => Row(
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
                          )),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.notifications_none_outlined,
                          color: Color(0xFF111827), size: 22),
                      const SizedBox(width: 12),
                      UserAvatar(
                        name: AuthService.instance.currentUser?.fullName,
                        radius: 17,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Cari nama hotel, kota, atau fasilitas...',
                          hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF374151),
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          suffixIcon: _searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Hapus pencarian',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  icon: const Icon(Icons.close, size: 18),
                                ),
                        ),
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
    const filters = [
      'Promo Kilat',
      'Harga',
      '⭐ 4.5+',
      '🏊 Kolam Renang',
    ];
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: filters.map((filter) {
                final selected = switch (filter) {
                  'Promo Kilat' => _filters.promotionsOnly,
                  '⭐ 4.5+' => _filters.rating45Plus,
                  '🏊 Kolam Renang' => _filters.poolOnly,
                  _ => _filters.maxPrice < 5000000,
                };
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: filter == 'Harga'
                        ? _showFilter
                        : () => _toggleFilter(filter),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: selected
                          ? Colors.white
                          : const Color(0xFF111827),
                      backgroundColor: selected
                          ? const Color(0xFF00B4D8)
                          : Colors.white,
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFF00B4D8)
                            : const Color(0xFFE5E7EB),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      filter,
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          InkWell(
            onTap: _showFilter,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Color(0xFF00B4D8), size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Seminyak, Bali  •  2 Tamu, 1 Kamar',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.tune, color: Color(0xFF00B4D8), size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsInfo() {
    final resultCount = _visibleHotels.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$resultCount Penginapan ',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                TextSpan(
                  text: 'di Seminyak',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.sort, color: Color(0xFF00B4D8), size: 16),
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
        ],
      ),
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        CustomerRouter.hotelDetail,
        arguments: hotel,
      ),
      child: _buildHotelCardBody(hotel),
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
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  hotel['imageUrl'] as String,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: const Color(0xFFE5E7EB),
                    child:
                        const Icon(Icons.hotel, size: 48, color: Colors.grey),
                  ),
                ),
              ),
              if (hotel['tag'] != null)
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hotel['tagColor'] as Color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hotel['tag'] as String,
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
                    hotel['isFavorite'] as bool
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: hotel['isFavorite'] as bool
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
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hotel['discount'] as String,
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
                    const Icon(Icons.star, color: Color(0xFFFBBC05), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      hotel['rating'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      '  (${hotel['reviews']})',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF6B7280)),
                    ),
                    const Spacer(),
                    if (hotel['distance'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          hotel['distance'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
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
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Text(
                        hotel['badgeText'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF16A34A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Text(
                  hotel['name'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Color(0xFF9CA3AF), size: 13),
                    const SizedBox(width: 3),
                    Text(
                      hotel['location'] as String,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: (hotel['features'] as List<String>)
                      .map(
                        (f) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check,
                                size: 12, color: Color(0xFF00B4D8)),
                            const SizedBox(width: 3),
                            Text(
                              f,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF374151)),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
                if (hotel['extras'] != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: (hotel['extras'] as List<String>)
                        .map(
                          (e) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check,
                                  size: 12, color: Color(0xFF00B4D8)),
                              const SizedBox(width: 3),
                              Text(
                                e,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF374151)),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hotel['originalPrice'] != null)
                          Text(
                            hotel['originalPrice'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF9CA3AF),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          hotel['discountedPrice'] as String,
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
                        if (hotel['isFree'] as bool)
                          Text(
                            '⊘ Bebas Biaya Layanan',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        CustomerRouter.hotelDetail,
                        arguments: hotel,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'Pilih Kamar',
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w700),
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

  Widget _buildBottomButtons() {
    final activeFiltersCount = (_filters.promotionsOnly ? 1 : 0) +
        (_filters.rating45Plus ? 1 : 0) +
        (_filters.poolOnly ? 1 : 0) +
        (_filters.maxPrice < 5000000 ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _showSort,
            child: Row(
              children: [
                const Icon(Icons.swap_vert,
                    color: Color(0xFF00B4D8), size: 18),
                const SizedBox(width: 6),
                Text(
                  _sort,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 16,
            width: 1,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 14),
          ),
          InkWell(
            onTap: _showFilter,
            child: Row(
              children: [
                const Icon(Icons.tune,
                    color: Color(0xFF00B4D8), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Filter ${activeFiltersCount > 0 ? "($activeFiltersCount)" : ""}',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
