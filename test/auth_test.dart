import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import 'test_helpers.dart';

void main() {
  // balasan API palsu: login berhasil kalau sandinya "benar"
  Future<http.Response> apiLogin(http.Request request) async {
    switch (request.url.path) {
      case '/api/v1/auth/token/':
        return request.body.contains('"password":"benar"')
            ? http.Response('{"token":"abc123"}', 200)
            : http.Response('{"non_field_errors":["salah"]}', 400);
      case '/api/v1/auth/logout/':
        return http.Response('', 204);
      default:
        return http.Response(proyekContohJson, 200);
    }
  }

  Future<void> pakaiLayarTinggi(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> bukaDrawer(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    // font Ahem membuat header drawer terhitung overflow di tes
    tester.takeException();
  }

  Future<void> isiLogin(
    WidgetTester tester,
    String username,
    String password,
  ) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      username,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      password,
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
  }

  group('AuthState', () {
    test('login menyimpan token dan memberi tahu listener', () async {
      final auth = AuthState(apiPalsu(apiLogin));
      var dipanggil = 0;
      auth.addListener(() => dipanggil++);

      expect(auth.isLoggedIn, isFalse);
      await auth.login('william', 'benar');

      expect(auth.isLoggedIn, isTrue);
      expect(auth.token, 'abc123');
      expect(dipanggil, 1);
    });

    test('login gagal tidak menyimpan token', () async {
      final auth = AuthState(apiPalsu(apiLogin));

      await expectLater(
        auth.login('william', 'salah'),
        throwsA(isA<ApiException>()),
      );
      expect(auth.isLoggedIn, isFalse);
    });

    test('logout menghapus token dan memanggil API', () async {
      final dipanggil = <String>[];
      final auth = AuthState(
        apiPalsu((request) async {
          dipanggil.add(request.url.path);
          return http.Response('', 204);
        }),
        initialToken: 'abc123',
      );

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
      expect(dipanggil, ['/api/v1/auth/logout/']);
    });

    test('logout tetap menghapus token walau server menolak', () async {
      final auth = AuthState(
        apiPalsu((request) async => http.Response('{}', 401)),
        initialToken: 'kedaluwarsa',
      );
      var dipanggil = 0;
      auth.addListener(() => dipanggil++);

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
      expect(dipanggil, 1);
    });

    test(
      'logout saat offline tetap menghapus token tanpa melempar error',
      () async {
        final auth = AuthState(
          apiPalsu((request) async => throw http.ClientException('putus')),
          initialToken: 'abc123',
        );

        await auth.logout();

        expect(auth.isLoggedIn, isFalse);
      },
    );

    test('logout saat belum login tidak mengirim request', () async {
      var jumlah = 0;
      final auth = AuthState(
        apiPalsu((request) async {
          jumlah++;
          return http.Response('', 204);
        }),
      );

      await auth.logout();

      expect(jumlah, 0);
    });
  });

  group('LoginScreen', () {
    Future<void> bukaLogin(WidgetTester tester, {Handler? handler}) async {
      await pakaiLayarTinggi(tester);
      await tester.pumpWidget(
        bungkus(const LoginScreen(), handler: handler ?? apiLogin),
      );
    }

    testWidgets('isian kosong ditolak dan API tidak dipanggil', (tester) async {
      var dipanggil = false;
      await bukaLogin(
        tester,
        handler: (request) async {
          dipanggil = true;
          return http.Response('{}', 200);
        },
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Username cannot be empty!'), findsOneWidget);
      expect(find.text('Password cannot be empty!'), findsOneWidget);
      expect(dipanggil, isFalse);
    });

    testWidgets('sandi salah menampilkan SnackBar dan tetap di layar login', (
      tester,
    ) async {
      await bukaLogin(tester);

      await isiLogin(tester, 'william', 'salah');

      expect(find.text('Username atau password salah (400).'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      // tombol aktif lagi supaya bisa dicoba ulang
      final tombol = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Login'),
      );
      expect(tombol.onPressed, isNotNull);
    });

    testWidgets('kode status lain ikut ditampilkan', (tester) async {
      await bukaLogin(tester, handler: (r) async => http.Response('', 503));

      await isiLogin(tester, 'william', 'benar');

      expect(find.text('Login gagal (503).'), findsOneWidget);
    });

    testWidgets('gagal tersambung menampilkan pesan koneksi', (tester) async {
      await bukaLogin(
        tester,
        handler: (r) async => throw http.ClientException('putus'),
      );

      await isiLogin(tester, 'william', 'benar');

      expect(find.text('Tidak bisa terhubung ke server.'), findsOneWidget);
    });
  });

  group('akses lewat kartu menu', () {
    testWidgets('Lihat Proyek bisa dibuka tanpa login', (tester) async {
      await pakaiLayarTinggi(tester);
      await tester.pumpWidget(buatApp(handler: apiLogin));

      await tester.tap(find.text('Lihat Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.text('Portofolio Web'), findsOneWidget);
    });

    testWidgets('Tambah Proyek tanpa login diarahkan ke layar login', (
      tester,
    ) async {
      await pakaiLayarTinggi(tester);
      await tester.pumpWidget(buatApp(handler: apiLogin));

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });

    testWidgets('setelah login berhasil langsung masuk ke form proyek', (
      tester,
    ) async {
      await pakaiLayarTinggi(tester);
      await tester.pumpWidget(buatApp(handler: apiLogin));

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      await isiLogin(tester, 'william', 'benar');

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(ProjectFormPage), findsOneWidget);

      // Back dari form kembali ke menu, bukan ke layar login
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('membatalkan login (Back) tidak membuka form', (tester) async {
      await pakaiLayarTinggi(tester);
      await tester.pumpWidget(buatApp(handler: apiLogin));

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormPage), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('sudah login: Tambah Proyek langsung membuka form', (
      tester,
    ) async {
      await pakaiLayarTinggi(tester);
      await tester.pumpWidget(buatApp(handler: apiLogin, token: 'abc123'));

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(ProjectFormPage), findsOneWidget);
    });

    testWidgets(
      'kartu Logout saat sudah login memanggil API dan memberi pesan',
      (tester) async {
        await pakaiLayarTinggi(tester);
        final dipanggil = <String>[];
        await tester.pumpWidget(
          buatApp(
            token: 'abc123',
            handler: (request) async {
              dipanggil.add(request.url.path);
              return http.Response('', 204);
            },
          ),
        );

        await tester.tap(find.text('Logout'));
        await tester.pumpAndSettle();

        expect(dipanggil, ['/api/v1/auth/logout/']);
        expect(find.text('Kamu berhasil logout.'), findsOneWidget);

        // setelah itu Tambah Proyek kembali meminta login
        await tester.tap(find.text('Tambah Proyek'));
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );

    testWidgets('kartu Logout saat belum login hanya memberi pesan', (
      tester,
    ) async {
      await pakaiLayarTinggi(tester);
      await tester.pumpWidget(buatApp(handler: apiLogin));

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Kamu belum login.'), findsOneWidget);
    });
  });

  group('drawer', () {
    testWidgets('belum login: ada opsi Login, tidak ada Logout', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp(handler: apiLogin));
      await bukaDrawer(tester);

      expect(find.text('Login'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Logout'), findsNothing);
    });

    testWidgets('sudah login: ada opsi Logout, tidak ada Login', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp(handler: apiLogin, token: 'abc123'));
      await bukaDrawer(tester);

      expect(find.widgetWithText(ListTile, 'Logout'), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    });

    testWidgets('Login di drawer membuka layar login dan opsinya berganti', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp(handler: apiLogin));
      await bukaDrawer(tester);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);

      await isiLogin(tester, 'william', 'benar');
      expect(find.byType(LoginScreen), findsNothing);

      await bukaDrawer(tester);
      expect(find.widgetWithText(ListTile, 'Logout'), findsOneWidget);
    });

    testWidgets('Logout di drawer mengakhiri sesi dan menutup drawer', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp(handler: apiLogin, token: 'abc123'));
      await bukaDrawer(tester);

      await tester.tap(find.widgetWithText(ListTile, 'Logout'));
      await tester.pumpAndSettle();
      tester.takeException();

      expect(find.text('Kamu berhasil logout.'), findsOneWidget);

      await bukaDrawer(tester);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Add Project di drawer tanpa login membuka layar login', (
      tester,
    ) async {
      await tester.pumpWidget(buatApp(handler: apiLogin));
      await bukaDrawer(tester);

      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });

    testWidgets('Add Project di drawer setelah login membuka form', (
      tester,
    ) async {
      await pakaiLayarTinggi(tester);
      await tester.pumpWidget(buatApp(handler: apiLogin));
      await bukaDrawer(tester);

      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();
      await isiLogin(tester, 'william', 'benar');
      tester.takeException();

      expect(find.byType(ProjectFormPage), findsOneWidget);
    });
  });
}
