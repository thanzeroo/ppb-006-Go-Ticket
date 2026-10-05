## 1. `auth/` — Modul Otentikasi & Akun

Mengatur seluruh logika masuk dan keluar sistem untuk semua jenis pengguna.

* **`auth_repository.dart`**
  Mengirim kredensial ke API backend untuk login (Customer, Staff FO, Maintenance, Admin Hotel, Super Admin) dan mengelola session logout.

* **`auth_controller.dart`**
  Menyimpan status login aktif, menyimpan token JWT ke lokal, dan menentukan role pengguna setelah login berhasil.

---

## 2. `booking/` — Modul Pemesanan & Transaksi

Mengatur alur pemesanan penginapan mulai dari pemilihan tanggal hingga pembayaran.

* **`booking_repository.dart`**
  Mengambil data ketersediaan kamar dari server, mengirim formulir booking, memproses transaksi pembayaran, dan mengambil data E-Tiket.

* **`booking_controller.dart`**
  Menampung tanggal *check-in* dan *check-out* yang dipilih dari kalender, menghitung total biaya harian, dan memvalidasi batas kapasitas tamu.

---

## 3. `room_management/` — Modul Operasional & Kelola Kamar

Mengatur operasional status fisik kamar dan pengaturan harga oleh pihak hotel.

* **`room_repository.dart`**
  Mengubah status kamar di server (*Dirty → Cleaning → Clean & Ready → Occupied*), membuat tiket laporan kerusakan fasilitas, serta memperbarui harga harian dan weekend.

* **`room_controller.dart`**
  Memperbarui daftar tugas harian tim Maintenance secara *real-time* dan mengelola form penyesuaian tarif kamar untuk Admin Hotel.

---

## 4. `payouts/` — Modul Keuangan & Pencairan Dana

Mengatur alur penarikan dana transaksi dari platform ke pihak hotel.

* **`payout_repository.dart`**
  Mengambil riwayat pendapatan hotel, mengirim pengajuan penarikan dana (*payout request*), dan memproses persetujuan transfer (*disbursement*) dari sisi Super Admin.

* **`payout_controller.dart`**
  Menghitung total komisi platform, memvalidasi saldo yang bisa ditarik hotel, dan mengelola status riwayat pencairan dana.
