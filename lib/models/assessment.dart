class AssessmentModel {
  final int id;
  final int babyId;
  final DateTime assessmentDate;
  final double actualAgeMonths;
  final double? overallDq;
  final double? overallMentalAge;
  final String status;
  final List<AreaResult>? areas;

  AssessmentModel({
    required this.id,
    required this.babyId,
    required this.assessmentDate,
    required this.actualAgeMonths,
    this.overallDq,
    this.overallMentalAge,
    this.status = 'draft',
    this.areas,
  });

  String get dqLevel {
    if (overallDq == null) return '未评估';
    if (overallDq! >= 130) return '优秀';
    if (overallDq! >= 110) return '良好';
    if (overallDq! >= 80) return '中等';
    if (overallDq! >= 70) return '临界偏低';
    return '需就医';
  }

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'],
      babyId: json['baby_id'],
      assessmentDate: DateTime.parse(json['assessment_date']),
      actualAgeMonths: (json['actual_age_months'] as num).toDouble(),
      overallDq: (json['overall_dq'] as num?)?.toDouble(),
      overallMentalAge: (json['overall_mental_age'] as num?)?.toDouble(),
      status: json['status'] ?? 'draft',
      areas: (json['areas'] as List<dynamic>?)
          ?.map((a) => AreaResult.fromJson(a))
          .toList(),
    );
  }
}

class AreaResult {
  final String area;
  final double? mentalAge;
  final double? dqScore;
  final int itemsPassed;
  final int itemsTotal;

  AreaResult({
    required this.area,
    this.mentalAge,
    this.dqScore,
    this.itemsPassed = 0,
    this.itemsTotal = 0,
  });

  double get percentage =>
      itemsTotal > 0 ? (itemsPassed / itemsTotal * 100) : 0;

  factory AreaResult.fromJson(Map<String, dynamic> json) {
    return AreaResult(
      area: json['area'],
      mentalAge: (json['mental_age'] as num?)?.toDouble(),
      dqScore: (json['dq_score'] as num?)?.toDouble(),
      itemsPassed: json['items_passed'] ?? 0,
      itemsTotal: json['items_total'] ?? 0,
    );
  }
}
