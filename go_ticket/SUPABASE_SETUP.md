# Panduan Integrasi Supabase Backend Go Ticket

File konfigurasi utama terletak di:
👉 `lib/core/config/supabase_config.dart`

---

## 1. Langkah Cepat Menghubungkan Supabase

1. Buka dashboard proyek Supabase Anda: https://supabase.com/dashboard
2. Buka menu **Project Settings** -> **API**
3. Salin **Project URL** dan **Project API Keys (anon public)**
4. Buka file `lib/core/config/supabase_config.dart` lalu ganti:
   ```dart
   static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
   static const String supabaseAnonKey = 'YOUR_ANON_PUBLIC_KEY';
   ```
5. Jalankan `flutter pub get` di folder `go_ticket/`.

Aplikasi akan otomatis mendeteksi konfigurasi dan langsung beralih dari Mock Engine ke Live Supabase Database!

---

## 2. Skema Tabel Database (SQL Editor di Supabase)

Buka menu **SQL Editor** di Supabase Dashboard, lalu jalankan query di bawah ini untuk membuat tabel-tabel yang diperlukan:

```sql
-- 1. PROFILES (Pengguna & Pelanggan, terhubung ke auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT,
    phone_number TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'customer', -- 'customer', 'staff_fo', 'maintenance', 'admin_hotel', 'super_admin'
    managed_hotel_id TEXT,
    managed_hotel_name TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. HOTELS (Daftar Hotel Mitra)
CREATE TABLE IF NOT EXISTS public.hotels (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    name TEXT NOT NULL,
    short_description TEXT,
    full_description TEXT,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    province TEXT NOT NULL,
    postal_code TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    phone_number TEXT,
    email TEXT,
    rating DOUBLE PRECISION DEFAULT 5.0,
    review_count INT DEFAULT 0,
    star_rating INT DEFAULT 4,
    price_per_night DOUBLE PRECISION NOT NULL,
    original_price DOUBLE PRECISION,
    thumbnail_url TEXT,
    photo_urls TEXT[] DEFAULT '{}',
    amenities TEXT[] DEFAULT '{}',
    status TEXT DEFAULT 'active', -- 'pending', 'active', 'suspended', 'rejected'
    is_recommended BOOLEAN DEFAULT FALSE,
    is_popular BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. ROOMS (Kamar Hotel)
CREATE TABLE IF NOT EXISTS public.rooms (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    hotel_id TEXT NOT NULL REFERENCES public.hotels(id) ON DELETE CASCADE,
    room_number TEXT NOT NULL,
    type_name TEXT NOT NULL,
    description TEXT,
    max_guests INT DEFAULT 2,
    price_per_night DOUBLE PRECISION NOT NULL,
    weekend_price DOUBLE PRECISION,
    status TEXT DEFAULT 'available', -- 'available', 'occupied', 'dirty', 'cleaning', 'maintenance'
    photo_urls TEXT[] DEFAULT '{}',
    amenities TEXT[] DEFAULT '{}',
    bed_type TEXT,
    room_size_m2 DOUBLE PRECISION,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. BOOKINGS (Pemesanan & Reservasi Tiket)
CREATE TABLE IF NOT EXISTS public.bookings (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    booking_code TEXT UNIQUE NOT NULL,
    user_id TEXT NOT NULL,
    hotel_id TEXT NOT NULL REFERENCES public.hotels(id) ON DELETE CASCADE,
    hotel_name TEXT NOT NULL,
    hotel_address TEXT,
    hotel_image_url TEXT,
    room_id TEXT NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    room_type_name TEXT NOT NULL,
    room_number TEXT NOT NULL,
    guest_name TEXT NOT NULL,
    guest_email TEXT NOT NULL,
    guest_phone_number TEXT NOT NULL,
    check_in_date TIMESTAMPTZ NOT NULL,
    check_out_date TIMESTAMPTZ NOT NULL,
    nights INT DEFAULT 1,
    total_guests INT DEFAULT 1,
    total_rooms INT DEFAULT 1,
    price_per_night DOUBLE PRECISION NOT NULL,
    subtotal_price DOUBLE PRECISION NOT NULL,
    tax_and_service_fee DOUBLE PRECISION DEFAULT 0,
    discount_amount DOUBLE PRECISION DEFAULT 0,
    total_price DOUBLE PRECISION NOT NULL,
    status TEXT DEFAULT 'confirmed', -- 'pending_payment', 'pending_verification', 'confirmed', 'checked_in', 'checked_out', 'cancelled', 'expired'
    payment_method TEXT,
    is_paid BOOLEAN DEFAULT TRUE,
    paid_at TIMESTAMPTZ,
    checked_in_at TIMESTAMPTZ,
    checked_out_at TIMESTAMPTZ,
    qr_code_data TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. MAINTENANCE_TICKETS (Laporan Kerusakan & Kebersihan)
CREATE TABLE IF NOT EXISTS public.maintenance_tickets (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    hotel_id TEXT NOT NULL REFERENCES public.hotels(id) ON DELETE CASCADE,
    room_id TEXT NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    room_number TEXT NOT NULL,
    category TEXT NOT NULL, -- 'cleaning', 'repair', 'inspection', 'amenities'
    title TEXT NOT NULL,
    description TEXT,
    priority TEXT DEFAULT 'medium', -- 'low', 'medium', 'urgent'
    status TEXT DEFAULT 'open', -- 'open', 'in_progress', 'resolved', 'closed'
    assigned_to_name TEXT,
    photo_urls TEXT[] DEFAULT '{}',
    resolution_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- 6. PROMOS (Voucher & Diskon)
CREATE TABLE IF NOT EXISTS public.promos (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    code TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    discount_percent INT DEFAULT 10,
    max_discount DOUBLE PRECISION DEFAULT 100000,
    min_booking_amount DOUBLE PRECISION DEFAULT 0,
    expired_date TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. PAYOUTS (Pencairan Saldo Mitra Hotel)
CREATE TABLE IF NOT EXISTS public.payouts (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    hotel_id TEXT NOT NULL REFERENCES public.hotels(id) ON DELETE CASCADE,
    hotel_name TEXT NOT NULL,
    amount DOUBLE PRECISION NOT NULL,
    bank_name TEXT NOT NULL,
    account_number TEXT NOT NULL,
    account_holder_name TEXT NOT NULL,
    status TEXT DEFAULT 'pending', -- 'pending', 'processing', 'approved', 'rejected'
    requested_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    reference_number TEXT
);

-- 8. STAFF (Karyawan Front Office & Maintenance)
CREATE TABLE IF NOT EXISTS public.staff (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    role TEXT NOT NULL,
    shift TEXT,
    status TEXT DEFAULT 'Aktif',
    avatar_url TEXT,
    hotel_id TEXT REFERENCES public.hotels(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 3. Struktur Service Layer yang Sudah Dibuat

1. **`SupabaseConfig` (`lib/core/config/supabase_config.dart`)**:
   Menyimpan kredensial dan pemetaan nama tabel Supabase.
2. **`SupabaseService` (`lib/core/services/supabase_service.dart`)**:
   Mengelola inisialisasi client, koneksi, auth state, dan query table.
3. **`AuthService` (`lib/core/services/auth_service.dart`)**:
   Menangani login & register untuk Customer, Hotel Staff, dan Super Admin, serta menyimpan sesi di `SharedPreferences`.
4. **`HotelService` (`lib/core/services/hotel_service.dart`)**:
   Mengambil data hotel (filter/sorting), kamar, dan aksi manajemen hotel.
5. **`BookingService` (`lib/core/services/booking_service.dart`)**:
   Menangani pembuatan reservasi, riwayat booking, verifikasi pembayaran, check-in, dan check-out.
6. **`MaintenanceService` (`lib/core/services/maintenance_service.dart`)**:
   Menangani penerbitan tiket kerusakan, kebersihan, dan update status penanganan.
7. **`PromoService` (`lib/core/services/promo_service.dart`)**:
   Menangani validasi kode promo/voucher dan kalkulasi diskon.
8. **`SuperAdminService` (`lib/core/services/super_admin_service.dart`)**:
   Menangani statistik platform nasional, manajemen akun pengguna, dan persetujuan pencairan dana mitra.
9. **`MockData` (`lib/core/services/mock_data.dart`)**:
   Menyediakan fallback data yang lengkap dan realistis ketika aplikasi sedang offline atau belum dihubungkan ke Supabase.
