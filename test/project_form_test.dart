import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/project_form.dart';

void main() {
  Future<void> bukaForm(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
  }

  testWidgets('menyimpan form kosong menampilkan pesan error', (tester) async {
    await bukaForm(tester);

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('isian hanya spasi tetap ditolak', (tester) async {
    await bukaForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Proyek'),
      '   ',
    );
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('input valid memunculkan dialog dan OK menutupnya', (
    tester,
  ) async {
    await bukaForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Proyek'),
      'Portofolio Mobile',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
      'Aplikasi Flutter untuk portofolio',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: Portofolio Mobile'), findsOneWidget);
    expect(
      find.text('Deskripsi: Aplikasi Flutter untuk portofolio'),
      findsOneWidget,
    );
    expect(find.text('Kategori: Web Development'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
