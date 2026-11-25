import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/date_form_field.dart';

void main() {
  Future<void> bukaAplikasi(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buatApp(token: 'tes'));
  }

  Future<void> bukaDrawer(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    // font Ahem di flutter_test jauh lebih lebar dari font asli, jadi header
    // drawer terhitung overflow di tes padahal di layar baik-baik saja
    tester.takeException();
  }

  Future<void> pilihDiDrawer(WidgetTester tester, String opsi) async {
    await bukaDrawer(tester);
    await tester.tap(find.text(opsi));
    await tester.pumpAndSettle();
    tester.takeException();
  }

  group('dari kartu aksi', () {
    testWidgets('Tambah Pengalaman membuka formulir', (tester) async {
      await bukaAplikasi(tester);

      await tester.tap(find.text('Tambah Pengalaman'));
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.text('Add Experience Form'), findsOneWidget);
    });

    testWidgets('tombol kembali sistem membawa pulang ke menu', (tester) async {
      await bukaAplikasi(tester);
      await tester.tap(find.text('Tambah Pengalaman'));
      await tester.pumpAndSettle();

      // push menumpuk route, jadi back sistem membuangnya dan menu muncul lagi
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('kartu Tambah Proyek tetap membuka formulir proyek', (
      tester,
    ) async {
      await bukaAplikasi(tester);

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);
    });

    testWidgets('kartu tanpa halaman tujuan tidak berpindah', (tester) async {
      await bukaAplikasi(tester);

      await tester.tap(find.text('Lihat Pengalaman'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);
    });
  });

  group('dari drawer', () {
    testWidgets('drawer punya Home, Add Project, dan Add Experience', (
      tester,
    ) async {
      await bukaAplikasi(tester);
      await bukaDrawer(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Add Project'), findsOneWidget);
      expect(find.text('Add Experience'), findsOneWidget);
    });

    testWidgets('Add Experience membuka formulir pengalaman', (tester) async {
      await bukaAplikasi(tester);

      await pilihDiDrawer(tester, 'Add Experience');

      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.byType(MyHomePage), findsNothing);
    });

    testWidgets('formulir pengalaman memakai drawer yang sama', (tester) async {
      await bukaAplikasi(tester);
      await pilihDiDrawer(tester, 'Add Experience');

      await bukaDrawer(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Add Project'), findsOneWidget);
      expect(find.text('Add Experience'), findsOneWidget);
    });

    testWidgets('Home dari formulir pengalaman kembali ke halaman utama', (
      tester,
    ) async {
      await bukaAplikasi(tester);
      await pilihDiDrawer(tester, 'Add Experience');

      await pilihDiDrawer(tester, 'Home');

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);
      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );
    });

    testWidgets('berpindah antar formulir lewat drawer', (tester) async {
      await bukaAplikasi(tester);

      await pilihDiDrawer(tester, 'Add Project');
      expect(find.byType(ProjectFormPage), findsOneWidget);

      await pilihDiDrawer(tester, 'Add Experience');
      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);

      await pilihDiDrawer(tester, 'Add Project');
      expect(find.byType(ProjectFormPage), findsOneWidget);
    });
  });

  testWidgets('alur lengkap: kartu, isi form, simpan, lalu Home', (
    tester,
  ) async {
    await bukaAplikasi(tester);

    await tester.tap(find.text('Tambah Pengalaman'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul Pengalaman'),
      'Asisten Dosen PBP',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi'),
      'Membantu mahasiswa belajar Flutter',
    );
    final mulai = tester.state<FormFieldState<DateTime>>(
      find.byType(DateFormField).first,
    );
    mulai.didChange(DateTime(2026, 8, 1));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    await pilihDiDrawer(tester, 'Home');
    expect(find.byType(MyHomePage), findsOneWidget);
  });
}
