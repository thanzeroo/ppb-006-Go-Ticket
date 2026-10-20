import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../router/customer_router.dart';

/// Tab Cari: Halaman hasil pencarian hotel seperti screenshot
class CariTab extends StatefulWidget {
  const CariTab({super.key});

  @override
  State<CariTab> createState() => _CariTabState();
}

class _CariTabState extends State<CariTab> {
  String _sortBy = 'Harga Terbaik';

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

  /// Data hotel diduplikasi 4x supaya daftar hasil terlihat banyak
  /// (sementara, sebelum terhubung ke API). Salinan tidak ditandai favorit.
  final List<Map<String, dynamic>> _hotels = [
    for (var i = 0; i < 4; i++)
      for (final h in _baseHotels)
        {...h, if (i > 0) 'isFavorite': false},
  ];

  String _sort = 'Terpopuler';

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

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
      _snack('Diurutkan: $v');
    }
  }

  void _showFilter() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Filter aktif: Promo Kilat • Rating 4.5+ • Kolam Renang',
                    style: TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _snack('Filter diterapkan');
                    },
                    child: const Text('Terapkan'),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildSearchHeader(),
          _buildFilterBar(),
          _buildResultsInfo(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _hotels.length,
              itemBuilder: (context, index) {
                return _buildHotelCard(_hotels[index]);
              },
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomButtons(),
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
                  const Icon(Icons.notifications_none_outlined,
                      color: Color(0xFF111827), size: 22),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 17,
                    backgroundImage:
                        const NetworkImage('https://i.pravatar.cc/100?img=11'),
                    backgroundColor: Colors.grey[200],
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
                        decoration: InputDecoration(
                          hintText: 'The Grand Amora Resort & Spa',
                          hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF374151),
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
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
    final filters = ['Promo Kilat', 'Harga', '⭐ 4.5+', '🏊 Kolam R...'];
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: filters.map((f) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () => _snack('Filter diterapkan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111827),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      f,
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
            onTap: () => Navigator.pushNamed(context, CustomerRouter.calendar),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Color(0xFF00B4D8), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Seminyak, Bali  •  24 - 26 Okt  •  2 Tamu, 1 Kamar',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '18 Penginapan ',
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
                _sortBy,
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
                        CustomerRouter.roomSelection,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showSort,
              icon: const Icon(Icons.local_fire_department,
                  color: Color(0xFF00B4D8), size: 16),
              label: Text(
                'Terpopuler',
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF00B4D8)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00B4D8)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showFilter,
              icon: const Icon(Icons.filter_list, size: 16),
              label: Text(
                'Filter (3)',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4D8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
