// =============================================================================
// FILE: lib/apps/customer/screens/booking/interactive_calendar_screen.dart
// RESPONSIBILITY: Halaman kalender interaktif untuk memilih tanggal
// check-in dan check-out. Menampilkan:
// - Kalender bulanan dengan navigasi bulan
// - Highlight tanggal yang dipilih (range check-in hingga check-out)
// - Tandai tanggal yang tidak tersedia (sudah di-booking)
// - Harga per malam per tanggal (jika ada variasi harga)
// - Tombol konfirmasi dengan ringkasan pilihan
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';

/// Kalender interaktif untuk pemilihan tanggal check-in dan check-out.
class InteractiveCalendarScreen extends StatefulWidget {
  final dynamic arguments;

  const InteractiveCalendarScreen({super.key, this.arguments});

  @override
  State<InteractiveCalendarScreen> createState() =>
      _InteractiveCalendarScreenState();
}

class _InteractiveCalendarScreenState
    extends State<InteractiveCalendarScreen> {
  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  /// Bulan yang sedang ditampilkan di kalender
  DateTime _displayedMonth = DateTime.now();

  /// Tanggal check-in yang dipilih
  DateTime? _checkIn;

  /// Tanggal check-out yang dipilih
  DateTime? _checkOut;

  /// Step pemilihan — 0: pilih check-in, 1: pilih check-out
  int _selectionStep = 0;

  /// Tanggal-tanggal yang tidak tersedia (dummy — nanti dari API)
  final Set<DateTime> _unavailableDates = {
    DateTime.now().add(const Duration(days: 3)),
    DateTime.now().add(const Duration(days: 4)),
    DateTime.now().add(const Duration(days: 10)),
  };

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  void _onDateTap(DateTime date) {
    // Jangan proses tanggal yang sudah lewat atau tidak tersedia
    if (_isDateUnavailable(date)) return;

    setState(() {
      if (_selectionStep == 0) {
        // Pilih check-in
        _checkIn = date;
        _checkOut = null;
        _selectionStep = 1;
      } else {
        // Pilih check-out
        if (date.isBefore(_checkIn!) || date.isAtSameMomentAs(_checkIn!)) {
          // Jika tap tanggal sebelum check-in, reset dan pilih sebagai check-in baru
          _checkIn = date;
          _checkOut = null;
        } else {
          _checkOut = date;
          _selectionStep = 0;
        }
      }
    });
  }

  bool _isDateUnavailable(DateTime date) {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final dateNorm = DateTime(date.year, date.month, date.day);

    if (dateNorm.isBefore(todayNorm)) return true;

    return _unavailableDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  bool _isInRange(DateTime date) {
    if (_checkIn == null || _checkOut == null) return false;
    return date.isAfter(_checkIn!) && date.isBefore(_checkOut!);
  }

  bool _isCheckIn(DateTime date) {
    if (_checkIn == null) return false;
    return date.year == _checkIn!.year &&
        date.month == _checkIn!.month &&
        date.day == _checkIn!.day;
  }

  bool _isCheckOut(DateTime date) {
    if (_checkOut == null) return false;
    return date.year == _checkOut!.year &&
        date.month == _checkOut!.month &&
        date.day == _checkOut!.day;
  }

  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  void _confirmSelection() {
    if (_checkIn == null || _checkOut == null) return;

    final nights = DateFormatter.calculateNights(_checkIn!, _checkOut!);
    Navigator.pop(context, {
      'checkIn': _checkIn,
      'checkOut': _checkOut,
      'nights': nights,
    });
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pilih Tanggal'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _checkIn = null;
                _checkOut = null;
                _selectionStep = 0;
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Panduan pemilihan
          _buildSelectionGuide(),

          // Kalender
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildCalendarHeader(),
                  const SizedBox(height: 12),
                  _buildWeekDayLabels(),
                  const SizedBox(height: 8),
                  _buildCalendarGrid(),
                  const SizedBox(height: 24),
                  _buildLegend(),
                ],
              ),
            ),
          ),

          // Tombol konfirmasi
          _buildConfirmBar(),
        ],
      ),
    );
  }

  Widget _buildSelectionGuide() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildDateChip(
              'Check-In',
              _checkIn != null ? DateFormatter.toDisplayDate(_checkIn!) : 'Belum dipilih',
              _selectionStep == 0,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_rounded,
              color: AppColors.grey400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDateChip(
              'Check-Out',
              _checkOut != null ? DateFormatter.toDisplayDate(_checkOut!) : 'Belum dipilih',
              _selectionStep == 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, String value, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.grey300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.white.withValues(alpha: 0.8) : AppColors.textHint,
              )),
          Text(value,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.white : AppColors.textPrimaryLight,
              )),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _goToPreviousMonth,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Text(
          DateFormatter.toMonthYear(_displayedMonth),
          style: AppTextStyles.titleLarge,
        ),
        IconButton(
          onPressed: _goToNextMonth,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  Widget _buildWeekDayLabels() {
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return Row(
      children: days.map((day) {
        return Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: (day == 'Min' || day == 'Sab')
                  ? AppColors.primary
                  : AppColors.textSecondaryLight,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0 = Minggu

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: startWeekday + daysInMonth,
      itemBuilder: (context, index) {
        if (index < startWeekday) return const SizedBox.shrink();

        final dayNum = index - startWeekday + 1;
        final date = DateTime(_displayedMonth.year, _displayedMonth.month, dayNum);

        return _buildDayCell(date);
      },
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isUnavailable = _isDateUnavailable(date);
    final isCheckIn = _isCheckIn(date);
    final isCheckOut = _isCheckOut(date);
    final isInRange = _isInRange(date);
    final isToday = DateFormatter.isToday(date);
    final isWeekend = DateFormatter.isWeekend(date);

    Color? bgColor;
    Color textColor = AppColors.textPrimaryLight;

    if (isCheckIn || isCheckOut) {
      bgColor = AppColors.primary;
      textColor = AppColors.white;
    } else if (isInRange) {
      bgColor = AppColors.primary.withValues(alpha: 0.12);
      textColor = AppColors.primary;
    } else if (isUnavailable) {
      textColor = AppColors.grey300;
    } else if (isWeekend) {
      textColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: isUnavailable ? null : () => _onDateTap(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isCheckIn && !isCheckOut
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: AppTextStyles.labelSmall.copyWith(
              color: isUnavailable ? AppColors.grey300 : textColor,
              fontWeight: (isCheckIn || isCheckOut) ? FontWeight.w700 : null,
              decoration: isUnavailable ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(AppColors.primary, 'Check-in/out'),
        const SizedBox(width: 16),
        _buildLegendItem(
            AppColors.primary.withValues(alpha: 0.2), 'Rentang menginap'),
        const SizedBox(width: 16),
        _buildLegendItem(AppColors.grey300, 'Tidak tersedia'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildConfirmBar() {
    final hasSelection = _checkIn != null && _checkOut != null;
    final nights = hasSelection
        ? DateFormatter.calculateNights(_checkIn!, _checkOut!)
        : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GoTicketButton(
        label: hasSelection
            ? 'Konfirmasi — $nights Malam'
            : 'Pilih Tanggal Check-in',
        onPressed: hasSelection ? _confirmSelection : null,
        icon: Icons.check_circle_outline_rounded,
      ),
    );
  }
}
