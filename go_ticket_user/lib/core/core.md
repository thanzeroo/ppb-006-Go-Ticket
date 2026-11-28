# Dokumentasi Lapisan Core (`lib/core/`)

Direktori `lib/core/` berisi komponen bersama yang digunakan di seluruh modul Go Ticket agar konfigurasi, model data, service backend, tema, dan komponen UI mudah dimodifikasi dari satu tempat.

---

## 1. `config/`

* **`supabase_config.dart`**
  Mengelola konfigurasi URL dan API Key Supabase secara aman dari `--dart-define` maupun `.env` (`flutter_dotenv`) tanpa menyimpan kredensial sensitif di dalam source code. Juga menyediakan `storagePublicUrl()` serta konstanta 25 nama tabel PostgreSQL Supabase.

---

## 2. `constants/`

Folder ini menyimpan parameter tetap agar penyesuaian aturan bisnis maupun tampilan cukup diubah di satu tempat:

* **`app_constants.dart`**
  Menyimpan metadata aplikasi (`appName`, `appVersion`), key penyimpanan lokal, timeout startup & jaringan (`dotenvTimeoutMs`, `supabaseInitTimeoutSeconds`, `httpTimeoutSeconds`), paginasi, aturan bisnis (`maxAdminPerHotel`, `taxAndServiceRate`, `defaultHotelFallbackPrice`, `platformCommissionPercent`), serta konfigurasi model & token AI **Tiko**.
* **`app_colors.dart`**
  Menyimpan palet warna resmi Go Ticket (brand, semantik success/error/warning/info, netral, serta latar terang/gelap).
* **`api_endpoints.dart`**
  Menyimpan daftar endpoint REST API Go Ticket (Auth, Hotel, Room, Booking, Payment, Admin).

---

## 3. `models/`

Cetak biru struktur data (*Data Models*) untuk serialisasi JSON Supabase dan transfer state antar-layar:

* **`user_model.dart`** — Profil pengguna dan role (`customer`, `adminHotel`, `frontOffice`, `maintenance`, `superAdmin`).
* **`hotel_model.dart`** — Data mitra hotel, koordinat GPS, fasilitas, rating, galeri foto, dan helper resolusi URL Storage.
* **`room_model.dart`** — Data tipe/unit kamar, status (`available`, `occupied`, `dirty`, `cleaning`, `maintenance`), tarif weekday/weekend, dan fasilitas.
* **`booking_model.dart`** — Siklus transaksi reservasi, rincian tarif/pajak, status pembayaran, check-in/out, serta payload E-Tiket QR.
* **`booking_args.dart`** — Objek argumen navigasi alur pemesanan kamar hingga pembayaran.
* **`review_model.dart`** — Ulasan, rating per kategori, lampiran foto, dan respons hotel.
* **`maintenance_ticket_model.dart`** — Tiket laporan kerusakan fasilitas, kategori (`TicketCategory`), prioritas, dan catatan teknisi.
* **`payout_model.dart`** — Data pencairan dana (*payout*) mitra hotel dan riwayat mutasi kas.
* **`hotel_admin_model.dart`** — Model pendukung Administrator Hotel (`RoomTypeData`, `StaffData`, `TransactionData`).

---

## 4. `services/`

Layanan singleton untuk orkestrasi startup, autentikasi, CRUD Supabase, dan fitur pendukung:

* **`app_initializer.dart`** — Inisialisasi startup non-blocking dengan timeout terukur (`.env`, `SupabaseService`, pemulihan sesi `AuthService`).
* **`supabase_service.dart`** — Wrapper koneksi dan query builder `SupabaseClient`.
* **`auth_service.dart`** — Login, registrasi, normalisasi ID staf, validasi status non-aktif, dan sesi lokal.
* **`hotel_service.dart`** — Pencarian & pengelolaan mitra hotel, tipe kamar, unit kamar, dan fasilitas.
* **`booking_service.dart`** — Pembuatan reservasi, sinkronisasi status booking, pembayaran, dan e-tiket.
* **`customer_data_service.dart`** — Poin loyalitas, tier membership, hotel tersimpan (`saved_hotels`), dan tamu tersimpan (`saved_guests`).
* **`review_service.dart`** — Pengambilan dan pengiriman ulasan tamu pada tabel `ulasan`.
* **`promo_service.dart`** — Pengelolaan kampanye promo dan validasi kode voucher.
* **`qris_service.dart`** — Konverter payload QRIS statis menjadi QRIS dinamis sesuai nominal Rupiah + CRC16-CCITT.
* **`maintenance_service.dart`** — CRUD tiket laporan kerusakan dan pelacakan progres perbaikan.
* **`super_admin_service.dart`** — Analitik platform, manajemen pengguna/staf lintas hotel, dan audit keuangan untuk Super Admin.
* **`hotel_operations_store.dart`** — Store sinkronisasi operasional lokal Front Office (check-out, perpanjangan, verifikasi e-tiket) dan Maintenance (antrean kebersihan, tiket).
* **`hotel_image_upload_service.dart`** — Unggah berkas gambar tunggal maupun banyak ke bucket Supabase Storage.
* **`tiko_chat_service.dart`** — Klien percakapan asisten AI **Tiko** terhubung ke Google Gemini API dengan konteks riwayat dan fallback model.

---

## 5. `network/`, `theme/`, `utils/`, & `widgets/`

* **`network/`** — `ApiClient` (pembawa header JWT & versi aplikasi) dan `ApiException` (pemetaan status HTTP ke pesan ramah pengguna).
* **`theme/`** — `AppTheme`, `HotelAdminTheme`, dan `AppTextStyles`.
* **`utils/`** — `CurrencyFormatter` (format Rupiah), `DateFormatter`, dan `StorageHelper` (`SharedPreferences`).
* **`widgets/`** — Komponen UI reusable seperti `GTCard`, `AppPaginationBar`, `AuthLogoHeader`, `CustomButton`, `CustomTextField`, `EmptyStateWidget`, `LoadingIndicator`, `UserAvatar`, `TermsAndPolicyScreen`, `TikoChatBubble`, dan `TikoChatbotScreen`.
