import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/supabase_config.dart';
import '../../../../core/models/hotel_admin_model.dart';
import '../../../../core/models/room_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/booking_service.dart';
import '../../../../core/services/hotel_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/hotel_admin_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/tiko_chat_bubble.dart';
import '../auth/staff_login_screen.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/kamar_tarif_tab.dart';
import 'tabs/keuangan_tab.dart';
import 'tabs/staf_tim_tab.dart';

/// Main Dashboard Screen for Administrator Pihak Hotel (100% Dinamis dari Database)
class AdministratorDashboardScreen extends StatefulWidget {
  const AdministratorDashboardScreen({super.key});

  @override
  State<AdministratorDashboardScreen> createState() =>
      _AdministratorDashboardScreenState();
}

class _AdministratorDashboardScreenState
    extends State<AdministratorDashboardScreen> {
  int _selectedTab = 0;

  List<RoomTypeData> _rooms = [];
  List<StaffData> _staff = [];
  List<TransactionData> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final hotelId = AuthService.instance.currentUser?.managedHotelId ?? '1';

    try {
      // 1. Load Rooms
      final roomsRes = await HotelService.instance.getRoomsByHotel(hotelId);
      final mappedRooms = roomsRes.map((r) {
        return RoomTypeData(
          badge: r.typeName,
          name: r.typeName,
          sub: 'Maks. ${r.maxGuests} Tamu • ${r.areaM2?.toInt() ?? 24} m² • ${r.bedType ?? "King Bed"}',
          totalUnit: 1,
          terjual: r.status == RoomStatus.occupied ? 1 : 0,
          occupancy: r.status == RoomStatus.occupied ? 100 : 0,
          weekdayPrice: CurrencyFormatter.toRupiah(r.pricePerNight),
          weekendPrice: CurrencyFormatter.toRupiah(r.weekendPrice ?? r.pricePerNight),
          weekendNote: 'Tarif Weekend',
          amenities: r.facilities,
          photoCount: r.imageUrls.length,
          imageUrl: r.mainImageUrl ??
              'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&auto=format&fit=crop',
        );
      }).toList();

      // 2. Load Staff (Dinamis dari database staf_hotel)
      List<StaffData> mappedStaff = [];
      try {
        final serviceKey = SupabaseConfig.supabaseServiceRoleKey.isNotEmpty
            ? SupabaseConfig.supabaseServiceRoleKey
            : SupabaseConfig.activeApiKey;

        List<dynamic>? rawStaffList;
        if (serviceKey.isNotEmpty && SupabaseConfig.supabaseUrl.isNotEmpty) {
          final uri = Uri.parse(
              '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableStafHotel}?select=*&id_penginapan=eq.${int.tryParse(hotelId) ?? 1}&order=created_at.desc');
          final resp = await http.get(uri, headers: {
            'apikey': serviceKey,
            'Authorization': 'Bearer $serviceKey',
          });
          if (resp.statusCode == 200) {
            rawStaffList = jsonDecode(resp.body) as List<dynamic>;
          }
        }

        final sb = SupabaseService.instance;
        if (rawStaffList == null && sb.isReady) {
          final staffRes = await sb
              .table(SupabaseConfig.tableStafHotel)
              ?.select()
              .eq('id_penginapan', int.tryParse(hotelId) ?? 1)
              .order('created_at', ascending: false);
          if (staffRes != null) {
            rawStaffList = staffRes as List;
          }
        }

        if (rawStaffList != null) {
          mappedStaff = rawStaffList.map((s) {
            final m = Map<String, dynamic>.from(s);
            final rawRole =
                (m['role_jabatan'] ?? m['role'] ?? '').toString().toLowerCase();

            final String displayRole;
            final String roleKey;
            final List<String> aksesList;
            final Color roleBg;
            final Color roleFg;

            if (rawRole.contains('admin')) {
              displayRole = 'Administrator';
              roleKey = 'administrator';
              aksesList = [
                'Kelola Karyawan',
                'Master Kamar',
                'Keuangan & Kas',
                'Otoritas Penuh'
              ];
              roleBg = const Color(0xFFDCFCE7);
              roleFg = const Color(0xFF15803D);
            } else if (rawRole.contains('maint') ||
                rawRole.contains('housekeeping')) {
              displayRole = 'Maintenance';
              roleKey = 'maintenance';
              aksesList = [
                'Kebersihan Kamar',
                'Laporan Kerusakan',
                'Checklist Sanitasi'
              ];
              roleBg = const Color(0xFFEDE9FE);
              roleFg = const Color(0xFF7C3AED);
            } else {
              displayRole = 'Staf';
              roleKey = 'front_office';
              aksesList = [
                'Check-in Tamu',
                'Check-out Tamu',
                'Verifikasi Booking',
                'Alokasi Kunci'
              ];
              roleBg = const Color(0xFFE0F4FB);
              roleFg = const Color(0xFF0284C7);
            }

            final isDuty =
                (m['status_duty'] ?? '').toString().toLowerCase() == 'on';
            final statusKaryawan = m['status_karyawan'] ?? 'Aktif';

            return StaffData(
              name: m['nama_staf'] ?? m['nama_lengkap'] ?? 'Karyawan',
              id: m['id_staf'] ?? '',
              role: displayRole,
              roleKey: roleKey,
              statusLabel: isDuty
                  ? 'On-Duty'
                  : (statusKaryawan == 'Aktif' ? 'Off-Duty' : 'Non-aktif'),
              statusBg: roleBg,
              statusFg: roleFg,
              onlineDotColor:
                  isDuty ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
              akses: aksesList,
              wa: m['no_telepon'] ?? '-',
              avatarUrl:
                  'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=300&auto=format&fit=crop',
              shift: m['shift_tugas'] ?? 'Shift Pagi (07:00 – 15:00 WIB)',
              email: m['email'],
              nik: m['nik_staf'],
            );
          }).toList();
        }
      } catch (staffErr) {
        debugPrint('⚠️ [LoadDashboardData] Gagal load staff: $staffErr');
      }

      // 3. Load Transactions
      final bookingsRes = await BookingService.instance.getHotelBookings(hotelId);
      final mappedTx = bookingsRes.map((b) {
        return TransactionData(
          name: b.customerName,
          amount: '+${CurrencyFormatter.toRupiah(b.totalAmount)}',
          room: '${b.roomTypeName} • ${b.totalNights} Malam',
          code: b.bookingCode,
          method: b.paymentMethod ?? 'Online Payment',
          time: '${b.checkInDate.day}/${b.checkInDate.month}/${b.checkInDate.year}',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _rooms = mappedRooms;
          _staff = mappedStaff;
          _transactions = mappedTx;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _rooms = [];
          _staff = [];
          _transactions = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Icons.bar_chart_rounded, 'Dashboard'),
      (Icons.bed_outlined, 'Kamar & Tarif'),
      (Icons.badge_outlined, 'Staf & Tim'),
      (Icons.account_balance_wallet_outlined, 'Keuangan'),
    ];

    final tabViews = [
      const AdministratorDashboardTab(),
      KamarTarifTab(rooms: _rooms, onRefresh: _loadData),
      StafTimTab(staff: _staff, onRefresh: _loadData),
      KeuanganTab(transactions: _transactions),
    ];

    return Stack(
      children: [
        Scaffold(
          backgroundColor: adminBg,
          body: SafeArea(
            child: Column(
              children: [
                // Top Bar with official Logo
                _buildTopAppBar(),

                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : IndexedStack(
                          index: _selectedTab,
                          children: tabViews,
                        ),
                ),

                // Bottom Navigation Bar
                _buildBottomNav(tabs),
              ],
            ),
          ),
        ),
        const TikoChatBubble(),
      ],
    );
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.instance.logout();
    } catch (e) {
      debugPrint('⚠️ [Logout error]: $e');
    }
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berhasil keluar. Silakan login kembali.'),
        backgroundColor: Color(0xFF007A87),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (Navigator.canPop(context)) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
          ],
          // Logo & Title
          Image.asset(
            'assets/logo.png',
            height: 30,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: cDarkActive,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('GT',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Go Ticket Administrator',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Hotel Partner Portal',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0284C7)),
            onPressed: _loadData,
            tooltip: 'Segarkan data',
          ),
          const SizedBox(width: 4),
          // Tombol Logout Merah
          Tooltip(
            message: 'Keluar / Logout',
            child: InkWell(
              onTap: _handleLogout,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(List<(IconData, String)> tabs) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final isSel = _selectedTab == i;
          return InkWell(
            onTap: () => setState(() => _selectedTab = i),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tabs[i].$1,
                    size: 22,
                    color: isSel ? cDarkActive : const Color(0xFF64748B),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tabs[i].$2,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: isSel ? cDarkActive : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
