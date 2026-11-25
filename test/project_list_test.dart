import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';

import 'test_helpers.dart';

void main() {
  Future<void> bukaDaftar(
    WidgetTester tester, {
    Future<http.Response> Function(http.Request request)? handler,
  }) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buatApp(handler: handler));
    await tester.tap(find.text('Lihat Proyek'));
  }

  testWidgets('menampilkan indikator muat lalu daftar proyek dari API', (
    tester,
  ) async {
    await bukaDaftar(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // sebelum Future selesai, yang tampil adalah indikator
    expect(find.byType(ProjectListScreen), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Portofolio Web'), findsOneWidget);
    expect(find.text('Aplikasi Mobile'), findsOneWidget);
    expect(find.textContaining('Django, DRF'), findsOneWidget);
  });

  testWidgets('permintaan hanya dikirim sekali saat layar dibuka', (
    tester,
  ) async {
    var jumlah = 0;
    await bukaDaftar(
      tester,
      handler: (request) async {
        jumlah++;
        return http.Response(proyekContohJson, 200);
      },
    );
    await tester.pumpAndSettle();

    // build ulang (misalnya drawer dibuka) tidak boleh memicu request baru
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    tester.takeException();

    expect(jumlah, 1);
  });

  testWidgets('mengetuk proyek membuka detail yang lengkap', (tester) async {
    await bukaDaftar(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Portofolio Web'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('Butuh etalase karya.'), findsOneWidget);
    expect(find.text('Website dengan Django.'), findsOneWidget);
    expect(find.text('https://contoh.com/'), findsOneWidget);
  });

  testWidgets('detail tanpa project_url tidak menampilkan bagian URL', (
    tester,
  ) async {
    await bukaDaftar(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aplikasi Mobile'));
    await tester.pumpAndSettle();

    expect(find.text('Project URL'), findsNothing);
    expect(find.text('Klien Flutter.'), findsOneWidget);
  });

  testWidgets('daftar kosong menampilkan pesan No projects found.', (
    tester,
  ) async {
    await bukaDaftar(
      tester,
      handler: (request) async => http.Response('[]', 200),
    );
    await tester.pumpAndSettle();

    expect(find.text('No projects found.'), findsOneWidget);
  });

  testWidgets('error ditampilkan dan Retry memuat ulang', (tester) async {
    var gagal = true;
    await bukaDaftar(
      tester,
      handler: (request) async {
        if (gagal) return http.Response('server mati', 500);
        return http.Response(proyekContohJson, 200);
      },
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load projects'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    gagal = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load projects'), findsNothing);
    expect(find.text('Portofolio Web'), findsOneWidget);
  });

  testWidgets('tarik ke bawah memuat ulang daftar', (tester) async {
    var jumlah = 0;
    await bukaDaftar(
      tester,
      handler: (request) async {
        jumlah++;
        return http.Response(proyekContohJson, 200);
      },
    );
    await tester.pumpAndSettle();
    expect(jumlah, 1);

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(jumlah, 2);
  });

  testWidgets('Back dari daftar kembali ke menu', (tester) async {
    await bukaDaftar(tester);
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(ProjectListScreen), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
  });
}
