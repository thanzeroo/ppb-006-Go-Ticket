import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_ticket_admin/core/widgets/app_pagination_bar.dart';
import '../../../../../core/services/promo_service.dart';
import 'tambah_promo_screen.dart';

/// Tab 2: Manajemen Promo & Diskon (100% Dinamis dari Supabase Database)
class PromoTab extends StatefulWidget {
  const PromoTab({super.key});

  @override
  State<PromoTab> createState() => _PromoTabState();
}

class _PromoTabState extends State<PromoTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'Semua'; // 'Semua', 'Aktif', 'Nonaktif'
  String _selectedTypeFilter = 'Semua'; // 'Semua', 'Persen', 'Nominal'

  List<Map<String, dynamic>> _promos = [];
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadPromos();
  }

  Future<void> _loadPromos() async {
    setState(() => _isLoading = true);
    try {
      final list = await PromoService.instance.getPromos();
      if (mounted) {
        setState(() {
          _promos = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _promos = [];
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

  List<Map<String, dynamic>> get _filteredPromos {
    return _promos.where((p) {
      // 1. Search filter
      final q = _searchQuery.trim().toLowerCase();
      if (q.isNotEmpty) {
        final code = (p['code'] ?? '').toString().toLowerCase();
        final title = (p['title'] ?? '').toString().toLowerCase();
        final desc = (p['description'] ?? '').toString().toLowerCase();
        if (!code.contains(q) && !title.contains(q) && !desc.contains(q)) {
          return false;
        }
      }

      // 2. Status filter
      final isActive = p['isActive'] == true ||
          (p['status'] ?? '').toString().toLowerCase().contains('aktif');
      if (_selectedStatusFilter == 'Aktif') {
        if (!isActive) return false;
      } else if (_selectedStatusFilter == 'Nonaktif') {
        if (isActive) return false;
      }

      // 3. Discount Type filter
      final dType = (p['discountType'] ?? '').toString().toLowerCase();
      if (_selectedTypeFilter == 'Persen') {
        if (!dType.contains('persen')) return false;
      } else if (_selectedTypeFilter == 'Nominal') {
        if (!dType.contains('nominal')) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _togglePromo(Map<String, dynamic> p) async {
    final promoId = p['id']?.toString() ?? '';
    final isCurrentlyActive = p['isActive'] == true ||
        (p['status'] ?? '').toString().toLowerCase().contains('aktif');
    final newActiveState = !isCurrentlyActive;

    final ok = await PromoService.instance.togglePromoStatus(promoId, newActiveState);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Status voucher "${p['code']}" diubah menjadi ${newActiveState ? "Aktif" : "Nonaktif"}'),
          backgroundColor: newActiveState ? const Color(0xFF16A34A) : Colors.orange,
        ),
      );
      _loadPromos();
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Promo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            const Text('Apakah Anda yakin ingin menghapus voucher promo ini? Data yang dihapus tidak dapat dipulihkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final ok = await PromoService.instance.deletePromo(id);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promo berhasil dihapus dari database'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      _loadPromos();
    }
  }

  Future<void> _openEditPromoScreen(Map<String, dynamic> p) async {
    final res = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahPromoScreen(promoToEdit: p),
      ),
    );
    if (res == true && mounted) {
      _loadPromos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _promos.where((p) {
      return p['isActive'] == true ||
          (p['status'] ?? '').toString().toLowerCase().contains('aktif');
    }).length;

    return RefreshIndicator(
      onRefresh: _loadPromos,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Breadcrumb & Active Count Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'KAMPANYE & PENAWARAN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF007A94),
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00B4D8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$activeCount Aktif',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF007A94),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 2. Title & Subtitle
          const Text(
            'Manajemen Promo & Diskon',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Buat kampanye potongan harga, voucher musiman, dan diskon hari libur.',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Primary Action Button: + Buat Voucher Promo Baru
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TambahPromoScreen()),
                );
                if (result == true) {
                  _loadPromos();
                }
              },
              icon: const Icon(Icons.confirmation_number_outlined,
                  size: 18, color: Colors.white),
              label: const Text(
                '+ Buat Voucher Promo Baru',
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

          // 4. Mini Stats Box
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  'Total Promo',
                  '${_promos.length}',
                  Icons.confirmation_number_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                  'Promo Aktif',
                  '$activeCount',
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                  'Nonaktif',
                  '${_promos.length - activeCount}',
                  Icons.pause_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5. Search Bar
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
                hintText: 'Cari kode kupon, nama promo, atau deskripsi...',
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

          // 6. Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua Status (${_promos.length})',
                  isSelected: _selectedStatusFilter == 'Semua',
                  onTap: () => setState(() => _selectedStatusFilter = 'Semua'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Aktif ($activeCount)',
                  isSelected: _selectedStatusFilter == 'Aktif',
                  onTap: () => setState(() => _selectedStatusFilter = 'Aktif'),
                  activeColor: const Color(0xFF16A34A),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Nonaktif (${_promos.length - activeCount})',
                  isSelected: _selectedStatusFilter == 'Nonaktif',
                  onTap: () =>
                      setState(() => _selectedStatusFilter = 'Nonaktif'),
                  activeColor: const Color(0xFFDC2626),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 7. Discount Type Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua Tipe',
                  isSelected: _selectedTypeFilter == 'Semua',
                  onTap: () => setState(() => _selectedTypeFilter = 'Semua'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Diskon Persen (%)',
                  isSelected: _selectedTypeFilter == 'Persen',
                  onTap: () => setState(() => _selectedTypeFilter = 'Persen'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Potongan Nominal (Rp)',
                  isSelected: _selectedTypeFilter == 'Nominal',
                  onTap: () => setState(() => _selectedTypeFilter = 'Nominal'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 8. Header Result
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Daftar Voucher',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_filteredPromos.length}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 9. Promo Cards List
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredPromos.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: const [
                  Icon(Icons.confirmation_number_outlined,
                      size: 40, color: Color(0xFF94A3B8)),
                  SizedBox(height: 10),
                  Text(
                    'Tidak ada voucher promo yang cocok',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ubah kata kunci pencarian atau sesuaikan pilihan filter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            )
          else ...[
            Builder(
              builder: (ctx) {
                final total = _filteredPromos.length;
                final maxPage = (total / 10).ceil();
                final safePage = _currentPage.clamp(1, maxPage > 0 ? maxPage : 1);
                final pagedPromos = paginateList(_filteredPromos, safePage, pageSize: 10);

                return Column(
                  children: [
                    for (final p in pagedPromos) ...[
                      _buildDynamicPromoCard(p),
                      const SizedBox(height: 12),
                    ],
                    AppPaginationBar(
                      currentPage: safePage,
                      totalItems: total,
                      pageSize: 10,
                      itemLabel: 'voucher promo',
                      primaryColor: const Color(0xFF00758F),
                      onPageChanged: (newPage) => setState(() => _currentPage = newPage),
                    ),
                  ],
                );
              },
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF00758F)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  Widget _buildDynamicPromoCard(Map<String, dynamic> p) {
    final code = p['code']?.toString() ?? 'PROMO';
    final title = p['title']?.toString() ?? 'Voucher Promo';
    final desc = p['description']?.toString() ?? '';
    final discountVal = p['discountPercent']?.toString() ?? '10';
    final discountType =
        p['discountType']?.toString().toLowerCase() ?? 'persen';
    final discountBadge = discountType.contains('nominal')
        ? 'DISKON Rp $discountVal'
        : 'DISKON $discountVal%';

    final expiredRaw = p['expiredDate']?.toString() ?? '-';
    final expired =
        expiredRaw.contains('T') ? expiredRaw.split('T').first : expiredRaw;
    final promoId = p['id']?.toString() ?? '';

    final isActive = p['isActive'] == true ||
        (p['status'] ?? '').toString().toLowerCase().contains('aktif');

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F4FB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      discountBadge,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isActive ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF64748B)),
                onSelected: (val) {
                  if (val == 'edit') {
                    _openEditPromoScreen(p);
                  } else if (val == 'toggle') {
                    _togglePromo(p);
                  } else if (val == 'delete') {
                    _delete(promoId);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0284C7)),
                        SizedBox(width: 8),
                        Text('Edit Promo', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                          size: 16,
                          color: isActive ? Colors.orange : const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isActive ? 'Nonaktifkan Promo' : 'Aktifkan Promo',
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
                        Text('Hapus Promo',
                            style: TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kode "$code" berhasil disalin ke clipboard')),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.copy, size: 12, color: Color(0xFF0284C7)),
                      const SizedBox(width: 4),
                      Text(
                        code,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 12, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    'Berlaku s/d $expired',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
