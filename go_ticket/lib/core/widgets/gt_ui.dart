import 'package:flutter/material.dart';

/// Warna & helper UI bersama untuk halaman alur pemesanan Go Ticket (sesuai Figma).
class GT {
  GT._();
  static const primary = Color(0xFF00C7F2);
  static const teal = Color(0xFF00677F);
  static const ink = Color(0xFF0F172A);
  static const body = Color(0xFF475569);
  static const muted = Color(0xFF64748B);
  static const bg = Color(0xFFF6F7FC);
  static const soft = Color(0xFFEDEFFF);
  static const sky = Color(0xFFCFF1FB);
  static const green = Color(0xFF16A34A);
  static const red = Color(0xFFDC2626);
}

/// Format rupiah: 1700000 -> "Rp 1.700.000"
String rp(int v) {
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}Rp $b';
}

/// AppBar: [<-] [logo] Judul ........ [avatar]
class GTAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  const GTAppBar({super.key, required this.title, this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0.5,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              const SizedBox(width: 4),
              if (showBack)
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: GT.teal),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              else
                const SizedBox(width: 12),
              Image.asset(
                'assets/logo.png',
                height: 28,
                errorBuilder: (_, __, ___) => const Text('GO',
                    style: TextStyle(
                        color: GT.primary, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: GT.ink,
                  ),
                ),
              ),
              const CircleAvatar(
                radius: 17,
                backgroundColor: GT.sky,
                child: Icon(Icons.person, color: GT.teal, size: 20),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu putih rounded dengan shadow halus.
class GTCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color color;
  const GTCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 14),
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Tombol utama cyan berbentuk pill.
class GTButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? trailing;
  final IconData? leading;
  final double height;
  final Color color;
  final Color textColor;
  const GTButton({
    super.key,
    required this.label,
    required this.onTap,
    this.trailing,
    this.leading,
    this.height = 52,
    this.color = GT.primary,
    this.textColor = GT.ink,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: GT.soft,
          foregroundColor: textColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Icon(leading, size: 18, color: textColor),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Icon(trailing, size: 18, color: textColor),
            ],
          ],
        ),
      ),
    );
  }
}

/// Gambar dari network dengan placeholder jika gagal dimuat.
class GTImage extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;
  final double radius;
  const GTImage(this.url,
      {super.key, this.height, this.width, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          width: width,
          color: GT.sky,
          child: const Icon(Icons.hotel_rounded, color: GT.teal, size: 36),
        ),
        loadingBuilder: (c, child, p) => p == null
            ? child
            : Container(height: height, width: width, color: GT.soft),
      ),
    );
  }
}

/// Chip kecil (fasilitas, badge).
class GTChip extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color bg;
  final Color fg;
  const GTChip(this.text,
      {super.key,
      this.icon,
      this.bg = GT.soft,
      this.fg = GT.teal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bar bawah (total + tombol aksi) yang menempel di bawah layar.
class GTBottomBar extends StatelessWidget {
  final Widget child;
  const GTBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}
