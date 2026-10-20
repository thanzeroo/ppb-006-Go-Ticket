import 'package:flutter/material.dart';

import 'input_hotel_screen.dart';

/// Tab 3: Kelola Hotel & Properti (Image 2)
class KelolaHotelTab extends StatefulWidget {
  const KelolaHotelTab({super.key});

  @override
  State<KelolaHotelTab> createState() => _KelolaHotelTabState();
}

class _KelolaHotelTabState extends State<KelolaHotelTab> {
  int _selectedFilterIndex = 0; // 0 = Semua, 1 = Resor Mewah, 2 = Villa, 3 = Boutique
  final List<String> _filters = [
    'Semua Hotel (4)',
    'Resor Mewah (2)',
    'Villa (1)',
    'Boutique (1)',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 1. Breadcrumb: MANAJEMEN PORTOFOLIO > PROPERTI
        Row(
          children: const [
            Icon(Icons.folder_open_rounded, size: 14, color: Color(0xFF007A94)),
            SizedBox(width: 5),
            Text(
              'MANAJEMEN PORTOFOLIO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF007A94),
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 14, color: Color(0xFF64748B)),
            SizedBox(width: 4),
            Text(
              'PROPERTI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 2. Title & Description
        const Text(
          'Kelola Hotel & Properti',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kelola daftar properti hotel, status operasional, dan pilih hotel untuk masuk ke manajemen Master Kamar.',
          style: TextStyle(
            fontSize: 11.5,
            color: Color(0xFF64748B),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),

        // 3. Primary Button: + Tambah Hotel Baru
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InputHotelScreen()),
              );
            },
            icon: const Icon(Icons.apartment_rounded, size: 18, color: Colors.white),
            label: const Text(
              '+ Tambah Hotel Baru',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C2FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 4. Summary Stats 2x2 Grid
        _buildStatsGrid(),
        const SizedBox(height: 16),

        // 5. Search Bar & Horizontal Filter Chips
        _buildSearchAndFilters(),
        const SizedBox(height: 16),

        // 6. Hotel List Cards (4 items from screenshot)
        _buildHotelCard(
          name: 'The Grand Amora Resort & Spa',
          location: 'Seminyak, Bali',
          starRating: '★ 5.0 • Resor Bintang 5',
          status: 'Aktif Beroperasi',
          totalRoomLabel: '20 Total Kamar',
          roomStatus: '16 Terisi • 4 Siap Jual',
          occupancyPercent: 80,
          buttonUnitLabel: '20 Unit',
          imageUrl:
              'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&auto=format&fit=crop',
        ),
        const SizedBox(height: 14),
        _buildHotelCard(
          name: 'Kayumanis Private Villa',
          location: 'Ubud, Bali',
          starRating: '★ 4.9 • Villa Mewah',
          status: 'Aktif Beroperasi',
          totalRoomLabel: '6 Total Villa',
          roomStatus: '5 Terisi • 1 Siap Jual',
          occupancyPercent: 83,
          buttonUnitLabel: '6 Unit',
          imageUrl:
              'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800&auto=format&fit=crop',
        ),
        const SizedBox(height: 14),
        _buildHotelCard(
          name: 'Seminyak Beach Breeze Hotel',
          location: 'Seminyak, Bali',
          starRating: '★ 4.7 • Bintang 4',
          status: 'Aktif Beroperasi',
          totalRoomLabel: '12 Total Kamar',
          roomStatus: '9 Terisi • 3 Siap Jual',
          occupancyPercent: 75,
          buttonUnitLabel: '12 Unit',
          imageUrl:
              'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&auto=format&fit=crop',
        ),
        const SizedBox(height: 14),
        _buildHotelCard(
          name: 'Ubud Forest Heritage Sanctuary',
          location: 'Gianyar, Bali',
          starRating: '★ 4.9 • Forest Suite',
          status: 'Aktif Beroperasi',
          totalRoomLabel: '8 Total Suite',
          roomStatus: '7 Terisi • 1 Siap Jual',
          occupancyPercent: 88,
          buttonUnitLabel: '8 Unit',
          imageUrl:
              'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&auto=format&fit=crop',
        ),
        const SizedBox(height: 18),

        // 7. Channel Manager Live Banner
        _buildChannelManagerCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Stats Grid 2x2
  // ---------------------------------------------------------------------------
  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniStatBox(
                title: 'Total Hotel',
                value: '4 Properti',
                subText: 'Semua Aktif',
                subDotColor: const Color(0xFF00B4D8),
                icon: Icons.apartment_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniStatBox(
                title: 'Total Kamar',
                value: '46 Kamar',
                subText: '37 Terisi saat ini',
                icon: Icons.meeting_room_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMiniStatBox(
                title: 'Rata-rata Okupansi',
                value: '84%',
                subText: '+4.2% pekan ini',
                subTextColor: const Color(0xFF0284C7),
                icon: Icons.trending_up_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniStatBox(
                title: 'Integrasi OTA',
                value: 'Live Sync',
                subText: '4 Channel Aktif',
                subTextColor: const Color(0xFF0284C7),
                icon: Icons.sync_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatBox({
    required String title,
    required String value,
    required String subText,
    Color? subDotColor,
    Color? subTextColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: const Color(0xFF0096B4)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (subDotColor != null) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: subDotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                subText,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: subTextColor != null ? FontWeight.w700 : FontWeight.w500,
                  color: subTextColor ?? const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search Bar & Filter Chips
  // ---------------------------------------------------------------------------
  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Search Input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: const [
              Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari nama hotel, wilayah, atau tipe akomodas...',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                ),
              ),
              Icon(Icons.tune_rounded, size: 18, color: Color(0xFF64748B)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Filter chips horizontal
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_filters.length, (index) {
              final isSelected = _selectedFilterIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedFilterIndex = index),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00758F) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00758F)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      _filters[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
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
  // Hotel Card Widget
  // ---------------------------------------------------------------------------
  Widget _buildHotelCard({
    required String name,
    required String location,
    required String starRating,
    required String status,
    required String totalRoomLabel,
    required String roomStatus,
    required int occupancyPercent,
    required String buttonUnitLabel,
    required String imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo Header with Badges and Overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF00758F),
                      child: const Center(
                        child: Icon(Icons.hotel_rounded, size: 48, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
              ),

              // Gradient Overlay at bottom of photo
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // Top Left Badge: Aktif Beroperasi
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C2FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00758F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Right Badge: Star Rating
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    starRating,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Bottom Overlay Text: Hotel Name & Location
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: Colors.white70),
                        const SizedBox(width: 3),
                        Text(
                          location,
                          style: const TextStyle(fontSize: 10.5, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content below photo
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.hotel_outlined, size: 15, color: Color(0xFF0096B4)),
                        const SizedBox(width: 5),
                        Text(
                          totalRoomLabel,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      roomStatus,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Occupancy progress bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Okupansi Kamar',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                    ),
                    Text(
                      '$occupancyPercent%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00758F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: occupancyPercent / 100.0,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C2FF)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 14),

                // Action Buttons Row: Masuk Kelola Kamar, Memo, More
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Membuka Manajemen Kamar $name...')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C2FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Masuk Kelola Kamar ($buttonUnitLabel)',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.playlist_add_check_rounded,
                            size: 19, color: Color(0xFF64748B)),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.more_vert_rounded,
                            size: 19, color: Color(0xFF64748B)),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
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

  // ---------------------------------------------------------------------------
  // Channel Manager Live Banner
  // ---------------------------------------------------------------------------
  Widget _buildChannelManagerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.hub_outlined,
                  color: Color(0xFF0096B4),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Channel Manager\nLive',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00758F),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Auto-\nSync',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Terhubung ke Traveloka, Tiket.com, Booking.com, dan Agoda',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sinkronkan Sekarang Button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Melakukan sinkronisasi data OTA...')),
                );
              },
              icon: const Icon(Icons.sync_rounded, size: 16, color: Color(0xFF007A94)),
              label: const Text(
                'Sinkronkan Sekarang',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF007A94),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF2FE),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
