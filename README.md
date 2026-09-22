# Curate

Curate adalah aplikasi mobile news reader berbasis Flutter yang menampilkan berita terkini dari [NewsAPI](https://newsapi.org/). Aplikasi ini dirancang dengan pendekatan editorial yang bersih, hangat, dan mudah dibaca: pengguna dapat menjelajahi berita berdasarkan kategori, mencari berita, membuka detail artikel, menyimpan artikel untuk dibaca kembali, serta menggunakan mode gelap.

Proyek ini dibuat sebagai aplikasi portfolio untuk menunjukkan implementasi UI Flutter, state management, konsumsi REST API, local persistence, dan desain sistem yang konsisten.

> **Status proyek:** aktif dikembangkan. Fitur inti sudah tersedia; polish visual berfokus pada peningkatan UI dan UX tanpa menambah alur produk baru.

## Daftar Isi

- [Fitur](#fitur)
- [Tech Stack](#tech-stack)
- [Struktur Proyek](#struktur-proyek)
- [Prasyarat](#prasyarat)
- [Instalasi dan Konfigurasi](#instalasi-dan-konfigurasi)
- [Menjalankan Aplikasi](#menjalankan-aplikasi)
- [Testing](#testing)
- [Arsitektur Singkat](#arsitektur-singkat)
- [Batasan yang Perlu Diketahui](#batasan-yang-perlu-diketahui)
- [Arah Pengembangan](#arah-pengembangan)
- [Lisensi](#lisensi)

## Fitur

### Feed berita

- Menampilkan top headlines dari NewsAPI.
- Feed dapat di-refresh dengan pull-to-refresh.
- Artikel dikelompokkan berdasarkan kategori:
  - General
  - Technology
  - Business
  - Sports
  - Health
  - Science
  - Entertainment
- Menampilkan hero story, top stories horizontal, dan daftar latest articles.
- Menampilkan loading state, empty state, dan error state yang selaras dengan visual Curate.

### Pencarian berita

- Mencari berita menggunakan endpoint `everything` milik NewsAPI.
- Search dapat diakses dari action search pada app bar.

### Detail artikel

- Menampilkan gambar utama, sumber berita, waktu publikasi, judul, deskripsi, dan isi artikel.
- Menyediakan aksi:
  - Menyimpan atau menghapus artikel dari daftar saved.
  - Membagikan artikel.
  - Menyalin link artikel.
  - Membuka artikel asli di browser eksternal.

### Saved articles

- Artikel yang disimpan tersedia melalui tab Saved.
- Data saved articles dipertahankan secara lokal menggunakan `SharedPreferences`.
- Saved state diidentifikasi berdasarkan URL artikel.

### Tema dan visual

- Light mode dan dark mode.
- Preferensi tema disimpan secara lokal.
- Design system menggunakan warm neutral surface, orange accent, rounded surfaces, dan editorial content hierarchy.
- Responsive terhadap ukuran layar mobile yang berbeda.
- Loading shimmer, card, category chip, dialog, navigation bar, dan empty state menggunakan visual token yang konsisten.

## Tech Stack

| Area | Teknologi |
| --- | --- |
| Framework | Flutter |
| Bahasa | Dart |
| State management | GetX |
| Networking | `http` |
| API | NewsAPI |
| Local persistence | `shared_preferences` |
| Image loading/cache | `cached_network_image` |
| Relative date | `timeago` |
| Share | `share_plus` |
| External links | `url_launcher` |
| Environment variables | `flutter_dotenv` |
| Testing | `flutter_test` |

Dependency utama dapat dilihat di [pubspec.yaml](./pubspec.yaml).

## Struktur Proyek

```text
lib/
├── bindings/
│   ├── app_bindings.dart
│   └── home_binding.dart
├── controllers/
│   └── news_controller.dart
├── models/
│   ├── news_article.dart
│   └── news_response.dart
├── routes/
│   ├── app_pages.dart
│   └── app_routes.dart
├── services/
│   └── news_service.dart
├── utils/
│   ├── app_colors.dart
│   └── constants.dart
├── views/
│   ├── home_view.dart
│   ├── news_detail_view.dart
│   └── splash_view.dart
├── widgets/
│   ├── category_chip.dart
│   ├── loading_shimmer.dart
│   └── news_card.dart
└── main.dart

test/
└── widget_test.dart
```

### Tanggung jawab folder utama

- `controllers/`: state feed, kategori, pencarian, saved articles, dan tema.
- `services/`: komunikasi dengan NewsAPI.
- `models/`: model response API dan artikel.
- `views/`: halaman utama aplikasi.
- `widgets/`: komponen UI reusable.
- `utils/`: design tokens, endpoint, kategori, dan konfigurasi umum.
- `routes/` dan `bindings/`: navigasi dan dependency injection GetX.

## Prasyarat

Pastikan environment berikut sudah tersedia:

- Flutter SDK yang kompatibel dengan Dart SDK `^3.13.3`.
- Android Studio dan Android SDK untuk Android.
- Xcode dan CocoaPods untuk iOS/macOS.
- Device fisik atau emulator/simulator.
- API key NewsAPI.

Verifikasi instalasi Flutter:

```bash
flutter doctor
```

## Instalasi dan Konfigurasi

### 1. Clone repository

```bash
git clone https://github.com/azkasketch/news_app.git
cd news_app
```

### 2. Install dependency

```bash
flutter pub get
```

### 3. Tambahkan API key

Buat atau isi file berikut:

```text
assets/.env
```

Dengan isi:

```env
API_KEY=your_newsapi_key
```

`assets/.env` sudah didaftarkan sebagai asset Flutter di [pubspec.yaml](./pubspec.yaml). Jangan commit API key asli ke repository publik. Gunakan key baru atau revoke key apabila pernah terekspos.

### 4. Cek konfigurasi API

Konfigurasi endpoint, negara default, dan kategori berada di [lib/utils/constants.dart](./lib/utils/constants.dart).

Konfigurasi default saat ini:

- Base URL: `https://newsapi.org/v2`
- Negara: `us`
- Top headlines: `/top-headlines`
- Search: `/everything`
- Ukuran halaman default: 20 artikel

## Menjalankan Aplikasi

Jalankan aplikasi pada device atau emulator aktif:

```bash
flutter run
```

Untuk melihat device yang tersedia:

```bash
flutter devices
```

Contoh menjalankan pada device tertentu:

```bash
flutter run -d <device-id>
```

Build Android APK:

```bash
flutter build apk --release
```

Build iOS:

```bash
flutter build ios --release
```

## Testing

Jalankan seluruh test:

```bash
flutter test
```

Test saat ini memverifikasi bahwa aplikasi dapat dimuat dan branding utama Curate tampil pada app shell. Sebelum membuka pull request, disarankan menjalankan:

```bash
flutter analyze
flutter test
```

## Arsitektur Singkat

Alur data utama aplikasi:

```text
View
  ↓
NewsController (GetX reactive state)
  ↓
NewsService
  ↓
NewsAPI
```

### Feed dan pencarian

1. `NewsController` meminta data kepada `NewsService`.
2. `NewsService` membangun URL dan query parameter NewsAPI.
3. Response JSON diubah menjadi `NewsResponse` dan `NewsArticle`.
4. Controller memperbarui observable state.
5. View bereaksi terhadap perubahan loading, error, dan daftar artikel.

### Persistensi lokal

- Mode gelap disimpan dengan key `dark_mode`.
- Saved articles disimpan dengan key `saved_articles`.
- Artikel diserialisasi ke JSON sebelum disimpan ke `SharedPreferences`.

### Navigasi

Route utama didefinisikan di [lib/routes/app_pages.dart](./lib/routes/app_pages.dart):

- Splash
- Home
- News detail

## Batasan yang Perlu Diketahui

- Aplikasi bergantung pada ketersediaan dan quota NewsAPI.
- NewsAPI dapat membatasi request berdasarkan API plan, environment, atau domain aplikasi.
- Isi artikel dari API dapat terpotong; tombol `Read Full Article` membuka URL sumber asli apabila tersedia.
- Tidak ada backend aplikasi sendiri. Saved articles dan preferensi tema hanya tersimpan di device.
- Belum ada akun pengguna, sinkronisasi antar-device, push notification, personalisasi server-side, atau offline cache penuh.
- Kualitas thumbnail dan kelengkapan metadata bergantung pada publisher yang dikembalikan NewsAPI.
- API key tetap dibutuhkan untuk menjalankan feed dan pencarian.

## Arah Pengembangan

Pengembangan berikutnya sebaiknya tetap menjaga prinsip bahwa Curate adalah aplikasi news reader yang fokus dan mudah digunakan:

- Menambah automated tests untuk controller, service, parsing model, dan state error.
- Menambah visual regression test untuk light mode, dark mode, loading, empty, dan error state.
- Menyempurnakan accessibility: semantic labels, contrast validation, dan text scaling.
- Memperkuat observability dan error mapping untuk response API.
- Menambahkan CI untuk `flutter analyze` dan `flutter test`.
- Mempertimbangkan backend/proxy apabila API key tidak boleh berada di client production.

## Lisensi

Proyek ini saat ini bersifat private/non-published (`publish_to: none` pada [pubspec.yaml](./pubspec.yaml)). Tambahkan file lisensi dan ubah status distribusi apabila proyek akan dipublikasikan atau digunakan oleh pihak lain.

## Credits

- [Flutter](https://flutter.dev/)
- [NewsAPI](https://newsapi.org/)
- [GetX](https://pub.dev/packages/get)
- [cached_network_image](https://pub.dev/packages/cached_network_image)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
