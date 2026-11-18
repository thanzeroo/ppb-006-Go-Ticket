import 'package:flutter/material.dart';

import '../../../../../core/models/hotel_model.dart';
import '../../../../../core/services/hotel_service.dart';
import 'input_hotel_screen.dart';

/// Tab 3: Kelola Hotel & Kamar Super Admin (100% Dinamis dari Supabase Database)
class KelolaHotelTab extends StatefulWidget {
  const KelolaHotelTab({super.key});

  @override
  State<KelolaHotelTab> createState() => _KelolaHotelTabState();
}

class _KelolaHotelTabState extends State<KelolaHotelTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'Semua'; // 'Semua', 'Aktif', 'Nonaktif'
  String _selectedCityFilter = 'Semua Kota';
  int _selectedStarFilter = 0; // 0 = Semua, 3 = 3 Bintang, 4 = 4 Bintang, 5 = 5 Bintang

  List<HotelModel> _hotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() => _isLoading = true);
    try {
      final list = await HotelService.instance.getHotels();
      if (mounted) {
        setState(() {
          _hotels = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hotels = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _availableCities {
    final cities = _hotels.map((h) => h.city.trim()).where((c) => c.isNotEmpty).toSet().toList();
    cities.sort();
    return ['Semua Kota', ...cities];
  }

  List<HotelModel> get _filteredHotels {
    return _hotels.where((h) {
      // 1. Search Query
      final q = _searchQuery.trim().toLowerCase();
      if (q.isNotEmpty) {
        final matches = h.name.toLowerCase().contains(q) ||
            h.city.toLowerCase().contains(q) ||
            h.address.toLowerCase().contains(q);
        if (!matches) return false;
      }

      // 2. Status Filter
      if (_selectedStatusFilter == 'Aktif') {
        if (h.status != HotelStatus.active) return false;
      } else if (_selectedStatusFilter == 'Nonaktif') {
        if (h.status == HotelStatus.active) return false;
      }

      // 3. City Filter
      if (_selectedCityFilter != 'Semua Kota') {
        if (!h.city.toLowerCase().contains(_selectedCityFilter.toLowerCase())) {
          return false;
        }
      }

      // 4. Star Rating Filter
      if (_selectedStarFilter > 0) {
        if (h.starRating != _selectedStarFilter) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _toggleHotelStatus(HotelModel h) async {
    final newStatus = h.status == HotelStatus.active
        ? HotelStatus.suspended
        : HotelStatus.active;
    final ok = await HotelService.instance.updateHotelStatus(h.id, newStatus);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Status operasional ${h.name} diubah menjadi ${newStatus == HotelStatus.active ? "Aktif" : "Nonaktif"}'),
          backgroundColor: newStatus == HotelStatus.active
              ? const Color(0xFF16A34A)
              : Colors.orange,
        ),
      );
      _loadHotels();
    }
  }

  Future<void> _deleteHotel(HotelModel h) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Mitra Penginapan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Apakah Anda yakin ingin menghapus hotel "${h.name}" beserta seluruh data kamarnya? Tindakan ini bersifat permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await HotelService.instance.deleteHotel(h.id);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hotel "${h.name}" berhasil dihapus dari database'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
      _loadHotels();
    }
  }

  Future<void> _openEditHotelScreen(HotelModel h) async {
    final res = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => InputHotelScreen(hotelToEdit: h),
      ),
    );
    if (res == true && mounted) {
      _loadHotels();
    }
  }

  void _showHotelDetail(HotelModel h) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.apartment_rounded, color: Color(0xFF00758F), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                h.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID Penginapan', h.id),
              _buildDetailRow('Kota/Wilayah', h.city),
              _buildDetailRow('Alamat', h.address),
              _buildDetailRow('Rating', '⭐ ${h.rating.toStringAsFixed(1)} (Bintang ${h.starRating})'),
              _buildDetailRow('Status', h.status.displayName),
              _buildDetailRow('Total Kamar', '${h.totalRooms} Unit'),
              if (h.phone != null && h.phone!.isNotEmpty)
                _buildDetailRow('Telepon', h.phone!),
              if (h.whatsapp != null && h.whatsapp!.isNotEmpty)
                _buildDetailRow('WhatsApp', h.whatsapp!),
              if (h.checkInTime != null)
                _buildDetailRow('Check-In', h.checkInTime!),
              if (h.checkOutTime != null)
                _buildDetailRow('Check-Out', h.checkOutTime!),
              if (h.cancellationPolicy != null)
                _buildDetailRow('Kebijakan', h.cancellationPolicy!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00758F),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _openEditHotelScreen(h);
            },
            child: const Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(0xFF64748B))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalHotels = _hotels.length;
    final totalRooms = _hotels.fold<int>(0, (sum, h) => sum + (h.totalRooms ?? 0));
    final activeHotels = _hotels.where((h) => h.status == HotelStatus.active).length;
    final uniqueCities = _hotels.map((h) => h.city).toSet().length;

    return RefreshIndicator(
      onRefresh: _loadHotels,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Title & Super Admin Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Kelola Hotel & Kamar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manajemen inventaris, tarif dinamis, serta kelola mitra hotel',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFFAFE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Super\nAdmin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0891B2),
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Button + Daftarkan Mitra Penginapan Baru
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InputHotelScreen()),
                );
                if (result == true) {
                  _loadHotels();
                }
              },
              icon: const Icon(Icons.add_business_rounded,
                  size: 18, color: Colors.white),
              label: const Text(
                '+ Daftarkan Mitra Penginapan Baru',
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

          // 3. Summary Stats 4 Box (Dinamis dari Database)
          Row(
            children: [
              Expanded(
                child: _buildMiniStatBox(
                  title: 'Total Hotel',
                  value: '$totalHotels Properti',
                  subText: '$activeHotels Aktif',
                  icon: Icons.apartment_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatBox(
                  title: 'Total Kamar',
                  value: '$totalRooms Unit',
                  subText: 'Database',
                  icon: Icons.meeting_room_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatBox(
                  title: 'Sebaran Wilayah',
                  value: '$uniqueCities Kota',
                  subText: 'Nasional',
                  icon: Icons.place_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4. Search Bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari nama hotel, wilayah, atau alamat...',
                hintStyle:
                    const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                prefixIcon:
                    const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 5. Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua Status (${_hotels.length})',
                  isSelected: _selectedStatusFilter == 'Semua',
                  onTap: () => setState(() => _selectedStatusFilter = 'Semua'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Aktif ($activeHotels)',
                  isSelected: _selectedStatusFilter == 'Aktif',
                  onTap: () => setState(() => _selectedStatusFilter = 'Aktif'),
                  activeColor: const Color(0xFF16A34A),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Nonaktif (${_hotels.length - activeHotels})',
                  isSelected: _selectedStatusFilter == 'Nonaktif',
                  onTap: () =>
                      setState(() => _selectedStatusFilter = 'Nonaktif'),
                  activeColor: const Color(0xFFDC2626),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 6. City Filter Chips
          if (_availableCities.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _availableCities.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: c,
                      isSelected: _selectedCityFilter == c,
                      onTap: () => setState(() => _selectedCityFilter = c),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8),

          // 7. Star Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua Bintang',
                  isSelected: _selectedStarFilter == 0,
                  onTap: () => setState(() => _selectedStarFilter = 0),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '⭐ 5 Bintang',
                  isSelected: _selectedStarFilter == 5,
                  onTap: () => setState(() => _selectedStarFilter = 5),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '⭐ 4 Bintang',
                  isSelected: _selectedStarFilter == 4,
                  onTap: () => setState(() => _selectedStarFilter = 4),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '⭐ 3 Bintang',
                  isSelected: _selectedStarFilter == 3,
                  onTap: () => setState(() => _selectedStarFilter = 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 8. Result Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HASIL HOTEL (${_filteredHotels.length})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 9. Hotel List
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredHotels.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: const [
                  Icon(Icons.hotel_outlined,
                      size: 40, color: Color(0xFF94A3B8)),
                  SizedBox(height: 10),
                  Text(
                    'Tidak ada hotel yang sesuai filter',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ubah kata kunci pencarian atau sesuaikan pilihan filter di atas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            )
          else
            for (final h in _filteredHotels) ...[
              _buildHotelCard(h),
              const SizedBox(height: 12),
            ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMiniStatBox({
    required String title,
    required String value,
    required String subText,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Icon(icon, size: 14, color: const Color(0xFF00B4D8)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subText,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0284C7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final color = activeColor ?? const Color(0xFF007A94);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? color : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildHotelCard(HotelModel h) {
    final isAktif = h.status == HotelStatus.active;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              GestureDetector(
                onTap: () => _showHotelDetail(h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    h.thumbnailUrl ?? (h.photoUrls.isNotEmpty ? h.photoUrls.first : ''),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: const Color(0xFFE2E8F0),
                      child: const Icon(Icons.hotel, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Detail
              Expanded(
                child: GestureDetector(
                  onTap: () => _showHotelDetail(h),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${h.city} • ${h.address}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '⭐ ${h.rating.toStringAsFixed(1)} (Bintang ${h.starRating})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  ${h.totalRooms} Kamar',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Actions Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF64748B)),
                onSelected: (val) {
                  if (val == 'detail') {
                    _showHotelDetail(h);
                  } else if (val == 'edit') {
                    _openEditHotelScreen(h);
                  } else if (val == 'toggle') {
                    _toggleHotelStatus(h);
                  } else if (val == 'delete') {
                    _deleteHotel(h);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Color(0xFF00758F)),
                        SizedBox(width: 8),
                        Text('Lihat Detail', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0284C7)),
                        SizedBox(width: 8),
                        Text('Edit Hotel', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          isAktif ? Icons.power_settings_new : Icons.check_circle_outline,
                          size: 16,
                          color: isAktif ? Colors.orange : const Color(0xFF16A34A),
                        ),
                        SizedBox(width: 8),
                        Text(
                          isAktif ? 'Nonaktifkan Hotel' : 'Aktifkan Hotel',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus Hotel',
                            style: TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAktif
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isAktif
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Operasional: ${h.status.displayName}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isAktif
                            ? const Color(0xFF15803D)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _openEditHotelScreen(h),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.edit, size: 12, color: Color(0xFF0284C7)),
                      SizedBox(width: 4),
                      Text(
                        'Kelola / Edit',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
