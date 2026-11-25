import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  /// Satu opsi drawer. pushReplacement dipakai supaya halaman yang sedang
  /// dibuka diganti, bukan ditumpuk di atas halaman sebelumnya. Kalau
  /// [requiresLogin] true, layar login dibuka lebih dulu bila belum login.
  Widget _opsi(
    BuildContext context, {
    required IconData ikon,
    required String judul,
    required Widget Function() halaman,
    bool requiresLogin = false,
  }) {
    return ListTile(
      leading: Icon(ikon),
      title: Text(judul),
      onTap: () async {
        if (requiresLogin && !await ensureLoggedIn(context)) return;
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => halaman()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch supaya opsi Login/Logout berganti saat status login berubah
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Portfolio',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore personal projects and experiences!',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
          _opsi(
            context,
            ikon: Icons.home_outlined,
            judul: 'Home',
            halaman: () => MyHomePage(),
          ),
          _opsi(
            context,
            ikon: Icons.folder_outlined,
            judul: 'Projects',
            halaman: () => const ProjectListScreen(),
          ),
          _opsi(
            context,
            ikon: Icons.add_circle_outline,
            judul: 'Add Project',
            halaman: () => const ProjectFormPage(),
            requiresLogin: true,
          ),
          _opsi(
            context,
            ikon: Icons.work_outline,
            judul: 'Add Experience',
            halaman: () => const ExperienceFormPage(),
          ),
          const Divider(),
          if (!isLoggedIn)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () => ensureLoggedIn(context),
            )
          else
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final auth = context.read<AuthState>();
                final messenger = ScaffoldMessenger.of(context);
                // drawer ditutup dulu, context-nya tidak dipakai lagi setelah await
                Navigator.pop(context);
                await auth.logout();
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Kamu berhasil logout.')),
                  );
              },
            ),
        ],
      ),
    );
  }
}
