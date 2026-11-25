import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

import 'test_helpers.dart';

void main() {
  Future<void> bukaForm(
    WidgetTester tester, {
    Handler? handler,
    String? token = 'token-tes',
  }) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      bungkus(const ProjectFormPage(), handler: handler, token: token),
    );
  }

  Finder kolom(String label) => find.widgetWithText(TextFormField, label);

  Future<void> isiSemua(WidgetTester tester) async {
    await tester.enterText(kolom('Title'), 'Portofolio Mobile');
    await tester.enterText(kolom('Problem'), 'Butuh akses dari ponsel');
    await tester.enterText(kolom('Solution'), 'Aplikasi Flutter');
    await tester.enterText(kolom('Tech Stack'), 'Flutter, Dart');
  }

  Future<void> tekanSave(WidgetTester tester) async {
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  const balasanDibuat =
      '{"id":"abc","title":"Portofolio Mobile","problem":"Butuh akses dari ponsel",'
      '"solution":"Aplikasi Flutter","tech_stack":"Flutter, Dart","project_url":""}';

  Future<http.Response> berhasil(http.Request request) async =>
      http.Response(balasanDibuat, 201);

  testWidgets('menampilkan kolom sesuai ProjectSerializer', (tester) async {
    await bukaForm(tester);

    for (final label in [
      'Title',
      'Problem',
      'Solution',
      'Tech Stack',
      'Project URL (optional)',
    ]) {
      expect(kolom(label), findsOneWidget, reason: label);
    }
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('form kosong menampilkan error dan tidak memanggil API', (
    tester,
  ) async {
    var dipanggil = false;
    await bukaForm(
      tester,
      handler: (request) async {
        dipanggil = true;
        return http.Response('{}', 201);
      },
    );

    await tekanSave(tester);

    expect(find.text('Title tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Problem tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Solution tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Tech Stack tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(dipanggil, isFalse);
  });

  testWidgets('isian hanya spasi ditolak', (tester) async {
    await bukaForm(tester);

    await tester.enterText(kolom('Title'), '    ');
    await tekanSave(tester);

    expect(find.text('Title tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Project URL yang salah ditolak, yang kosong boleh', (
    tester,
  ) async {
    await bukaForm(tester, handler: berhasil);
    await isiSemua(tester);

    await tester.enterText(kolom('Project URL (optional)'), 'contoh.com');
    await tekanSave(tester);
    expect(find.textContaining('URL tidak valid'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(kolom('Project URL (optional)'), '');
    await tekanSave(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets(
    'input valid mengirim POST dengan token lalu menampilkan dialog',
    (tester) async {
      late http.Request diterima;
      await bukaForm(
        tester,
        handler: (request) async {
          diterima = request;
          return http.Response(balasanDibuat, 201);
        },
      );
      await isiSemua(tester);
      await tekanSave(tester);

      expect(diterima.method, 'POST');
      expect(diterima.url.path, '/api/v1/projects/');
      expect(diterima.headers['Authorization'], 'Token token-tes');
      expect(jsonDecode(diterima.body), {
        'title': 'Portofolio Mobile',
        'problem': 'Butuh akses dari ponsel',
        'solution': 'Aplikasi Flutter',
        'tech_stack': 'Flutter, Dart',
        'project_url': '',
      });

      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Portofolio Mobile'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('OK menutup dialog dan mengosongkan form', (tester) async {
    await bukaForm(tester, handler: berhasil);
    await isiSemua(tester);
    await tekanSave(tester);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Portofolio Mobile'), findsNothing);

    // menyimpan lagi tanpa isian harus ditolak, bukan memakai data lama
    await tekanSave(tester);
    expect(find.text('Title tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('belum login: Save membuka layar login, bukan memanggil API', (
    tester,
  ) async {
    var dipanggil = false;
    await bukaForm(
      tester,
      token: null,
      handler: (request) async {
        dipanggil = true;
        return http.Response(balasanDibuat, 201);
      },
    );
    await isiSemua(tester);
    await tekanSave(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(dipanggil, isFalse);
  });

  testWidgets('setelah login berhasil, kembali ke form dan bisa menyimpan', (
    tester,
  ) async {
    final permintaan = <String>[];
    await bukaForm(
      tester,
      token: null,
      handler: (request) async {
        permintaan.add(request.url.path);
        if (request.url.path == '/api/v1/auth/token/') {
          return http.Response('{"token":"baru"}', 200);
        }
        return http.Response(balasanDibuat, 201);
      },
    );
    await isiSemua(tester);
    await tekanSave(tester);

    await tester.enterText(kolom('Username'), 'william');
    await tester.enterText(kolom('Password'), 'sandi');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(ProjectFormPage), findsOneWidget);
    // isian form tidak hilang selama login
    expect(
      tester.widget<TextFormField>(kolom('Title')).controller!.text,
      'Portofolio Mobile',
    );

    await tekanSave(tester);
    expect(permintaan, ['/api/v1/auth/token/', '/api/v1/projects/']);
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
  });

  testWidgets('401 dari server: logout dan layar login dibuka lagi', (
    tester,
  ) async {
    final permintaan = <String>[];
    await bukaForm(
      tester,
      handler: (request) async {
        permintaan.add(request.url.path);
        return http.Response('{"detail":"Invalid token."}', 401);
      },
    );
    await isiSemua(tester);
    await tekanSave(tester);

    expect(permintaan, contains('/api/v1/auth/logout/'));
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('403 dari server menampilkan SnackBar tanpa dialog', (
    tester,
  ) async {
    await bukaForm(tester, handler: (r) async => http.Response('{}', 403));
    await isiSemua(tester);
    await tekanSave(tester);

    expect(
      find.text('Hanya pemilik portofolio yang boleh menambah proyek.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('error lain menampilkan kode statusnya', (tester) async {
    await bukaForm(tester, handler: (r) async => http.Response('oops', 500));
    await isiSemua(tester);
    await tekanSave(tester);

    expect(find.text('Gagal menyimpan proyek (500).'), findsOneWidget);
  });

  testWidgets('gagal tersambung menampilkan pesan koneksi', (tester) async {
    await bukaForm(
      tester,
      handler: (r) async => throw http.ClientException('putus'),
    );
    await isiSemua(tester);
    await tekanSave(tester);

    expect(find.text('Tidak bisa terhubung ke server.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
