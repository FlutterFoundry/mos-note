// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Memos';

  @override
  String get welcomeBack => 'Selamat datang kembali';

  @override
  String get signInWithToken => 'Masuk dengan Token Akses Pribadi Anda';

  @override
  String get signInWithCredentials => 'Masuk dengan kredensial Anda';

  @override
  String get personalAccessToken => 'Token Akses Pribadi';

  @override
  String get credentials => 'Kredensial';

  @override
  String get token => 'Token';

  @override
  String get password => 'Kata Sandi';

  @override
  String get enterUsername => 'Masukkan nama pengguna Anda';

  @override
  String get enterPassword => 'Masukkan kata sandi Anda';

  @override
  String get pasteTokenHere => 'Tempel token Anda di sini';

  @override
  String get enterAccessToken => 'Masukkan token akses Anda';

  @override
  String get signIn => 'Masuk';

  @override
  String get tokenHelp =>
      'Buat token di pengaturan Memos Anda\\ndi Pengaturan > Akun Saya > Token Akses.';

  @override
  String get invalidToken =>
      'Token akses tidak valid. Pastikan belum kedaluwarsa.';

  @override
  String get connectToMemos => 'Hubungkan ke Memos';

  @override
  String get enterInstanceUrl => 'Silakan masukkan URL instansi Memos Anda';

  @override
  String get instanceUrl => 'URL Instansi';

  @override
  String get instanceUrlHint => 'https://demo.usememos.com';

  @override
  String get continueBtn => 'Lanjutkan';

  @override
  String get connectionFailed =>
      'Tidak dapat terhubung ke instansi. Periksa URL-nya.';

  @override
  String get memosInfo =>
      'Memos adalah aplikasi catatan sumber terbuka yang di-host sendiri.\\nPelajari lebih lanjut di usememos.com';

  @override
  String get searchMemos => 'Cari memo...';

  @override
  String get noMemos => 'Belum ada memo';

  @override
  String get noResults => 'Tidak ada hasil ditemukan';

  @override
  String get createFirst => 'Ketuk + untuk membuat memo pertama Anda';

  @override
  String get failedToLoad => 'Gagal memuat memo';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get all => 'Semua';

  @override
  String get savedOffline => 'Tersimpan offline';

  @override
  String get offline => 'Offline';

  @override
  String get pendingSync => 'perubahan menunggu sinkronisasi';

  @override
  String get showingCached => 'menampilkan memo tersimpan';

  @override
  String get synced => 'Tersinkron';

  @override
  String syncedPending(int count) {
    return 'Tersinkron ($count menunggu diunggah)';
  }

  @override
  String get newMemo => 'Memo Baru';

  @override
  String get editMemo => 'Edit Memo';

  @override
  String get writeMemo => 'Tulis memo Anda... (ketik / untuk format)';

  @override
  String get save => 'Simpan';

  @override
  String get saved => 'Tersimpan';

  @override
  String failedToSave(String error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String get private => 'Pribadi';

  @override
  String get protected => 'Terlindungi';

  @override
  String get public => 'Publik';

  @override
  String get format => 'Format';

  @override
  String get heading1 => 'Judul 1';

  @override
  String get heading2 => 'Judul 2';

  @override
  String get heading3 => 'Judul 3';

  @override
  String get bold => 'Tebal';

  @override
  String get italic => 'Miring';

  @override
  String get inlineCode => 'Kode Inline';

  @override
  String get codeBlock => 'Blok Kode';

  @override
  String get blockquote => 'Kutipan';

  @override
  String get bulletList => 'Daftar Poin';

  @override
  String get numberedList => 'Daftar Nomor';

  @override
  String get task => 'Tugas';

  @override
  String get link => 'Tautan';

  @override
  String get divider => 'Pembatas';

  @override
  String get tag => 'Tag';

  @override
  String get profile => 'Profil';

  @override
  String get notLoggedIn => 'Tidak masuk';

  @override
  String get instance => 'Instansi';

  @override
  String get account => 'Akun';

  @override
  String get username => 'Nama Pengguna';

  @override
  String get description => 'Deskripsi';

  @override
  String get settings => 'Pengaturan';

  @override
  String get changeInstance => 'Ganti Instansi';

  @override
  String get signOut => 'Keluar';

  @override
  String get signOutConfirm => 'Keluar';

  @override
  String get signOutMessage => 'Apakah Anda yakin ingin keluar?';

  @override
  String get cancel => 'Batal';

  @override
  String get language => 'Bahasa';

  @override
  String get english => 'Inggris';

  @override
  String get indonesian => 'Indonesia';

  @override
  String get languageSettings => 'Pengaturan Bahasa';

  @override
  String get comments => 'Komentar';

  @override
  String get noComments => 'Belum ada komentar';

  @override
  String get addComment => 'Tambahkan komentar...';

  @override
  String get shareMemo => 'Bagikan Memo';

  @override
  String get shareContentAndLink => 'Bagikan konten dan tautan';

  @override
  String get shareLinkOnly => 'Bagikan tautan saja';

  @override
  String get memoNotFound => 'Memo tidak ditemukan';

  @override
  String get deleteMemo => 'Hapus memo';

  @override
  String get deleteMemoConfirm => 'Tindakan ini tidak dapat dibatalkan.';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Edit';
}
