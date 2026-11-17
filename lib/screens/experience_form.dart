import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/date_form_field.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  // controller dipakai supaya isi kolom bisa dikosongkan lagi setelah disimpan
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _thumbnailController = TextEditingController();

  // kunci kolom tanggal, dipakai membaca nilainya dan mengosongkannya
  final _mulaiKey = GlobalKey<FormFieldState<DateTime>>();
  final _selesaiKey = GlobalKey<FormFieldState<DateTime>>();

  // sama dengan default 'full-time' di model Django
  static const _kategoriAwal = ExperienceCategory.fullTime;
  ExperienceCategory _kategori = _kategoriAwal;
  bool _berjalan = false;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  InputDecoration _dekorasi(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final entry = ExperienceEntry(
      title: _judulController.text.trim(),
      category: _kategori,
      description: _deskripsiController.text.trim(),
      thumbnail: _thumbnailController.text.trim(),
      startedAt: _mulaiKey.currentState!.value!,
      endedAt: _berjalan ? null : _selesaiKey.currentState!.value,
    );
    _tampilkanRingkasan(entry);
  }

  void _tampilkanRingkasan(ExperienceEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pengalaman berhasil disimpan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final baris in entry.summary)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          baris.key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(baris.value),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.pop(context);
                _kosongkan();
              },
            ),
          ],
        );
      },
    );
  }

  /// Mengembalikan formulir ke keadaan awal setelah dialog ditutup.
  void _kosongkan() {
    _formKey.currentState!.reset();
    _judulController.clear();
    _deskripsiController.clear();
    _thumbnailController.clear();
    setState(() {
      _kategori = _kategoriAwal;
      _berjalan = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Experience Form',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // lebar dibatasi seperti halaman utama, isi digulir kalau layar pendek
      // atau papan ketik sedang tampil
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // === Judul ===
                  TextFormField(
                    controller: _judulController,
                    decoration: _dekorasi(
                      'Judul Pengalaman',
                      hint: 'Contoh: Magang Backend Developer',
                    ),
                    validator: (value) =>
                        validateRequired(value, 'Judul', maxLength: 255),
                  ),
                  const SizedBox(height: 16),

                  // === Kategori ===
                  DropdownButtonFormField<ExperienceCategory>(
                    decoration: _dekorasi('Kategori'),
                    initialValue: _kategoriAwal,
                    items: [
                      for (final kategori in ExperienceCategory.values)
                        DropdownMenuItem(
                          value: kategori,
                          child: Text(kategori.label),
                        ),
                    ],
                    onChanged: (nilai) => setState(() => _kategori = nilai!),
                  ),
                  const SizedBox(height: 16),

                  // === Deskripsi ===
                  TextFormField(
                    controller: _deskripsiController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: _dekorasi(
                      'Deskripsi',
                      hint: 'Apa yang kamu kerjakan?',
                    ),
                    validator: (value) =>
                        validateRequired(value, 'Deskripsi', maxLength: 1000),
                  ),
                  const SizedBox(height: 16),

                  // === Thumbnail (opsional) ===
                  TextFormField(
                    controller: _thumbnailController,
                    keyboardType: TextInputType.url,
                    decoration: _dekorasi(
                      'URL Thumbnail (opsional)',
                      hint: 'https://contoh.com/gambar.png',
                    ),
                    validator: validateOptionalUrl,
                  ),
                  const SizedBox(height: 16),

                  // === Tanggal mulai ===
                  DateFormField(
                    key: _mulaiKey,
                    label: 'Tanggal Mulai',
                    validator: (tanggal) => validateStartDate(tanggal),
                  ),
                  const SizedBox(height: 8),

                  // === Masih berjalan ===
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Masih berjalan'),
                    value: _berjalan,
                    onChanged: (nilai) {
                      setState(() => _berjalan = nilai);
                      // tanggal selesai tidak berlaku lagi, jadi dikosongkan
                      if (nilai) _selesaiKey.currentState?.didChange(null);
                    },
                  ),
                  const SizedBox(height: 8),

                  // === Tanggal selesai ===
                  DateFormField(
                    key: _selesaiKey,
                    label: 'Tanggal Selesai',
                    enabled: !_berjalan,
                    disabledText: 'Masih berjalan',
                    validator: (tanggal) => validateEndDate(
                      tanggal,
                      _mulaiKey.currentState?.value,
                      sedangBerjalan: _berjalan,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // === Tombol Simpan ===
                  FilledButton.icon(
                    onPressed: _simpan,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
