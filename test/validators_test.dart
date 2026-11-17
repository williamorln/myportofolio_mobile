import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/utils/formatters.dart';
import 'package:myportofolio_mobile/utils/validators.dart';

void main() {
  // tanggal acuan tetap supaya tes tidak bergantung pada hari menjalankannya
  final sekarang = DateTime(2026, 11, 17);

  group('validateRequired', () {
    test('menolak null, kosong, dan hanya spasi', () {
      expect(validateRequired(null, 'Judul'), 'Judul tidak boleh kosong!');
      expect(validateRequired('', 'Judul'), 'Judul tidak boleh kosong!');
      expect(validateRequired('   \n ', 'Judul'), 'Judul tidak boleh kosong!');
    });

    test('menerima isian biasa', () {
      expect(validateRequired('Magang Backend', 'Judul'), isNull);
    });

    test('batas panjang dihitung setelah dipangkas', () {
      expect(validateRequired('a' * 255, 'Judul'), isNull);
      expect(
        validateRequired('a' * 256, 'Judul'),
        'Judul maksimal 255 karakter!',
      );
      expect(validateRequired('  ${'a' * 255}  ', 'Judul'), isNull);
      expect(validateRequired('abcd', 'Judul', maxLength: 3), isNotNull);
    });
  });

  group('validateOptionalUrl', () {
    test('boleh kosong', () {
      expect(validateOptionalUrl(null), isNull);
      expect(validateOptionalUrl('   '), isNull);
    });

    test('menerima http dan https', () {
      expect(validateOptionalUrl('https://contoh.com/gambar.png'), isNull);
      expect(validateOptionalUrl('http://contoh.co.id'), isNull);
      expect(validateOptionalUrl('http://localhost:8000/a.png'), isNull);
    });

    test('menolak yang bukan URL web', () {
      for (final salah in [
        'contoh.com',
        'ftp://contoh.com/a.png',
        'https://',
        'https://tanpa-titik',
        'bukan url',
        'javascript:alert(1)',
      ]) {
        expect(validateOptionalUrl(salah), isNotNull, reason: salah);
      }
    });

    test('menolak URL lebih dari 500 karakter', () {
      final panjang = 'https://contoh.com/${'a' * 490}';
      expect(validateOptionalUrl(panjang), 'URL maksimal 500 karakter!');
    });
  });

  group('validateStartDate', () {
    test('wajib dipilih', () {
      expect(
        validateStartDate(null, now: sekarang),
        'Tanggal mulai harus dipilih!',
      );
    });

    test('hari ini dan masa lalu lolos, masa depan ditolak', () {
      expect(validateStartDate(DateTime(2026, 11, 17), now: sekarang), isNull);
      expect(validateStartDate(DateTime(2024, 1, 5), now: sekarang), isNull);
      expect(
        validateStartDate(DateTime(2026, 11, 18), now: sekarang),
        'Tanggal mulai tidak boleh di masa depan!',
      );
    });
  });

  group('validateEndDate', () {
    final mulai = DateTime(2025, 6, 1);

    test('tidak perlu diisi kalau masih berjalan', () {
      expect(
        validateEndDate(null, mulai, sedangBerjalan: true, now: sekarang),
        isNull,
      );
    });

    test('wajib diisi kalau tidak berjalan', () {
      expect(
        validateEndDate(null, mulai, sedangBerjalan: false, now: sekarang),
        contains('Masih berjalan'),
      );
    });

    test('tidak boleh sebelum tanggal mulai', () {
      expect(
        validateEndDate(
          DateTime(2025, 5, 31),
          mulai,
          sedangBerjalan: false,
          now: sekarang,
        ),
        'Tanggal selesai tidak boleh sebelum tanggal mulai!',
      );
    });

    test('sama dengan tanggal mulai masih boleh', () {
      expect(
        validateEndDate(mulai, mulai, sedangBerjalan: false, now: sekarang),
        isNull,
      );
    });

    test('jam di tanggal yang sama tidak mempengaruhi hasil', () {
      expect(
        validateEndDate(
          DateTime(2025, 6, 1, 0, 0),
          DateTime(2025, 6, 1, 23, 59),
          sedangBerjalan: false,
          now: sekarang,
        ),
        isNull,
      );
    });

    test('tidak boleh di masa depan', () {
      expect(
        validateEndDate(
          DateTime(2026, 12, 1),
          mulai,
          sedangBerjalan: false,
          now: sekarang,
        ),
        'Tanggal selesai tidak boleh di masa depan!',
      );
    });
  });

  group('formatTanggal', () {
    test('memakai nama bulan Indonesia', () {
      expect(formatTanggal(DateTime(2026, 11, 17)), '17 November 2026');
      expect(formatTanggal(DateTime(2025, 1, 5)), '5 Januari 2025');
      expect(formatTanggal(DateTime(2024, 8, 31)), '31 Agustus 2024');
    });
  });

  group('formatDurasi', () {
    test('kurang dari sebulan dihitung dalam hari, kedua ujung ikut', () {
      expect(
        formatDurasi(DateTime(2025, 6, 1), DateTime(2025, 6, 1)),
        '1 hari',
      );
      expect(
        formatDurasi(DateTime(2025, 6, 1), DateTime(2025, 6, 20)),
        '20 hari',
      );
    });

    test('bulan penuh, dan sisa hari tidak membulatkan ke atas', () {
      expect(
        formatDurasi(DateTime(2025, 6, 1), DateTime(2025, 8, 30)),
        '2 bulan',
      );
      expect(
        formatDurasi(DateTime(2025, 6, 15), DateTime(2025, 8, 14)),
        '1 bulan',
      );
      expect(
        formatDurasi(DateTime(2025, 6, 15), DateTime(2025, 8, 15)),
        '2 bulan',
      );
    });

    test('lebih dari setahun memakai tahun dan bulan', () {
      expect(
        formatDurasi(DateTime(2024, 1, 10), DateTime(2025, 1, 10)),
        '1 tahun',
      );
      expect(
        formatDurasi(DateTime(2024, 1, 10), DateTime(2026, 4, 12)),
        '2 tahun 3 bulan',
      );
    });

    test('jam di dalam tanggal tidak mempengaruhi hasil', () {
      expect(
        formatDurasi(DateTime(2025, 6, 1, 23, 59), DateTime(2025, 6, 1, 0, 0)),
        '1 hari',
      );
    });
  });

  group('ExperienceEntry', () {
    test('summary berisi semua isian berurutan', () {
      final entry = ExperienceEntry(
        title: 'Magang Backend',
        category: ExperienceCategory.internship,
        description: 'Membuat REST API',
        startedAt: DateTime(2025, 6, 1),
        endedAt: DateTime(2025, 8, 30),
      );

      expect(entry.isOngoing, isFalse);
      final ringkasan = entry.summary();
      expect(ringkasan.map((e) => e.key), [
        'Judul',
        'Kategori',
        'Deskripsi',
        'Thumbnail',
        'Mulai',
        'Selesai',
        'Durasi',
      ]);
      expect(ringkasan[1].value, 'Internship');
      expect(ringkasan[3].value, '-');
      expect(ringkasan[4].value, '1 Juni 2025');
      expect(ringkasan[5].value, '30 Agustus 2025');
      expect(ringkasan[6].value, '2 bulan');
    });

    test('tanpa tanggal selesai dianggap masih berjalan', () {
      final entry = ExperienceEntry(
        title: 'Freelance Web',
        category: ExperienceCategory.freelance,
        description: 'Membangun situs',
        startedAt: DateTime(2026, 1, 10),
      );

      final ringkasan = entry.summary(now: DateTime(2026, 11, 17));
      expect(entry.isOngoing, isTrue);
      expect(ringkasan[5].value, 'Masih berjalan');
      expect(ringkasan[6].value, '10 bulan (sampai sekarang)');
    });

    test('kategori sama dengan pilihan di model Django', () {
      expect(ExperienceCategory.values.map((c) => c.label), [
        'Internship',
        'Research',
        'Volunteer',
        'Part-Time',
        'Full-Time',
        'Freelance',
      ]);
    });
  });
}
