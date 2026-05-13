class BabyModel {
  final int id;
  final int userId;
  final String name;
  final int gender; // 0=女, 1=男
  final DateTime birthDate;
  final bool isPremature;
  final String? avatarUrl;

  BabyModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.gender,
    required this.birthDate,
    this.isPremature = false,
    this.avatarUrl,
  });

  int get ageInMonths {
    final now = DateTime.now();
    if (birthDate.isAfter(now)) return 0;
    final months = (now.year - birthDate.year) * 12 +
        (now.month - birthDate.month);
    if (now.day < birthDate.day) return months - 1;
    return months;
  }

  /// Corrected age for premature babies.
  /// [gestationalWeeks] is the number of weeks at birth (normally 40).
  int correctedAgeInMonths(int gestationalWeeks) {
    final raw = ageInMonths - (40 - gestationalWeeks);
    return raw < 0 ? 0 : raw;
  }

  String get ageDisplay {
    final m = ageInMonths;
    if (m < 12) return '$m个月';
    final y = m ~/ 12;
    final rm = m % 12;
    return '$y岁${rm > 0 ? '$rm个月' : ''}';
  }

  factory BabyModel.fromJson(Map<String, dynamic> json) {
    return BabyModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      gender: (json['gender'] as num?)?.toInt() ?? 1,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : DateTime.now(),
      isPremature: json['is_premature'] == 1 || json['is_premature'] == true,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'gender': gender,
    'birth_date':
        '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
    'is_premature': isPremature,
    'avatar_url': avatarUrl,
  };
}
