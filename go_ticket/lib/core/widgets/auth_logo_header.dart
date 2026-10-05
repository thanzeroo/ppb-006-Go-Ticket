import 'package:flutter/material.dart';

/// Logo Go Ticket dalam card putih dengan efek cyan glow (bayangan bercahaya),
/// digunakan secara konsisten di semua halaman login (User, Hotel, Super Admin).
class AuthLogoHeader extends StatelessWidget {
  /// Teks opsional di bawah logo, misalnya 'HOTEL'
  final String? badgeText;

  const AuthLogoHeader({super.key, this.badgeText});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C7F2).withValues(alpha: 0.38),
                blurRadius: 30,
                spreadRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/Go_Ticket_Short_logo 1 (1).png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (badgeText != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText!,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0284C7),
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
