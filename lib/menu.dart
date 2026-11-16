import 'package:material_ui/material_ui.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506657390";
  final String nama = "William Orlando";
  final String kelas = "PBP E";

  // warna dipasang di model supaya ItemCard tidak perlu if-else per tombol
  final List<ItemHomepage> items = [
    ItemHomepage("Lihat Proyek", Icons.folder, Colors.blue.shade700),
    ItemHomepage("Tambah Proyek", Icons.add_circle, Colors.green.shade700),
    ItemHomepage("Lihat Skills", Icons.bolt, Colors.purple.shade700),
    ItemHomepage("Lihat Pengalaman", Icons.work, Colors.orange.shade900),
    ItemHomepage("Tambah Pengalaman", Icons.post_add, Colors.teal.shade700),
    ItemHomepage("Logout", Icons.logout, Colors.red.shade700),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      // dibatasi 600 px supaya tetap enak dilihat di Chrome yang lebar
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // IntrinsicHeight membuat tiga kartu identitas sama tinggi
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: InfoCard(title: 'NPM', content: npm),
                      ),
                      Expanded(
                        child: InfoCard(title: 'Name', content: nama),
                      ),
                      Expanded(
                        child: InfoCard(title: 'Class', content: kelas),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 32.0),
                  child: Text(
                    'Selamat datang di MyPortfolio Mobile!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                // kisi ikut tinggi isinya, yang menggulir halaman di atasnya
                GridView.count(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [for (final item in items) ItemCard(item)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            // FittedBox mengecilkan teks seperlunya, jadi NPM tidak terpotong
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(content, style: const TextStyle(fontSize: 14.0)),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // sembunyikan SnackBar lama dulu supaya pesan tidak menumpuk
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: item.color,
                content: Row(
                  children: [
                    Icon(item.icon, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text("Kamu telah menekan tombol ${item.name}!"),
                    ),
                  ],
                ),
              ),
            );
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const SizedBox(height: 6),
                // Flexible + maxLines supaya teks panjang tidak mendorong kartu overflow
                Flexible(
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
