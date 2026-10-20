import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../router/customer_router.dart';

/// Tab Saved Hotel (dari halaman Pesanan → tab Saved Hotel)
/// Digunakan sebagai layar terpisah
class SavedHotelScreen extends StatefulWidget {
  const SavedHotelScreen({super.key});

  @override
  State<SavedHotelScreen> createState() => _SavedHotelScreenState();
}

class _SavedHotelScreenState extends State<SavedHotelScreen> {
  String _activeCategory = 'Semua';

  final List<String> _categories = [
    'Semua (6)',
    'Resor Bali (3)',
    'Villa Privat (2)',
    'Hotel Kot...',
  ];

  final List<Map<String, dynamic>> _folders = [
    {
      'name': 'Liburan Akhir Tahun',
      'count': 4,
      'icon': Icons.wb_sunny,
      'color': Color(0xFF00B4D8),
    },
    {
      'name': 'Staycation Romantis',
      'count': 2,
      'icon': Icons.favorite,
      'color': Color(0xFFEC4899),
    },
  ];

  final List<Map<String, dynamic>> _hotels = [
    {
      'name': 'The Grand Amora Resort & Spa',
      'location': 'Seminyak, Bali • 450m dari Pantai Petittenget',
      'type': 'Resor Mewah',
      'rating': '5.0',
      'originalPrice': 'Rp 1.190.000',
      'price': 'Rp 850.000',
      'discount': 'Hemat 25%',
      'features': ['Infinity Pool', 'Spa & Wellness'],
      'extras': ['Sarapan Gratis'],
      'availability': 'Tersedia 2 Kamar',
      'imageUrl':
          'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=400',
      'isFavorite': true,
      'badgeIcon': Icons.local_offer,
    },
    {
      'name': 'Kayumanis Private Villa',
      'location': 'Ubud, Bali • Nuansa Hutan Tropis',
      'type': 'Hutan Tropis Alri',
      'rating': '4.9',
      'originalPrice': null,
      'price': 'Rp 1.450.000',
      'discount': null,
      'features': ['Private Pool', 'Jacuzzi Pribadi'],
      'extras': ['Romantic Dinner'],
      'availability': 'Best Seller',
      'imageUrl':
          'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400',
      'isFavorite': true,
      'badgeIcon': null,
    },
    {
      'name': 'Seminyak Beach Breeze Hotel',
      'location': 'Seminyak, Bali • Kawasan Pantai Utama',
      'type': 'Akses Langsung Pantai',
      'rating': '4.7',
      'originalPrice': null,
      'price': 'Rp 550.000',
      'discount': null,
      'features': ['Wi-Fi Cepat', 'Gym Center'],
      'extras': ['Coffee Bar'],
      'availability': 'Populer',
      'imageUrl':
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400',
      'isFavorite': true,
      'badgeIcon': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          _buildFolderSection(),
          _buildCategoryTabs(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _hotels.length,
              itemBuilder: (ctx, i) => _buildHotelCard(_hotels[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      const SizedBox(width: 6),
                      Text(
                        'Saved Hotels',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.notifications_none_outlined,
                          color: Color(0xFF111827), size: 22),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 17,
                        backgroundImage: const NetworkImage(
                            'https://i.pravatar.cc/100?img=11'),
                        backgroundColor: Colors.grey[200],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tab switcher
              Row(
                children: [
                  _buildTopTab('Pemesanan', false),
                  const SizedBox(width: 8),
                  _buildTopTab('Saved Hotel', true),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00B4D8) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF00B4D8) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search,
                      color: Color(0xFF9CA3AF), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari koleksi favorit...',
                        hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF9CA3AF), fontSize: 13),
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
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(Icons.tune,
                color: Color(0xFF6B7280), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderSection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FOLDER KOLEKSI',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9CA3AF),
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '2 Favorit Aktif',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: const Color(0xFF00B4D8)),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: _folders.map((f) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (f['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: (f['color'] as Color).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(f['icon'] as IconData,
                          color: f['color'] as Color, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        '${f['name']} (${f['count']})',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: f['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              children: _categories.map((cat) {
                final isActive = (_activeCategory == cat ||
                    (cat.startsWith('Semua') && _activeCategory == 'Semua'));
                return GestureDetector(
                  onTap: () => setState(() => _activeCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF00B4D8)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isActive ? Colors.white : const Color(0xFF374151),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel) {
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
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.terrain,
                          color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        hotel['type'] as String,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
                      color: Colors.orange[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '🔥 ${hotel['discount']}',
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
                    color: Colors.white.withOpacity(0.92),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite,
                      color: Colors.red, size: 18),
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
                    const Icon(Icons.location_on,
                        color: Color(0xFF9CA3AF), size: 13),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        hotel['location'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hotel['name'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...(hotel['features'] as List<String>).map(
                      (f) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 12, color: Color(0xFF00B4D8)),
                          const SizedBox(width: 3),
                          Text(f,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF374151))),
                        ],
                      ),
                    ),
                    ...(hotel['extras'] as List<String>).map(
                      (e) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 12, color: Color(0xFF00B4D8)),
                          const SizedBox(width: 3),
                          Text(e,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF374151))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (hotel['originalPrice'] != null)
                  Text(
                    hotel['originalPrice'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel['price'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          '/ malam',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (hotel['availability'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (hotel['availability'] as String)
                                      .contains('Tersedia')
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hotel['availability'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: (hotel['availability'] as String)
                                        .contains('Tersedia')
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
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
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Pesan Sekarang',
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
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
