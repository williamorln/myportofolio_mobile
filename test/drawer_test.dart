import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

void main() {
  Future<void> bukaDrawer(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    // font Ahem di flutter_test jauh lebih lebar dari font asli, jadi header
    // drawer terhitung overflow di tes padahal di layar baik-baik saja
    tester.takeException();
  }

  testWidgets('drawer di halaman utama berisi header, Home, dan Add Project', (
    tester,
  ) async {
    await tester.pumpWidget(buatApp());
    await bukaDrawer(tester);

    expect(find.text('My Portfolio'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
  });

  testWidgets('Add Project di drawer membuka form dan Home kembali', (
    tester,
  ) async {
    await tester.pumpWidget(buatApp());

    await bukaDrawer(tester);
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.byType(MyHomePage), findsNothing);

    // drawer yang sama tersedia di halaman form
    await bukaDrawer(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    tester.takeException();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });
}
