// =============================================================================
// FILE: lib/core/widgets/tiko_chat_bubble.dart
// RESPONSIBILITY: Floating Action Button (FAB) berbentuk bubble di kanan bawah
//                 untuk membuka chatbot Tiko AI. Widget ini didesain agar
//                 TIDAK menimpa navbar (menggunakan Positioned di atas navbar).
// =============================================================================

import 'package:flutter/material.dart';

import 'tiko_chatbot_screen.dart';

/// Widget bubble chat Tiko yang bisa di-wrap di Stack bersama konten utama.
/// Bubble akan muncul di kanan bawah TANPA menimpa BottomNavigationBar.
///
/// Cara pakai:
/// ```dart
/// Stack(
///   children: [
///     Scaffold(...), // konten utama dengan bottomNav
///     const TikoChatBubble(),
///   ],
/// )
/// ```
///
/// Atau langsung sebagai `floatingActionButton` di Scaffold.
class TikoChatBubble extends StatefulWidget {
  /// Jarak dari bawah layar. Default 90 agar di atas navbar.
  final double bottomOffset;

  const TikoChatBubble({
    super.key,
    this.bottomOffset = 90,
  });

  @override
  State<TikoChatBubble> createState() => _TikoChatBubbleState();
}

class _TikoChatBubbleState extends State<TikoChatBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openChat() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TikoChatbotScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: widget.bottomOffset,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: _openChat,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00B4D8),
                  Color(0xFF0077B6),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B4D8).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFF0077B6).withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

