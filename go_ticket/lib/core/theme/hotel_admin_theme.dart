import 'package:flutter/material.dart';

// =============================================================================
// FILE: lib/core/theme/hotel_admin_theme.dart
// RESPONSIBILITY: Design system tokens & helper widgets untuk modul Pihak Hotel.
// =============================================================================

// Color tokens untuk tema cyan/teal Administrator Hotel
const Color cLight = Color(0xFFE6FAFF);
const Color cLightActive = Color(0xFFB0F1FF);
const Color cNormal = Color(0xFF00D1FF);
const Color cDark = Color(0xFF009DBF);
const Color cDarkActive = Color(0xFF005E73);
const Color cDarker = Color(0xFF004959);

const Color adminBg = Color(0xFFF8FAFC);
const Color adminCardBorder = Color(0xFFE2E8F0);

/// Helper untuk render network image dengan placeholder & spinner
Widget buildNetworkImage(
  String url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? placeholder,
}) {
  return Image.network(
    url,
    width: width,
    height: height,
    fit: fit,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
        width: width,
        height: height,
        color: cLight,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: cNormal),
          ),
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      return placeholder ??
          Container(
            width: width,
            height: height,
            color: cDarkActive,
            child: const Icon(Icons.hotel, color: Colors.white70),
          );
    },
  );
}

/// Helper dot legend grafik
class LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const LegendDot({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
