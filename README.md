# 🏎️ SG GP Tickets 2027 - Mobile App Final Project

Aplikasi mobile Flutter untuk pemesanan tiket resmi **Formula 1 Singapore Grand Prix 2027** di Marina Bay Street Circuit (8-10 Oktober 2027).

---

## 📋 Fitur Utama & Kesesuaian Modul

| Modul / Fitur | Implementasi di Aplikasi |
|---|---|
| **Tema & Desain** | Singapore GP Night Race theme (`#E10600` Red, `#FFFFFF` White, `#10111A` Dark Carbon) |
| **Database Lokal (Modul 6)** | **Hive 2.2** (`usersBox`, `ticketsBox`, `ordersBox`, `wishlistBox`, `draftBox`) + **SharedPreferences** (Sesi login & preferensi mata uang) |
| **State Management (Modul 8)**| **GetX** (`Obx`, `GetxController`, `Bindings`, `GetPage` Named Routes, `AuthMiddleware`) |
| **APIs Eksternal (Modul 5)** | • **Open-Meteo Weather**: Cuaca live sirkuit Marina Bay<br>• **Open-Meteo Air Quality**: Kualitas udara & PM2.5 (Haze)<br>• **Frankfurter API**: Kurs live SGD ke IDR (Rupiah) & USD (Dollar) |
| **LBS & Geolocator (Modul 7)** | Perhitungan jarak user ke 8 pintu masuk (Gate) sirkuit Marina Bay. Gate `< 150m` ditandai hijau |
| **Notifikasi Lokal (Modul 7)** | Notifikasi instan konfirmasi pemesanan + notifikasi terjadwal pengingat balapan & gate (termasuk tombol demo tes 10 detik) |
| **CRUD Lengkap** | **Create** (Checkout tiket), **Read** (Tiketku per akun), **Update** (Ubah nama pemegang & jumlah tiket via bottom sheet), **Delete** (Batalkan tiket & auto-cancel reminder) |

---

## 🔄 Clickable Prototype Flows (Sesuai Alur)

1. **Beranda (`/root` tab 0):**
   - Tap **Ticket Card** atau tombol **MORE** ➔ Membuka **"02 Detail - Overview"**.
   - Tap tombol **BUY NOW** di hero banner ➔ Otomatis scroll halus ke carousel tiket.
2. **Detail Tiket (`/ticket-detail`):**
   - Tab switch antara **"02 Overview"** (zona, gate, benefit) dan **"03 Pricing Details"** (3-Day, Fri, Sat, Sun).
   - Tap **BUY** ➔ Auth Gate: jika belum login, dialihkan ke **"04 Masuk / Daftar"** (Guest Flow) ➔ setelah berhasil, otomatis lanjut ke **"05 Checkout"** ➔ **"06 Pesanan Berhasil"** ➔ otomatis membuka **"07 Tiketku"**.
3. **Bottom Navigation (4 Tab):**
   - Berpindah antara **Beranda**, **Tiketku**, **Venue**, dan **Profil** dengan animasi halus **200 ms** (`PageView` + `animateToPage`).
4. **Tiketku (Tab 1):**
   - Tap tombol **KELOLA** ➔ Membuka bottom sheet **"08 Kelola Tiket"** (edit nama pemegang, ubah kuantitas, atau batalkan tiket).
5. **Venue (Tab 2):**
   - Menampilkan jarak GPS user ke setiap Gate sirkuit.
   - Tap **Ikon Lonceng (Bell Icon)** pada gate ➔ Membuka bottom sheet **"10 Atur Pengingat"** (atur jam notifikasi pengingat & tes notif 10 detik).
6. **Profil (Tab 3):**
   - Tap tombol **KELUAR** ➔ Muncul konfirmasi dialog ➔ Sesi dihapus ➔ Dialihkan kembali ke **"01 Beranda"**.

---

## 💱 Multi-Currency (SGD / IDR / USD)

Aplikasi dilengkapi selector mata uang di AppBar dan halaman Profil:
- **SGD (S$)**: Mata uang standar Singapore GP
- **IDR (Rp)**: Konversi live ke Rupiah Indonesia
- **USD ($)**: Konversi live ke Dollar Amerika

---

## 📁 Struktur Folder Proyek

```
lib/
├── main.dart                  # Entry point, init Hive, Notifikasi, seed tiket, GetMaterialApp
├── routes.dart                # Named routes + AuthMiddleware
├── bindings.dart              # InitialBindings Get.lazyPut semua controller
├── theme.dart                 # F1 Dark Theme (#E10600, #10111A, #00D26A, #FFB800)
│
├── models/
│   ├── app_user.dart          # Model user + Hive TypeAdapter (typeId: 0)
│   ├── ticket_package.dart    # Model tiket + Hive TypeAdapter (typeId: 1)
│   └── order.dart             # Model pesanan + Hive TypeAdapter (typeId: 2)
│
├── services/
│   ├── local_service.dart     # Inisialisasi Hive boxes & SharedPreferences
│   ├── auth_service.dart      # Registrasi/login lokal + SHA-256 + salt
│   ├── ticket_service.dart    # Seeding assets/data/tickets.json + wishlist
│   ├── api_service.dart       # Open-Meteo Weather, Air Quality, Frankfurter API
│   ├── device_service.dart    # Notifikasi lokal instan/terjadwal + Geolocator LBS
│   └── order_service.dart     # CRUD pesanan tiket di Hive
│
├── controllers/
│   ├── auth_controller.dart   # Sesi login, register, logout, auth gate
│   ├── currency_controller.dart # Konversi kurs SGD/IDR/USD live
│   ├── ticket_controller.dart # Filter kategori, detail tiket, wishlist
│   ├── home_controller.dart   # Countdown GP 2027, cuaca, scroll to carousel
│   ├── order_controller.dart  # Checkout, update nama/qty, pembatalan
│   └── venue_controller.dart  # GPS lokasi, jarak gate (<150m hijau), pengingat
│
├── views/
│   ├── root_page.dart         # Bottom nav 4 tab (smart animate 200 ms)
│   ├── home_page.dart         # Hero video/banner, countdown, cuaca, carousel
│   ├── ticket_detail_page.dart# Tab 02 Overview & Tab 03 Pricing Details + BUY
│   ├── login_page.dart        # 04 Masuk / Daftar (Sign In & Register)
│   ├── checkout_page.dart     # 05 Checkout & 06 Dialog Pesanan Berhasil
│   ├── my_tickets_page.dart   # 07 Tiketku (CRUD list) & 08 Kelola Tiket bottom sheet
│   ├── venue_page.dart        # 09 LBS Gate proximity & 10 Atur Pengingat bottom sheet
│   └── profile_page.dart      # Info akun, switch mata uang, KELUAR -> Beranda
│
└── widgets/
    ├── app_button.dart        # Reusable primary & outlined button
    ├── ticket_card.dart       # Kartu tiket horizontal & tombol MORE
    ├── video_bg.dart          # Hero banner loop + live countdown timer
    └── currency_selector.dart # Widget selector mata uang (SGD/IDR/USD)
```

---

## 🚀 Cara Menjalankan Aplikasi

1. Clone repositori:
   ```bash
   git clone <link-repo>
   cd projectakhir
   ```
2. Ambil seluruh package:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi pada perangkat Android atau emulator:
   ```bash
   flutter run
   ```

### Akun Demo Cepat
- **Email**: `fan@singaporegp.sg`
- **Password**: `f1gp2027`
- *Tersedia tombol "Quick Fill Demo Account" pada halaman Sign In.*
