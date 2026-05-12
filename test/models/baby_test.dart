import 'package:flutter_test/flutter_test.dart';
import 'package:little_tree_growth/models/baby.dart';

void main() {
  group('BabyModel', () {
    test('ageInMonths returns 0 for future birth date', () {
      final baby = BabyModel(
        id: 1,
        userId: 1,
        name: '未来宝宝',
        gender: 1,
        birthDate: DateTime.now().add(const Duration(days: 365)),
      );
      expect(baby.ageInMonths, 0);
    });

    test('ageDisplay shows months when under 12', () {
      final baby = BabyModel(
        id: 1,
        userId: 1,
        name: '小宝',
        gender: 1,
        birthDate: DateTime.now().subtract(
          const Duration(days: 180),
        ),
      );
      expect(baby.ageDisplay, contains('个月'));
    });

    test('ageDisplay shows years when over 12 months', () {
      final baby = BabyModel(
        id: 1,
        userId: 1,
        name: '大宝',
        gender: 1,
        birthDate: DateTime.now().subtract(
          const Duration(days: 545), // ~18 months
        ),
      );
      expect(baby.ageDisplay, contains('岁'));
    });

    test('correctedAgeInMonths adjusts for prematurity', () {
      final baby = BabyModel(
        id: 1,
        userId: 1,
        name: '早产宝宝',
        gender: 0,
        birthDate: DateTime.now().subtract(
          const Duration(days: 365),
        ),
      );
      // Born at 34 weeks: corrected = 12 - (40 - 34) = 6
      expect(baby.correctedAgeInMonths(34), 6);
    });

    test('correctedAgeInMonths returns 0 for extreme prematurity', () {
      final baby = BabyModel(
        id: 1,
        userId: 1,
        name: '极早产宝宝',
        gender: 0,
        birthDate: DateTime.now(),
      );
      // Born at 25 weeks: corrected = 0 - (40-25) = negative → 0
      expect(baby.correctedAgeInMonths(25), 0);
    });

    test('toJson and fromJson round-trip', () {
      final original = BabyModel(
        id: 1,
        userId: 1,
        name: '测试',
        gender: 1,
        birthDate: DateTime(2025, 6, 1),
        isPremature: false,
        avatarUrl: null,
      );
      final json = original.toJson();
      final restored = BabyModel.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.gender, original.gender);
    });
  });
}
