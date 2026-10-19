import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:go_ticket/apps/pihak_hotel/screens/auth/staff_login_screen.dart';
import 'package:go_ticket/apps/pihak_hotel/screens/splash/hotel_splash_screen.dart';
import 'package:go_ticket/apps/pihak_go_ticket/screens/auth/admin_login_screen.dart';
import 'package:go_ticket/apps/pihak_go_ticket/screens/splash/admin_splash_screen.dart';
import 'package:go_ticket/apps/pihak_user/screens/auth/customer_login_screen.dart';
import 'package:go_ticket/apps/pihak_user/screens/splash/customer_loading_screen.dart';
import 'package:go_ticket/main.dart';

void main() {
  testWidgets('Portal App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const GoTicketApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('CustomerLoadingScreen should render', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CustomerLoadingScreen(),
    ));

    expect(find.byType(CustomerLoadingScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('HotelSplashScreen should render', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HotelSplashScreen(),
    ));

    expect(find.byType(HotelSplashScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('AdminSplashScreen should render', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AdminSplashScreen(),
    ));

    expect(find.byType(AdminSplashScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('CustomerLoginScreen should render login & register tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CustomerLoginScreen(),
    ));

    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Daftar Akun'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);

    await tester.tap(find.text('Daftar Akun'));
    await tester.pumpAndSettle();

    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Nomor Telepon'), findsOneWidget);
    expect(find.text('Buat Akun'), findsOneWidget);

    // Scroll ke tombol "Buat Akun" dan klik
    await tester.ensureVisible(find.text('Buat Akun'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat Akun'));
    await tester.pumpAndSettle();

    expect(find.text('Syarat & Ketentuan'), findsOneWidget);
    expect(find.text('Hotel Policies'), findsOneWidget);
    expect(find.text('Kebijakan Berlaku Aktif'), findsOneWidget);
    expect(find.text('Setuju & Lanjutkan'), findsOneWidget);

    // Klik "Setuju & Lanjutkan" balik lagi ke login utama
    await tester.tap(find.text('Setuju & Lanjutkan'));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Akun'), findsOneWidget);
  });

  testWidgets('StaffLoginScreen should render role selector', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: StaffLoginScreen(),
    ));

    expect(find.text('Portal Operasional Staf'), findsOneWidget);
    expect(find.text('Staf'), findsNWidgets(2)); // Tab utama dan Sub-role
    expect(find.text('Maintenance'), findsOneWidget);
    expect(find.text('Administrator'), findsOneWidget);
    expect(find.text('Pilih Shift Tugas'), findsOneWidget);

    // Beralih ke tab Administrator
    await tester.tap(find.text('Administrator'));
    await tester.pumpAndSettle();

    expect(find.text('Portal Administrator Hotel'), findsOneWidget);
    expect(find.text('PIN Otorisasi Keuangan 6-Digit'), findsOneWidget);
  });

  testWidgets('AdminLoginScreen should render', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AdminLoginScreen(),
    ));

    expect(find.text('LOGIN ADMIN'), findsOneWidget);
    expect(find.text('Email / ID Super Admin'), findsOneWidget);
    expect(find.text('Otorisasi & Buka Dashboard'), findsOneWidget);
    expect(find.text('AUDIT TRAIL KEAMANAN AKTIF'), findsOneWidget);
  });
}
