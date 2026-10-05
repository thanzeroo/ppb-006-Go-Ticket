// =============================================================================
// FILE: lib/apps/hotel_partner/screens/admin_hotel/room_pricing_screen.dart
// RESPONSIBILITY: Halaman pengaturan harga kamar oleh Admin Hotel.
// Admin dapat mengatur:
// - Harga normal (weekday)
// - Harga akhir pekan (weekend)
// - Harga peak season (Lebaran, Natal, dll.)
// - Diskon persen per tipe kamar
// - Periode berlakunya harga khusus
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

/// Halaman pengaturan harga dan diskon kamar.
class RoomPricingScreen extends StatefulWidget {
  const RoomPricingScreen({super.key});

  @override
  State<RoomPricingScreen> createState() => _RoomPricingScreenState();
}

class _RoomPricingScreenState extends State<RoomPricingScreen> {
  // Dummy data kamar — di produksi dari RoomRepository
  final List<_RoomPricingData> _rooms = [
    _RoomPricingData(
      typeName: 'Standard Room',
      weekdayPrice: 350000,
      weekendPrice: 450000,
      discountPercent: 0,
    ),
    _RoomPricingData(
      typeName: 'Deluxe Room',
      weekdayPrice: 550000,
      weekendPrice: 700000,
      discountPercent: 10,
    ),
    _RoomPricingData(
      typeName: 'Suite Room',
      weekdayPrice: 900000,
      weekendPrice: 1200000,
      discountPercent: 0,
    ),
  ];

  void _showEditPriceDialog(int roomIndex) {
    final room = _rooms[roomIndex];
    final weekdayCtrl = TextEditingController(
        text: room.weekdayPrice.toString());
    final weekendCtrl = TextEditingController(
        text: room.weekendPrice.toString());
    final discountCtrl = TextEditingController(
        text: room.discountPercent.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Harga — ${room.typeName}'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GoTicketTextField(
                label: 'Harga Weekday (per malam)',
                hint: '350000',
                controller: weekdayCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 12),
              GoTicketTextField(
                label: 'Harga Weekend (per malam)',
                hint: '450000',
                controller: weekendCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: Icons.weekend_outlined,
              ),
              const SizedBox(height: 12),
              GoTicketTextField(
                label: 'Diskon (%)',
                hint: '0 - 50',
                controller: discountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: Icons.local_offer_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          GoTicketButton(
            label: 'Simpan',
            onPressed: () {
              setState(() {
                _rooms[roomIndex] = _RoomPricingData(
                  typeName: room.typeName,
                  weekdayPrice: int.tryParse(weekdayCtrl.text) ?? room.weekdayPrice,
                  weekendPrice: int.tryParse(weekendCtrl.text) ?? room.weekendPrice,
                  discountPercent: int.tryParse(discountCtrl.text) ?? 0,
                );
              });
              // TODO: Integrasikan dengan RoomRepository.updateRoom()
              Navigator.pop(ctx);
            },
            width: 100,
            height: 40,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Harga & Diskon Kamar')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _buildRoomPriceCard(index),
      ),
    );
  }

  Widget _buildRoomPriceCard(int index) {
    final room = _rooms[index];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: nama tipe kamar + tombol edit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(room.typeName, style: AppTextStyles.titleMedium),
              IconButton(
                onPressed: () => _showEditPriceDialog(index),
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.primary, size: 20),
              ),
            ],
          ),
          const Divider(color: AppColors.grey100),
          const SizedBox(height: 8),

          // Harga rows
          _buildPriceRow('Weekday', room.weekdayPrice),
          _buildPriceRow('Weekend', room.weekendPrice),

          if (room.discountPercent > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_offer_rounded,
                      size: 14, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text('Diskon ${room.discountPercent}% aktif',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.success)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, int price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(CurrencyFormatter.toRupiah(price),
              style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}

class _RoomPricingData {
  final String typeName;
  final int weekdayPrice;
  final int weekendPrice;
  final int discountPercent;

  const _RoomPricingData({
    required this.typeName,
    required this.weekdayPrice,
    required this.weekendPrice,
    required this.discountPercent,
  });
}
