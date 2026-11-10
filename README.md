# Go Ticket

Aplikasi pemesanan tiket dan manajemen layanan terpadu yang mencakup pihak Customer (User), Mitra Hotel (Hotel Partner), dan Super Admin.

## Struktur Project

Project ini menggunakan pendekatan struktur monorepo untuk mengorganisir frontend dan backend:

- `go_ticket/` - Aplikasi Flutter (Mobile & Web)
  - `lib/apps/user/` - Antarmuka dan fitur untuk Customer / Pengguna
  - `lib/apps/hotel_partner/` - Antarmuka dan fitur untuk Mitra Hotel
  - `lib/apps/superadmin_go-ticket/` - Antarmuka dan fitur untuk Super Admin
- `backend/` - Layanan Backend & API

## Memulai Aplikasi Flutter

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart SDK

### Instalasi & Menjalankan
1. Masuk ke folder aplikasi Flutter:
   ```bash
   cd go_ticket
   ```
2. Pasang dependensi:
   ```bash
   flutter pub get
   ```
3. Copy .env.example -> .eny:
   ```bash
   cp .env.example .env
   ```
4. Ubah Nilai SUPABASE_URL DAN SUPABASE_ANON_KE (Minta Ke tim)
5. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Anggota Tim
- Sulthan
- Yasmin
- Farchan
