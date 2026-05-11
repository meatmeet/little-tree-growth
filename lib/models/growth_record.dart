class GrowthRecord {
  final int id;
  final int babyId;
  final DateTime recordDate;
  final double? heightCm;
  final double? weightKg;
  final double? headCircCm;
  final String? notes;

  GrowthRecord({
    required this.id,
    required this.babyId,
    required this.recordDate,
    this.heightCm,
    this.weightKg,
    this.headCircCm,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'baby_id': babyId,
    'record_date': recordDate.toIso8601String().substring(0, 10),
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'head_circ_cm': headCircCm,
    'notes': notes,
  };

  factory GrowthRecord.fromJson(Map<String, dynamic> json) {
    return GrowthRecord(
      id: json['id'],
      babyId: json['baby_id'],
      recordDate: DateTime.parse(json['record_date']),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      headCircCm: (json['head_circ_cm'] as num?)?.toDouble(),
      notes: json['notes'],
    );
  }
}

class Milestone {
  final int id;
  final int babyId;
  final String milestoneType;
  final DateTime? occurredAt;
  final String? notes;
  final String? photoUrl;

  Milestone({
    required this.id,
    required this.babyId,
    required this.milestoneType,
    this.occurredAt,
    this.notes,
    this.photoUrl,
  });

  String get typeLabel {
    switch (milestoneType) {
      case 'first_teeth': return '第一颗牙';
      case 'first_roll': return '第一次翻身';
      case 'first_sit': return '第一次坐';
      case 'first_crawl': return '第一次爬';
      case 'first_stand': return '第一次站立';
      case 'first_walk': return '第一次走路';
      case 'first_word': return '第一个词';
      default: return milestoneType;
    }
  }

  String get typeIcon {
    switch (milestoneType) {
      case 'first_teeth': return '🦷';
      case 'first_roll': return '🔄';
      case 'first_sit': return '🪑';
      case 'first_crawl': return '🐛';
      case 'first_stand': return '🧍';
      case 'first_walk': return '🚶';
      case 'first_word': return '🗣';
      default: return '🏅';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'baby_id': babyId,
    'milestone_type': milestoneType,
    'occurred_at': occurredAt?.toIso8601String(),
    'notes': notes,
    'photo_url': photoUrl,
  };

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'],
      babyId: json['baby_id'],
      milestoneType: json['milestone_type'],
      occurredAt: json['occurred_at'] != null
          ? DateTime.parse(json['occurred_at'])
          : null,
      notes: json['notes'],
      photoUrl: json['photo_url'],
    );
  }
}
