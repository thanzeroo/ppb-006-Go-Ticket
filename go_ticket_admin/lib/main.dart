import 'package:flutter/material.dart';

import 'apps/pihak_go_ticket/main_pihak_go_ticket.dart';
import 'core/services/app_initializer.dart';

/// Entrypoint aplikasi go_ticket_admin.
void main() async {
  await AppInitializer.init();
  runApp(const PihakGoTicketApp());
}
