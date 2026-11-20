import 'package:flutter/material.dart';

import 'apps/pihak_go_ticket/main_pihak_go_ticket.dart';
import 'core/services/app_initializer.dart';

/// Entrypoint khusus aplikasi Pihak Go Ticket (Super Admin Platform).
/// Jalankan dengan:
/// `flutter run -t lib/main_go_ticket.dart`
void main() async {
  await AppInitializer.init();
  runApp(const PihakGoTicketApp());
}

