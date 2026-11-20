import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:go_ticket_admin/apps/pihak_go_ticket/main_pihak_go_ticket.dart';

void main() {
  testWidgets('PihakGoTicketApp should render', (WidgetTester tester) async {
    await tester.pumpWidget(const PihakGoTicketApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
