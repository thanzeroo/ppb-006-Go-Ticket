import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_ticket/apps/hotel_partner/screens/auth/staff_login_screen.dart';
import 'package:go_ticket/apps/superadmin_go-ticket/screens/auth/super_admin_login_screen.dart';
import 'package:go_ticket/apps/user/screens/auth/customer_login_screen.dart';
import 'package:go_ticket/apps/user/screens/splash/customer_loading_screen.dart';
import 'package:go_ticket/main.dart';

void main() {
  testWidgets('Portal App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const GoTicketApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('CustomerLoadingScreen should render logo on dark background', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CustomerLoadingScreen(),
    ));

    expect(find.byType(CustomerLoadingScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Image), findsWidgets);

    // Majukan waktu agar timer selesai
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('CustomerLoginScreen should render and toggle between Masuk and Daftar Akun', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CustomerLoginScreen(),
    ));

    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Daftar Akun'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);

    // Beralih ke tab Daftar Akun
    await tester.tap(find.text('Daftar Akun'));
    await tester.pumpAndSettle();

    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Nomor Telepon'), findsOneWidget);
    expect(find.text('Buat Akun'), findsOneWidget);
  });

  testWidgets('StaffLoginScreen should toggle between Maintenance, Staff, and Administrator', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: StaffLoginScreen(initialRole: 1),
    ));

    expect(find.text('Portal Operasional Staf'), findsOneWidget);
    expect(find.text('Shift Pagi'), findsOneWidget);

    // Klik Maintenance
    await tester.tap(find.text('Maintenance'));
    await tester.pumpAndSettle();
    expect(find.text('Portal Operasional Maintenance'), findsOneWidget);

    // Klik Administrator
    await tester.tap(find.text('Administrator'));
    await tester.pumpAndSettle();
    expect(find.text('Portal Administrator Hotel'), findsOneWidget);
  });

  testWidgets('SuperAdminLoginScreen should render admin authorization portal', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SuperAdminLoginScreen(),
    ));

    expect(find.text('LOGIN ADMIN'), findsOneWidget);
    expect(find.textContaining('TINGKAT OTORISASI LEVEL 1'), findsOneWidget);
    expect(find.text('Otorisasi & Buka Dashboard'), findsOneWidget);
  });
}
