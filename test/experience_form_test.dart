import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/utils/formatters.dart';
import 'package:myportofolio_mobile/widgets/date_form_field.dart';

void main() {
  Future<void> bukaForm(WidgetTester tester) async {
    // layar tinggi supaya semua kolom dan pesan error muat tanpa menggulir
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
  }

  Finder kolom(String label) => find.widgetWithText(TextFormField, label);

  Finder diDialog(String teks) =>
      find.descendant(of: find.byType(AlertDialog), matching: find.text(teks));

  Future<void> isiTeks(WidgetTester tester, String label, String nilai) async {
    await tester.enterText(kolom(label), nilai);
  }

  // mengisi tanggal langsung lewat state kolomnya, tanpa membuka date picker
  void isiTanggal(WidgetTester tester, int urutan, DateTime nilai) {
    final state = tester.state<FormFieldState<DateTime>>(
      find.byType(DateFormField).at(urutan),
    );
    state.didChange(nilai);
  }

  Future<void> isiDasar(WidgetTester tester) async {
    await isiTeks(tester, 'Judul Pengalaman', 'Magang Backend');
    await isiTeks(tester, 'Deskripsi', 'Membuat REST API dengan Django');
  }

  Future<void> tekanSimpan(WidgetTester tester) async {
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
  }

  testWidgets('menampilkan semua kolom formulir', (tester) async {
    await bukaForm(tester);

    expect(find.text('Add Experience Form'), findsOneWidget);
    expect(kolom('Judul Pengalaman'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(kolom('Deskripsi'), findsOneWidget);
    expect(kolom('URL Thumbnail (opsional)'), findsOneWidget);
    expect(find.text('Tanggal Mulai'), findsOneWidget);
    expect(find.text('Masih berjalan'), findsOneWidget);
    expect(find.text('Tanggal Selesai'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('Simpan dengan form kosong menampilkan error di tiap kolom', (
    tester,
  ) async {
    await bukaForm(tester);
    await tekanSimpan(tester);

    expect(find.text('Judul tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Tanggal mulai harus dipilih!'), findsOneWidget);
    expect(find.textContaining('Pilih tanggal selesai'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('isian yang hanya spasi ditolak', (tester) async {
    await bukaForm(tester);
    await isiTeks(tester, 'Judul Pengalaman', '    ');
    await isiTeks(tester, 'Deskripsi', '   ');
    await tekanSimpan(tester);

    expect(find.text('Judul tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('judul lebih dari 255 karakter ditolak', (tester) async {
    await bukaForm(tester);
    await isiTeks(tester, 'Judul Pengalaman', 'a' * 256);
    await tekanSimpan(tester);

    expect(find.text('Judul maksimal 255 karakter!'), findsOneWidget);
  });

  testWidgets('URL thumbnail yang salah ditolak, yang kosong boleh', (
    tester,
  ) async {
    await bukaForm(tester);
    await isiDasar(tester);
    isiTanggal(tester, 0, DateTime(2025, 6, 1));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await isiTeks(tester, 'URL Thumbnail (opsional)', 'bukan url');
    await tekanSimpan(tester);
    expect(find.textContaining('URL tidak valid'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await isiTeks(tester, 'URL Thumbnail (opsional)', '');
    await tekanSimpan(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('tanggal selesai sebelum tanggal mulai ditolak', (tester) async {
    await bukaForm(tester);
    await isiDasar(tester);
    isiTanggal(tester, 0, DateTime(2025, 8, 30));
    isiTanggal(tester, 1, DateTime(2025, 6, 1));
    await tester.pump();
    await tekanSimpan(tester);

    expect(
      find.text('Tanggal selesai tidak boleh sebelum tanggal mulai!'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('input valid menampilkan ringkasan lengkap di dialog', (
    tester,
  ) async {
    await bukaForm(tester);
    await isiDasar(tester);
    await isiTeks(
      tester,
      'URL Thumbnail (opsional)',
      'https://contoh.com/a.png',
    );
    isiTanggal(tester, 0, DateTime(2025, 6, 1));
    isiTanggal(tester, 1, DateTime(2025, 8, 30));

    await tester.tap(find.text('Full-Time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Internship').last);
    await tester.pumpAndSettle();

    await tekanSimpan(tester);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Pengalaman berhasil disimpan!'), findsOneWidget);
    // isian juga masih terlihat di kolom, jadi dicari di dalam dialog saja
    for (final teks in [
      'Magang Backend',
      'Internship',
      'Membuat REST API dengan Django',
      'https://contoh.com/a.png',
      '1 Juni 2025',
      '30 Agustus 2025',
    ]) {
      expect(diDialog(teks), findsOneWidget, reason: teks);
    }
  });

  testWidgets(
    'Masih berjalan mengosongkan tanggal selesai dan lolos validasi',
    (tester) async {
      await bukaForm(tester);
      await isiDasar(tester);
      isiTanggal(tester, 0, DateTime(2025, 6, 1));
      isiTanggal(tester, 1, DateTime(2025, 8, 30));
      await tester.pump();
      expect(find.text('30 Agustus 2025'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('30 Agustus 2025'), findsNothing);

      await tekanSimpan(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('Masih berjalan'),
        findsNWidgets(3),
      ); // switch, kolom, dialog
    },
  );

  testWidgets('Tutup menutup dialog dan mengosongkan formulir', (tester) async {
    await bukaForm(tester);
    await isiDasar(tester);
    isiTanggal(tester, 0, DateTime(2025, 6, 1));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tekanSimpan(tester);

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Magang Backend'), findsNothing);
    // kedua kolom tanggal kembali kosong
    expect(find.text('Pilih tanggal'), findsNWidgets(2));

    // menyimpan lagi tanpa mengisi harus ditolak, bukan memakai data lama
    await tekanSimpan(tester);
    expect(find.text('Judul tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('date picker mengisi tanggal mulai', (tester) async {
    await bukaForm(tester);

    await tester.tap(find.byType(DateFormField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final sekarang = DateTime.now();
    expect(
      find.text(formatTanggal(DateTime(sekarang.year, sekarang.month, 1))),
      findsOneWidget,
    );
  });

  testWidgets('mengubah tanggal mulai mengecek ulang tanggal selesai', (
    tester,
  ) async {
    await bukaForm(tester);
    isiTanggal(tester, 1, DateTime(2020, 1, 1));
    await tester.pump();
    expect(
      find.text('Tanggal selesai tidak boleh sebelum tanggal mulai!'),
      findsNothing,
    );

    // tanggal mulai dipilih lewat date picker (tanggal 1 bulan ini)
    await tester.tap(find.byType(DateFormField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(
      find.text('Tanggal selesai tidak boleh sebelum tanggal mulai!'),
      findsOneWidget,
    );
  });

  group('kemudahan pengisian', () {
    testWidgets('penghitung karakter tampil di kolom teks', (tester) async {
      await bukaForm(tester);

      expect(find.text('0/255'), findsOneWidget);
      expect(find.text('0/1000'), findsOneWidget);
      expect(find.text('0/500'), findsOneWidget);

      await isiTeks(tester, 'Judul Pengalaman', 'Magang');
      await tester.pump();
      expect(find.text('6/255'), findsOneWidget);
    });

    testWidgets('error langsung berubah saat mengetik, tanpa menekan Simpan', (
      tester,
    ) async {
      await bukaForm(tester);

      await isiTeks(tester, 'Judul Pengalaman', '   ');
      await tester.pump();
      expect(find.text('Judul tidak boleh kosong!'), findsOneWidget);

      await isiTeks(tester, 'Judul Pengalaman', 'Magang');
      await tester.pump();
      expect(find.text('Judul tidak boleh kosong!'), findsNothing);
    });

    testWidgets('dialog menampilkan durasi pengalaman', (tester) async {
      await bukaForm(tester);
      await isiDasar(tester);
      isiTanggal(tester, 0, DateTime(2025, 6, 1));
      isiTanggal(tester, 1, DateTime(2025, 8, 30));
      await tekanSimpan(tester);

      expect(diDialog('Durasi'), findsOneWidget);
      expect(diDialog('2 bulan'), findsOneWidget);
    });
  });

  group('layar sempit dengan papan ketik', () {
    // ponsel kecil (320 x 640) dengan papan ketik setinggi 300 px
    Future<void> bukaDiPonsel(WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    }

    testWidgets('tombol Simpan tetap bisa dijangkau dengan menggulir', (
      tester,
    ) async {
      await bukaDiPonsel(tester);
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();

      // tombol berada di area yang tidak tertutup papan ketik
      final kotak = tester.getRect(find.text('Simpan'));
      expect(kotak.bottom, lessThanOrEqualTo(640 - 300));

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Simpan menggulir layar ke kolom pertama yang error', (
      tester,
    ) async {
      await bukaDiPonsel(tester);
      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // judul adalah kolom pertama yang error, jadi harus kembali terlihat
      final kotak = tester.getRect(find.text('Judul tidak boleh kosong!'));
      expect(kotak.top, greaterThanOrEqualTo(56)); // di bawah AppBar
      expect(kotak.bottom, lessThanOrEqualTo(640 - 300));
    });
  });
}
