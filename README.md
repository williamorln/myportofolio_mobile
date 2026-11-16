# myportofolio_mobile

Aplikasi mobile portofolio pribadi William Orlando (NPM 2506657390, PBP E) yang dibuat dengan Flutter. Aplikasi ini menjadi pendamping situs Django [myportofolio](https://github.com/williamorln/myportofolio) dan nantinya akan dihubungkan ke API DRF dari Tutorial 07.

Dibuat untuk mata kuliah **Pemrograman Berbasis Platform (PBP)**, Fakultas Ilmu Komputer, Universitas Indonesia, Gasal 2026/2027.

## Progres mingguan

| Minggu | Isi |
|---|---|
| Tutorial 08 | Proyek Flutter dibuat, halaman utama dipisah ke `lib/menu.dart`, `MyHomePage` menjadi `StatelessWidget`, `InfoCard` dan `ItemCard` dengan data contoh Burhan. |
| Tugas 7 | Identitas diganti dengan data sendiri, setiap tombol menu punya warna sendiri lewat model `ItemHomepage`, ditambah tiga tombol baru dan tata letak yang tetap rapi di layar sempit. |
| Tutorial 09 | Navigasi dengan `Navigator`, drawer (`LeftDrawer`), halaman formulir Tambah Proyek dengan validasi dan dialog ringkasan, serta refactor ke `lib/screens/` dan `lib/widgets/`. |

## Fitur saat ini

- Tiga `InfoCard` di bagian atas berisi NPM, nama, dan kelas pemilik portofolio.
- Enam `ItemCard` berbentuk kisi: Lihat Proyek, Tambah Proyek, Lihat Skills, Lihat Pengalaman, Tambah Pengalaman, dan Logout. Warna latar tiap kartu berbeda dan diambil dari atribut `color` pada `ItemHomepage`, sehingga tidak ada percabangan if-else untuk warna.
- Menekan kartu menampilkan `SnackBar` bertuliskan "Kamu telah menekan tombol [Nama Tombol]!". SnackBar memakai warna dan ikon kartu yang ditekan, dan pesan lama diganti, bukan menumpuk.
- Tata letak responsif: kartu identitas memakai `Expanded` sehingga lebarnya mengikuti layar, halaman bisa digulir, dan lebar isi dibatasi 600 px agar tetap enak dilihat di Chrome.
- Drawer di sisi kiri (header, **Home**, dan **Add Project**). Drawer yang sama dipasang di halaman utama dan halaman formulir. Opsi di drawer memakai `Navigator.pushReplacement()` supaya halaman tidak menumpuk.
- Kartu **Tambah Proyek** membuka `ProjectFormPage` dengan `Navigator.push()`, jadi tombol Back perangkat atau browser kembali ke menu.
- `ProjectFormPage` (`StatefulWidget` dengan `Form` dan `GlobalKey<FormState>`) berisi nama proyek dan deskripsi (wajib, isian kosong atau hanya spasi ditolak), kategori (dropdown), teknologi, dan tautan opsional. Tombol Save memanggil `validate()` dan, kalau lolos, menampilkan `AlertDialog` berisi semua isian. Data belum disimpan ke database. Setelah OK, form dan variabelnya dikosongkan.

## Menjalankan

Versi yang dipakai: Flutter 3.47.9 dan Dart 3.13.7. Mulai Tutorial 09, impor Material memakai paket `material_ui` (`import 'package:material_ui/material_ui.dart';`), sesuai catatan perubahan Flutter 3.50 di tutorial. Paketnya sudah ada di `pubspec.yaml`, jadi `flutter pub get` sudah cukup.

```sh
flutter pub get
flutter run -d chrome
```

Pemeriksaan kode dan tes:

```sh
flutter analyze
flutter test
```

## Struktur

```
lib/
  main.dart                titik masuk aplikasi dan tema
  screens/
    menu.dart              halaman utama (MyHomePage)
    project_form.dart      formulir Tambah Proyek (ProjectFormPage)
  widgets/
    left_drawer.dart       drawer navigasi
    info_card.dart         kartu identitas (InfoCard)
    project_card.dart      model ItemHomepage dan kartu menu (ItemCard)
test/
  widget_test.dart         halaman utama dan SnackBar
  drawer_test.dart         drawer dan navigasi Home / Add Project
  project_form_test.dart   validasi dan dialog formulir
  navigation_test.dart     navigasi dari kartu dan reset form
```

## Pertanyaan Reflektif

### Tugas 7

1. **Widget tree** adalah susunan widget berbentuk pohon yang menggambarkan seluruh tampilan aplikasi Flutter. Setiap widget punya tepat satu parent (kecuali widget paling atas) dan bisa punya nol, satu, atau banyak child. Hubungan parent-child bekerja dua arah: parent memberi batasan ukuran (constraints) ke child, child memilih ukurannya sendiri di dalam batasan itu lalu melaporkannya, dan parent yang menentukan posisinya. Di proyek ini pohonnya kira-kira `MyApp` → `MaterialApp` → `MyHomePage` → `Scaffold` → `AppBar` dan `Center` → `ConstrainedBox` → `SingleChildScrollView` → `Column` → `IntrinsicHeight` → `Row` → `Expanded` → `InfoCard` → `Card` → `Padding` → `Column` → `Text`. Karena `InfoCard` dibungkus `Expanded`, lebarnya ditentukan oleh `Row` di atasnya, bukan oleh dirinya sendiri. Kalau satu widget berubah, Flutter hanya membangun ulang bagian pohon di bawahnya, bukan seluruh aplikasi.

2. Widget yang saya pakai di proyek ini:

   | Widget | Fungsi |
   |---|---|
   | `MyApp`, `MyHomePage` | Widget buatan sendiri: `MyApp` sebagai akar aplikasi dan `MyHomePage` sebagai halaman utama. |
   | `MaterialApp` | Akar aplikasi yang menyediakan tema, navigator, dan `ScaffoldMessenger`. |
   | `Scaffold` | Kerangka halaman Material: tempat `AppBar` dan isi halaman. |
   | `AppBar` | Bilah judul "MyPortfolio" di atas halaman. |
   | `Center` | Menempatkan child di tengah. |
   | `ConstrainedBox` | Membatasi lebar maksimum isi halaman (600 px). |
   | `SingleChildScrollView` | Membuat isi halaman bisa digulir sehingga tidak overflow di layar pendek. |
   | `Column`, `Row` | Menyusun child secara vertikal dan horizontal. |
   | `IntrinsicHeight` | Membuat tiga kartu identitas dalam satu `Row` sama tinggi. |
   | `Expanded`, `Flexible` | Membagi ruang yang tersisa ke child: `Expanded` memaksa mengisi, `Flexible` membolehkan child lebih kecil. |
   | `Padding`, `SizedBox` | Memberi jarak di dalam kartu dan antarwidget. |
   | `Card` | Kartu dengan bayangan untuk `InfoCard`. |
   | `GridView.count` | Menyusun `ItemCard` menjadi kisi tiga kolom. |
   | `Material`, `InkWell` | `Material` memberi warna dan sudut membulat pada `ItemCard`, `InkWell` memberi efek sentuh dan menangani `onTap`. |
   | `Icon`, `Text` | Menampilkan ikon dan teks. |
   | `SnackBar` | Pesan singkat di bagian bawah layar setelah tombol ditekan. |
   | `InfoCard`, `ItemCard` | Widget buatan sendiri yang bisa dipakai ulang untuk kartu identitas dan kartu tombol menu. |

   Selain itu ada `ScaffoldMessenger.of(context)` untuk menampilkan `SnackBar`, `Theme.of(context)` untuk membaca warna tema, dan model biasa `ItemHomepage` (bukan widget) yang menyimpan nama, ikon, dan warna tombol.

3. `MaterialApp` adalah widget yang membungkus aplikasi dengan semua kebutuhan dasar Material Design: tema (`ThemeData`), judul aplikasi, halaman awal (`home`), `Navigator` beserta tabel rute, pengaturan bahasa dan arah teks, serta `ScaffoldMessenger` yang mengatur SnackBar. Widget ini biasanya jadi root karena banyak widget lain bergantung pada hal-hal yang ia sediakan lewat pohon widget. `Scaffold` dan `AppBar` butuh `MediaQuery`, `Theme`, dan `Directionality` di atasnya, sedangkan `ScaffoldMessenger.of(context)` baru bisa menemukan pengelola SnackBar kalau ada `MaterialApp` di atas widget tersebut. Dengan menaruhnya di akar, satu tema di `main.dart` (seed indigo) otomatis berlaku di semua halaman, dan navigasi antarhalaman nanti tinggal memakai `Navigator` yang sudah tersedia.

4. `StatelessWidget` adalah widget yang tidak menyimpan keadaan yang berubah. Tampilannya sepenuhnya ditentukan oleh nilai yang diberikan lewat konstruktor dan data dari atasnya, jadi `build` menghasilkan tampilan yang sama untuk masukan yang sama. `StatefulWidget` dipasangkan dengan objek `State` yang tetap hidup walau widget dibangun ulang, dan perubahan di dalamnya dikabarkan lewat `setState()` supaya tampilan digambar ulang. Pilih `StatelessWidget` bila isinya statis atau hanya bergantung pada data masukan, seperti `MyHomePage`, `InfoCard`, dan `ItemCard` di proyek ini. SnackBar pun tidak butuh state di widget saya karena `ScaffoldMessenger` yang mengelolanya. Pilih `StatefulWidget` bila tampilan harus berubah mengikuti interaksi atau waktu, misalnya isi formulir yang sedang diketik, hitungan, animasi, atau pilihan yang bisa dicentang.

5. `BuildContext` adalah penanda posisi sebuah widget di dalam widget tree. Lewat konteks inilah sebuah widget bisa "melihat ke atas" untuk mengambil data dari widget leluhurnya, seperti tema, ukuran layar, atau `Navigator`. Di metode `build(BuildContext context)`, konteks itu milik widget yang sedang dibangun. Di proyek ini saya memakainya di `Theme.of(context).colorScheme.primary` untuk warna `AppBar`, dan di `ScaffoldMessenger.of(context)` pada `onTap` `ItemCard` untuk menampilkan SnackBar. Konteks yang dipakai harus berada di bawah widget yang dicari: `ItemCard` berada di bawah `MaterialApp`, jadi `ScaffoldMessenger` ketemu. Kalau konteksnya berada di atas atau di luar widget tersebut, pencarian gagal dan muncul error.

6. **Hot reload** menyuntikkan kode Dart yang baru ke aplikasi yang sedang berjalan lalu membangun ulang widget tree, sehingga perubahan tampilan terlihat dalam hitungan detik dan state yang sedang ada (misalnya teks yang sudah diketik) tidak hilang. **Hot restart** menjalankan ulang aplikasi dari `main()` dengan state yang dikosongkan, tetap lebih cepat daripada menjalankan ulang dari awal. Hot reload tidak cukup, dan saya perlu hot restart, saat mengubah `main()`, nilai awal variabel global atau `static` (inisialisasinya tidak dijalankan ulang), atau nilai awal di `initState` pada State yang sudah terbentuk. Full restart (hentikan lalu `flutter run` lagi) diperlukan saat menambah paket di `pubspec.yaml`, mengubah aset atau konfigurasi native seperti `AndroidManifest.xml`, dan perubahan lain di luar kode Dart yang tidak ikut dimuat ulang.

## AI Disclosure

Saya menggunakan **Claude Code** (Anthropic) selama mengerjakan Tugas 7. Claude membantu saat debugging, misalnya ketika tata letak overflow di layar sempit, dan memberi arahan tentang bagaimana struktur kode sebaiknya disusun. Seluruh perubahan saya tinjau dan uji sebelum di-commit.
