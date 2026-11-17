const _namaBulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Contoh: `DateTime(2026, 11, 17)` menjadi "17 November 2026".
String formatTanggal(DateTime tanggal) =>
    '${tanggal.day} ${_namaBulan[tanggal.month - 1]} ${tanggal.year}';

/// Lama waktu antara [mulai] dan [selesai] dalam tahun dan bulan penuh.
/// Kalau belum sebulan, dihitung dalam hari (hari mulai dan selesai ikut dihitung).
/// Contoh: 1 Juni 2025 sampai 30 Agustus 2025 menjadi "2 bulan".
String formatDurasi(DateTime mulai, DateTime selesai) {
  final awal = DateTime(mulai.year, mulai.month, mulai.day);
  final akhir = DateTime(selesai.year, selesai.month, selesai.day);

  var bulan = (akhir.year - awal.year) * 12 + akhir.month - awal.month;
  if (akhir.day < awal.day) bulan -= 1;

  if (bulan < 1) {
    final hari = akhir.difference(awal).inDays + 1;
    return '$hari hari';
  }

  final tahun = bulan ~/ 12;
  final sisa = bulan % 12;
  return [if (tahun > 0) '$tahun tahun', if (sisa > 0) '$sisa bulan'].join(' ');
}
