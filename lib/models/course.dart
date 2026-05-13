class CourseModel {
  final int id;
  final String title;
  final String description;
  final String? coverUrl;
  final double price;
  final String courseType;
  final int? ageGroupMin;
  final int? ageGroupMax;
  final int totalLessons;
  final double progress;
  final bool isPublished;

  CourseModel({
    required this.id,
    required this.title,
    this.description = '',
    this.coverUrl,
    this.price = 0,
    this.courseType = 'free',
    this.ageGroupMin,
    this.ageGroupMax,
    this.totalLessons = 0,
    this.progress = 0,
    this.isPublished = true,
  });

  bool get isFree => courseType == 'free' || price == 0;

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      coverUrl: json['cover_url'],
      price: (json['price'] as num?)?.toDouble() ?? 0,
      courseType: json['course_type'] ?? 'free',
      ageGroupMin: json['age_group_min'],
      ageGroupMax: json['age_group_max'],
      totalLessons: json['total_lessons'] ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      isPublished: json['is_published'] == 1 || json['is_published'] == true,
    );
  }
}

class CourseLesson {
  final int id;
  final int courseId;
  final String title;
  final String? description;
  final String? videoUrl;
  final int? durationMin;
  final bool isFreePreview;

  CourseLesson({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.videoUrl,
    this.durationMin,
    this.isFreePreview = false,
  });

  factory CourseLesson.fromJson(Map<String, dynamic> json) {
    return CourseLesson(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['video_url'],
      durationMin: json['duration_min'],
      isFreePreview: json['is_free_preview'] == 1 || json['is_free_preview'] == true,
    );
  }
}
