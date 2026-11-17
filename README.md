# myportofolio_mobile

Aplikasi mobile portofolio pribadi William Orlando (NPM 2506657390, PBP E) yang dibuat dengan Flutter. Aplikasi ini menjadi pendamping situs Django [myportofolio](https://github.com/williamorln/myportofolio) dan nantinya akan dihubungkan ke API DRF dari Tutorial 07.

Dibuat untuk mata kuliah **Pemrograman Berbasis Platform (PBP)**, Fakultas Ilmu Komputer, Universitas Indonesia, Gasal 2026/2027.

## Progres mingguan

| Minggu | Isi |
|---|---|
| Tutorial 08 | Proyek Flutter dibuat, halaman utama dipisah ke `lib/menu.dart`, `MyHomePage` menjadi `StatelessWidget`, `InfoCard` dan `ItemCard` dengan data contoh Burhan. |
| Tugas 7 | Identitas diganti dengan data sendiri, setiap tombol menu punya warna sendiri lewat model `ItemHomepage`, ditambah tiga tombol baru dan tata letak yang tetap rapi di layar sempit. |
| Tutorial 09 | Navigasi dengan `Navigator`, drawer (`LeftDrawer`), halaman formulir Tambah Proyek dengan validasi dan dialog ringkasan, serta refactor ke `lib/screens/` dan `lib/widgets/`. |
| Tugas 8 | Formulir **Tambah Pengalaman** (`ExperienceFormPage`) yang field dan aturannya mengikuti model `Experience` di proyek Django: judul, kategori, deskripsi, URL thumbnail, tanggal mulai dan selesai dengan `showDatePicker()`. Dibuka dari kartu aksi dan dari opsi baru di drawer, dengan validasi dan dialog ringkasan. |

## Fitur saat ini

- Tiga `InfoCard` di bagian atas berisi NPM, nama, dan kelas pemilik portofolio.
- Enam `ItemCard` berbentuk kisi: Lihat Proyek, Tambah Proyek, Lihat Skills, Lihat Pengalaman, Tambah Pengalaman, dan Logout. Warna latar tiap kartu berbeda dan diambil dari atribut `color` pada `ItemHomepage`, sehingga tidak ada percabangan if-else untuk warna.
- Menekan kartu menampilkan `SnackBar` bertuliskan "Kamu telah menekan tombol [Nama Tombol]!". SnackBar memakai warna dan ikon kartu yang ditekan, dan pesan lama diganti, bukan menumpuk.
- Tata letak responsif: kartu identitas memakai `Expanded` sehingga lebarnya mengikuti layar, halaman bisa digulir, dan lebar isi dibatasi 600 px agar tetap enak dilihat di Chrome.
- Drawer di sisi kiri (header, **Home**, dan **Add Project**). Drawer yang sama dipasang di halaman utama dan halaman formulir. Opsi di drawer memakai `Navigator.pushReplacement()` supaya halaman tidak menumpuk.
- Kartu **Tambah Proyek** membuka `ProjectFormPage` dengan `Navigator.push()`, jadi tombol Back perangkat atau browser kembali ke menu.
- `ProjectFormPage` (`StatefulWidget` dengan `Form` dan `GlobalKey<FormState>`) berisi nama proyek dan deskripsi (wajib, isian kosong atau hanya spasi ditolak), kategori (dropdown), teknologi, dan tautan opsional. Tombol Save memanggil `validate()` dan, kalau lolos, menampilkan `AlertDialog` berisi semua isian. Data belum disimpan ke database. Setelah OK, form dan variabelnya dikosongkan.
- **Tambah Pengalaman** (Tugas 8): halaman `ExperienceFormPage` dibuka dari kartu **Tambah Pengalaman** (`Navigator.push()`) dan dari opsi **Add Experience** di drawer. Drawer lama dipertahankan (Home dan Add Project) dan drawer yang sama dipakai di halaman ini.
  - Enam input sesuai model Django `Experience`: judul (`TextFormField`, wajib, maksimal 255 karakter), kategori (`DropdownButtonFormField`, enam pilihan yang sama dengan `EXPERIENCE_CHOICES`), deskripsi (wajib, maksimal 1000 karakter), URL thumbnail (opsional, harus `http` atau `https`, maksimal 500 karakter), tanggal mulai dan tanggal selesai (`showDatePicker()` lewat `DateFormField`), serta saklar **Masih berjalan** yang mengosongkan tanggal selesai.
  - Validasi: isian wajib yang kosong atau hanya spasi ditolak, batas panjang dicek, format URL dicek, tanggal selesai tidak boleh sebelum tanggal mulai, dan kedua tanggal tidak boleh di masa depan. Semua aturan ada di `lib/utils/validators.dart` sebagai fungsi murni dan dites sendiri.
  - Tombol **Simpan** memanggil `FormState.validate()`. Kalau ada yang tidak valid, pesan error tampil di kolom terkait dan layar menggulir ke kolom pertama yang error. Kalau semua lolos, `showDialog()` menampilkan `AlertDialog` berisi semua isian beserta durasinya, dengan tombol **Tutup** yang juga mengosongkan formulir. Data belum dikirim ke API.
  - Tambahan: penghitung karakter, error yang ikut berubah saat mengetik, tombol Next di papan ketik, dan pengecekan ulang tanggal selesai saat tanggal mulai diganti.

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
  models/
    experience.dart        ExperienceEntry dan ExperienceCategory
  screens/
    menu.dart              halaman utama (MyHomePage)
    project_form.dart      formulir Tambah Proyek (ProjectFormPage)
    experience_form.dart   formulir Tambah Pengalaman (ExperienceFormPage)
  utils/
    validators.dart        aturan validasi formulir
    formatters.dart        format tanggal dan durasi
  widgets/
    left_drawer.dart       drawer navigasi
    info_card.dart         kartu identitas (InfoCard)
    project_card.dart      model ItemHomepage dan kartu menu (ItemCard)
    date_form_field.dart   kolom tanggal dengan date picker (DateFormField)
test/
  widget_test.dart               halaman utama dan SnackBar
  drawer_test.dart               drawer dan navigasi Home / Add Project
  project_form_test.dart         validasi dan dialog formulir proyek
  navigation_test.dart           navigasi dari kartu dan reset form proyek
  validators_test.dart           aturan validasi, format tanggal, dan model
  experience_form_test.dart      formulir pengalaman, termasuk layar sempit
  experience_navigation_test.dart  akses dari kartu dan drawer, serta Home
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

### Tugas 8

1. Ketiganya mengatur tumpukan (stack) halaman yang dikelola `Navigator`. `Navigator.push()` menaruh route baru di atas route yang sedang tampil, sedangkan route lama tetap ada di bawahnya sehingga pengguna bisa kembali. `Navigator.pushReplacement()` mengganti route yang sedang tampil dengan route baru: route lama dibuang dari stack, jadi tidak ada halaman lama untuk kembali, dan yang ada di bawahnya tetap sama. `Navigator.pop()` membuang route paling atas sehingga halaman di bawahnya muncul lagi. Untuk membuka formulir dari kartu aksi saya memakai `Navigator.push()`: `ItemCard` memanggil `Navigator.push(context, MaterialPageRoute(builder: tujuan))` dengan `tujuan` dari atribut `page` pada `ItemHomepage`, sehingga stack menjadi menu lalu formulir dan tombol kembali bawaan perangkat atau browser membawa pengguna pulang ke menu. Di halaman yang punya drawer, `AppBar` menampilkan ikon drawer di tempat panah kembali, jadi kembali dilakukan lewat tombol kembali sistem. Opsi **Home** di drawer memanggil `Navigator.pushReplacement()` dengan `MaterialPageRoute` ke `MyHomePage`, sehingga halaman formulir yang sedang tampil diganti halaman utama. Satu catatan: kalau formulir dibuka lewat kartu, stack-nya sudah berisi menu lebih dulu, jadi setelah Home di drawer halaman utama yang lama masih ada di bawahnya dan muncul kalau pengguna menekan kembali.

2. `Scaffold` menyediakan slot tetap untuk `appBar`, `drawer`, dan `body`, jadi setiap halaman punya kerangka yang sama dan yang berbeda hanya isi `body`. `AppBar` di halaman utama dan di `ExperienceFormPage` memakai gaya yang sama (judul putih tebal, ikon putih), dan `LeftDrawer` adalah satu widget yang dipasang di halaman utama, `ProjectFormPage`, dan `ExperienceFormPage`. Saat opsi **Add Experience** ditambahkan, cukup mengubah `left_drawer.dart` dan ketiga halaman langsung ikut berubah. Contoh warna tema di lebih dari satu halaman: `ThemeData` di `main.dart` memakai seed indigo, dan `Theme.of(context).colorScheme.primary` dipakai sebagai warna `AppBar` di `MyHomePage` dan `ExperienceFormPage`. Tombol **Simpan** (`FilledButton`) juga otomatis memakai warna primer yang sama, jadi kalau seed diganti, ketiganya ikut berganti. Catatan: `ProjectFormPage` dari tutorial dan header drawer masih memakai `Colors.indigo` yang ditulis langsung, bukan dari tema.

3. Formulir saya susun satu kolom: `Column` dengan `crossAxisAlignment: stretch` sehingga setiap input selebar layar, dengan label di dalam kolom dan pesan error tepat di bawahnya. Pilihan ini cocok untuk layar ponsel karena dua kolom berdampingan akan terlalu sempit untuk field tanggal dan teks panjang. `Align` dengan `ConstrainedBox` (maksimal 600 px) menjaga lebar tetap enak dilihat di Chrome yang lebar. Widget pengatur jarak (`Padding` 16 px di sekeliling isi, `SizedBox(height: 16)` antar-field) membuat field tidak berdempetan tanpa membungkus tiap field satu per satu. `SingleChildScrollView` adalah kunci saat ruang terbatas: ketika papan ketik muncul, `Scaffold` memperkecil area `body`, dan isi yang lebih tinggi dari area itu bisa digulir sehingga semua input dan tombol **Simpan** tetap terjangkau. `keyboardDismissBehavior: onDrag` menutup papan ketik saat menggulir, dan setelah Simpan gagal, layar digulirkan otomatis ke kolom pertama yang error karena pesannya mungkin ada di luar layar. Saya menguji ini di tes widget pada layar 320 x 640 dengan papan ketik 300 px, dan di Chrome pada lebar 360 px.

4. `GlobalKey<FormState>` adalah pegangan ke `FormState` milik `Form`, sehingga `_simpan()` bisa memanggil `_formKey.currentState!.validate()` dari luar widget field. Setiap field punya `validator`, yaitu fungsi yang menerima isian dan mengembalikan pesan error atau `null` kalau lolos (aturannya ada di `validators.dart`). `validate()` menjalankan semua validator, menampilkan pesan di kolom yang gagal, dan mengembalikan `true` hanya kalau semuanya lolos. Dialog ringkasan hanya dibuka pada kasus `true`. Contoh nilai yang ditolak: judul `"    "` (hanya spasi) dan tanggal selesai 1 Mei 2025 dengan tanggal mulai 1 Juni 2025. Memilih jenis input atau papan ketik saja belum cukup. `TextInputType.url` hanya mengubah tampilan papan ketik, sedangkan pengguna tetap bisa mengetik atau menempel `contoh.com` tanpa `https://`, yang ditolak `validateOptionalUrl`. Papan ketik teks menerima spasi, jadi judul kosong tetap lolos tanpa validator. `showDatePicker()` hanya menjamin satu tanggal valid, bukan urutan dua tanggal, sehingga aturan "selesai tidak sebelum mulai" tetap harus dicek oleh validator. Aturan yang sama dengan model Django juga membuat data dari aplikasi mobile tidak ditolak server nantinya.

## AI Disclosure

Pada Tugas 8 saya membuat halaman formulir **Add Experience** (model, validator, date picker, dialog ringkasan, serta navigasi dari kartu dan drawer) beserta tes untuk semuanya. Untuk pengerjaannya saya menggunakan **Claude Code** (Anthropic), yang hanya membantu untuk debugging, misalnya label tanggal yang bertumpuk dan tes yang gagal, serta sebagai pemandu yang memberi ide dan arahan tentang bagaimana pengerjaannya sebaiknya disusun.
