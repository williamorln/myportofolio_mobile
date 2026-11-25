import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'test_helpers.dart';

void main() {
  group('Project', () {
    test('fromJson memetakan kunci snake_case dan mengabaikan field lain', () {
      final project = Project.fromJson({
        'id': 'abc',
        'title': 'Portofolio',
        'problem': 'Masalah',
        'solution': 'Solusi',
        'tech_stack': 'Django',
        'project_url': 'https://contoh.com/',
        'star_count': 3,
      });

      expect(project.id, 'abc');
      expect(project.techStack, 'Django');
      expect(project.projectUrl, 'https://contoh.com/');
    });

    test('project_url yang null atau tidak ada menjadi string kosong', () {
      final base = {
        'title': 'A',
        'problem': 'B',
        'solution': 'C',
        'tech_stack': 'D',
      };

      expect(Project.fromJson({...base, 'project_url': null}).projectUrl, '');
      expect(Project.fromJson(base).projectUrl, '');
    });

    test('toJson memakai snake_case dan tidak mengirim id', () {
      const project = Project(
        id: 'abc',
        title: 'A',
        problem: 'B',
        solution: 'C',
        techStack: 'D',
        projectUrl: 'https://contoh.com/',
      );

      expect(project.toJson(), {
        'title': 'A',
        'problem': 'B',
        'solution': 'C',
        'tech_stack': 'D',
        'project_url': 'https://contoh.com/',
      });
    });
  });

  group('ApiClient', () {
    test('getProjects membaca daftar proyek dari /api/v1/projects/', () async {
      late http.Request diterima;
      final api = apiPalsu((request) async {
        diterima = request;
        return http.Response(proyekContohJson, 200);
      });

      final projects = await api.getProjects();

      expect(diterima.method, 'GET');
      expect(diterima.url.toString(), 'http://tes/api/v1/projects/');
      expect(projects, hasLength(2));
      expect(projects.first.title, 'Portofolio Web');
      expect(projects.last.projectUrl, '');
    });

    test('status bukan 2xx menjadi ApiException', () async {
      final api = apiPalsu((request) async => http.Response('rusak', 500));

      await expectLater(
        api.getProjects(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.message, 'message', 'rusak'),
        ),
      );
    });

    test(
      'createProject mengirim token dan body JSON, lalu membaca balasan',
      () async {
        late http.Request diterima;
        final api = apiPalsu((request) async {
          diterima = request;
          return http.Response(
            '{"id":"baru","title":"A","problem":"B","solution":"C",'
            '"tech_stack":"D","project_url":""}',
            201,
          );
        });

        final hasil = await api.createProject(
          const Project(
            title: 'A',
            problem: 'B',
            solution: 'C',
            techStack: 'D',
          ),
          token: 'rahasia',
        );

        expect(diterima.method, 'POST');
        expect(diterima.url.path, '/api/v1/projects/');
        expect(diterima.headers['Authorization'], 'Token rahasia');
        expect(diterima.headers['Content-Type'], contains('application/json'));
        expect(jsonDecode(diterima.body), containsPair('tech_stack', 'D'));
        expect(jsonDecode(diterima.body), isNot(contains('id')));
        expect(hasil.id, 'baru');
      },
    );

    test('createProject melempar ApiException pada 401', () async {
      final api = apiPalsu((request) async => http.Response('{}', 401));

      await expectLater(
        api.createProject(
          const Project(
            title: 'A',
            problem: 'B',
            solution: 'C',
            techStack: 'D',
          ),
          token: 'kedaluwarsa',
        ),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'kode', 401)),
      );
    });

    test(
      'obtainToken mengirim username dan password lalu mengembalikan token',
      () async {
        late http.Request diterima;
        final api = apiPalsu((request) async {
          diterima = request;
          return http.Response('{"token":"abc123"}', 200);
        });

        final token = await api.obtainToken('william', 'sandi');

        expect(diterima.url.path, '/api/v1/auth/token/');
        expect(jsonDecode(diterima.body), {
          'username': 'william',
          'password': 'sandi',
        });
        expect(token, 'abc123');
      },
    );

    test('obtainToken dengan sandi salah melempar ApiException 400', () async {
      final api = apiPalsu((request) async => http.Response('{}', 400));

      await expectLater(
        api.obtainToken('william', 'salah'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'kode', 400)),
      );
    });

    test('logout memanggil /api/v1/auth/logout/ dengan token', () async {
      late http.Request diterima;
      final api = apiPalsu((request) async {
        diterima = request;
        return http.Response('', 204);
      });

      await api.logout(token: 'abc123');

      expect(diterima.method, 'POST');
      expect(diterima.url.path, '/api/v1/auth/logout/');
      expect(diterima.headers['Authorization'], 'Token abc123');
    });
  });
}
