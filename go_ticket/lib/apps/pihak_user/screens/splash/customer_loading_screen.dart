import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../router/customer_router.dart';

/// Splash/Loading Screen untuk User/Customer dengan logo Go Ticket.
class CustomerLoadingScreen extends StatefulWidget {
  const CustomerLoadingScreen({super.key});

  @override
  State<CustomerLoadingScreen> createState() => _CustomerLoadingScreenState();
}

class _CustomerLoadingScreenState extends State<CustomerLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );
    _animController.forward();

    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, CustomerRouter.login);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF16272F),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'assets/logo.png',
              width: 220,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 72,
                    color: Color(0xFF00C2FF),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'GO TICKET',
                    style: TextStyle(
                      color: Color(0xFF00C2FF),
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
