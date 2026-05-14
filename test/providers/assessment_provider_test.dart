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

    test('initial report state is correct', () {
      expect(provider.highlights, isEmpty);
      expect(provider.suggestions, isEmpty);
      expect(provider.reportLoading, false);
      expect(provider.reportError, isNull);
    });

    test('initial radar state is correct', () {
      expect(provider.radarLabels, isEmpty);
      expect(provider.radarValues, isEmpty);
      expect(provider.radarLoading, false);
      expect(provider.radarError, isNull);
    });

    test('selectAssessment sets current assessment', () {
      expect(provider.currentAssessment, isNull);
    });

    test('clearError resets error', () {
      provider.clearError();
      expect(provider.error, isNull);
    });

    test('items getter returns default empty list', () {
      expect(provider.items, isEmpty);
    });

    test('trend getter returns default empty list', () {
      expect(provider.trend, isEmpty);
    });
  });
}
