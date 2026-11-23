import 'package:flutter/material.dart';

import 'apps/pihak_go_ticket/main_pihak_go_ticket.dart';
import 'core/services/app_initializer.dart';

/// Entrypoint aplikasi go_ticket_admin.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppInitializer.init();
  } catch (e) {
    debugPrint('⚠️ [main] Inisialisasi mengalami kendala: $e');
  }
  runApp(const PihakGoTicketApp());
}
