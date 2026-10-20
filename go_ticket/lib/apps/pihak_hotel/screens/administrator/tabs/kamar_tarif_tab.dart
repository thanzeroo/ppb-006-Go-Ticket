import 'package:flutter/material.dart';

import '../../../../../core/theme/hotel_admin_theme.dart';
import '../../../../../core/models/hotel_admin_model.dart';
import 'add_room_type_screen.dart';
import 'edit_room_type_screen.dart';

/// Tab 2: Master Kamar & Kelola Tarif Administrator
class KamarTarifTab extends StatefulWidget {
  final List<RoomTypeData> rooms;

  const KamarTarifTab({super.key, required this.rooms});

  @override
  State<KamarTarifTab> createState() => _KamarTarifTabState();
}

class _KamarTarifTabState extends State<KamarTarifTab> {
  int _categoryIndex = 0;
  final _categories = ['Semua Kamar (45)', 'Ocean View (15)', 'Private Villa (10)'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title
        const Text(
          'Kelola Master Kamar & Tarif',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        // Bright Cyan Pill Button: + Tambah Tipe Kamar Baru
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddRoomTypeScreen()),
            );
          },
          icon: const Icon(Icons.add_circle_outline, size: 16),
          label: const Text(
            '+ Tambah Tipe Kamar Baru',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: cNormal,
            foregroundColor: const Color(0xFF00383D),
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
        ),

        const SizedBox(height: 12),
        // Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_categories.length, (i) {
              final sel = _categoryIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _categoryIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? cDarkActive : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _categories[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),
        // Room Cards
        ...widget.rooms.map((r) => _buildRoomCard(r)),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRoomCard(RoomTypeData room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: adminCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Image Header
          SizedBox(
            height: 140,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                buildNetworkImage(room.imageUrl),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              room.badge,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: cDarker),
                            ),
                          ),
                          if (room.secondaryBadge != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cNormal,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                room.secondaryBadge!,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF00383D)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            room.sub,
                            style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quota Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.hotel, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text('${room.totalUnit} Unit Total', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                      ],
                    ),
                    Text(
                      '${room.terjual} Terjual (${room.occupancy}% Okupansi)',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: cDarkActive),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.80,
                    minHeight: 5,
                    backgroundColor: Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation(cDarkActive),
                  ),
                ),

                const SizedBox(height: 12),
                // Price Section
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Weekday (Sen – Kam)', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                            const SizedBox(height: 2),
                            Text(room.weekdayPrice, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            const Text('per malam', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Weekend (Jum – Min)', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                            const SizedBox(height: 2),
                            Text(room.weekendPrice, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: cDarkActive)),
                            Text(room.weekendNote, style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                // Amenities Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: room.amenities.map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(a, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.photo_library_outlined, size: 14),
                        label: Text('Galeri Foto (${room.photoCount})'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: cLight,
                          foregroundColor: cDarkActive,
                          side: const BorderSide(color: cLightActive),
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditRoomTypeScreen(
                                roomName: room.name,
                                category: room.badge,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text('Edit Kamar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cDarkActive,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
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
