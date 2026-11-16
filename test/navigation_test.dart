import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

void main() {
  Future<void> pakaiLayarTinggi(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('kartu Tambah Proyek membuka form dan Back kembali ke menu', (
    tester,
  ) async {
    await pakaiLayarTinggi(tester);
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.text('Add Project Form'), findsOneWidget);

    // push menumpuk route, jadi pop membawa kita kembali ke menu
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('kartu selain Tambah Proyek tidak berpindah halaman', (
    tester,
  ) async {
    await pakaiLayarTinggi(tester);
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('setelah OK, form kosong lagi dan data lama tidak muncul', (
    tester,
  ) async {
    await pakaiLayarTinggi(tester);
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Proyek'),
      'Proyek Lama',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
      'Deskripsi lama',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // menyimpan lagi tanpa isian harus ditolak, bukan memakai data lama
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
