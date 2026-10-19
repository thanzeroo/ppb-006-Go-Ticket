import 'package:flutter/material.dart';
import '../administrator/administrator_dashboard_screen.dart';

export '../administrator/administrator_dashboard_screen.dart';

/// Backward-compatible alias for ExecutiveDashboardScreen -> AdministratorDashboardScreen
class ExecutiveDashboardScreen extends StatelessWidget {
  const ExecutiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdministratorDashboardScreen();
  }
}
