import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Contoh data proyek dalam bentuk yang sama dengan balasan API Django.
const proyekContohJson =
    '[{"id":"6f1c2b0e-0000-4000-8000-000000000001","title":"Portofolio Web",'
    '"problem":"Butuh etalase karya.","solution":"Website dengan Django.",'
    '"tech_stack":"Django, DRF","project_url":"https://contoh.com/","star_count":2,'
    '"is_starred":false,"starred_by_names":"a, b"},'
    '{"id":"6f1c2b0e-0000-4000-8000-000000000002","title":"Aplikasi Mobile",'
    '"problem":"Akses dari ponsel.","solution":"Klien Flutter.",'
    '"tech_stack":"Flutter","project_url":null,"star_count":0,'
    '"is_starred":false,"starred_by_names":""}]';

/// ApiClient dengan MockClient supaya tes tidak memanggil jaringan sungguhan.
ApiClient apiPalsu(
  Future<http.Response> Function(http.Request request) handler,
) => ApiClient(client: MockClient(handler), baseUrl: 'http://tes');

/// Aplikasi lengkap dengan klien palsu yang membalas daftar proyek contoh.
MyApp buatApp({Future<http.Response> Function(http.Request request)? handler}) {
  return MyApp(
    apiClient: apiPalsu(
      handler ?? (request) async => http.Response(proyekContohJson, 200),
    ),
  );
}
