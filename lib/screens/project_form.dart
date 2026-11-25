import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _problemController = TextEditingController();
  final _solutionController = TextEditingController();
  final _techStackController = TextEditingController();
  final _urlController = TextEditingController();

  // batas panjang disamakan dengan model Django (title dan tech_stack 255,
  // URLField 200), problem dan solution dibatasi 2000 di sini
  static const _maxTitle = 255;
  static const _maxTechStack = 255;
  static const _maxText = 2000;
  static const _maxUrl = 200;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _problemController.dispose();
    _solutionController.dispose();
    _techStackController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  InputDecoration _dekorasi(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    // belum login: layar login dibuka dulu, batal kalau tidak jadi login
    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;

    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final dibuat = await api.createProject(
        Project(
          title: _titleController.text.trim(),
          problem: _problemController.text.trim(),
          solution: _solutionController.text.trim(),
          techStack: _techStackController.text.trim(),
          projectUrl: _urlController.text.trim(),
        ),
        token: auth.token!,
      );
      if (!mounted) return;
      _tampilkanRingkasan(dibuat);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // token ditolak server (kedaluwarsa atau sudah dicabut)
        await auth.logout();
        if (!mounted) return;
        _tampilkanPesan('Sesi habis, silakan login lagi.');
        await ensureLoggedIn(context);
      } else if (e.statusCode == 403) {
        _tampilkanPesan('Hanya pemilik portofolio yang boleh menambah proyek.');
      } else {
        _tampilkanPesan('Gagal menyimpan proyek (${e.statusCode}).');
      }
    } catch (_) {
      if (!mounted) return;
      _tampilkanPesan('Tidak bisa terhubung ke server.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _tampilkanRingkasan(Project project) {
    final baris = <MapEntry<String, String>>[
      MapEntry('Title', project.title),
      MapEntry('Problem', project.problem),
      MapEntry('Solution', project.solution),
      MapEntry('Tech Stack', project.techStack),
      MapEntry(
        'Project URL',
        project.projectUrl.isEmpty ? '-' : project.projectUrl,
      ),
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in baris)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(item.value),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
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

  void _kosongkan() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _problemController.clear();
    _solutionController.clear();
    _techStackController.clear();
    _urlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Project Form',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    maxLength: _maxTitle,
                    maxLengthEnforcement: MaxLengthEnforcement.none,
                    decoration: _dekorasi('Title', hint: 'Nama proyek'),
                    validator: (value) =>
                        validateRequired(value, 'Title', maxLength: _maxTitle),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _problemController,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: _maxText,
                    maxLengthEnforcement: MaxLengthEnforcement.none,
                    decoration: _dekorasi(
                      'Problem',
                      hint: 'Masalah apa yang ingin diselesaikan?',
                    ),
                    validator: (value) =>
                        validateRequired(value, 'Problem', maxLength: _maxText),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _solutionController,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: _maxText,
                    maxLengthEnforcement: MaxLengthEnforcement.none,
                    decoration: _dekorasi(
                      'Solution',
                      hint: 'Bagaimana proyek ini menyelesaikannya?',
                    ),
                    validator: (value) => validateRequired(
                      value,
                      'Solution',
                      maxLength: _maxText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _techStackController,
                    textInputAction: TextInputAction.next,
                    maxLength: _maxTechStack,
                    maxLengthEnforcement: MaxLengthEnforcement.none,
                    decoration: _dekorasi(
                      'Tech Stack',
                      hint: 'Contoh: Flutter, Django, Figma',
                    ),
                    validator: (value) => validateRequired(
                      value,
                      'Tech Stack',
                      maxLength: _maxTechStack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    maxLength: _maxUrl,
                    maxLengthEnforcement: MaxLengthEnforcement.none,
                    decoration: _dekorasi(
                      'Project URL (optional)',
                      hint: 'https://contoh.com/proyek',
                    ),
                    validator: (value) =>
                        validateOptionalUrl(value, maxLength: _maxUrl),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _simpan,
                    icon: _isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Save'),
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
