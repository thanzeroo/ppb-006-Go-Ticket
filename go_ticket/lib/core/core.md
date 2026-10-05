# Struktur Folder Flutter

## 1. `constants/`

Folder ini berisi nilai-nilai tetap (*hardcoded*) yang digunakan di seluruh aplikasi. Jika ada perubahan, cukup ubah di satu tempat.

* **`api_endpoints.dart`**
  Menyimpan URL dasar backend dan jalur-jalur API, misalnya `/auth/login`, `/hotels`, dan `/bookings`.

* **`app_colors.dart`**
  Menyimpan variabel warna resmi Go Ticket, misalnya warna biru utama, hijau sukses, dan merah warning.

* **`app_constants.dart`**
  Menyimpan konstanta aplikasi seperti kunci penyimpanan lokal (`KEY_TOKEN`), batas timeout HTTP, dan jumlah data per halaman (*pagination*).

* **`app_assets.dart`**
  Menyimpan path menuju file gambar atau ikon lokal, misalnya `assets/images/logo.png`.

---

## 2. `network/`

Folder ini mengatur segala hal yang berhubungan dengan komunikasi data antara aplikasi Flutter dan Backend API.

* **`api_client.dart`**
  Class utama untuk mengirim request seperti `GET`, `POST`, `PUT`, dan `DELETE`.

* **`network_interceptor.dart`**
  Penengah otomatis yang bertugas menambahkan Token JWT ke header setiap request dan menangani kondisi token yang sudah *expired*.

* **`api_exception.dart`**
  Menangani error server secara terpusat, misalnya koneksi terputus, `401 Unauthorized`, atau `500 Server Error`.

---

## 3. `theme/`

Folder ini mengatur tampilan visual dan gaya tulisan agar seragam di seluruh aplikasi.

* **`app_theme.dart`**
  Mengatur konfigurasi `ThemeData` Flutter untuk Light & Dark Mode, termasuk gaya tombol, input text, dan AppBar.

* **`text_styles.dart`**
  Menyimpan gaya teks seperti `heading1`, `subtitle`, dan `bodyText` dengan ukuran serta ketebalan yang baku.

---

## 4. `utils/`

Folder ini berisi fungsi-fungsi bantuan (*helper function*) untuk mengolah format data sederhana.

* **`date_formatter.dart`**
  Mengubah format tanggal dari backend, misalnya `2026-10-05` menjadi `5 Okt 2026`.

* **`currency_formatter.dart`**
  Mengubah angka menjadi format mata uang Rupiah, misalnya `350000` menjadi `Rp 350.000`.

* **`storage_helper.dart`**
  Wrapper untuk menyimpan dan membaca data seperti Token JWT menggunakan `FlutterSecureStorage` atau `SharedPreferences`.

---

## 5. `widgets/`

Folder ini berisi komponen antarmuka (UI) generik yang sering digunakan kembali di berbagai screen.

* **`custom_button.dart`**
  Tombol standar aplikasi yang sudah dilengkapi animasi loading.

* **`custom_text_field.dart`**
  Kolom input form standar dengan desain border dan penanganan `error text`.

* **`loading_indicator.dart`**
  Widget indikator loading atau spinner dengan tampilan yang seragam.

* **`empty_state_widget.dart`**
  Tampilan khusus ketika data dari backend kosong atau terjadi kegagalan saat memuat data.
