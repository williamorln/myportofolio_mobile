import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  /// Satu opsi drawer. pushReplacement dipakai supaya halaman yang sedang
  /// dibuka diganti, bukan ditumpuk di atas halaman sebelumnya.
  Widget _opsi(
    BuildContext context, {
    required IconData ikon,
    required String judul,
    required Widget Function() halaman,
  }) {
    return ListTile(
      leading: Icon(ikon),
      title: Text(judul),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => halaman()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          ),
          _opsi(
            context,
            ikon: Icons.work_outline,
            judul: 'Add Experience',
            halaman: () => const ExperienceFormPage(),
          ),
        ],
      ),
    );
  }
}
