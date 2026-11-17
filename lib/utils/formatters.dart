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
