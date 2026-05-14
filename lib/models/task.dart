class TaskModel {
  final int id;
  final String area;
  final String title;
  final String description;
  final String purpose;
  final int ageGroupMin;
  final int ageGroupMax;
  final int difficulty;
  final int durationMin;
  final String? materialsNeeded;
  final String? videoUrl;
  final String? iconUrl;
  final String? tips;

  // Runtime state
  final bool isCompleted;
  final DateTime? completedAt;
  final int? userRating;

  TaskModel({
    required this.id,
    required this.area,
    required this.title,
    required this.description,
    this.purpose = '',
    required this.ageGroupMin,
    required this.ageGroupMax,
    this.difficulty = 1,
    this.durationMin = 10,
    this.materialsNeeded,
    this.videoUrl,
    this.iconUrl,
    this.tips,
    this.isCompleted = false,
    this.completedAt,
    this.userRating,
  });

  TaskModel copyWith({
    int? id,
    String? area,
    String? title,
    String? description,
    String? purpose,
    int? ageGroupMin,
    int? ageGroupMax,
    int? difficulty,
    int? durationMin,
    String? materialsNeeded,
    String? videoUrl,
    String? iconUrl,
    String? tips,
    bool? isCompleted,
    DateTime? completedAt,
    int? userRating,
  }) {
    return TaskModel(
      id: id ?? this.id,
      area: area ?? this.area,
      title: title ?? this.title,
      description: description ?? this.description,
      purpose: purpose ?? this.purpose,
      ageGroupMin: ageGroupMin ?? this.ageGroupMin,
      ageGroupMax: ageGroupMax ?? this.ageGroupMax,
      difficulty: difficulty ?? this.difficulty,
      durationMin: durationMin ?? this.durationMin,
      materialsNeeded: materialsNeeded ?? this.materialsNeeded,
      videoUrl: videoUrl ?? this.videoUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      tips: tips ?? this.tips,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      userRating: userRating ?? this.userRating,
    );
  }

  String get difficultyLabel {
    switch (difficulty) {
      case 1: return '简单';
      case 2: return '中等';
      case 3: return '挑战';
      default: return '简单';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'area': area,
    'title': title,
    'description': description,
    'purpose': purpose,
    'age_group_min': ageGroupMin,
    'age_group_max': ageGroupMax,
    'difficulty': difficulty,
    'duration_min': durationMin,
    'materials_needed': materialsNeeded,
    'video_url': videoUrl,
    'icon_url': iconUrl,
    'tips': tips,
    'is_completed': isCompleted,
    'completed_at': completedAt?.toIso8601String(),
    'user_rating': userRating,
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      area: json['area'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      ageGroupMin: (json['age_group_min'] as num?)?.toInt() ?? 0,
      ageGroupMax: (json['age_group_max'] as num?)?.toInt() ?? 0,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
      durationMin: (json['duration_min'] as num?)?.toInt() ?? 10,
      materialsNeeded: json['materials_needed'] as String?,
      videoUrl: json['video_url'] as String?,
      iconUrl: json['icon_url'] as String?,
      tips: json['tips'] as String?,
    );
  }
}

class DailyTaskPlan {
  final DateTime date;
  final String weekday;
  final String theme;
  final List<TaskModel> tasks;

  DailyTaskPlan({
    required this.date,
    required this.weekday,
    this.theme = '',
    required this.tasks,
  });

  int get totalDuration =>
      tasks.fold(0, (sum, t) => sum + t.durationMin);

  int get completedCount =>
      tasks.where((t) => t.isCompleted).length;
}
