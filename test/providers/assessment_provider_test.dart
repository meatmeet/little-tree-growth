import 'package:flutter_test/flutter_test.dart';
import 'package:little_tree_growth/providers/assessment_provider.dart';

void main() {
  group('AssessmentProvider', () {
    late AssessmentProvider provider;

    setUp(() {
      provider = AssessmentProvider();
    });

    test('initial state is correct', () {
      expect(provider.assessments, isEmpty);
      expect(provider.currentAssessment, isNull);
      expect(provider.loading, false);
      expect(provider.error, isNull);
    });

    test('selectAssessment sets current assessment', () {
      expect(provider.currentAssessment, isNull);
    });

    test('clearError resets error', () {
      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
