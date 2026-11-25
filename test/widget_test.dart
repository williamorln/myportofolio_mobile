import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

import 'package:myportofolio_mobile/widgets/project_card.dart';

const namaTombol = [
  'Lihat Proyek',
  'Tambah Proyek',
  'Lihat Skills',
  'Lihat Pengalaman',
  'Tambah Pengalaman',
  'Logout',
];

Color? warnaKartu(WidgetTester tester, String nama) {
  final kartu = find.widgetWithText(ItemCard, nama);
  final material = find.descendant(of: kartu, matching: find.byType(Material));
  return tester.widget<Material>(material.first).color;
}

void main() {
  testWidgets('halaman utama menampilkan identitas pemilik', (tester) async {
    await tester.pumpWidget(buatApp());

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);

    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('2506657390'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('William Orlando'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('PBP E'), findsOneWidget);

    // data contoh dari tutorial tidak boleh tersisa
    expect(find.text('Burhan'), findsNothing);
    expect(find.text('2406000001'), findsNothing);
  });

  testWidgets('semua tombol menu tampil dan warna latarnya berbeda', (
    tester,
  ) async {
    await tester.pumpWidget(buatApp());

    final warna = <Color?>[];
    for (final nama in namaTombol) {
      expect(find.widgetWithText(ItemCard, nama), findsOneWidget);
      warna.add(warnaKartu(tester, nama));
    }

    expect(warna.toSet().length, namaTombol.length);
  });

  testWidgets('menekan kartu menu memunculkan SnackBar', (tester) async {
    await tester.pumpWidget(buatApp());

    expect(find.byType(SnackBar), findsNothing);

    await tester.tap(find.text('Lihat Skills'));
    await tester.pump();

    expect(
      find.text('Kamu telah menekan tombol Lihat Skills!'),
      findsOneWidget,
    );

    // menekan kartu lain mengganti pesan, bukan menumpuk
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(find.text('Kamu telah menekan tombol Lihat Skills!'), findsNothing);
  });

  testWidgets('SnackBar memakai warna kartu yang ditekan', (tester) async {
    // layar tinggi supaya SnackBar tidak menutupi kartu di baris bawah
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buatApp());

    for (final nama in ['Lihat Skills', 'Lihat Pengalaman']) {
      await tester.tap(find.text(nama));
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, warnaKartu(tester, nama));
    }
  });

  for (final ukuran in const [Size(320, 640), Size(360, 740), Size(412, 915)]) {
    testWidgets('tata letak muat di layar ${ukuran.width.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = ukuran;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buatApp());

      expect(tester.takeException(), isNull);

      // tombol paling bawah tetap bisa dijangkau lewat gulir
      await tester.ensureVisible(find.text('Logout'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
