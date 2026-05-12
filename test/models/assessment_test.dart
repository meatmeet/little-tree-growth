import 'package:flutter_test/flutter_test.dart';
import 'package:little_tree_growth/models/assessment.dart';

void main() {
  group('AssessmentModel', () {
    test('dqLevel returns 优秀 for DQ >= 130', () {
      final a = AssessmentModel(
        id: 1,
        babyId: 1,
        assessmentDate: DateTime.now(),
        actualAgeMonths: 12,
        overallDq: 135,
      );
      expect(a.dqLevel, '优秀');
    });

    test('dqLevel returns 良好 for DQ >= 110', () {
      final a = AssessmentModel(
        id: 1,
        babyId: 1,
        assessmentDate: DateTime.now(),
        actualAgeMonths: 12,
        overallDq: 115,
      );
      expect(a.dqLevel, '良好');
    });

    test('dqLevel returns 中等 for DQ >= 80', () {
      final a = AssessmentModel(
        id: 1,
        babyId: 1,
        assessmentDate: DateTime.now(),
        actualAgeMonths: 12,
        overallDq: 90,
      );
      expect(a.dqLevel, '中等');
    });

    test('dqLevel returns 需就医 for DQ < 70', () {
      final a = AssessmentModel(
        id: 1,
        babyId: 1,
        assessmentDate: DateTime.now(),
        actualAgeMonths: 12,
        overallDq: 50,
      );
      expect(a.dqLevel, '需就医');
    });

    test('dqLevel returns 未评估 when DQ is null', () {
      final a = AssessmentModel(
        id: 1,
        babyId: 1,
        assessmentDate: DateTime.now(),
        actualAgeMonths: 12,
        overallDq: null,
      );
      expect(a.dqLevel, '未评估');
    });

    test('toJson and fromJson round-trip', () {
      final original = AssessmentModel(
        id: 1,
        babyId: 1,
        assessmentDate: DateTime(2026, 5, 10),
        actualAgeMonths: 12,
        overallDq: 105.2,
        overallMentalAge: 12.6,
        status: 'completed',
        areas: [
          AreaResult(
            area: 'gross_motor',
            mentalAge: 13.0,
            dqScore: 108.3,
            itemsPassed: 3,
            itemsTotal: 4,
          ),
        ],
      );
      final json = original.toJson();
      final restored = AssessmentModel.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.dqLevel, original.dqLevel);
      expect(restored.areas?.length, 1);
      expect(restored.areas?.first.area, 'gross_motor');
    });
  });

  group('AreaResult', () {
    test('percentage calculates correctly', () {
      final area = AreaResult(
        area: 'language',
        itemsPassed: 3,
        itemsTotal: 4,
      );
      expect(area.percentage, 75.0);
    });

    test('percentage returns 0 when total is 0', () {
      final area = AreaResult(area: 'social');
      expect(area.percentage, 0);
    });
  });
}
