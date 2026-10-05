// =============================================================================
// FILE: lib/apps/hotel_partner/screens/auth/admin_hotel_login_screen.dart
// RESPONSIBILITY: Entry point login Administrator Hotel.
// Membuka antarmuka login hotel dengan tab Administrator terpilih secara default.
// =============================================================================

import 'package:flutter/material.dart';
import 'staff_login_screen.dart';

class AdminHotelLoginScreen extends StatelessWidget {
  const AdminHotelLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaffLoginScreen(initialRole: 2);
  }
}
