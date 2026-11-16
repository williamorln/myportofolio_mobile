import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';

void main() {
  testWidgets('halaman utama menampilkan identitas pemilik', (tester) async {
    await tester.pumpWidget(const MyApp());

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

  testWidgets('tiap tombol menu punya warna latar yang berbeda', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final warna = <Color?>[];
    for (final nama in ['Lihat Proyek', 'Tambah Proyek', 'Logout']) {
      final kartu = find.widgetWithText(ItemCard, nama);
      expect(kartu, findsOneWidget);
      final material = find.descendant(
        of: kartu,
        matching: find.byType(Material),
      );
      warna.add(tester.widget<Material>(material.first).color);
    }

    expect(warna.toSet().length, warna.length);
  });

  testWidgets('menekan kartu menu memunculkan SnackBar', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(SnackBar), findsNothing);

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pump();

    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );

    // menekan kartu lain mengganti pesan, bukan menumpuk
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(find.text('Kamu telah menekan tombol Lihat Proyek!'), findsNothing);
  });
}
