import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  /// Halaman tujuan kalau kartu ditekan. null berarti kartu hanya menampilkan
  /// SnackBar tanpa berpindah halaman.
  final WidgetBuilder? page;

  /// Kalau true, pengguna harus login dulu sebelum halaman tujuan dibuka.
  final bool requiresLogin;

  /// Aksi khusus yang dijalankan saat kartu ditekan, menggantikan perpindahan
  /// halaman (misalnya Logout).
  final Future<void> Function(BuildContext context)? action;

  ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.page,
    this.requiresLogin = false,
    this.action,
  });
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
        onTap: () async {
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

          final aksi = item.action;
          if (aksi != null) {
            await aksi(context);
            return;
          }

          final tujuan = item.page;
          if (tujuan == null) return;

          if (item.requiresLogin) {
            final loggedIn = await ensureLoggedIn(context);
            if (!loggedIn || !context.mounted) return;
          }
          // push (bukan pushReplacement) supaya tombol Back kembali ke menu
          Navigator.push(context, MaterialPageRoute(builder: tujuan));
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
