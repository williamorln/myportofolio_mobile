import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp(apiClient: ApiClient()));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.apiClient, this.initialToken, super.key});

  final ApiClient apiClient;

  /// Token awal kalau aplikasi dibuka dalam keadaan sudah login.
  final String? initialToken;

  @override
  Widget build(BuildContext context) {
    // objek yang sering dipakai (klien API dan status login) disisipkan ke
    // widget tree lewat provider supaya layar mana pun bisa mengambilnya
    return MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        ChangeNotifierProvider(
          create: (_) => AuthState(apiClient, initialToken: initialToken),
        ),
      ],
      child: MaterialApp(
        title: 'MyPortfolio',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: MyHomePage(),
      ),
    );
  }
}
