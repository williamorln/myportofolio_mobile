import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

typedef Handler = Future<http.Response> Function(http.Request request);

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
ApiClient apiPalsu(Handler handler) =>
    ApiClient(client: MockClient(handler), baseUrl: 'http://tes');

Future<http.Response> _balasanBawaan(http.Request request) async =>
    http.Response(proyekContohJson, 200);

/// Aplikasi lengkap dengan klien palsu. Isi [token] untuk memulai dalam
/// keadaan sudah login.
MyApp buatApp({Handler? handler, String? token}) {
  return MyApp(
    apiClient: apiPalsu(handler ?? _balasanBawaan),
    initialToken: token,
  );
}

/// Satu halaman saja dengan provider yang sama seperti aplikasi aslinya.
Widget bungkus(Widget halaman, {Handler? handler, String? token}) {
  final api = apiPalsu(handler ?? _balasanBawaan);
  return MultiProvider(
    providers: [
      Provider.value(value: api),
      ChangeNotifierProvider(
        create: (_) => AuthState(api, initialToken: token),
      ),
    ],
    child: MaterialApp(home: halaman),
  );
}
