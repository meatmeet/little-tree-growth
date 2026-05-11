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
  bool isCompleted;
  DateTime? completedAt;
  int? userRating;

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
      id: json['id'],
      area: json['area'],
      title: json['title'],
      description: json['description'],
      purpose: json['purpose'] ?? '',
      ageGroupMin: json['age_group_min'],
      ageGroupMax: json['age_group_max'],
      difficulty: json['difficulty'] ?? 1,
      durationMin: json['duration_min'] ?? 10,
      materialsNeeded: json['materials_needed'],
      videoUrl: json['video_url'],
      iconUrl: json['icon_url'],
      tips: json['tips'],
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
