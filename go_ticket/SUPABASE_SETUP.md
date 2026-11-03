# Panduan Integrasi Supabase Backend Go Ticket (Database Aktif)

File konfigurasi utama terletak di:
👉 `lib/core/config/supabase_config.dart`

Koneksi database telah **diselaraskan 100%** dengan database Supabase proyek Anda (`yujbnwaapualgliixsmm`).

---

## 1. Status Konfigurasi Aktif

- **Project URL:** `https://yujbnwaapualgliixsmm.supabase.co`
- **Active Key:** Service Role Key (Bypass RLS saat development agar semua data langsung terbaca di aplikasi).
- **Anon Public Key:** Tersedia di `SupabaseConfig.supabaseAnonKey`.

---

## 2. Struktur Tabel Database Aktual (25 Tabel)

Database Supabase Anda memiliki 25 tabel yang telah dipetakan secara presisi ke dalam Data Models dan Service Layer Flutter:

| No | Nama Tabel di Supabase | Model / Service Terkait | Deskripsi |
|---|---|---|---|
| 1 | `users` | `UserModel` / `AuthService` | Akun pelanggan (Customer), nama, email, no HP, tier, poin |
| 2 | `staf_hotel` | `UserModel` / `AuthService` | Akun staf hotel (Front Office, Maintenance, Admin Hotel) |
| 3 | `super_admin` | `UserModel` / `AuthService` | Akun administrator platform Go Ticket |
| 4 | `mitra_penginapan` | `HotelModel` / `HotelService` | Daftar hotel mitra (Aruna Stay, Puspa Inn, Nusa Residence, dll.) |
| 5 | `tipe_kamar` | `RoomModel` / `HotelService` | Tipe kamar (Standard, Superior, Deluxe, Suite, harga dasar/weekend) |
| 6 | `kamar` | `RoomModel` / `HotelService` | Unit nomor kamar fisik, lantai, dan status (tersedia/terisi/kotor) |
| 7 | `ketersediaan_kamar` | `HotelService` | Kuota dan kalender ketersediaan kamar harian |
| 8 | `harga_khusus_kamar` | `HotelService` | Tarif dinamis / diskon tanggal khusus |
| 9 | `fasilitas_properti` | `HotelModel` | Fasilitas umum hotel (WiFi, Kolam Renang, Parkir, dll.) |
| 10 | `booking` | `BookingModel` / `BookingService` | Transaksi reservasi tiket/kamar (check-in, check-out, tamu, total bayar) |
| 11 | `pembayaran` | `BookingService` | Mutasi transaksi pembayaran tamu (metode, nominal, status) |
| 12 | `verifikasi_booking` | `BookingService` | Log persetujuan & verifikasi pemesanan oleh staf Front Office |
| 13 | `check_in` | `BookingService` | Log kedatangan dan check-in tamu (kunci RFID, waktu aktual) |
| 14 | `check_out` | `BookingService` | Log kepulangan tamu, pengembalian deposit, status turnover |
| 15 | `eticket` | `BookingService` | E-Tiket resmi dengan nomor tiket unik & token QR Code |
| 16 | `kampanye_promo` | `PromoService` | Daftar voucher promo aktif (GT202601, diskon, plafon, kuota) |
| 17 | `promo_kamar` | `PromoService` | Pemetaan promo ke tipe kamar tertentu |
| 18 | `laporan_kebersihan` | `MaintenanceService` | Tugas & checklist kebersihan kamar oleh tim Housekeeping |
| 19 | `laporan_kerusakan` | `MaintenanceService` | Tiket kerusakan fasilitas, tingkat prioritas, tindakan perbaikan |
| 20 | `monitoring_dana` | `PayoutModel` / `SuperAdminService` | Pengajuan dan audit pencairan dana (payout) mitra hotel |
| 21 | `ulasan` | `ReviewModel` | Rating bintang, ulasan kepuasan tamu, dan balasan manajemen hotel |
| 22 | `saved_hotels` | `HotelService` | Daftar hotel yang disimpan/difavoritkan pengguna |
| 23 | `saved_guests` | `AuthService` | Data tamu tersimpan untuk pengisian form instan |
| 24 | `notifikasi` | `NotificationService` | Notifikasi transaksi, promo, dan sistem |
| 25 | `audit_log_sistem` | `SuperAdminService` | Rekam jejak aktivitas admin platform |

---

## 3. Opsional: SQL Policy Jika Ingin Menggunakan Anon Key

Jika kelak Anda ingin beralih dari Service Role Key ke **Anon Key**, jalankan perintah SQL berikut di **Supabase SQL Editor** agar tabel-tabel publik dapat dibaca oleh anonymous user:

```sql
-- Berikan izin baca publik untuk tabel eksplorasi:
ALTER TABLE public.mitra_penginapan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Penginapan" ON public.mitra_penginapan FOR SELECT USING (true);

ALTER TABLE public.tipe_kamar ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Tipe Kamar" ON public.tipe_kamar FOR SELECT USING (true);

ALTER TABLE public.kamar ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Kamar" ON public.kamar FOR SELECT USING (true);

ALTER TABLE public.fasilitas_properti ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Fasilitas" ON public.fasilitas_properti FOR SELECT USING (true);

ALTER TABLE public.kampanye_promo ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Promos" ON public.kampanye_promo FOR SELECT USING (true);
```

---

## 4. Alur Kerja Aplikasi (Testing)

1. **Jalankan Aplikasi:**
   ```bash
   cd go_ticket
   flutter run
   ```
2. **Customer Portal:**
   - Halaman **Beranda** dan **Cari** otomatis mengambil hotel langsung dari tabel `mitra_penginapan` di Supabase.
   - Form Login dapat login dengan email dari tabel `users` (misal: `user01@example.com` / `DummyPass123!`).
3. **Pihak Hotel Portal:**
   - Dapat login menggunakan staf dari tabel `staf_hotel` (misal: ID Staf `1` / email `staf01@example.com` / password `DummyPass123!`).
4. **Pihak Go Ticket Portal (Super Admin):**
   - Dapat login menggunakan akun dari tabel `super_admin` (misal: `admin01@example.com`).
