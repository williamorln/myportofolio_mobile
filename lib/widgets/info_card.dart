import 'package:material_ui/material_ui.dart';

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
