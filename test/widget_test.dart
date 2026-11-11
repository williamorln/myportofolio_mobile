import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('halaman utama menampilkan identitas dan tombol menu', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);

    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('2406000001'), findsOneWidget);
    expect(find.text('Burhan'), findsOneWidget);
    expect(find.text('PBP A'), findsOneWidget);

    for (final nama in ['Lihat Proyek', 'Tambah Proyek', 'Logout']) {
      expect(find.text(nama), findsOneWidget);
    }
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
