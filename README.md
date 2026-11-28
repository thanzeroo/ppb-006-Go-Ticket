# Go Ticket

Aplikasi **PPB** bertema pemesanan tiket hotel dan manajemen layanan penginapan terpadu yang menghubungkan **Pelanggan (User)**, **Mitra Pengelola Hotel**, dan **Super Admin Platform** dalam satu ekosistem berbasis Flutter + Supabase + Gemini AI.

---

## Anggota Tim
- **Sulthan**
- **Yasmin**
- **Farchan**

---

## Arsitektur Monorepo

Repository ini terdiri dari 3 aplikasi Flutter mandiri (versi `2.0.0+1`) dengan struktur `lib/core/` yang seragam agar konfigurasi, model data, tema, dan service mudah dipelihara dan dimodifikasi:

| Folder | Nama Paket | Sasaran Pengguna | Fitur Utama |
| :--- | :--- | :--- | :--- |
| `go_ticket_user/` | `go_ticket_user` | **Customer / Tamu** | Eksplorasi & filter hotel, kalender interaktif, reservasi kamar, pembayaran QRIS dinamis, E-Tiket QR, riwayat pesanan, ulasan pasca check-out, hotel & tamu tersimpan, voucher promo, dan asisten AI **Tiko**. |
| `go_ticket_hotel/` | `go_ticket_hotel` | **Mitra Hotel** (`Administrator`, `Front Office`, `Maintenance`) | **Administrator**: dashboard pendapatan/okupansi, manajemen tipe kamar & tarif, pengelolaan staf & shift (maks. 3 admin per hotel), mutasi & pengajuan payout. **Front Office**: dashboard kedatangan/keberangkatan, verifikasi booking, scanner QR e-tiket, check-in, perpanjangan menginap, & check-out. **Maintenance**: antrean kebersihan & sanitasi kamar, tiket laporan kerusakan + bukti foto. |
| `go_ticket_admin/` | `go_ticket_admin` | **Super Admin Platform** | Ringkasan analitik platform, pendaftaran & pengelolaan mitra hotel beserta tipe kamar, manajemen pengguna & staf, manajemen kampanye promo, serta pemantauan keuangan & pencairan dana mitra. |

---

## Struktur Modul Inti (`lib/core/`)

Setiap aplikasi memiliki lapisan `lib/core/` dengan peran terpisah sehingga perubahan konfigurasi cukup dilakukan di satu lokasi:

- `lib/core/config/supabase_config.dart` — Pembaca kredensial Supabase (`--dart-define` / `.env`), helper URL Supabase Storage, serta konstanta nama 25 tabel database.
- `lib/core/constants/app_constants.dart` — Pusat parameter aplikasi yang mudah diubah: `appVersion`, timeout startup & HTTP, ukuran paginasi, batas malam/tamu, `maxAdminPerHotel`, `taxAndServiceRate`, `defaultHotelFallbackPrice`, hingga konfigurasi model & token AI **Tiko**.
- `lib/core/constants/app_colors.dart` — Palet warna resmi brand, semantik, dan latar belakang.
- `lib/core/constants/api_endpoints.dart` — Definisi endpoint REST API & skema path backend.
- `lib/core/models/` — Model data terstruktur (`UserModel`, `HotelModel`, `RoomModel`, `BookingModel`, `BookingArgs`, `ReviewModel`, `PayoutModel`, `MaintenanceTicketModel`, `HotelAdminModel`).
- `lib/core/services/` — Lapisan akses data & logika bisnis (`AppInitializer`, `SupabaseService`, `AuthService`, `HotelService`, `BookingService`, `CustomerDataService`, `ReviewService`, `PromoService`, `QrisService`, `MaintenanceService`, `SuperAdminService`, `HotelOperationsStore`, `HotelImageUploadService`, `TikoChatService`).
- `lib/core/network/` — Client HTTP (`ApiClient`) dan pemetaan error (`ApiException`).
- `lib/core/theme/` & `lib/core/utils/` — Tema UI (`AppTheme`, `HotelAdminTheme`, `AppTextStyles`) dan utilitas (`CurrencyFormatter`, `DateFormatter`, `StorageHelper`).
- `lib/core/widgets/` — Komponen UI reusable (`GTCard`, `AppPaginationBar`, `CustomButton`, `CustomTextField`, `TikoChatBubble`, `TikoChatbotScreen`, `UserAvatar`, `TermsAndPolicyScreen`, dll.).

Dokumentasi rincian setiap file di dalam `lib/core/` tersedia di [`go_ticket_user/lib/core/core.md`](go_ticket_user/lib/core/core.md).

---

## Keamanan & Manajemen Kredensial

- **Tanpa Hardcoded Secret**: Tidak ada URL proyek sensitif, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_ANON_KEY`, maupun `GEMINI_API_KEY` yang ditanam langsung pada kode Dart.
- **Konfigurasi Environment**: Semua kredensial dibaca lewat `--dart-define` saat build atau dari file `.env` (via `flutter_dotenv`) yang diabaikan oleh `.gitignore`.
- **Template `.env.example`**: Setiap folder aplikasi menyediakan `.env.example` yang mendokumentasikan seluruh variabel wajib.

---

## Prasyarat & Cara Menjalankan

### Prasyarat
- **Flutter SDK** (Dart SDK `^3.12.2`)
- **Android SDK / Emulator / Perangkat fisik** (untuk build atau debug Android)

### Setup Environment
Salin `.env.example` menjadi `.env` di **masing-masing** folder aplikasi yang ingin dijalankan (`go_ticket_user/`, `go_ticket_hotel/`, `go_ticket_admin/`):

```bash
cp go_ticket_user/.env.example go_ticket_user/.env
cp go_ticket_hotel/.env.example go_ticket_hotel/.env
cp go_ticket_admin/.env.example go_ticket_admin/.env
```

Isi variabel pada setiap file `.env`:
```env
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
SUPABASE_SERVICE_ROLE_KEY=<opsional-khusus-internal>
GEMINI_API_KEY=<gemini-api-key>
```

### Perintah Pengembangan, Analisis, Pengujian, & Build

Jalankan di masing-masing direktori aplikasi (`go_ticket_user`, `go_ticket_hotel`, atau `go_ticket_admin`):

```bash
# 1. Pasang dependensi
flutter pub get

# 2. Jalankan analisis statis (harus 0 issues)
flutter analyze

# 3. Jalankan unit/widget test
flutter test

# 4. Jalankan aplikasi di perangkat/emulator
flutter run

# 5. Build APK release
flutter build apk --release
```
