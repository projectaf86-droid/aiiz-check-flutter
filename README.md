# aiiz.__ Check — Flutter Prototype

Aplikasi checklist kebersihan/kerapian tempat kerja yang bisa diubah langsung dari HP, lalu dibuat menjadi **PDF, Excel, atau diprint**.

## Fitur yang sudah ada

- Splash screen + logo **aiiz.__ Check**.
- Login prototype (belum Firebase; semua email/password bisa masuk).
- Dashboard progress checklist.
- Checklist **per hari**.
- Checklist **bulanan dalam tabel tanggal 1–28/29/30/31 otomatis**.
- Tambah, edit, hapus, dan urutkan kegiatan.
- Ubah nama dokumen, tempat/bagian, penanggung jawab, bulan, dan tahun.
- Data disimpan lokal menggunakan `shared_preferences`.
- Preview PDF langsung di aplikasi.
- Export **PDF**.
- Export **Excel (.xlsx)**.
- **Print langsung** lewat printer yang dikenali perangkat.
- Pengaturan export: A4, A5, Letter, Legal, F4/Folio; Landscape/Portrait; margin; logo; tanda tangan; catatan.
- Mode export **mentahan kosong** atau **dengan centang yang sudah diisi**.
- Rekap progress per tanggal.

## Cara menjalankan di Windows + VS Code

### 1. Persiapan
Pastikan sudah terinstall:
- Flutter SDK
- VS Code + extension Flutter & Dart
- Android Studio / Android SDK jika ingin menjalankan Android emulator

Cek:

```bash
flutter doctor
```

### 2. Setup project pertama kali
Karena ZIP ini berisi source aplikasi dan aset, platform native dibuat sesuai Flutter SDK milik komputer kamu.

Paling gampang di Windows, double click:

```text
SETUP_WINDOWS.bat
```

Atau lewat terminal di folder project:

```bash
flutter create . --project-name aiiz_check --org com.aiizcheck --platforms=android,web,windows
flutter pub get
dart run flutter_launcher_icons
```

### 3. Jalankan

Android emulator/HP:

```bash
flutter run
```

Web Chrome:

```bash
flutter run -d chrome
```

Windows desktop:

```bash
flutter run -d windows
```

## Login prototype

Email dan password bebas. Contoh yang sudah terisi:

```text
admin@aiizcheck.local
123456
```

## Struktur utama

```text
lib/
├── main.dart
├── app_state.dart
├── models.dart
├── services/
│   └── export_service.dart
└── screens/
    ├── login_screen.dart
    ├── dashboard_screen.dart
    ├── checklist_screen.dart
    ├── document_screen.dart
    ├── export_screen.dart
    ├── recap_screen.dart
    └── profile_screen.dart
```

## Aset desain

```text
assets/images/aiiz_check_logo.png  -> logo lengkap
assets/images/app_icon.png         -> icon aplikasi
docs/mockup.png                    -> ilustrasi UI
 docs/flowchart.png                -> algoritma & flowchart
```

## Catatan pengembangan berikutnya

Versi ini sengaja dibuat **offline-first** supaya langsung bisa dipakai sebagai prototype. Tahap berikutnya bisa ditambahkan:
- Firebase Authentication untuk login asli.
- Cloud Firestore untuk sinkronisasi beberapa HP.
- Role Admin / Petugas.
- Foto bukti pekerjaan.
- Tanda tangan digital.
- Riwayat dokumen per bulan.
- Backup cloud.
- Notifikasi jadwal tugas.

## Jika ada error package

Jalankan:

```bash
flutter clean
flutter pub get
flutter run
```

Jika Flutter kamu terlalu lama, update:

```bash
flutter upgrade
```

