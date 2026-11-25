import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

/// Memastikan pengguna sudah login. Kalau belum, layar login dibuka dan
/// hasilnya true hanya kalau login berhasil.
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) return true;

  final loggedIn = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
  return loggedIn ?? false;
}

/// Logout lalu memberi tahu lewat SnackBar. Dipakai kartu Logout di menu.
Future<void> logoutWithMessage(BuildContext context) async {
  final auth = context.read<AuthState>();
  final messenger = ScaffoldMessenger.of(context);

  final pesan = auth.isLoggedIn ? 'Kamu berhasil logout.' : 'Kamu belum login.';
  await auth.logout();
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(pesan)));
}
