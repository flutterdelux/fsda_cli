// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get create => 'Buat';

  @override
  String get add => 'Tambah';

  @override
  String get edit => 'Ubah';

  @override
  String get update => 'Perbarui';

  @override
  String get remove => 'Hapus';

  @override
  String get delete => 'Hapus';

  @override
  String get refresh => 'Segarkan';

  @override
  String get retry => 'Coba lagi';

  @override
  String get back => 'Kembali';

  @override
  String get backToHome => 'Kembali ke Beranda';

  @override
  String get seeAll => 'Lihat Semua';

  @override
  String get more => 'Lainnya';

  @override
  String get invalidArgumentPageTitle => 'Argumen Tidak Valid';

  @override
  String get invalidArgumentPageMessage =>
      'Operasi yang diminta tidak dapat dilakukan karena argumen tidak valid.';

  @override
  String get notFoundPageTitle => 'Tidak Ditemukan';

  @override
  String get notFoundPageMessage => 'Halaman yang Anda cari tidak ada.';

  @override
  String get unknownError => 'Kesalahan tidak diketahui';

  @override
  String get coreFailureUnauthenticated => 'Tidak terautentikasi';

  @override
  String get coreFailureServiceUnavailable => 'Layanan tidak tersedia';

  @override
  String get coreFailureNetworkError => 'Kesalahan jaringan';

  @override
  String get coreFailureTimeoutError => 'Permintaan habis waktu';

  @override
  String get coreFailureServerError => 'Kesalahan server';

  @override
  String get coreFailureCacheError => 'Kesalahan cache';
}
