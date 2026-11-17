// Aturan validasi formulir. Semuanya fungsi murni (tanpa widget) supaya mudah
// dites sendiri. Mengembalikan pesan error, atau null kalau isiannya lolos.

DateTime _hanyaTanggal(DateTime t) => DateTime(t.year, t.month, t.day);

/// Isian wajib: tidak boleh kosong atau hanya spasi, dan tidak lebih panjang
/// dari [maxLength] (isian dipangkas dulu sebelum dihitung).
String? validateRequired(String? value, String label, {int maxLength = 255}) {
  final teks = value?.trim() ?? '';
  if (teks.isEmpty) return '$label tidak boleh kosong!';
  if (teks.length > maxLength) return '$label maksimal $maxLength karakter!';
  return null;
}

/// URL opsional: boleh kosong, tapi kalau diisi harus http atau https dengan
/// host yang valid dan tidak lebih panjang dari [maxLength].
String? validateOptionalUrl(String? value, {int maxLength = 500}) {
  final teks = value?.trim() ?? '';
  if (teks.isEmpty) return null;
  if (teks.length > maxLength) return 'URL maksimal $maxLength karakter!';

  final uri = Uri.tryParse(teks);
  final skemaValid =
      uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  final hostValid =
      uri != null &&
      uri.host.isNotEmpty &&
      (uri.host.contains('.') || uri.host == 'localhost');
  if (!skemaValid || !hostValid) {
    return 'URL tidak valid, contoh: https://contoh.com/gambar.png';
  }
  return null;
}

/// Tanggal mulai wajib diisi dan tidak boleh di masa depan.
String? validateStartDate(DateTime? mulai, {DateTime? now}) {
  if (mulai == null) return 'Tanggal mulai harus dipilih!';
  final hariIni = _hanyaTanggal(now ?? DateTime.now());
  if (_hanyaTanggal(mulai).isAfter(hariIni)) {
    return 'Tanggal mulai tidak boleh di masa depan!';
  }
  return null;
}

/// Tanggal selesai: tidak perlu diisi kalau [sedangBerjalan], selain itu wajib,
/// tidak boleh sebelum [mulai], dan tidak boleh di masa depan.
String? validateEndDate(
  DateTime? selesai,
  DateTime? mulai, {
  required bool sedangBerjalan,
  DateTime? now,
}) {
  if (sedangBerjalan) return null;
  if (selesai == null) {
    return 'Pilih tanggal selesai atau aktifkan "Masih berjalan"!';
  }
  if (mulai != null && _hanyaTanggal(selesai).isBefore(_hanyaTanggal(mulai))) {
    return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
  }
  final hariIni = _hanyaTanggal(now ?? DateTime.now());
  if (_hanyaTanggal(selesai).isAfter(hariIni)) {
    return 'Tanggal selesai tidak boleh di masa depan!';
  }
  return null;
}
