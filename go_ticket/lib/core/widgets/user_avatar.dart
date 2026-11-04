import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget Avatar Pengguna yang elegan dengan fallback inisial nama atau ikon default.
/// Mencegah gambar rusak/broken dari URL eksternal jika foto belum tersedia.
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final bool showVerifiedBadge;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 18,
    this.showVerifiedBadge = false,
    this.onTap,
  });

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  bool get _hasValidCustomImage {
    if (imageUrl == null) return false;
    final url = imageUrl!.trim();
    if (url.isEmpty) return false;
    if (url.contains('pravatar.cc') || url.contains('placeholder')) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;

    if (_hasValidCustomImage) {
      avatarWidget = CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE2E8F0),
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, __) {},
        child: _buildDefaultContent(),
      );
    } else {
      avatarWidget = Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00B4D8).withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: _buildDefaultContent(),
        ),
      );
    }

    if (showVerifiedBadge) {
      avatarWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: const BoxDecoration(
                  color: Color(0xFF00B4D8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: radius * 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  Widget _buildDefaultContent() {
    final initials = _initials;
    if (initials.isNotEmpty) {
      return Text(
        initials,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: radius * 0.85,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      );
    }
    return Icon(
      Icons.person_rounded,
      color: Colors.white,
      size: radius * 1.15,
    );
  }
}

