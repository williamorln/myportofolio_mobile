# myportofolio_mobile

Aplikasi mobile portofolio pribadi yang dibuat dengan Flutter. Aplikasi ini menjadi pendamping situs Django [myportofolio](https://github.com/williamorln/myportofolio) dan nantinya akan dihubungkan ke API DRF dari Tutorial 07.

Dibuat untuk **Tutorial 08: Basic Flutter** (PBP Gasal 2026/2027).

## Yang sudah ada

- Proyek Flutter baru dengan kode halaman dipisah ke `lib/menu.dart`, sedangkan `lib/main.dart` hanya berisi titik masuk dan tema.
- Tema Material 3 dengan seed indigo dan warna sekunder amber.
- `MyHomePage` berupa `StatelessWidget`, karena isinya statis dan tidak menyimpan state.
- `InfoCard` untuk identitas (NPM, nama, kelas) dan `ItemCard` untuk tombol menu, keduanya widget yang bisa dipakai ulang.
- `ItemHomepage` sebagai model data sederhana untuk nama dan ikon tombol.
- Tata letak memakai `Scaffold`, `AppBar`, `Padding`, `Column`, `Row`, dan `GridView.count`.
- Menekan kartu menu menampilkan `SnackBar`.

Identitas yang tampil sekarang masih data contoh (Burhan) sesuai tutorial.

## Menjalankan

Versi yang dipakai: Flutter 3.47.9 dan Dart 3.13.7.

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
  main.dart   titik masuk aplikasi dan tema
  menu.dart   halaman utama, InfoCard, ItemHomepage, dan ItemCard
test/
  widget_test.dart
```
