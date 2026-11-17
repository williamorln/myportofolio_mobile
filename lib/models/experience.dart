import 'package:myportofolio_mobile/utils/formatters.dart';

/// Pilihan kategori, disamakan dengan `EXPERIENCE_CHOICES` di model Django.
enum ExperienceCategory {
  internship('Internship'),
  research('Research'),
  volunteer('Volunteer'),
  partTime('Part-Time'),
  fullTime('Full-Time'),
  freelance('Freelance');

  final String label;
  const ExperienceCategory(this.label);
}

/// Data satu pengalaman yang diisi lewat formulir. Belum disimpan ke mana-mana,
/// hanya ditampilkan di dialog ringkasan.
class ExperienceEntry {
  final String title;
  final ExperienceCategory category;
  final String description;
  final String thumbnail;
  final DateTime startedAt;

  /// null berarti pengalaman masih berjalan (sama seperti `ended_at` di Django).
  final DateTime? endedAt;

  const ExperienceEntry({
    required this.title,
    required this.category,
    required this.description,
    required this.startedAt,
    this.thumbnail = '',
    this.endedAt,
  });

  bool get isOngoing => endedAt == null;

  /// Pasangan label dan nilai untuk dialog ringkasan, urutannya sama dengan formulir.
  List<MapEntry<String, String>> get summary => [
    MapEntry('Judul', title),
    MapEntry('Kategori', category.label),
    MapEntry('Deskripsi', description),
    MapEntry('Thumbnail', thumbnail.isEmpty ? '-' : thumbnail),
    MapEntry('Mulai', formatTanggal(startedAt)),
    MapEntry('Selesai', isOngoing ? 'Masih berjalan' : formatTanggal(endedAt!)),
  ];
}
