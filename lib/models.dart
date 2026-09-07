class ActivityItem {
  ActivityItem({
    required this.id,
    required this.name,
  });

  final String id;
  String name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class LocalUser {
  LocalUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.photoBase64 = '',
  });

  final String id;
  String name;
  String email;
  String passwordHash;
  String photoBase64;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'photoBase64': photoBase64,
    };
  }

  factory LocalUser.fromJson(Map<String, dynamic> json) {
    return LocalUser(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Pengguna',
      email: json['email'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      photoBase64: json['photoBase64'] as String? ?? '',
    );
  }
}

enum PaperKind {
  a4,
  a5,
  letter,
  legal,
  f4,
}

class ExportOptions {
  PaperKind paper = PaperKind.a4;
  bool landscape = true;
  double marginMm = 8;

  bool showLogo = true;
  bool showSignature = true;
  bool showNote = true;
  bool includeChecks = true;

  ExportOptions copy() {
    final result = ExportOptions();

    result.paper = paper;
    result.landscape = landscape;
    result.marginMm = marginMm;
    result.showLogo = showLogo;
    result.showSignature = showSignature;
    result.showNote = showNote;
    result.includeChecks = includeChecks;

    return result;
  }
}