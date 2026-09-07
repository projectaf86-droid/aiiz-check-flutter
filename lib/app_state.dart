import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AppStore extends ChangeNotifier {
  // ============================================================
  // STORAGE
  // ============================================================

  static const String _storageKey = 'aiiz_check_state_v2';

  // ============================================================
  // NOTIFIER KHUSUS
  // Supaya login/dark mode tidak membuat seluruh root aplikasi
  // rebuild setiap checklist atau kegiatan berubah.
  // ============================================================

  final ValueNotifier<bool> authNotifier =
      ValueNotifier<bool>(false);

  final ValueNotifier<bool> darkModeNotifier =
      ValueNotifier<bool>(false);

  // ============================================================
  // DATA DOKUMEN
  // ============================================================

  String documentTitle =
      'CHECKLIST KEBERSIHAN & KERAPIAN HARIAN TEMPAT KERJA';

  String place = 'Kantor Pusat';

  String personInCharge = 'Penanggung Jawab';

  String userName = 'Petugas';

  int month = 9;

  int year = 2026;

  bool darkMode = false;

  // ============================================================
  // DATA KEGIATAN & CHECKLIST
  // ============================================================

  final List<ActivityItem> activities = [];

  final Map<String, bool> checks = {};

  // ============================================================
  // DATA AKUN
  // ============================================================

  final List<LocalUser> users = [];

  String? currentUserId;

  // ============================================================
  // GETTER
  // ============================================================

  int get daysInMonth {
    return DateTime(
      year,
      month + 1,
      0,
    ).day;
  }

  LocalUser? get currentUser {
    final id = currentUserId;

    if (id == null) {
      return null;
    }

    for (final user in users) {
      if (user.id == id) {
        return user;
      }
    }

    return null;
  }

  bool get isLoggedIn {
    return currentUser != null;
  }

  int get totalPossible {
    return activities.length * daysInMonth;
  }

  int get totalChecked {
    var count = 0;

    for (final activity in activities) {
      for (var day = 1; day <= daysInMonth; day++) {
        if (isChecked(activity.id, day)) {
          count++;
        }
      }
    }

    return count;
  }

  double get progress {
    if (totalPossible == 0) {
      return 0;
    }

    return totalChecked / totalPossible;
  }

  // ============================================================
  // CHECK KEY
  // ============================================================

  String checkKey(
    String activityId,
    int day,
  ) {
    return '$year-$month-$day|$activityId';
  }

  bool isChecked(
    String activityId,
    int day,
  ) {
    return checks[
          checkKey(
            activityId,
            day,
          )
        ] ??
        false;
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_storageKey);

    if (raw == null) {
      _seedActivities();

      authNotifier.value = false;
      darkModeNotifier.value = darkMode;

      return;
    }

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;

      documentTitle =
          data['documentTitle'] as String? ?? documentTitle;

      place = data['place'] as String? ?? place;

      personInCharge =
          data['personInCharge'] as String? ?? personInCharge;

      userName = data['userName'] as String? ?? userName;

      month = data['month'] as int? ?? month;

      year = data['year'] as int? ?? year;

      darkMode = data['darkMode'] as bool? ?? false;

      currentUserId = data['currentUserId'] as String?;

      // ========================================================
      // LOAD KEGIATAN
      // ========================================================

      activities
        ..clear()
        ..addAll(
          (data['activities'] as List<dynamic>? ?? const [])
              .map(
            (item) {
              return ActivityItem.fromJson(
                Map<String, dynamic>.from(
                  item as Map,
                ),
              );
            },
          ),
        );

      // ========================================================
      // LOAD CHECKLIST
      // ========================================================

      checks
        ..clear()
        ..addAll(
          (data['checks'] as Map<String, dynamic>? ?? const {})
              .map(
            (key, value) {
              return MapEntry(
                key,
                value == true,
              );
            },
          ),
        );

      // ========================================================
      // LOAD USERS
      // ========================================================

      users
        ..clear()
        ..addAll(
          (data['users'] as List<dynamic>? ?? const []).map(
            (item) {
              return LocalUser.fromJson(
                Map<String, dynamic>.from(
                  item as Map,
                ),
              );
            },
          ),
        );

      if (activities.isEmpty) {
        _seedActivities();
      }

      // Kalau akun yang tersimpan sudah tidak ada,
      // hapus sesi login.
      if (currentUserId != null && currentUser == null) {
        currentUserId = null;
      }

      // Sinkron nama user.
      if (currentUser != null) {
        userName = currentUser!.name;
      }
    } catch (e) {
      _seedActivities();

      currentUserId = null;
    }

    // ==========================================================
    // SINKRON NOTIFIER
    // ==========================================================

    authNotifier.value = isLoggedIn;

    darkModeNotifier.value = darkMode;

    notifyListeners();
  }

  // ============================================================
  // KEGIATAN DEFAULT
  // ============================================================

  void _seedActivities() {
    const names = [
      'Menyapu lantai / area kerja',
      'Mengepel lantai',
      'Membersihkan meja dan kursi',
      'Merapikan barang / perlengkapan kerja',
      'Membersihkan kaca, pintu, dan area yang berdebu',
      'Membersihkan rak / lemari',
      'Membersihkan toilet',
      'Mengisi ulang sabun / tisu jika habis',
      'Membuang sampah dan mengganti plastik sampah',
      'Membersihkan area pantry / tempat makan',
      'Mencuci gelas / alat makan yang digunakan',
      'Membersihkan teras / halaman depan',
      'Mengecek kerapian kabel dan peralatan kerja',
      'Mengecek stok alat kebersihan',
      'Memastikan area kerja rapi sebelum pulang',
    ];

    activities
      ..clear()
      ..addAll(
        List.generate(
          names.length,
          (index) {
            return ActivityItem(
              id: 'task_${index + 1}',
              name: names[index],
            );
          },
        ),
      );

    notifyListeners();

    save();
  }

  // ============================================================
  // SAVE DATA
  // ============================================================

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      'documentTitle': documentTitle,
      'place': place,
      'personInCharge': personInCharge,
      'userName': userName,
      'month': month,
      'year': year,
      'darkMode': darkMode,
      'currentUserId': currentUserId,

      'activities': activities
          .map(
            (item) => item.toJson(),
          )
          .toList(),

      'checks': checks,

      'users': users
          .map(
            (user) => user.toJson(),
          )
          .toList(),
    };

    await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );
  }

  // ============================================================
  // PASSWORD HASH
  // ============================================================

  String _hashPassword(
    String value,
  ) {
    return sha256
        .convert(
          utf8.encode(value),
        )
        .toString();
  }

  String _normalizeEmail(
    String value,
  ) {
    return value.trim().toLowerCase();
  }

  // ============================================================
  // REGISTER ACCOUNT
  // ============================================================

  String? registerAccount({
    required String name,
    required String email,
    required String password,
  }) {
    final cleanName = name.trim();

    final cleanEmail = _normalizeEmail(email);

    if (cleanName.length < 2) {
      return 'Nama minimal 2 karakter.';
    }

    if (!cleanEmail.contains('@') ||
        !cleanEmail.contains('.')) {
      return 'Format email belum benar.';
    }

    if (password.length < 6) {
      return 'Kata sandi minimal 6 karakter.';
    }

    final exists = users.any(
      (user) => user.email == cleanEmail,
    );

    if (exists) {
      return 'Email sudah terdaftar.';
    }

    users.add(
      LocalUser(
        id:
            'user_${DateTime.now().microsecondsSinceEpoch}',
        name: cleanName,
        email: cleanEmail,
        passwordHash: _hashPassword(password),
      ),
    );

    notifyListeners();

    save();

    return null;
  }

  // ============================================================
  // LOGIN
  // ============================================================

  String? loginAccount({
    required String email,
    required String password,
  }) {
    final cleanEmail = _normalizeEmail(email);

    LocalUser? found;

    for (final user in users) {
      if (user.email == cleanEmail) {
        found = user;
        break;
      }
    }

    if (found == null) {
      return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
    }

    final passwordHash = _hashPassword(password);

    if (found.passwordHash != passwordHash) {
      return 'Kata sandi salah.';
    }

    currentUserId = found.id;

    userName = found.name;

    // Hanya auth router yang berubah.
    authNotifier.value = true;

    notifyListeners();

    save();

    return null;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void logout() {
    currentUserId = null;

    authNotifier.value = false;

    notifyListeners();

    save();
  }

  // ============================================================
  // LUPA EMAIL
  // Cari menggunakan nama + password.
  // ============================================================

  String? findEmail({
    required String name,
    required String password,
  }) {
    final cleanName = name.trim().toLowerCase();

    final passwordHash = _hashPassword(password);

    for (final user in users) {
      if (user.name.trim().toLowerCase() == cleanName &&
          user.passwordHash == passwordHash) {
        return user.email;
      }
    }

    return null;
  }

  // ============================================================
  // LUPA / RESET PASSWORD
  // Prototype lokal.
  // ============================================================

  String? resetPassword({
    required String email,
    required String newPassword,
  }) {
    final cleanEmail = _normalizeEmail(email);

    LocalUser? found;

    for (final user in users) {
      if (user.email == cleanEmail) {
        found = user;
        break;
      }
    }

    if (found == null) {
      return 'Email tidak ditemukan.';
    }

    if (newPassword.length < 6) {
      return 'Kata sandi minimal 6 karakter.';
    }

    found.passwordHash =
        _hashPassword(newPassword);

    notifyListeners();

    save();

    return null;
  }

  // ============================================================
  // UPDATE PROFIL
  // ============================================================

  String? updateCurrentProfile({
    required String name,
    required String email,
  }) {
    final user = currentUser;

    if (user == null) {
      return 'Sesi pengguna tidak ditemukan.';
    }

    final cleanName = name.trim();

    final cleanEmail = _normalizeEmail(email);

    if (cleanName.length < 2) {
      return 'Nama minimal 2 karakter.';
    }

    if (!cleanEmail.contains('@') ||
        !cleanEmail.contains('.')) {
      return 'Format email belum benar.';
    }

    final duplicate = users.any(
      (otherUser) =>
          otherUser.id != user.id &&
          otherUser.email == cleanEmail,
    );

    if (duplicate) {
      return 'Email sudah digunakan akun lain.';
    }

    user.name = cleanName;

    user.email = cleanEmail;

    userName = cleanName;

    notifyListeners();

    save();

    return null;
  }

  // ============================================================
  // FOTO PROFIL
  // ============================================================

  void updateProfilePhoto(
    String base64Image,
  ) {
    final user = currentUser;

    if (user == null) {
      return;
    }

    user.photoBase64 = base64Image;

    notifyListeners();

    save();
  }

  void removeProfilePhoto() {
    final user = currentUser;

    if (user == null) {
      return;
    }

    user.photoBase64 = '';

    notifyListeners();

    save();
  }

  // ============================================================
  // UBAH PASSWORD DARI PROFIL
  // ============================================================

  String? changeCurrentPassword({
    required String oldPassword,
    required String newPassword,
  }) {
    final user = currentUser;

    if (user == null) {
      return 'Sesi pengguna tidak ditemukan.';
    }

    if (user.passwordHash !=
        _hashPassword(oldPassword)) {
      return 'Kata sandi lama salah.';
    }

    if (newPassword.length < 6) {
      return 'Kata sandi baru minimal 6 karakter.';
    }

    user.passwordHash =
        _hashPassword(newPassword);

    notifyListeners();

    save();

    return null;
  }

  // ============================================================
  // DARK MODE
  // ============================================================

  void setDarkMode(
    bool value,
  ) {
    darkMode = value;

    // Hanya MaterialApp theme yang perlu rebuild.
    darkModeNotifier.value = value;

    notifyListeners();

    save();
  }

  // ============================================================
  // CHECKLIST
  // ============================================================

  void toggleCheck(
    String activityId,
    int day,
  ) {
    final key = checkKey(
      activityId,
      day,
    );

    checks[key] = !(checks[key] ?? false);

    notifyListeners();

    save();
  }

  void setCheck(
    String activityId,
    int day,
    bool value,
  ) {
    checks[
      checkKey(
        activityId,
        day,
      )
    ] = value;

    notifyListeners();

    save();
  }

  // ============================================================
  // UPDATE DOKUMEN
  // ============================================================

  void updateDocument({
    required String title,
    required String newPlace,
    required String pic,
    required int newMonth,
    required int newYear,
  }) {
    if (title.trim().isNotEmpty) {
      documentTitle = title.trim();
    }

    if (newPlace.trim().isNotEmpty) {
      place = newPlace.trim();
    }

    if (pic.trim().isNotEmpty) {
      personInCharge = pic.trim();
    }

    month = newMonth;

    year = newYear;

    notifyListeners();

    save();
  }

  // ============================================================
  // TAMBAH KEGIATAN
  // ============================================================

  void addActivity(
    String name,
  ) {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return;
    }

    activities.add(
      ActivityItem(
        id:
            'task_${DateTime.now().microsecondsSinceEpoch}',
        name: cleanName,
      ),
    );

    notifyListeners();

    save();
  }

  // ============================================================
  // EDIT KEGIATAN
  // ============================================================

  void editActivity(
    String id,
    String name,
  ) {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return;
    }

    ActivityItem? found;

    for (final activity in activities) {
      if (activity.id == id) {
        found = activity;
        break;
      }
    }

    if (found == null) {
      return;
    }

    found.name = cleanName;

    notifyListeners();

    save();
  }

  // ============================================================
  // HAPUS KEGIATAN
  // ============================================================

  void removeActivity(
    String id,
  ) {
    activities.removeWhere(
      (activity) => activity.id == id,
    );

    // Hapus semua checklist milik kegiatan tersebut.
    checks.removeWhere(
      (key, value) => key.endsWith(
        '|$id',
      ),
    );

    notifyListeners();

    save();
  }

  // ============================================================
  // PINDAH URUTAN KEGIATAN
  // ============================================================

  void moveActivity(
    int oldIndex,
    int newIndex,
  ) {
    if (oldIndex < 0 ||
        oldIndex >= activities.length) {
      return;
    }

    if (newIndex > activities.length) {
      newIndex = activities.length;
    }

    if (newIndex > oldIndex) {
      newIndex--;
    }

    final item =
        activities.removeAt(oldIndex);

    activities.insert(
      newIndex,
      item,
    );

    notifyListeners();

    save();
  }

  // ============================================================
  // RESET CHECKLIST BULAN AKTIF
  // ============================================================

  void resetCurrentMonth() {
    for (final activity in activities) {
      for (var day = 1; day <= daysInMonth; day++) {
        checks.remove(
          checkKey(
            activity.id,
            day,
          ),
        );
      }
    }

    notifyListeners();

    save();
  }
}

final appStore = AppStore();