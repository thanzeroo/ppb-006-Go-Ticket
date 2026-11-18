import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatter otomatis pemisah ribuan dengan titik (contoh: 1500000 -> 1.500.000).
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Bersihkan karakter non-digit
    final cleanDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final number = int.tryParse(cleanDigits);
    if (number == null) return oldValue;

    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Format angka integer / double ke string titik ribuan (mis. 1500000 -> "1.500.000")
  static String format(num? value) {
    if (value == null) return '0';
    return _formatter.format(value.round());
  }

  /// Parse string berformat titik ribuan kembali ke double (mis. "1.500.000" -> 1500000.0)
  static double parse(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(clean) ?? 0.0;
  }
}

/// Helper untuk memilih jam menggunakan showTimePicker() bawaan dengan tampilan jam bulat
Future<void> showRoundTimePicker({
  required BuildContext context,
  required TextEditingController controller,
  String suffix = ' WIB',
}) async {
  TimeOfDay initial = const TimeOfDay(hour: 14, minute: 0);

  // Parse jam dari controller jika ada
  final match = RegExp(r'\b(\d{1,2}):(\d{2})\b').firstMatch(controller.text);
  if (match != null) {
    final h = int.tryParse(match.group(1)!) ?? 14;
    final m = int.tryParse(match.group(2)!) ?? 0;
    initial = TimeOfDay(hour: h, minute: m);
  }

  final picked = await showTimePicker(
    context: context,
    initialTime: initial,
    initialEntryMode: TimePickerEntryMode.dial, // Tampilan pemilih jam bulat
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF007A94),
            onPrimary: Colors.white,
            onSurface: Color(0xFF0F172A),
          ),
          timePickerTheme: TimePickerThemeData(
            dialHandColor: const Color(0xFF007A94),
            dialBackgroundColor: const Color(0xFFF1F5F9),
            hourMinuteColor: const Color(0xFFE0F7FA),
            hourMinuteTextColor: const Color(0xFF00758F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    final h = picked.hour.toString().padLeft(2, '0');
    final m = picked.minute.toString().padLeft(2, '0');
    controller.text = '$h:$m$suffix';
  }
}

