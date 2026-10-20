import 'package:flutter/material.dart';

import 'screens/splash/customer_loading_screen.dart';

/// Aplikasi root untuk User/Customer.
void main() {
  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoTicket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B4D8),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const CustomerLoadingScreen(),
    );
  }
}
